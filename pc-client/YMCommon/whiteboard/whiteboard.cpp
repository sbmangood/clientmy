/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  whiteboard.cpp
 *  Description: whiteboard class
 *
 *  Author: ccb
 *  Date: 2019/05/17 13:00:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/05/17    V4.5.1       创建文件
*******************************************************************************/

#include <qDebug>
#include<QImage>
#include <stdio.h>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QMessageBox>
#include <QDateTime>
#include <QSettings>
#include <QStandardPaths>
#include <QStringList>
#include <QMap>

#include "whiteboard.h"
#include "whiteboardctrlbase.h"
#include "whiteboardmsg.h"
#include "whiteboardctrlinstance.h"

static double s_lineRatioA[11] = {0.500, 0.405, 0.320, 0.245, 0.180, 0.125, 0.080, 0.045, 0.020, 0.005, 0.000};
static double s_lineRatioB[11] = {0.500, 0.590, 0.660, 0.710, 0.740, 0.750, 0.740, 0.710, 0.660, 0.590, 0.500};
static double s_lineRatioC[11] = {0.000, 0.005, 0.020, 0.045, 0.080, 0.125, 0.180, 0.245, 0.320, 0.405, 0.500};

WhiteBoard::WhiteBoard( QQuickPaintedItem *parent)
    :QQuickPaintedItem(parent)
    ,m_whiteBoardCtrl(NULL)
    ,m_currentImageHeight(0)
    ,m_cursorShape(0)
{
    setAcceptedMouseButtons(Qt::LeftButton);
    m_tempTrail =  QPixmap(this->width(), this->height() );
    m_tempTrail.fill(QColor(255, 255, 255, 0));
    m_penColor = QColor(0, 0, 0);
    m_operateStatus = 1;

    m_brushSize = 0.000997;
    setCursor(Qt::PointingHandCursor);

    connect(this, SIGNAL( heightChanged() ), this, SLOT( onCtentsSizeChanged()) );
    connect(this, SIGNAL( widthChanged()  ), this, SLOT( onCtentsSizeChanged()) );
//    connect(this, SIGNAL(sigSendUrl(const QString,double,double,bool,QString,bool) ), this, SLOT(onSigSendUrl(QString,double,double))) ;

    m_whiteBoardCtrl = WhiteBoardCtrlInstance::getInstance();
    connect(m_whiteBoardCtrl, SIGNAL(sigAuthChange(QString,int,int,int,int)), this, SIGNAL(sigAuthChange(QString,int,int,int,int)));
    connect(m_whiteBoardCtrl, SIGNAL(sigDrawLine(QString)), this, SLOT(drawRemoteLine(QString)));
    connect(m_whiteBoardCtrl, SIGNAL(sigDrawPage(QString, double, bool)), this, SLOT(drawPage(QString, double, bool)));
    connect(m_whiteBoardCtrl, SIGNAL(sigZoomInOut(double, double, double)), this, SLOT(getOffSetImage(double, double, double)));

/*  connect(m_whiteBoardCtrl, SIGNAL(sigCurrentImageHeight(double)), this, SIGNAL(sigCurrentImageHeight(double)));
    connect(m_whiteBoardCtrl, SIGNAL(getOffSetImage(double, double, double)), this, SLOT(getOffSetImage(double, double, double)));
    connect(m_whiteBoardCtrl, SIGNAL(sigOffsetY(double)), this, SIGNAL(sigOffsetY(double)));

    connect(m_whiteBoardCtrl,SIGNAL(sigSendUrl(QString,double,double,bool,QString,bool)),this,SIGNAL(sigSendUrl(QString,double,double,bool,QString,bool)));
    connect(m_whiteBoardCtrl, SIGNAL(sigSendUrl(QString,double,double,bool,QString)), this, SLOT(onSigSendUrl(QString, double, double )   )) ;
    connect(m_whiteBoardCtrl, SIGNAL( sigSendHttpUrl(QString ) ), this, SIGNAL( sigSendHttpUrl(QString ) ) ) ;  */
    connect(m_whiteBoardCtrl, SIGNAL( sigPointerPosition(double, double ) ), this, SLOT( onSigPointerPosition(double, double ) ) ) ;
//    connect(this, SIGNAL(sigSendDocIDPageNo(QString )), this, SLOT( onSigSendDocIDPageNo(QString  ) )  );

    m_pointerTimer = new QTimer(this);
    connect(m_pointerTimer, SIGNAL(timeout()), this, SLOT(onPointerTimerout() )  );

    setCursorShape();
}

