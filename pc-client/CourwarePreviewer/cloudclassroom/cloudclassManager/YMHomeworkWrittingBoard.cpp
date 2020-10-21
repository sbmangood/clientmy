#include "YMHomeworkWrittingBoard.h"


YMHomeworkWrittingBoard::YMHomeworkWrittingBoard(QQuickPaintedItem *parent): QQuickPaintedItem(parent)
{
    connect(this, SIGNAL( heightChanged() ), this, SLOT( onCtentsSizeChanged()) );
    connect(this, SIGNAL( widthChanged()  ), this, SLOT( onCtentsSizeChanged()) );

    //setAcceptHoverEvents(true);
    // setAcceptedMouseButtons(Qt::AllButtons);
    // setFlag(ItemAcceptsDrops, true);
    setAcceptedMouseButtons(Qt::LeftButton);

    m_tempTrail =  QPixmap(this->width(), this->height() );
    m_tempTrail.fill(QColor(255, 255, 255, 0));
    m_penColor = QColor(0, 0, 0);
    m_operateStatus = 1;
    setCursor(Qt::PointingHandCursor);
    m_brushSize = 0.000997;

    setRenderTarget(QQuickPaintedItem::FramebufferObject);
    m_cursorShape = 1;
    setCursorShape();
    this->grapImageSetting();
}
//设置画笔颜色
void YMHomeworkWrittingBoard::setPenColor(int pencolors)
{
    //qDebug()<<QStringLiteral("设置画笔颜色");
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



//改变画笔颜色
void YMHomeworkWrittingBoard::changePenColor(QColor color)
{
    m_penColor = color;

    m_cursorShape = 1;
    m_operateStatus = 1;
    setCursorShape();
}

//填充的画刷
void YMHomeworkWrittingBoard::changeBrushSize(double size)
{
    m_brushSize = size;
    m_cursorShape = 1;
    m_operateStatus = 1;

    setCursorShape();
}
//设置鼠标类型
void YMHomeworkWrittingBoard::setCursorShapeTypes(int types)
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




//本地图形画多边图形
void YMHomeworkWrittingBoard::drawLocalGraphic(QString command)
{
    //qDebug()<<"command =="<<command;
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
                QJsonArray trails = document.object().take("trail").toArray();
                foreach (QJsonValue trail, trails)
                {
                    double x = trail.toObject().take("x").toString().toDouble();
                    double y = trail.toObject().take("y").toString().toDouble();
                    pointFs.append(QPointF(x, y));
                }
                this->drawLine(pointFs, brushSizes, m_penColor, 1);

                QJsonArray arr;
                for (int i = 0; i < pointFs.size(); ++i)
                {
                    QJsonObject obj;
                    obj.insert("x", QString::number(pointFs.at(i).x(), 'f', 6));
                    obj.insert("y", QString::number(pointFs.at(i).y(), 'f', 6));
                    arr.append(obj);
                }
                QJsonObject obj;
                obj.insert("trail", arr);
                obj.insert("width", QString::number(brushSizes, 'f', 6));
                obj.insert("color", QString(m_penColor.name().mid(1)));
                QJsonObject object;
                object.insert("domain", QString("draw"));
                object.insert("command", QString("polygon"));
                object.insert("content", obj);
                QJsonDocument doc;
                doc.setObject(object);
                QString s(doc.toJson(QJsonDocument::Compact));
                //s = s.replace("\r\n","").replace("\n","").replace("\r","").replace("\t","").replace(" ","");
                if(TemporaryParameter::gestance()->m_isStartClass )
                {
                    m_handler->sendLocalMessage(s, true, false);
                }
            }
            else if (command == "ellipse")
            {
                //{command:ellipse,domain:draw,x:1,y:1,height:1,width:1,angle:1}
                double x = document.object().take("x").toString().toDouble();
                double y = document.object().take("y").toString().toDouble();
                double width = document.object().take("width").toString().toDouble();
                double height = document.object().take("height").toString().toDouble();
                double angle = document.object().take("angle").toString().toDouble();
                this->drawEllipse(QRectF(x, y, width, height), brushSizes, m_penColor, angle);

                QJsonObject obj;
                obj.insert("rectX", QString::number(x, 'f', 6));
                obj.insert("rectY", QString::number(y, 'f', 6));
                obj.insert("rectWidth", QString::number(width, 'f', 6));
                obj.insert("rectHeight", QString::number(height, 'f', 6));
                obj.insert("angle", QString::number(angle, 'f', 6));
                obj.insert("width", QString::number(brushSizes, 'f', 6));
                obj.insert("color", QString(m_penColor.name().mid(1)));
                QJsonObject object;
                object.insert("domain", QString("draw"));
                object.insert("command", QString("ellipse"));
                object.insert("content", obj);
                QJsonDocument doc;
                doc.setObject(object);
                QString s(doc.toJson(QJsonDocument::Compact));
                // s = s.replace("\r\n","").replace("\n","").replace("\r","").replace("\t","").replace(" ","");
                if(TemporaryParameter::gestance()->m_isStartClass )
                {
                    m_handler->sendLocalMessage(s, true, false);
                }
            }
        }
    }
    else
        update();
}


