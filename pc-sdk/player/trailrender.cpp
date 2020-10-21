#include "trailrender.h"
#include "messagetype.h"
#include "getoffsetimage.h"

QMutex TrailRender::m_instanceMutex;
TrailRender* TrailRender::m_trailRender = nullptr;
TrailRender::TrailRender(QQuickPaintedItem *parent)
    : QQuickPaintedItem(parent)
{
    m_trailRender = this;
    connect(this, SIGNAL(heightChanged()), this, SLOT(onCtentsSizeChanged()));
    connect(this, SIGNAL(widthChanged()), this, SLOT(onCtentsSizeChanged()));
    trailPixmap = QPixmap(this->width(), this->height());
    trailPixmap.fill(QColor(255, 255, 255, 0));

    setRenderTarget(QQuickPaintedItem::FramebufferObject);
}

TrailRender::~TrailRender()
{

}

TrailRender* TrailRender::getInstance()
{
    if(nullptr == m_trailRender)
    {
        m_instanceMutex.lock();
        if(nullptr == m_trailRender)
        {
            m_trailRender = new TrailRender();
        }
        m_instanceMutex.unlock();
    }
    return m_trailRender;
}

void TrailRender::setCurrentImgHeight(double height)
{
    m_currentImageHeight = height;
    GetOffsetImage::instance()->currrentImageHeight = height;
}

//根据偏移量截图
void TrailRender::getOffsetImage(QString imageUrl, double offsetY)
{
    QImage tempImage;
    GetOffsetImage::instance()->currentBeBufferedImage = tempImage;
    currentImagaeOffSetY = offsetY;
    GetOffsetImage::instance()->getOffSetImage(imageUrl, offsetY);
    //qDebug() << "****************TrailBoard::getOffsetImage********" << offsetY;
}

void TrailRender::getOffSetImage(double offsetX, double offsetY, double zoomRate)
{
    currentImagaeOffSetY = qAbs(offsetY);//记录当前图的偏移量
    GetOffsetImage::instance()->getOffSetImage(offsetY);
    //获取轨迹信息
    //qDebug() << "****TrailBoard::getOffSetImage******" << offsetY;
    onCtentsSizeChanged();
}