WhiteBoard::~WhiteBoard()
{

}

void WhiteBoard::setPenColor(int pencolors)
{
    switch (pencolors)
    {
    case 0:
        changePenColor( QColor("#000000") );
        break;
    case 1:
        changePenColor( QColor("#ff0000") );
        break;
    case 2:
        changePenColor( QColor("#ffd800") );
        break;
    case 3:
        changePenColor( QColor("#00aeef") );
        break;
    case 4:
        changePenColor( QColor("#aaaaaa") );
        break;
    case 5:
        changePenColor( QColor("#363aee") );
        break;
    case 6:
        changePenColor( QColor("#84c000") );
        break;
    case 7:
        changePenColor( QColor("#ff00ff") );
        break;

    default:
        break;
    }
}

//填充的画刷
void WhiteBoard::changeBrushSize(double size)
{
    m_brushSize = size;
    m_cursorShape = 1;
    m_operateStatus = 1;

    setCursorShape();
}
//设置鼠标类型
void WhiteBoard::setCursorShapeTypes(int types)
{
    m_operateStatus = 2;
    m_cursorShape = types;
    if(types == 2)
    {
        m_eraserSize = 0.03;
        m_cursorShape = types;
    }
    if(types == 1)
    {
        m_eraserSize = 0.02;
        m_cursorShape = 3;
    }
    setCursorShape();
}


void WhiteBoard::setEraserSize(double size)
{
    m_eraserSize = size;
}

//撤销某条记录
void WhiteBoard::undo()
{
    if(m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->onUndo();
    }
    else
    {
        qWarning() << "undo is failed, m_whiteBoardCtrl is null!";
    }
}

void WhiteBoard::clearScreen()
{
    if(m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->onClearTrails();
    }
    else
    {
        qWarning() << "clear screen is failed, m_whiteBoardCtrl is null!";
    }
}

//清屏、撤销操作
void WhiteBoard::clearScreen(int type,int pageNo,int totalNum)
{
    if(m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->onClearTrails(type, pageNo, totalNum);
    }
    else
    {
        qWarning() << "clear screen is failed, m_whiteBoardCtrl is null!";
    }

}