//改变橡皮大小
void YMHomeworkWrittingBoard::changeEraserSize(double size)
{
    m_eraserSize = size;
}

void YMHomeworkWrittingBoard::clearScreen()
{
    m_tempTrail =  QPixmap(this->width(), this->height() );
    m_tempTrail.fill(QColor(255, 255, 255, 0));
    m_currentTrail.clear();
    bufferPoint.clear();
    m_undoIndex = 0;
    update();
}

void YMHomeworkWrittingBoard::undo()
{
    //qDebug()<<"YMHomeworkWrittingBoard::undo()";
    if( m_undoIndex - 1 < 0)
    {
        return;
    }
    QPixmap bufferPixmap = QPixmap(this->width(), this->height());
    bufferPixmap.fill(QColor(255, 255, 255, 0));
    m_tempTrail = bufferPixmap;

    QPainter painter;
    painter.begin(&m_tempTrail);
    painter.setPen(QPen(QBrush(m_penColor), 0.000997, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());

    QMap<int, QList<int>>::iterator its  = bufferPoint.begin();
    int index = 0;
    for(; its != bufferPoint.end(); its++)
    {

        if(index == m_undoIndex - 1)
        {
            continue;
        }

        QList<int> numberList = its.value();
        for(int i = 0; i < numberList.size(); i++)
        {
            QVector<QPointF> points;
            QMap<int, QVector<QPointF>>::Iterator dataPoints  = m_bufferPoint.find(numberList.at(i));

            points = dataPoints.value();
            painter.drawPolyline(points.data(), points.size());
        }
        index++;
    }

    painter.end();
    update();
    m_undoIndex--;
}

void YMHomeworkWrittingBoard::fallback()
{
    if(m_undoIndex + 1 > bufferPoint.size())
    {
        return;
    }
    m_undoIndex++;

    QPixmap bufferPixmap = QPixmap(this->width(), this->height());
    bufferPixmap.fill(QColor(255, 255, 255, 0));
    m_tempTrail = bufferPixmap;

    QPainter painter;
    painter.begin(&m_tempTrail);
    painter.setPen(QPen(QBrush(m_penColor), 0.000997, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());

    QMap<int, QList<int>>::iterator its  = bufferPoint.begin();
    int index = 0;
    for(; its != bufferPoint.end(); its++)
    {
        if(index == m_undoIndex)
        {
            continue;
        }

        QList<int> numberList = its.value();
        for(int i = 0; i < numberList.size(); i++)
        {
            QVector<QPointF> points;
            QMap<int, QVector<QPointF>>::Iterator dataPoints  = m_bufferPoint.find(numberList.at(i));

            points = dataPoints.value();
            painter.drawPolyline(points.data(), points.size());
        }
        index++;
    }
    painter.end();
    update();
}

//界面尺寸变化
void YMHomeworkWrittingBoard::onCtentsSizeChanged()
{
    //qDebug() << "YMHomeworkWrittingBoard::onCtentsSizeChanged" << this->width() << this->height();
    if(m_tempTrail.size().width() > 0)
    {

        m_tempTrail = m_tempTrail.scaled(this->width(), this->height() );

    }
    else
    {

        m_tempTrail =  QPixmap(this->width(), this->height() );
        m_tempTrail.fill(QColor(255, 255, 255, 0));
    }
    update();
}

//画多边形
void YMHomeworkWrittingBoard::drawLine(const QVector<QPointF> &points, double brushWidth, QColor color, int type)
{
    QPainter painter;
    painter.begin(&m_tempTrail );//m_tempTrail
    QColor colors(255, 255, 255); //220,20,60);//
    painter.setPen(QPen(QBrush(colors), 0.02, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());
    //    QVector<QPointF> points;
    //    QMap<int,QVector<QPointF>>::Iterator dataPoints  = m_bufferPoint.find(m_undoIndex -1);

    //    points = dataPoints.value();

    //qDebug() << "=======undo======"<< dataPoints.value() << m_undoIndex;

    painter.setCompositionMode(QPainter::CompositionMode_Clear);
    painter.drawPolyline(points.data(), points.size());
    painter.end();
    update();
}

//本地画线
void YMHomeworkWrittingBoard::drawLocalLine()
{
    culist.clear();
    if (m_currentTrail.size() >= 3)
    {
        culist = m_currentTrail.mid(m_currentTrail.size() - 3, 3);
    }
    else
    {
        culist = m_currentTrail;
    }

    QVector<QPointF> pointVector;
    float x, y;
    for(int j = 0; j <= culist.size() - 3; j++)
    {
        for(int k = 0; k <= 10; k++)
        {
            //求出曲线上点的坐标
            x = D[k] * culist[j].x() + E[k] * culist[j + 1].x() + F[k] * culist[j + 2].x();
            y = D[k] * culist[j].y() + E[k] * culist[j + 1].y() + F[k] * culist[j + 2].y();
            pointVector.append(QPointF(x, y));
        }
    }
    m_ListIndex.append(m_currentIndex);
    m_bufferPoint.insert(m_currentIndex, pointVector);
    m_currentIndex++;

    QPainter painter;
    painter.begin(&m_tempTrail );//m_tempTrail
    painter.setPen(QPen(QBrush(m_penColor), 0.000997, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());

    painter.drawPolyline(culist.data(), culist.size());
    painter.end();
    update();
}

//画椭圆
void YMHomeworkWrittingBoard::drawEllipse(const QRectF &rect, double brushWidth, QColor color, double angle)
{
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

//绘制贝塞尔曲线
void YMHomeworkWrittingBoard::drawBezier(const QVector<QPointF> &points, double size, QColor m_penColor, int type)
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
    listr.clear();
    float x, y;
    for(int j = 0; j <= points.size() - 3; j++)
    {
        for(int k = 0; k <= 10; k++)
        {
            //求出曲线上点的坐标
            x = D[k] * culist[j].x() + E[k] * culist[j + 1].x() + F[k] * culist[j + 2].x();
            y = D[k] * culist[j].y() + E[k] * culist[j + 1].y() + F[k] * culist[j + 2].y();
            listr.append(QPointF(x, y));
        }
    }
    if(points.size() >= 3)
    {
        painter.drawPolyline(listr.data(), listr.size());

    }
    else
    {
        painter.drawPolyline(points.data(), points.size());
    }
    painter.end();
}

//设置鼠标形状
void YMHomeworkWrittingBoard::setCursorShape()
{
    //qDebug()<<QStringLiteral("设置鼠标状态")<<m_cursorShape;
    switch (m_cursorShape)
    {
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

void YMHomeworkWrittingBoard::paint(QPainter *painter)
{
    painter->setRenderHint(QPainter::Antialiasing);
    QPixmap pixmap = m_tempTrail.scaled(this->width(), this->height(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation );
    painter->drawPixmap(0, 0, pixmap);
}

void YMHomeworkWrittingBoard::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
    {
        m_currentTrail.clear();
        m_currentPoint = QPointF((double)(event->pos().x()) / this->width(), (double)(event->pos().y()) / this->height());
        m_lastPoint = m_currentPoint;
        m_currentTrail.append(m_currentPoint);
    }

}

void YMHomeworkWrittingBoard::mouseMoveEvent(QMouseEvent *event)
{
    if(event->buttons() &Qt::LeftButton)
    {
        //qDebug() << "===Drawpanel::mouseMoveEvent======";
        m_lastPoint = m_currentPoint;
        m_currentPoint = QPointF((double)(event->pos().x()) / this->width(), (double)(event->pos().y()) / this->height());
        m_currentTrail.append(m_currentPoint);
        this->drawLocalLine();
    }
}

void YMHomeworkWrittingBoard::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
    {
        //qDebug() << "===Drawpanel::mouseReleaseEvent======";
        if (m_currentTrail.size() > 1)
        {
            int n = (m_currentTrail.size() - 1) / 35;
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
            }
            m_currentTrail.clear();
        }

        bufferPoint.insert(m_undoIndex, m_ListIndex);
        m_undoIndex++;
        m_ListIndex.clear();
    }

}


void YMHomeworkWrittingBoard::grapItemImage(QObject *itemObj)
{
    m_grab_item = qobject_cast<QQuickItem*>(itemObj);
    m_grab_result = m_grab_item->grabToImage();
    QQuickItemGrabResult * grabResult = m_grab_result.data();
    connect(grabResult, SIGNAL(ready()), this, SLOT(saveIamge()));
}

void YMHomeworkWrittingBoard::saveIamge()
{
    QImage img = m_grab_result->image();

    QImage jpgImage(img.size(), QImage::Format_ARGB32);
    jpgImage.fill(QColor(Qt::white).rgb());
    QPainter painter(&jpgImage);
    painter.drawImage(0, 0, img);

    int currentDateTimes = QDateTime::currentDateTime().toTime_t();
    QString names = QString("/%1.jpg").arg(currentDateTimes);
    if(jpgImage.save(m_docParh + names))
    {
        emit sigBeSavedGrapAnswer(m_docParh + names, img.width(), img.height());
    }
}

void YMHomeworkWrittingBoard::grapImageSetting()
{
    //创建 图片生成目录
    m_docParh = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    m_docParh += "/";
    QDir wdir(m_docParh);
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_docParh + "YiMi/writtingGrap"))
    {


        wdir.mkpath("YiMi/writtingGrap/" );
    }
    m_docParh += "YiMi/writtingGrap";

    //清除上次的图片文件
    QStringList nameFilters;
    QStringList fileList;
    nameFilters << "*.png" << "*.jpg" << "*.PNG" << "*.JPG" ;
    QDirIterator dirIterator(m_docParh, nameFilters, QDir::Files | QDir::NoSymLinks | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
    while(dirIterator.hasNext())
    {
        fileList << dirIterator.filePath();
        dirIterator.next();
    }
    QString fileallpath;
    QString filetemparay;
//    for (int i =0 ;i < fileList.count() ; i++) {
//        fileallpath += fileList[i] +" ;\n ";
//        filetemparay = fileList[i];
//        QFile::remove(filetemparay);
//    }
}