void TrailRender::drawLine(QString line)
{
    qDebug()<< "222222111"<< line;
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8(), &err);
    if (err.error == QJsonParseError::NoError)
    {
        if(!doc.isObject())
        {
            //qDebug() << "invalid message:" << line;
            return;
        }
        QJsonValue cmdVal = doc.object().take(kSocketCmd);
        if (!cmdVal.isString())
        {
            //qDebug() << "invalid message:" << line;
            return;
        }
        QString command = cmdVal.toString();
        QJsonValue contentVal = doc.object().take("content");
        if (!contentVal.isObject())
        {
            //qDebug() << "invalid message:" << line;
            return;
        }
        QJsonObject contentObj = contentVal.toObject();

        if(command == kSocketTrail)
        {
            QJsonArray trailArr = contentObj.take("pts").toArray();
            double  factor = 1000000.000000;
            QString color = contentObj.take("color").toString();
            double width = contentObj.take("width").toInt() / factor;
            int type = contentObj.take("type").toInt();
            QVector<QPointF> points;
            qint32 factorVal = 0;
            double x = 0, y = 0;
            for (int i = 0; i < trailArr.size(); ++i)
            {
                factorVal = trailArr[i].toInt();
                if(i % 2 == 0)
                {
                    x = factorVal / factor;
                }
                if(i % 2 == 1)
                {
                    y = factorVal / factor;
                    y = changeYPoinToLocal(y);
                    points.append(QPointF(x, y));
                }
            }
            drawBezier(points, width * StudentData::gestance()->midHeight / this->height(), QColor("#" + color), type == 1 ? 1 : 2);
        }
        else if(command == "ellipse")
        {
            double rectX = contentObj.take("rectX").toString().toDouble();
            double rectY = contentObj.take("rectY").toString().toDouble();
            rectY = changeYPoinToLocal(rectY);
            double rectWidth = contentObj.take("rectWidth").toString().toDouble();
            double rectHeight = contentObj.take("rectHeight").toString().toDouble();

            double angle = contentObj.take("angle").toString().toDouble();
            double width = contentObj.take("width").toString().toDouble();

            QString color = contentObj.take("color").toString();
            drawEllipse(QRectF(rectX, rectY, rectWidth, rectHeight), 0.00099, QColor("#" + color), angle);
        }
        else if(command == "polygon")
        {
            QJsonArray trailArr = contentObj.take("trail").toArray();
            QString color = contentObj.take("color").toString();
            double width = contentObj.take("width").toString().toDouble();
            QVector<QPointF> points;
            for (int i = 0; i < trailArr.size(); ++i)
            {
                double x = trailArr[i].toObject().take("x").toString().toDouble();
                double y = trailArr[i].toObject().take("y").toString().toDouble();
                y = changeYPoinToLocal(y);
                points.append(QPointF(x, y));
            }
            drawLine(points, 0.001, QColor("#" + color), 1);
        }

    }
    else
    {
        qDebug() << "play video json parse error:" << line;
    }
}
//画贝塞尔曲线
void TrailRender::drawBezier(const QVector<QPointF> &points, double size, QColor penColor, int type)
{
    QMutexLocker locker(&m_tempTrailMutex);
    QPainter painter;
    qDebug()<< "1111111"<<this->width()<< this->height()<< size;
    trailPixmap = trailPixmap.scaled(this->width(), this->height());
    painter.begin(&trailPixmap);
    painter.setPen(QPen(QBrush(penColor), size, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());

    if(type == 2)
    {
        painter.setCompositionMode(QPainter::CompositionMode_Clear);
    }

    if(points.size() > 3)
    {
        painter.drawPolyline(QPolygonF(points));
    }
    else
    {
        QVector<QPointF> addPointF;
        double x = points.at(0).x() + 0.000001;
        double y = points.at(0).y() + 0.000001;
        addPointF.append(QPointF(points.at(0).x(), points.at(0).y()));
        addPointF.append(QPointF(x, y));
        painter.drawPolyline(addPointF.data(), addPointF.size());
    }
    painter.end();
    update();
    //qDebug() << "==PlayManager::drawBezier==" << this->width() << this->height();
}

void TrailRender::drawPage(PageModel model)
{
    //qDebug() << "=======drawPage========" << this->height() << this->width() << model.offsetY;

    trailPixmap = QPixmap(this->width(), this->height());
    trailPixmap.fill(QColor(255, 255, 255, 0));

    GetOffsetImage::instance()->currrentImageHeight = this->height();

    if(model.height < 1)//截图设置图片高度
    {
        currentImagaeOffSetY = 0;
        model.offsetY = 0;
        GetOffsetImage::instance()->currrentImageHeight = StudentData::gestance()->midHeight * model.height;
    }
    if(model.height == 1)//上传图片设置图片高度
    {
        currentImagaeOffSetY = 0;
        model.offsetY = 0;
        GetOffsetImage::instance()->currrentImageHeight = StudentData::gestance()->midHeight;//  this->height();//
    }
    if(model.height == 1 && model.questionId != "" && model.questionId == "-2")//新讲义截图、上传图片处理
    {
        currentImagaeOffSetY = 0;
        model.offsetY = 0;
        GetOffsetImage::instance()->currrentImageHeight = StudentData::gestance()->midHeight;//  this->height();//
    }
    if(model.height == 1 && model.questionId != "" && model.questionId == "-1")//老课件截图、上传图片处理
    {
        currentImagaeOffSetY = 0;
        model.offsetY = 0;
        GetOffsetImage::instance()->currrentImageHeight = StudentData::gestance()->midHeight;//  this->height();//
    }
    if(model.height == 1 && model.questionId != "" && model.questionId != "-1" && model.questionId != "-2")
    {
        GetOffsetImage::instance()->currrentImageHeight = m_currentImageHeight;
    }

    emit sigZoomInOut(0, model.offsetY, 1.0);

    foreach (Msg mess, model.msgs)
    {
        bufferModel.addMsg("temp", mess.message, mess.currentPage);
        drawLine(mess.message);
    }

    if(_isnan(model.width) == 1)
    {
        model.width =  _fpclass(model.width);
    }
    if(_isnan(model.height) == 1)
    {
        model.height = _fpclass(model.height);
    }
    //qDebug() << "*******PlayManager::drawPage*******" << model.width << model.height << model.bgimg;
    //qDebug() << "====width::length====" << _isnan(model.width) << _fpclass(model.width);
    emit sigChangeBgimg(model.bgimg, model.width, model.height, model.questionId);
}

//画线
void TrailRender::drawLine(const QVector<QPointF> &points, double brushWidth, QColor color, int type)
{
    if(points.size() == 0) return;
    QPen pen(QBrush(color), brushWidth, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);
    QPainter painter;
    painter.begin(&trailPixmap);
    painter.setPen(pen);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());
    if(type == 2)
    {
        painter.setCompositionMode(QPainter::CompositionMode_Clear);
    }
    painter.drawPolyline(QPolygonF(points));
    painter.end();
    update();
    //this->paint(painter);
}