//本地画多边图形
void WhiteBoard::drawLocalGraphic(const QString &command, double backGroundHeight, double ImageY)
{
    qDebug() << "command ==" << command<<backGroundHeight<<ImageY;
    double  brushSizes =  0.000977;
    QJsonParseError err;
    QJsonDocument document = QJsonDocument::fromJson(command.toUtf8(), &err);
    if (err.error == QJsonParseError::NoError)
    {
        QString command = document.object().take("command").toString();
        QString domain = document.object().take("domain").toString();
        if (domain == "draw")
        {
            if (command == "polygon")
            {
                //{command:polygon,domain:draw,trail:[{x:1,y:1},{x:1,y:1},{x:1,y:1}]}
                QVector<QPointF> pointFs;
                QVector<QPointF> pointFsSend;//new

                QJsonArray trails = document.object().take("trail").toArray();
                foreach (QJsonValue trail, trails)
                {
                    double x = trail.toObject().take("x").toString().toDouble();
                    double y = trail.toObject().take("y").toString().toDouble();
                    //y = ( y * backGroundHeight + ( -ImageY )  ) / this->height();
                    pointFs.append(QPointF(x, y));
                    y = changeYPoinToSend(y);
                    pointFsSend.append(QPointF(x, y));

                }
                this->drawLine(pointFs, brushSizes, m_penColor, 1);

                QJsonArray arr;
                for (int i = 0; i < pointFsSend.size(); ++i)
                {
                    QJsonObject obj;
                    obj.insert("x", QString::number(pointFsSend.at(i).x(), 'f', 6));
                    obj.insert("y", QString::number(pointFsSend.at(i).y(), 'f', 6));
                    arr.append(obj);
                }
                QJsonObject obj;
                obj.insert("trail", arr);
                obj.insert("width", QString::number(brushSizes, 'f', 6));
                obj.insert("color", QString(m_penColor.name().mid(1)));

                if(m_whiteBoardCtrl)
                {
                    m_whiteBoardCtrl->onDrawPolygon(obj);
                }
                else
                {
                    qWarning() << "draw polygon is failed, m_whiteBoardCtrl is null!";
                }
            }
            else if (command == "ellipse")
            {
                //{command:ellipse,domain:draw,x:1,y:1,height:1,width:1,angle:1}
                double x = document.object().take("x").toString().toDouble();
                double y = document.object().take("y").toString().toDouble();
                // y = ( y * backGroundHeight + ( -ImageY )  ) / this->height();
                double width = document.object().take("width").toString().toDouble();
                double height = document.object().take("height").toString().toDouble();
                height = height * backGroundHeight / this->height();
                double angle = document.object().take("angle").toString().toDouble();
                this->drawEllipse(QRectF(x, y, width, height), brushSizes, m_penColor, angle);
                y =  changeYPoinToSend(y);

                QJsonObject obj;
                obj.insert("rectX", QString::number(x, 'f', 6));
                obj.insert("rectY", QString::number(y, 'f', 6));
                obj.insert("rectWidth", QString::number(width, 'f', 6));

                if(m_whiteBoardCtrl)
                {
                    double tempHeight = m_whiteBoardCtrl->getCurrentImageHeight() > this->height() ? m_whiteBoardCtrl->getCurrentImageHeight() : this->height();
                    if(m_whiteBoardCtrl->getCurrentImageHeight() == this->height()) //画板是空白页的时候
                    {
                        tempHeight = this->height();
                    }
                    height = height * this->height() /tempHeight;
                }

                obj.insert("rectHeight", QString::number(height, 'f', 6));
                obj.insert("angle", QString::number(angle, 'f', 6));
                obj.insert("width", QString::number(brushSizes, 'f', 6));
                obj.insert("color", QString(m_penColor.name().mid(1)));

                if(m_whiteBoardCtrl)
                {
                    m_whiteBoardCtrl->onDrawEllipse(obj);
                }
                else
                {
                    qWarning() << "draw ellipse is failed, m_whiteBoardCtrl is null!";
                }
            }
        }
    }
    else
        update();
}

//设置表情的url
void WhiteBoard::setInterfaceUrls(const QString &urls)
{
    if(m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->onDrawExpression(urls);
    }
    else
    {
        qWarning() << "draw expression is failed, m_whiteBoardCtrl is null!";
    }

}

//上传图片成功后发送额指令
void WhiteBoard::upLoadSendUrlHttp(const QString &https)
{
    if(https.length() > 0)
    {
        QJsonParseError error;
        QJsonDocument documet = QJsonDocument::fromJson(https.toUtf8(), &error);
        if(error.error == QJsonParseError::NoError)
        {
            if(documet.isObject())
            {
                QJsonObject jsonObj = documet.object();
                QString domain;
                QJsonValue contentValue;

                if(jsonObj.contains("message"))
                {

                    QJsonValue typeValue = jsonObj.take("message");
                    if(typeValue.isString())
                        domain = typeValue.toString().toLower();

                    if(domain.toLower() == "success")
                    {
                        contentValue = jsonObj.take("data");
                        QString urlhhtp = contentValue.toObject().take("url").toString();
                        QString mdStr = urlhhtp.replace("https", "http");

                        if(m_whiteBoardCtrl)
                        {
                            m_whiteBoardCtrl->onDrawImage(mdStr, m_pictureWidthRate, m_pictureHeihtRate);
                        }
                        else
                        {
                            qWarning() << "draw image is failed, m_whiteBoardCtrl is null!";
                        }

                    }
                    else
                    {
                        qDebug() << "TrailBoard::upLoadSendUrlHttp failed." << jsonObj;
                    }

                    return;

                }
            }
        }

    }
}

void WhiteBoard::setPictureRate(double widthRate, double heightRate)
{
    m_pictureWidthRate = widthRate;
    m_pictureHeihtRate = heightRate;
}

//滚动长图命令
void WhiteBoard::updataScrollMap(double scrollY)
{
    if(m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->onScroll(0, scrollY);
    }
    else
    {
        qWarning() << "draw scroll is failed, m_whiteBoardCtrl is null!";
    }
}

void WhiteBoard::setCurrentImageHeight(int height)
{
    m_currentImageHeight = height;
    if(m_whiteBoardCtrl)
        m_whiteBoardCtrl->setCurrentImageHeight(height);
}

//根据偏移量截图
void WhiteBoard::getOffsetImage(const QString &imageUrl, double offsetY)
{
    QImage tempImage;
    if(m_whiteBoardCtrl)
        m_whiteBoardCtrl->setCurrentBeBufferedImage(tempImage);

    m_currentImagaeOffSetY = offsetY;
    if(m_whiteBoardCtrl)
        m_whiteBoardCtrl->getOffSetImage(imageUrl, offsetY);
}

//改变画笔颜色
void WhiteBoard::changePenColor(const QColor &color)
{
    m_penColor = color;
    m_cursorShape = 1;
    m_operateStatus = 1;
    setCursorShape();
}

void WhiteBoard::drawRemoteLine(const QString &command)
{
    parseTrail(command);
    update();
}


void WhiteBoard::drawPage(const QString &questionId, double offsetY,bool isBlank)
{
    if(NULL == m_whiteBoardCtrl)
    {
        return;
    }

    emit sigOffsetY(offsetY);
    if(currentImgUrl.contains(questionId) && questionId.size() > 5)
    {
        m_whiteBoardCtrl->setCurrentImageHeight(m_currentImageHeight);
    }

    //不是空白页的时候, 即: 有课件显示的时候
    if(!isBlank)
    {
        m_whiteBoardCtrl->setCurrentImageHeight(m_currentImageHeight);
    }
    m_currentImagaeOffSetY = abs(offsetY);

    if(offsetY != 0)
    {
        sigZoomInOut(1, offsetY, 0);
    }
    //画轨迹
    m_tempTrail =  QPixmap(this->width(), this->height());
    m_tempTrail.fill(QColor(255, 255, 255, 0));
    foreach (WhiteBoardMsg mess, m_whiteBoardCtrl->getCurrentModelMsg())
    {
        //qDebug()<<"parseTrail"<< mess.msg;
        this->parseTrail(mess.msg);
    }

    update();
}

void WhiteBoard::setCurrentImgUrl(const QString &url)
{
    currentImgUrl = url;
}

//void WhiteBoard::onSigSendDocIDPageNo(QString docs)
//{
//    QList<QString> lista;
//    lista.clear();
//    QMap<QString, QList<QString> >::iterator ita =  TemporaryParameter::gestance()->m_coursewareName.begin();
//    int j = -1;
//    for( ; ita !=  TemporaryParameter::gestance()->m_coursewareName.end() ; ita++)
//    {
//        QList<QString> lists = ita.value();
//        for(int i = 0; i < lists.count(); i++)
//        {
//            if(lists[i] == docs)
//            {
//                j = i + 1;
//                break;
//            }
//        }
//    }

//    TemporaryParameter::gestance()->m_pageNo = j ;
//    TemporaryParameter::gestance()->m_docs = docs;
//    emit updateFileurlCOntent();

//}