//画椭圆
void TrailRender::drawEllipse(const QRectF &rect, double brushWidth, QColor color, double angle)
{
    QPen pen(QBrush(color), brushWidth, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);
    QPainter painter;
    painter.begin(&trailPixmap);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.save();
    painter.translate((rect.x() + rect.width() * 0.5) * this->width(), (rect.y() + rect.height() * 0.5) * this->height());
    painter.rotate(angle);
    painter.scale(this->width(), this->height());
    painter.setPen(pen);
    //平移画布到矩形中心点
    painter.drawEllipse(QRectF(-rect.width() * 0.5, -rect.height() * 0.5, rect.width(), rect.height()));
    painter.end();
    update();
    //qDebug() << "==PlayManager::drawEllipse==";
}

void TrailRender::zoomInOut(double offsetX, double offsetY, double zoomRate)
{
    emit sigZoomInOut(offsetX, offsetY, zoomRate);
}

void TrailRender::changeBgimg(QString url, double width, double height, QString questionId)
{
    emit sigChangeBgimg(url, width, height, questionId);
}

void TrailRender::cursorPointer(double pointx, double pointy)
{
    pointy = changeYPoinToLocal(pointy);
    emit sigCursorPointer(this->width() * pointx, this ->height() * pointy);
}

void TrailRender::updateTrails()
{
    update();
}

void TrailRender::addModelMsg(QString userId, QString msg, QString currentPage)
{
    bufferModel.addMsg(userId, msg, currentPage);
}

void TrailRender::clearModelMsg()
{
    bufferModel.clear();
}

//界面尺寸变化
void TrailRender::onCtentsSizeChanged()
{
    trailPixmap = QPixmap(this->width(), this->height());
    trailPixmap.fill(QColor(255, 255, 255, 0));
    StudentData::gestance()->midWidth = this->width();

    StudentData::gestance()->midHeight = this->height();// - StudentData::gestance()->spacingSize;
    GetOffsetImage::instance()->currentTrailBoardHeight = this->height();// - StudentData::gestance()->spacingSize;

    foreach (Msg mess, bufferModel.getMsgs())
    {
        TrailRender::drawLine(mess.message);
    }

    qDebug() << "==TrailBoard::onCtentsSizeChanged==" << this->width() << this->height() << GetOffsetImage::instance()->currrentImageHeight;
    update();
}

void TrailRender::paint(QPainter *painter)
{
    painter->setRenderHint(QPainter::Antialiasing);
    QPixmap pixmap = trailPixmap.scaled(this->width(), this->height()); //, Qt::IgnoreAspectRatio,Qt::SmoothTransformation );
    painter->drawPixmap(0, 0, pixmap);
}

double TrailRender::changeYPoinToLocal(double pointY)
{
    //qDebug() << "********TrailBoard::changeYPoinToLocal**********" << pointY << currentImagaeOffSetY << StudentData::gestance()->midHeight <<  GetOffsetImage::instance()->currrentImageHeight << this->height();
    double tempHeight = GetOffsetImage::instance()->currrentImageHeight > this->height() ? GetOffsetImage::instance()->currrentImageHeight : this->height();
    pointY = ((pointY * tempHeight) - (currentImagaeOffSetY * this->height())) / this->height();
    //qDebug() << "====current::pointY===" << pointY;
    return pointY;
}

double TrailRender::changeYPoinToSend(double pointY)
{
    //qDebug() << "********TrailBoard::changeYPoinToSend*******" << pointY << currentImagaeOffSetY << GetOffsetImage::instance()->currrentImageHeight << this->height();
    double tempHeight = GetOffsetImage::instance()->currrentImageHeight > this->height() ? GetOffsetImage::instance()->currrentImageHeight : this->height();
    pointY = (pointY + currentImagaeOffSetY) * this->height() / tempHeight;
    return pointY;
}