void WhiteBoard::onSigSendUrl(const QString &urls, double width, double height)
{
    //qDebug() << "onSigSendUrl:" << urls;
//    QString urlsh = urls;
//    if(urlsh.contains("docId"))
//    {
//        QStringList list = urlsh.split("docId=");
//        if(list.size() == 2)
//        {
//            QString docid = list.at(1);
//            emit  sigSendDocIDPageNo(docid);
//        }
//        else
//        {
//            emit sigSendDocIDPageNo("");
//        }
//    }
//    else
//    {
//        emit  sigSendDocIDPageNo( QString("") );
//    }
}


void WhiteBoard::getOffSetImage(double offsetX, double offsetY, double zoomRate)
{
    if(NULL == m_whiteBoardCtrl)
    {
        return;
    }

    if(zoomRate > 1.0)
    {      
        m_whiteBoardCtrl->getOffSetImage( offsetY / zoomRate );
        m_currentImagaeOffSetY = m_whiteBoardCtrl->resetOffsetY( qAbs(offsetY / zoomRate), zoomRate); //记录当前图的偏移量
    }
    else
    {       
        m_whiteBoardCtrl->getOffSetImage( offsetY );
        m_currentImagaeOffSetY = qAbs(offsetY);
    }
    //qDebug() <<"getOffSetImage" << offsetY << -m_currentImagaeOffSetY;

    //获取轨迹信息
    onCtentsSizeChanged();
    sigZoomInOut(offsetX, -m_currentImagaeOffSetY, zoomRate);
}

//界面尺寸变化
void WhiteBoard::onCtentsSizeChanged()
{
    m_tempTrail = QPixmap(this->width(), this->height());
    m_tempTrail.fill(QColor(255, 255, 255, 0));

    if(m_whiteBoardCtrl)
    {
        foreach (WhiteBoardMsg mess, m_whiteBoardCtrl->getCurrentModelMsg())
        {
            this->parseTrail(mess.msg);
        }
        update();
        m_whiteBoardCtrl->setcurrentTrailBoardHeight( this->height() );
    }

}

void WhiteBoard::onPointerTimerout()
{
    m_pointerTimer->stop();
}

void WhiteBoard::onSigPointerPosition(double xpoint, double ypoint)
{
    double xPos = xpoint * 1.0 * this->width() - 7;
    double yPos = ( ypoint ) * 1.0 * this->height()  - 10.0 ;

    m_pointerTimer->start(2000);
    //new
    emit sigPointerPosition(xpoint, changeYPoinToLocal(ypoint));
}


void WhiteBoard::paint(QPainter *painter)
{
    if(painter)
    {
        painter->setRenderHint(QPainter::Antialiasing);
        QPixmap pixmap = m_tempTrail.scaled(this->width(), this->height(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation );
        painter->drawPixmap(0, 0, pixmap);
    }
    else
    {
        qCritical()<<"painter is null!";
    }
}

void WhiteBoard::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
    {
        emit sigFocusTrailboard();
        if (m_operateStatus)//橡皮或者画笔
        {
            m_currentTrail.clear();
            m_currentPoint = QPointF((double)(event->pos().x()) / this->width()  , (double)(event->pos().y()) / this->height());
            m_lastPoint = m_currentPoint;
            m_currentTrail.append(m_currentPoint);
        }
        else//教鞭
        {
            QPoint init = event->pos() - QPoint(5, 35); //7，35
            emit sigCursorPointer(true, init.x(), init.y() );

            double xPos = (init.x()) * 1.0  / this->width(); //-10
            double yPos = ( init.y()) * 1.0 / this->height(); //+ 12
            yPos  = changeYPoinToSend(yPos);

            //发送教鞭命令
            if(m_whiteBoardCtrl)
                m_whiteBoardCtrl->onDrawPointer(xPos, yPos);
        }
        m_pointCount = 0;
        emit sigMousePress();
    }
}

void WhiteBoard::mouseMoveEvent(QMouseEvent *event)
{
    if(event->buttons() &Qt::LeftButton)
    {
        if(m_operateStatus == -1)
        {
            return;
        }
        if (m_operateStatus)
        {
            m_lastPoint = m_currentPoint;
            m_currentPoint = QPointF((double)(event->pos().x()) / this->width(), (double)(event->pos().y()) / this->height());

            //qDebug()<<"m_lastPoint=="<<event->pos().x()<<"m_currentPoint=="<<event->pos().y();
            m_currentTrail.append(m_currentPoint);
            this->drawLocalLine();
        }
        else//教鞭
        {
            m_pointCount++;
            QPoint init = event->pos() - QPoint(5, 35); //7，35
            emit sigCursorPointer(true, init.x(), init.y() );

            if(m_pointCount == 5 )
            {
                m_pointCount = 0;
                double xPos = (init.x()) * 1.0  / this->width();
                double yPos = ( init.y()) * 1.0 / this->height();
                yPos = changeYPoinToSend(yPos);
                if(m_whiteBoardCtrl)
                    m_whiteBoardCtrl->onDrawPointer(xPos, yPos);
            }
        }
    }
}

void WhiteBoard::mouseReleaseEvent(QMouseEvent *event)
{

    if (event->button() == Qt::LeftButton)
    {
        if(!m_operateStatus)
        {
            //   emit sigCursorPointer(false,0 ,0 );
        }
        if (m_operateStatus && m_currentTrail.size() > 1)
        {
            int n = (m_currentTrail.size() - 1) / 35;
            //if( TemporaryParameter::gestance()->m_isStartClass ) {
            for(int j = 0; j < n + 1; j++)
            {
                QVector<QPointF> points;
                for (int i = j * 35;  i < (j + 1) * 35 + 3 ; ++i)
                {
                    if( i >= m_currentTrail.size())
                    {
                        break;
                    }
                    points.append(m_currentTrail.at(i));
                }
                //发送轨迹命令
                if(m_whiteBoardCtrl)
                {
                    double tempHeight = m_whiteBoardCtrl->getCurrentImageHeight() > this->height() ? m_whiteBoardCtrl->getCurrentImageHeight() : this->height();
                    double hightRate = this->height() / tempHeight;
                    m_whiteBoardCtrl->onDrawLine(points, m_operateStatus, m_brushSize, m_eraserSize, m_penColor.name(), hightRate, m_currentImagaeOffSetY);
                }
            }
            // }
            m_currentTrail.clear();
        }
        emit sigMouseRelease();
    }
}

//设置鼠标形状
void WhiteBoard::setCursorShape()
{
    switch (m_cursorShape)
    {
    case 0:
    {
        m_operateStatus = -1;
        setCursor(Qt::ArrowCursor);
    }
        break;
    case 1:
    {
        QCursor cursor ;
        QPixmap pixmap(":/images/sdthcr_mouse_pen.png") ;
        cursor = QCursor(pixmap, 2, 26);
        setCursor(cursor) ;
    }
        break;
    case 2:
    {
        QCursor cursor ;
        QPixmap pixmap(":/images/sdthcr_mouse_bigeraser.png") ;
        cursor = QCursor(pixmap, 2, -20);
        setCursor(cursor) ;
    }
        break;
    case 3:
    {
        QCursor cursor ;
        QPixmap pixmap(":/images/sdthcr_mouse_smalleraser.png") ;
        cursor = QCursor(pixmap, 2, 20);
        setCursor(cursor) ;
    }
        break;
    case 4:
    {
        QCursor cursor ;
        QPixmap pixmap(":/images/thcr_mouse_hand.png") ;
        cursor = QCursor(pixmap, 2, 26);
        setCursor(cursor) ;
        m_operateStatus = 0;
    }
        break;
    default:
        break;
    }

}

//本地画线
void WhiteBoard::drawLocalLine()
{
    QVector<QPointF> culist;
    if (m_currentTrail.size() >= 3)
    {
        culist = m_currentTrail.mid(m_currentTrail.size() - 3, 3);
    }
    else
    {
        culist = m_currentTrail;
    }
    // 解决长图画笔变形问题
//    for(int j = 0; j < culist.size(); j++)
//    {
//        culist[j].setX(culist[j].x()*this->width());
//        culist[j].setY(culist[j].y()*this->height());
//    }

    QVector<QPointF> listt;
    float x, y;
    for(int j = 0; j <= culist.size() - 3; j++)
    {
        for(int k = 0; k <= 10; k++)
        {
            //求出曲线上点的坐标
            x = s_lineRatioA[k] * culist[j].x() + s_lineRatioB[k] * culist[j + 1].x() + s_lineRatioC[k] * culist[j + 2].x();
            y = s_lineRatioA[k] * culist[j].y() + s_lineRatioB[k] * culist[j + 1].y() + s_lineRatioC[k] * culist[j + 2].y();
            listt.append(QPointF(x, y));
        }
    }

    QPainter painter;
    painter.begin(&m_tempTrail);
    if (m_operateStatus == 2)
        painter.setPen(QPen(QBrush(m_penColor), m_eraserSize, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    else
        painter.setPen(QPen(QBrush(m_penColor), m_brushSize, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());
    if(m_operateStatus == 2)
    {
        painter.setCompositionMode(QPainter::CompositionMode_Clear);
    }
    if(culist.size() >= 3)
    {
        painter.drawPolyline(listt.data(), listt.size());
    }
    else
    {
        painter.drawPolyline(culist.data(), culist.size());
    }
    painter.end();
    update();
}

//解析数据发过来的信息
void WhiteBoard::parseTrail(QString command)
{
    QJsonParseError err;
    QJsonDocument document = QJsonDocument::fromJson(command.toUtf8(), &err);
    if (err.error == QJsonParseError::NoError)
    {
        QString command = document.object().take("command").toString();
        QString domain = document.object().take("domain").toString();
        QJsonValue contentVal = document.object().take("content");
        if (domain == "draw")
        {
            if (command == "trail")
            {
                QVector<QPointF> pointFs;
                QJsonObject contentObj = contentVal.toObject();
                QString color = contentObj.take("color").toString();
                double width = contentObj.take("width").toString().toDouble();
                QString type = contentObj.take("type").toString();
                QJsonArray trails = contentObj.take("trail").toArray();
                foreach (QJsonValue trail, trails)
                {
                    double x = trail.toObject().take("x").toString().toDouble();
                    double y = trail.toObject().take("y").toString().toDouble();
                    y = changeYPoinToLocal(y);
                    pointFs.append(QPointF(x, y));
                }
                //绘制贝塞尔曲线
                if(m_whiteBoardCtrl)
                {
                    this->drawBezier(pointFs, width * m_whiteBoardCtrl->getMidHeight() / this->height(), QColor("#" + color), type == "pencil" ? 1 : 2);
                }
            }
            else if (command == "polygon")
            {
                QVector<QPointF> pointFs;
                QJsonObject contentObj = contentVal.toObject();
                QString color = contentObj.take("color").toString();
                //double width = contentObj.take("width").toString().toDouble();
                double width =  0.000977;
                QJsonArray trails = contentObj.take("trail").toArray();
                foreach (QJsonValue trail, trails)
                {
                    double x = trail.toObject().take("x").toString().toDouble();
                    double y = trail.toObject().take("y").toString().toDouble();
                    y = changeYPoinToLocal(y);
                    pointFs.append(QPointF(x, y));
                }
                //画多边形
                this->drawLine(pointFs, width, QColor("#" + color), 1);
            }
            else if (command == "ellipse")
            {
                QJsonObject contentObj = contentVal.toObject();
                double rectX = contentObj.take("rectX").toString().toDouble();
                double rectY = contentObj.take("rectY").toString().toDouble();
                rectY = changeYPoinToLocal(rectY);
                double rectWidth = contentObj.take("rectWidth").toString().toDouble();
                double rectHeight = contentObj.take("rectHeight").toString().toDouble();

                if(m_whiteBoardCtrl)
                {
                    double tempHeight = m_whiteBoardCtrl->getCurrentImageHeight() > this->height() ? m_whiteBoardCtrl->getCurrentImageHeight() : this->height();
                    if(m_whiteBoardCtrl->getCurrentImageHeight() == this->height())//画板是空白页的时候
                    {
                        tempHeight = this->height();
                    }
                    rectHeight = rectHeight * tempHeight / this->height();
                }

                double angle = contentObj.take("angle").toString().toDouble();
                //double width = contentObj.take("width").toString().toDouble();
                double width =  0.000977;
                QString color = contentObj.take("color").toString();
                //画椭圆
                this->drawEllipse(QRectF(rectX, rectY, rectWidth, rectHeight), width, QColor("#" + color), angle);
            }
        }
    }
    else
    {
    }
}

//画椭圆
void WhiteBoard::drawEllipse(const QRectF &rect, double brushWidth, const QColor &color, double angle)
{
    //qDebug()<<"this->width() =="<<this->width()<<"this->height() =="<<this->height();
    QPen pen(QBrush(color), brushWidth, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);
    QPainter painter;
    painter.begin(&m_tempTrail);
    painter.setPen(pen);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.save();
    painter.translate((rect.x() + rect.width() / 2)*this->width(), (rect.y() + rect.height() / 2)*this->height());
    painter.rotate(angle);
    painter.scale(this->width(), this->height());

    //平移画布到矩形中心点
    painter.drawEllipse(QRectF(-rect.width() / 2, -rect.height() / 2, rect.width(), rect.height()));
    painter.end();

    update();
}

//画多边形
void WhiteBoard::drawLine(const QVector<QPointF> &points, double brushWidth, const QColor &color, int type)
{
    if(points.size() == 0) return;
    QPen pen(QBrush(color), brushWidth, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);
    QPainter painter;
    painter.begin(&m_tempTrail);
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
}

//绘制贝塞尔曲线
void WhiteBoard::drawBezier(const QVector<QPointF> &points, double size, const QColor &m_penColor, int type)
{
    QMutexLocker locker(&m_tempTrailMutex);
    QPainter painter;
    painter.begin(&m_tempTrail);

    painter.setPen(QPen(QBrush(m_penColor), size, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());
    if(type == 2)
    {
        painter.setCompositionMode(QPainter::CompositionMode_Clear);
    }

    QVector<QPointF> listr;
    float x, y;
    for(int j = 0; j <= points.size() - 3; j++)
    {
        for(int k = 0; k <= 10; k++)
        {
            //求出曲线上点的坐标
            if(j == 0)
            {
                x += 0.0000001;
            }
            x = s_lineRatioA[k] * points[j].x() + s_lineRatioB[k] * points[j + 1].x() + s_lineRatioC[k] * points[j + 2].x();
            y = s_lineRatioA[k] * points[j].y() + s_lineRatioB[k] * points[j + 1].y() + s_lineRatioC[k] * points[j + 2].y();
            listr.append(QPointF(x, y));
        }
    }

    if(points.size() > 3)
    {
        painter.drawPolyline(listr.data(), listr.size());
    }
    else
    {
        QVector<QPointF> addPointF;
        double x = points.at(0).x() + 0.0000001;
        double y = points.at(0).y() + 0.0000001;
        addPointF.append(QPointF(points.at(0).x(), points.at(0).y()));
        addPointF.append(QPointF(x, y));
        painter.drawPolyline(addPointF.data(), addPointF.size());
    }
    painter.end();
}

double WhiteBoard::changeYPoinToLocal(double pointY)
{   
    if(m_whiteBoardCtrl)
    {
        double tempHeight = m_whiteBoardCtrl->getCurrentImageHeight() > this->height() ? m_whiteBoardCtrl->getCurrentImageHeight() : this->height();
        pointY = ((pointY * tempHeight) - (m_currentImagaeOffSetY * this->height())) / this->height();
    }

    return pointY;
}

double WhiteBoard::changeYPoinToSend(double pointY)
{
    if(m_whiteBoardCtrl)
    {
        double tempHeight = m_whiteBoardCtrl->getCurrentImageHeight() > this->height() ? m_whiteBoardCtrl->getCurrentImageHeight() : this->height();
        pointY = (pointY + m_currentImagaeOffSetY) * this->height() / tempHeight;
    }

    return pointY;
}
