#include "trailboard.h"

#include <QPainter>
#include <QMouseEvent>
#include <QMutexLocker>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>
#include <debuglog.h>
#include "getoffsetimage.h"

#if 1
double A[11] = {0.500, 0.405, 0.320, 0.245, 0.180, 0.125, 0.080, 0.045, 0.020, 0.005, 0.000};
double B[11] = {0.500, 0.590, 0.660, 0.710, 0.740, 0.750, 0.740, 0.710, 0.660, 0.590, 0.500};
double C[11] = {0.000, 0.005, 0.020, 0.045, 0.080, 0.125, 0.180, 0.245, 0.320, 0.405, 0.500};

const double scrollRate = 0.618;//屏幕比例常量

TrailBoard::TrailBoard(QQuickPaintedItem *parent): QQuickPaintedItem(parent)
    , m_handler(NULL)
#ifdef USE_OSS_AUTHENTICATION
    , bufferModel(0, "", 1.0, 1.0, "", "0", 0, false, 0)
#else
    , bufferModel(0, "", 1.0, 1.0, "", "0", 0, false)
#endif
    , currentImagaeOffSetY(0.0)
{
#ifdef USE_OSS_AUTHENTICATION
    m_httpClient = YMHttpClient::defaultInstance();
    m_httpUrl = m_httpClient->getRunUrl(1);
#endif

    connect(this, SIGNAL( heightChanged() ), this, SLOT( onCtentsSizeChanged()) );
    connect(this, SIGNAL( widthChanged()  ), this, SLOT( onCtentsSizeChanged()) );

    setAcceptedMouseButtons(Qt::LeftButton);
    m_tempTrail =  QPixmap(this->width(), this->height() );
    m_tempTrail.fill(QColor(255, 255, 255, 0));
    m_penColor = QColor(0, 0, 0);
    m_operateStatus = 1;

    setCursor(Qt::PointingHandCursor);
    m_brushSize = 0.000997;
    m_handler = new SocketHandler(this);

    connect(m_handler, &SocketHandler::sigDrawPage, this, &TrailBoard::drawPage);
    connect(m_handler, &SocketHandler::sigDrawLine, this, &TrailBoard::drawRemoteLine); //sigPointerPosition
    //connect(m_handler,SIGNAL( sigPointerPosition(double  ,double ) ) , this ,SLOT( onSigPointerPosition(double  ,double ) ) ) ;
    connect(m_handler, SIGNAL( sigSendHttpUrl(QString ) ), this, SIGNAL( sigSendHttpUrl(QString ) ) ) ;
    connect(m_handler, SIGNAL( sigEnterOrSync(int  ) ), this, SLOT( onSigEnterOrSync(int  ) ) ) ;
    connect(m_handler, SIGNAL( sigStartClassTimeData(QString   ) ), this, SLOT(slotsStartClass(QString)));// SIGNAL( sigStartClassTimeData(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigSendUserId(QString )), this, SIGNAL(sigSendUserId(QString)));
    connect(m_handler, SIGNAL( sigUserIdCameraMicrophone(QString, QString,  QString ) ), this, SLOT(onSigUserIdCameraMicrophone(QString, QString,  QString ))) ;
    connect(m_handler, SIGNAL( sigAuthtrail(QMap<QString, QString>) ), this, SLOT( onSigAuthtrail(QMap<QString, QString> ) )) ;
    connect(m_handler, SIGNAL( sigStudentEndClass(QString   ) ), this, SLOT( onStudentEndClass(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigExitRoomIds(QString   ) ), this, SIGNAL( sigExitRoomIds(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigDroppedRoomIds(QString   ) ), this, SIGNAL( sigDroppedRoomIds(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigAvUrl( QString, QString, QString, QString  ) ), this, SIGNAL( sigVideoAudioUrl( QString, QString, QString, QString  )  ) ) ;
    connect(m_handler, SIGNAL( sigNetworkOnline(bool)), this, SIGNAL(sigNetworkOnline(bool)));
    connect(m_handler, SIGNAL( sigChangedWay(QString)), this, SLOT(changedWay(QString)));
    connect(m_handler, SIGNAL( sigChangedPage()), this, SLOT(changedPage()));
    connect(m_handler, SIGNAL( autoChangeIpResult(QString)), this, SIGNAL(autoChangeIpResult(QString)));
    connect(m_handler, SIGNAL(sigAutoConnectionNetwork()), this, SIGNAL(sigAutoConnectionNetwork()));
    connect(m_handler, SIGNAL(sigCurrentLessonTimer(int)), this, SIGNAL(sigCurrentLessonTimer(int)));
    connect(m_handler, SIGNAL(sigAnalysisQuestionAnswer(long, QString, QString, QString)), this, SIGNAL(sigAnalysisQuestionAnswer(long, QString, QString, QString)));
    connect(m_handler, SIGNAL(sigCurrentQuestionId(QString, QString, QString, double, bool)), this, SIGNAL(sigCurrentQuestionId(QString, QString, QString, double, bool)));
    connect(m_handler, SIGNAL(sigOffsetY(double)), this, SIGNAL(sigOffsetY(double)));
    connect(m_handler, SIGNAL(sigPlanChange(long, long, long)), this, SIGNAL(sigPlanChange(long, long, long)));
    connect(m_handler, SIGNAL(sigCurrentColumn(long, long)), this, SIGNAL(sigCurrentColumn(long, long)));
    connect(m_handler, SIGNAL(sigIsOpenAnswer(bool, QString, QString)), this, SIGNAL(sigIsOpenAnswer(bool, QString, QString)));
    connect(m_handler, SIGNAL(sigIsOpenCorrect(bool)), this, SIGNAL(sigIsOpenCorrect(bool)));
    connect(m_handler, SIGNAL(sigSynColumn(QString, QString)), this, SIGNAL(sigSynColumn(QString, QString)));
    connect(m_handler, SIGNAL(sigOneStartClass()), this, SIGNAL(sigOneStartClass()));
    connect(m_handler, SIGNAL(sigSynQuestionStatus(bool)), this, SIGNAL(sigSynQuestionStatus(bool)));
    connect(m_handler, SIGNAL(sigStudentAppversion(bool)), this, SIGNAL(sigStudentAppversion(bool)));
    connect(m_handler, SIGNAL(sigZoomInOut(double, double, double)), this, SLOT(getOffSetImage(double, double, double)));

    connect(this, SIGNAL( sigSendUrl(QString, double, double, bool ) ), this, SLOT(onSigSendUrl(QString, double, double )   )) ;
    connect(this, SIGNAL(sigSendDocIDPageNo(QString )), this, SLOT( onSigSendDocIDPageNo(QString  ) )  );
    connect(GetOffsetImage::instance(), SIGNAL(sigCurrentImageHeight(double)), this, SIGNAL(sigCurrentImageHeight(double)));

    m_cursorShape = 1;
    setCursorShape();
    //setRenderTarget(QQuickPaintedItem::FramebufferObject);
}
void TrailBoard::setAllTrails( QByteArray trailData)
{
//    QFile file("i22222n33.txt");
//            if (!file.open(QIODevice::ReadWrite | QIODevice::Text))
//                return;
//            file.write(trailData);
//            file.flush();
//            file.close();

//    qDebug()<<"asdddddddddddddddd";
    if(trailData.size() == 0)
    {
        trailData = "16#{10002487:1522720677947}#{\"domain\":\"server\",\"command\":\"synchronize\",\"content\":{\"state\":\"complete\",\"commands\":[]}}";
    }
    m_handler->readMessage( trailData );
}
void TrailBoard::slotsStartClass(QString startTimer)
{
    emit sigStartClassTimeData(startTimer);
    if(m_handler->m_isGotoPageRequst)
    {
        emit sigPromptInterface("8");
        m_handler->m_isGotoPageRequst = false;
    }
}
#ifdef USE_OSS_AUTHENTICATION
//修改老课件验签状态
void TrailBoard::updateOssSignStatus(bool status)
{
    StudentData::gestance()->coursewareSignOff = status;
    //qDebug() << "==TrailBoard::updateOssSignStatus==" <<StudentData::gestance()->coursewareSignOff ;
}

//题库里面图片进行验签
void TrailBoard::getOssSignUrl(QString ImgUrl)
{
    long current_second = QDateTime::currentDateTime().toTime_t();
    int indexOf = ImgUrl.indexOf(".com");
    int midOf = ImgUrl.indexOf("?");
    QString key = ImgUrl.mid(indexOf + 4, midOf - indexOf - 4); //ImgUrl.length() - indexOf - 4);

    bool isKey = m_bufferOssKey.contains(key);
    if(!isKey)//key是否存在,不存在则添加
    {
        m_bufferOssKey.insert(key, 0);
    }

    QMap<QString, long>::iterator key_Map = m_bufferOssKey.find(key);
    long buffer_second = key_Map.value();

    //qDebug() << "==TrailBoard::getOssSignUrl==" << isKey << buffer_second << current_second << key;

    if(current_second - buffer_second >= 1800 || isKey == false)//如果该key存在则判断是否过期
    {
        QVariantMap  reqParm;
        reqParm.insert("key", key);
        reqParm.insert("expiredTime", 1800 * 1000);
        reqParm.insert("token", YMUserBaseInformation::token);

        QString signSort = YMEncryption::signMapSort(reqParm);
        QString sign = YMEncryption::md5(signSort).toUpper();
        reqParm.insert("sign", sign);

        QString httpUrl = m_httpClient->getRunUrl(0);
        QString url = "https://" + httpUrl + "/api/oss/make/sign";
        QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
        QJsonObject allDataObj = QJsonDocument::fromJson(dataArray).object();

        if(allDataObj.value("result").toString().toLower() == "success")
        {
            QString url = allDataObj.value("data").toString();
            m_bufferOssKey[key] = current_second;
            qDebug() << "*********url********" << url << current_second;
            emit sigOssSignUrl(url);
            return;
        }
        else
        {
            qDebug() << "TrailBoard::getOssSignUrl Fail" << allDataObj;
        }
    }

    emit sigOssSignUrl(ImgUrl);
}
#endif

//切换通道
void TrailBoard::changedWay(QString supplier)
{
    if(TemporaryParameter::gestance()->m_isStartClass)
    {
        if(supplier != TemporaryParameter::gestance()->m_supplier)
        {
            //qDebug() << "TrailBoard::changedWay11" << supplier;
            TemporaryParameter::gestance()->m_supplier = supplier;
            emit sigPromptInterface("changedWay");
        }
        TemporaryParameter::gestance()->m_supplier = supplier;
        //qDebug() << "TrailBoard::changedWay22" << supplier;
        QString sendVideo;
        if(TemporaryParameter::gestance()->m_supplier == "2")
        {
            sendVideo =  QString("SYSTEM{\"command\":\"changeAudio\",\"content\":{\"supplier\":\"%1\",\"audioName\":\"%2\",\"videoType\":\"%3\"},\"domain\":\"system\"}").arg(TemporaryParameter::gestance()->m_supplier).arg(StudentData::gestance()->m_audioName).arg(TemporaryParameter::gestance()->m_videoType);
        }
        else
        {
            sendVideo = QString("SYSTEM{\"command\":\"changeAudio\",\"content\":{\"videoType\":\"%1\",\"supplier\":\"%2\",\"audioName\":\"\"},\"domain\":\"system\"}").arg(TemporaryParameter::gestance()->m_videoType).arg(TemporaryParameter::gestance()->m_supplier);
        }
        if(m_handler != NULL)
        {
            m_handler->sendLocalMessage(sendVideo, true, false);
        }
    }
    //qDebug()<< "TrailBoard::changedWay333";
}

//翻页
void TrailBoard::changedPage()
{
    if(m_handler != NULL)
    {
        if(TemporaryParameter::gestance()->m_isStartClass)
        {
            QString pageStr = QString("{\"domain\":\"page\",\"command\":\"goto\",\"content\":{\"page\":\"" + QString::number( m_handler->m_currentPage ) + "\"}}");
            m_handler->sendLocalMessage(pageStr, true, false);
        }
    }
    //qDebug()<< "TrailBoard::changedPage";
}

QString TrailBoard::justImageIsExisting(QString urls)
{
    //"http://static.1mifd.com/api/images/emotion/201606/like_v2" _pad.gif
    QString tempUrl = urls;
    tempUrl.remove("http://");
    if(tempUrl.split("/").size() > 0)
    {
        tempUrl = tempUrl.split("/").takeLast();
    }
    else
    {
        return urls;
    }
    tempUrl.append("_pad.gif");

    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/emotion/";
    QDir isDir;

    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
    }
    if(QFile::exists(m_systemPublicFilePath + tempUrl))
    {
        //qDebug () <<QStringLiteral("已存在 的表情 图片");
        return "file:///" + m_systemPublicFilePath + tempUrl;
    }
    QNetworkRequest httpRequest(urls + "_pad.gif");
    QEventLoop httploop;
    m_httpAccessmanger = new QNetworkAccessManager(this);
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply *)), &httploop, SLOT(quit()));
    QNetworkReply * reply = m_httpAccessmanger->get(httpRequest);

    httploop.exec();

    QFile file(m_systemPublicFilePath + tempUrl);
    file.open(QIODevice::WriteOnly);
    file.write(reply->readAll());
    file.flush();
    file.close();
    //qDebug()<<"file:///" + m_systemPublicFilePath + tempUrl<<"dsaaaaaaaaaaaaaaa";
    return "file:///" + m_systemPublicFilePath + tempUrl;
}

//选择课件消息处理
void TrailBoard::setCourseware(QString message)
{
    //qDebug() << "===TrailBoard::setCourseware===" << message;
    if(m_handler != NULL)
    {
        QJsonObject dataObj = QJsonDocument::fromJson(message.toLatin1()).object();
        QJsonObject contentObj = dataObj.value("content").toObject();
        QJsonArray urlArray = contentObj.value("urls").toArray();
        if(urlArray.size() == 0)
        {
            //qDebug() << "=====url::null======" << urlArray;
            return;
        }
        m_handler->sendLocalMessage(message, true, true);
        this->changedPage();
    }
    // qDebug() << "TrailBoard::setCourseware" << message;
}

//设置画笔颜色
void TrailBoard::setPenColor(int pencolors)
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

//改变操作状态
void TrailBoard::changeOperateStatus(int status)
{
    m_operateStatus = status;
}

//改变画笔颜色
void TrailBoard::changePenColor(QColor color)
{
    m_penColor = color;
    m_cursorShape = 1;
    m_operateStatus = 1;
    setCursorShape();
}

//填充的画刷
void TrailBoard::changeBrushSize(double size)
{
    m_brushSize = size;
    m_cursorShape = 1;
    m_operateStatus = 1;

    setCursorShape();
}
//设置鼠标类型
void TrailBoard::setCursorShapeTypes(int types)
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

//根据偏移量截图
void TrailBoard::getOffsetImage(QString imageUrl, double offsetY)
{
    QImage tempImage;
    GetOffsetImage::instance()->currentBeBufferedImage = tempImage;

    currentImagaeOffSetY = offsetY;
    GetOffsetImage::instance()->getOffSetImage(imageUrl, offsetY);
    //qDebug() << "****************TrailBoard::getOffsetImage********";
}

void TrailBoard::getOffSetImage(double offsetX, double offsetY, double zoomRate)
{
    currentImagaeOffSetY = qAbs(offsetY);//记录当前图的偏移量
    GetOffsetImage::instance()->getOffSetImage(offsetY);
    //获取轨迹信息
    //qDebug() << "****TrailBoard::getOffSetImage******" << offsetY;
    onCtentsSizeChanged();
}

double TrailBoard::changeYPoinToLocal(double pointY)
{
    //qDebug() << "********TrailBoard::changeYPoinToLocal**********" << pointY << currentImagaeOffSetY  << StudentData::gestance()->midWidth << StudentData::gestance()->midHeight<<  GetOffsetImage::instance()->currrentImageHeight << this->height();
    double tempHeight = GetOffsetImage::instance()->currrentImageHeight > this->height() ? GetOffsetImage::instance()->currrentImageHeight : this->height();
    pointY = ((pointY * tempHeight) - (currentImagaeOffSetY * this->height())) / this->height();
    //qDebug() << "********TrailBoard::changeYPoinToLocal::new**********" << pointY;
    return pointY;
}
double TrailBoard::changeYPoinToSend(double pointY)
{
    //qDebug() << "********TrailBoard::changeYPoinToSend*******" << pointY << currentImagaeOffSetY << GetOffsetImage::instance()->currrentImageHeight << this->height();
    double tempHeight = GetOffsetImage::instance()->currrentImageHeight > this->height() ? GetOffsetImage::instance()->currrentImageHeight : this->height();
    pointY = (pointY + currentImagaeOffSetY) * this->height() / tempHeight;
    return pointY;
}

//网络画当前的页面内容
void TrailBoard::drawPage(MessageModel model)
{
    bufferModel.clear();
    bufferModel = model;
    //qDebug() << "==TrailBoard::drawPage==" <<currentImagaeOffSetY << this->height() << model.questionId<< model.offsetY << model.bgimg;

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

    m_tempTrail =  QPixmap(this->width(), this->height());
    //m_tempTrail = QPixmap(boardSize);
    m_tempTrail.fill(QColor(255, 255, 255, 0));
    foreach (Msg mess, model.getMsgs())
    {
        this->parseTrail(mess.msg);
    }

    update();

    //qDebug() << "=======TrailBoard::drawPage::handler========" << m_handler->m_sysnStatus << currentImagaeOffSetY;

    bool isLongImg = (model.questionId == "") ? false :  (model.bgimg == ""  ? false : true);
    emit sigSendUrl(model.bgimg, model.width, model.height, isLongImg, model.questionId);

    //qDebug() << "=======TrailBoard::drawPage========" <<  model.bgimg << isLongImg  << model.width << model.height << "question:" + model.questionId;

    emit sigChangeCurrentPage(model.getCurrentPage());
    emit sigChangeTotalPage(model.getTotalPage());
}

void TrailBoard::drawRemoteLine(QString command)
{
    parseTrail(command);
    update();
}

int TrailBoard::getCursorPage(QString docId)
{
    if(m_handler != NULL)
    {
        return m_handler->getCurrentPage(docId);
    }
    return 1;
}

//本地画多边图形
void TrailBoard::drawLocalGraphic(QString command, double backGroundHeight, double ImageY)
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
                QJsonObject object;
                object.insert("domain", QString("draw"));
                object.insert("command", QString("polygon"));
                object.insert("content", obj);
                QJsonDocument doc;
                doc.setObject(object);
                QString s(doc.toJson(QJsonDocument::Compact));
                //s = s.replace("\r\n","").replace("\n","").replace("\r","").replace("\t","").replace(" ","");
                // if(TemporaryParameter::gestance()->m_isStartClass ) {
                m_handler->sendLocalMessage(s, true, false);
                bufferModel.addMsg("temp", s);
                //}
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
                //if(TemporaryParameter::gestance()->m_isStartClass ) {
                m_handler->sendLocalMessage(s, true, false);
                bufferModel.addMsg("temp", s);
                //}
            }
        }
    }
    else
        update();
}
//上传图片成功后发送额指令
void TrailBoard::upLoadSendUrlHttp(QString https)
{
    if(https.length() > 0)
    {
        /*
         * 新加截图图片
         */
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


                        QJsonObject json;
                        json.insert("command", QString("picture"));
                        json.insert("domain", QString("draw"));

                        QJsonObject json1;
                        json1.insert("type", QString("picture"));
                        json1.insert("pageIndex", QString("%1").arg( m_handler->m_currentPage + 1 ) );
                        json1.insert("url", QString("%1").arg( mdStr ) );
                        json1.insert("width", QString("%1").arg(m_pictureWidthRate));
                        json1.insert("height", QString("%1").arg(m_pictureHeihtRate));

                        json.insert("content", json1);
                        //QJsonObject json3;


                        QJsonDocument documents;
                        documents.setObject(json);
                        QString str(documents.toJson(QJsonDocument::Compact));


                        if( m_handler != NULL )
                        {
                            m_handler->sendLocalMessage(str, true, true);
                        }
                    }
                    else
                    {
                        qDebug() << "TrailBoard::upLoadSendUrlHttp" << jsonObj;
                    }

                    return;

                }
            }
        }

    }
}

void TrailBoard::setPictureRate(double widthRate, double heightRate)
{
    m_pictureWidthRate = widthRate;
    m_pictureHeihtRate = heightRate;
}
//设置表情的url
void TrailBoard::setInterfaceUrls(QString urls)
{
    if(m_handler != NULL)
    {
        QString str = QString("0#{\"command\":\"magicface\",\"content\":\"%1\",\"domain\":\"control\"}").arg(urls);
        m_handler->sendLocalMessage(str, false, false);
    }

}
//开始上课
void TrailBoard::startClassBegin()
{
    if(m_handler != NULL)
    {
        m_handler->clearRecord();
        TemporaryParameter::gestance()->m_isAlreadyClass = true;
        QString str;
        if(TemporaryParameter::gestance()->m_supplier == "2")
        {
            str = QString("SYSTEM{\"command\":\"startClass\",\"content\":{\"videoType\":\"%1\",\"supplier\":\"%2\",\"audioName\":\"%3\"},\"domain\":\"system\"}").arg(TemporaryParameter::gestance()->m_videoType).arg(TemporaryParameter::gestance()->m_supplier).arg(StudentData::gestance()->m_audioName);
        }
        else
        {
            str = QString("SYSTEM{\"command\":\"startClass\",\"content\":{\"videoType\":\"%1\",\"supplier\":\"%2\",\"audioName\":\"shengwang\"},\"domain\":\"system\"}").arg(TemporaryParameter::gestance()->m_videoType).arg(TemporaryParameter::gestance()->m_supplier);

        }

        m_handler->sendLocalMessage(str, true, false);
        QString pageStr = QString("{\"domain\":\"page\",\"command\":\"goto\",\"content\":{\"page\":\"" + QString::number( m_handler->m_currentPage ) + "\"}}");
        m_handler->sendLocalMessage(pageStr, true, false);
    }
}
//处理翻页请求
void TrailBoard::handlePageRequest(bool requests)
{
    if(requests)
    {
        QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"gotoPage\",\"content\":{\"userId\":\"%1\",\"auth\":\"1\"}}").arg( TemporaryParameter::gestance()->m_userId );
        m_handler->sendLocalMessage(bstr, true, false);
    }
    else
    {
        QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"gotoPage\",\"content\":{\"userId\":\"%1\",\"auth\":\"0\"}}").arg( TemporaryParameter::gestance()->m_userId );
        m_handler->sendLocalMessage(bstr, true, false);
    }
}
//学生离开教室老师离开教室
void TrailBoard::leaveClassroom()
{
    if( m_handler != NULL )
    {
        m_handler->sendLocalMessage("0#SYSTEM{\"domain\":\"system\",\"command\":\"exitRoom\"}", false, false);
        m_handler->disconnectSocket(true);
        emit sigCloseAllWidgets();
    }
}

void TrailBoard::disconnectSocket(bool autoReconnect)
{
    if(m_handler != NULL)
    {
        m_handler->disconnectSocket(autoReconnect);
    }
}

//处理学生离开教室请求
void TrailBoard::handlLeaveClassroom(bool leaves)
{
    if(leaves)
    {
        QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"exit\",\"content\":{\"userId\":\"%1\",\"auth\":\"1\"}}").arg( TemporaryParameter::gestance()->m_exitRequestId );
        // qDebug()<<"bstr =="<<bstr;
        m_handler->sendLocalMessage(bstr, true, false);
    }
    else
    {
        QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"exit\",\"content\":{\"userId\":\"%1\",\"auth\":\"0\"}}").arg( TemporaryParameter::gestance()->m_exitRequestId);
        // qDebug()<<"bstr =="<<bstr;
        m_handler->sendLocalMessage(bstr, true, false);
    }
}
//处理b学生进入教室请求
void TrailBoard::handlEnterClassroom(bool enters)
{
    QString bstr;
    if(enters)
    {
        bstr =  QString("{\"domain\":\"auth\",\"command\":\"enterRoom\",\"content\":{\"userId\":\"%1\",\"auth\":\"1\"}}").arg( TemporaryParameter::gestance()->m_enterRoomRequest );
    }
    else
    {
        bstr =  QString("{\"domain\":\"auth\",\"command\":\"enterRoom\",\"content\":{\"userId\":\"%1\",\"auth\":\"0\"}}").arg( TemporaryParameter::gestance()->m_enterRoomRequest );
    }
    m_handler->sendLocalMessage(bstr, true, false);
}
//退出
void TrailBoard::temporaryExitWidget()
{
    //qDebug() << "TrailBoard::temporaryExitWidget()";

    //================================
    DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server(); //关闭进程前, 需要上传日志文件

    //================================
    if( m_handler != NULL )
    {
        m_handler->sendLocalMessage("0#SYSTEM{\"command\":\"exitRoom\",\"domain\":\"control\"}", false, false);
        m_handler->disconnectSocket(false);

        QProcess process;
        process.execute("TASKKILL /IM CourwarePreviewer.exe /F");
        process.close();
    }
    //临时退出
//    if(m_handler != NULL) {
//        m_handler->sendLocalMessage("0#SYSTEM{\"domain\":\"system\",\"command\":\"exitRoom\"}",false,false);
//        m_handler->disconnectSocket(true);
//        emit sigCloseAllWidgets();
//    }
}
//家庭作业
void TrailBoard::sendTopicContent(QString tags, QString names, bool status)
{
    QNetworkAccessManager * httpAccessmanger = new QNetworkAccessManager(this);

    QNetworkRequest httpRequest;
    QEventLoop httploop;
    connect(this, SIGNAL(sigEndWidget()), &httploop, SLOT(quit()));
    QUrl url("http://" + m_httpUrl + "/lesson/finishLesson?");
    QByteArray post_data;
    QString param1;
    if(status)
    {
        param1 = QStringLiteral("1");
    }
    else
    {
        param1 = QStringLiteral("0");
    }
    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("userId", StudentData::gestance()->m_teacher.m_teacherId);
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("type", "TEA");
    maps.insert("apiVersion", "3.0"); //StudentData::gestance()->m_apiVersion);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    maps.insert("param1", param1);
    maps.insert("param2", QString(tags )  ); //.toPercentEncoding()
    maps.insert("param3", QString(names)); //.toPercentEncoding()
    QString sign;
    QString urls;
    QMap<QString, QString>::iterator it =  maps.begin();
    for(int i = 0; it != maps.end() ; it++, i++)
    {
        if(i == 0)
        {
            sign.append(it.key());
            sign.append("=" + it.value());
        }
        else
        {
            sign.append("&" + it.key());
            sign.append("=" + it.value());
        }
    }
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toUtf8(), QCryptographicHash::Md5).toHex().toUpper());

    //  QString str = QString("userId=%1&lessonId=%2&type=TEA&param1=%3&param2=%4&param3=%5").arg(StudentData::gestance()->m_teacher.m_teacherId).arg(StudentData::gestance()->m_lessonId).arg(param1).arg(tags).arg(names);
    //  post_data.append(urls);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    // httpRequest.setHeader(QNetworkRequest::ContentLengthHeader, post_data.length());
    httpRequest.setUrl(url);
    QNetworkReply * httpReply = httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.

    connect(httpReply, SIGNAL(finished()), this, SLOT( onHttpFinished() ));

    httploop.exec();
    QByteArray arrys =  httpReply->readAll();
    QString str(arrys) ;
    if( m_handler != NULL )
    {
        m_handler->sendLocalMessage("0#{\"command\":\"finishClass\",\"domain\":\"control\"}", false, false);
        m_handler->disconnectSocket(false);
        emit sigCloseAllWidgets();
    }
}
//退出教室
void TrailBoard::finishClassRoom()
{
    if( m_handler != NULL )
    {
        TemporaryParameter::gestance()->m_isFinishLesson = true;
        m_handler->sendLocalMessage("0#{\"command\":\"finishClass\",\"domain\":\"control\"}", false, false);
        m_handler->disconnectSocket(false);
    }
}

//处理可见信息
void TrailBoard::handlCoursewareNameInfor(QString contents)
{
    if(m_handler != NULL)
    {
        m_handler->sendLocalMessage(contents, true, true);
    }
}
//给学生发送音频、视频播放命令
void TrailBoard::setVideoStream(QString types, QString staues, QString times, QString address)
{
    if( m_handler != NULL )
    {
        QJsonObject json;
        json.insert("command", QString("avControl"));
        json.insert("domain", QString("control"));

        QJsonObject json1;
        json1.insert("startTime", times);
        json1.insert("avType", types);
        json1.insert("controlType", staues);
        json1.insert("avUrl", address);
        json.insert("content", json1);

        QJsonDocument documents;
        documents.setObject(json);
        QString str(documents.toJson(QJsonDocument::Compact));

        m_handler->sendLocalMessage(str, true, false);
    }
}
//设置发送的内容
void TrailBoard::setSendStudentId(QString contents)
{
    if( m_handler != NULL )
    {
        m_handler->sendLocalMessage(contents, true, false);
    }

}
//直接发送信息
void TrailBoard::directSendInformation(QString contents)
{
    if( m_handler != NULL )
    {
        m_handler->sendLocalMessage(contents, false, false);
    }
}

void TrailBoard::disconnectSocket()
{
    if( m_handler != NULL )
    {
        m_handler->sendLocalMessage("0#SYSTEM{\"domain\":\"system\",\"command\":\"exitRoom\"}", false, false);
        m_handler->disconnectSocket(false);
    }
}
//主动退出教室
void TrailBoard::selectWidgetType(int types)
{
    if(types == 1)
    {
        QString cmd =  QString("{\"domain\":\"auth\",\"command\":\"exitRequest\",\"content\":{\"userId\":\"%1\",\"auth\":\"%2\"}}").arg(StudentData::gestance()->m_selfStudent.m_studentId).arg(1);
        m_handler->sendLocalMessage(cmd, true, false);
        return;
    }
}


//同意学生申请结束课程
void TrailBoard::agreeEndLesson(int types)
{
    //types 1同意 0不同意
    if(m_handler != NULL)
    {
        QString cmd =  QString("{\"domain\":\"auth\",\"command\":\"finishResp\",\"content\":{\"userId\":\"%1\",\"auth\":\"1\"}}").arg(StudentData::gestance()->m_selfStudent.m_studentId);
        m_handler->sendLocalMessage(cmd, true, false);
        return;
    }
}

//获取课程总时长
void TrailBoard::getCurrentCourseTotalTimer()
{
    if(m_handler != NULL)
    {
        QString cmd =  QString("SYSTEM{\"domain\":\"system\",\"command\":\"totalTime\"}");
        m_handler->sendLocalMessage(cmd, true, false);
        return;
    }
}

//发送评价
void TrailBoard::setSendTopicContent(QString param1, QString param2, QString param3)
{
    QNetworkRequest httpRequest;
    QEventLoop httploop;
    QNetworkAccessManager *m_httpAccessmangers = new QNetworkAccessManager(this);
    QNetworkReply * reply;
    QTimer::singleShot(10000, &httploop, SLOT(quit()));
    connect(m_httpAccessmangers, SIGNAL(finished(QNetworkReply *)), &httploop, SLOT(quit()));
    QUrl url("http://" + m_httpUrl + "/lesson/finishLesson?");

    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("userId", StudentData::gestance()->m_selfStudent.m_studentId);
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("type", "TEA");
    maps.insert("apiVersion", "3.0");
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    QString s_param;
    //s_param.append(param1).append("#").append(param2).append("#").append(param3);
    s_param.append(QStringLiteral("知识掌握情况:")).append("#").append(QStringLiteral("课堂表现:")).append("#").append(QStringLiteral("老师评价:"));

    maps.insert("titles", s_param);
    maps.insert("param1", param1);
    maps.insert("param2", param2);
    maps.insert("param3", param3);

    QString sign;
    QString urls;
    QMap<QString, QString>::iterator it =  maps.begin();
    for(int i = 0; it != maps.end() ; it++, i++)
    {
        if(i == 0)
        {
            sign.append(it.key());
            sign.append("=" + it.value());
        }
        else
        {
            sign.append("&" + it.key());
            sign.append("=" + it.value());
        }
    }
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toUtf8(), QCryptographicHash::Md5).toHex().toUpper());
    httpRequest.setUrl(url);

    QMap<QString, QString>::iterator its =  maps.begin();
    maps.insert("titles", s_param.toUtf8().toPercentEncoding()); //
    maps.insert("param1", param1.toUtf8().toPercentEncoding());
    maps.insert("param2", param2.toUtf8().toPercentEncoding());
    maps.insert("param3", param3.toUtf8().toPercentEncoding());
    urls = "";
    for(int i = 0; its != maps.end() ; its++, i++)
    {
        if(i == 0)
        {
            urls.append(its.key());
            urls.append("=" + its.value());
        }
        else
        {
            urls.append("&" + its.key());
            urls.append("=" + its.value());
        }
    }

    urls.append("&sign=").append(QCryptographicHash::hash(sign.toUtf8(), QCryptographicHash::Md5).toHex().toUpper());
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    reply = m_httpAccessmangers->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    httploop.exec();

    QByteArray data = reply->readAll();
    QJsonObject jsonObj = QJsonDocument::fromJson(data).object();

    if( m_handler != NULL && jsonObj.value("result").toString().toLower() == "success")
    {
        QProcess process;
        process.execute("TASKKILL /IM CourwarePreviewer.exe /F");
        process.close();
    }
    else
    {
        qDebug() << "TrailBoard::setSendTopicContent" << jsonObj;
    }
}

//设置申请翻页
void TrailBoard::setApplyPage()
{
    if( m_handler != NULL )
    {
        QString cmd =  QString("{\"domain\":\"auth\",\"command\":\"gotoPageRequest\",\"content\":{\"userId\":\"%1\",\"auth\":\"%2\"}}").arg(StudentData::gestance()->m_selfStudent.m_studentId).arg(1);
        m_handler->sendLocalMessage(cmd, true, false);
    }
}

//收回翻页权限
void TrailBoard::setRecoverPage()
{
    if(m_handler != NULL)
    {
        if(TemporaryParameter::gestance()->m_userPagePermissions == "1")
        {
            QString cmd = QString("{\"command\":\"gotoPage\",\"content\":{\"auth\":\"0\",\"userId\":\"%1\"},\"domain\":\"auth\"}").arg(TemporaryParameter::gestance()->m_userId);
            m_handler->sendLocalMessage(cmd, true, false);
            TemporaryParameter::gestance()->m_userPagePermissions = "0";
            //qDebug() << "TrailBoard::setRecoverPage:" << TemporaryParameter::gestance()->m_userPagePermissions;
        }
    }
}

//控制本地摄像头
void TrailBoard::setOperationVideoOrAudio(QString userId, QString videos, QString audios)
{
    QString userIds = userId;
    if(userIds == "0")
    {
        for(int i = 0; i < StudentData::gestance()->m_student.size(); i++)
        {
            userIds = StudentData::gestance()->m_student.at(i).m_studentId;//StudentData::gestance()->m_selfStudent.m_studentId;
            break;
        }
    }
    //qDebug() << "TrailBoard::setOperationVideoOrAudio" << userIds << videos << audios;
    QPair<QString, QString > pair(videos, audios);
    StudentData::gestance()->m_cameraPhone.insert(userIds, pair);

    QString sendStr = QString("0#{\"command\":\"settinginfo\",\"content\":{\"infos\":{\"camera\":\"%1\",\"networktype\":\"1\",\"microphone\":\"%2\",\"volume\":\"3\",\"ishideapp\":\"0\"},\"userId\":\"%3\"},\"domain\":\"control\"}")
                      .arg(videos).arg(audios).arg(StudentData::gestance()->m_selfStudent.m_studentId);

    if(m_handler != NULL)
    {
        m_handler->sendLocalMessage(sendStr, false, false);
    }
}

//打开学生端音频、音视频
void TrailBoard::setOpenSutdentVideo(QString videoType)
{
    //supplier 通道 1：A通道 2、B通道 带音频名字  通道退出时要关闭音视频
    //videoType 0 音频，1音视频
    //audioName 加密

    TemporaryParameter::gestance()->m_videoType = videoType;
    QString sendVideo;
    if(TemporaryParameter::gestance()->m_supplier == "2")
    {
        sendVideo =  QString("SYSTEM{\"command\":\"changeAudio\",\"content\":{\"supplier\":\"%1\",\"audioName\":\"%2\",\"videoType\":\"%3\"},\"domain\":\"system\"}").arg(TemporaryParameter::gestance()->m_supplier).arg(StudentData::gestance()->m_audioName).arg(TemporaryParameter::gestance()->m_videoType);
    }
    else
    {
        sendVideo = QString("SYSTEM{\"command\":\"changeAudio\",\"content\":{\"videoType\":\"%1\",\"supplier\":\"%2\",\"audioName\":\"\"},\"domain\":\"system\"}").arg(TemporaryParameter::gestance()->m_videoType).arg(TemporaryParameter::gestance()->m_supplier);
    }
    //qDebug() << "m_videoType:" <<TemporaryParameter::gestance()->m_videoType;
    if(m_handler != NULL)
    {
        m_handler->sendLocalMessage(sendVideo, true, false);
    }
}

//ip切换
void TrailBoard::setChangeOldIpToNew()
{
    if(m_handler != NULL)
    {
        m_handler->onChangeOldIpToNew();
    }
}

//通道切换
void TrailBoard::setAisle(QString aisle)
{
    TemporaryParameter::gestance()->m_supplier = aisle;
}

//发送延迟信息
void TrailBoard::setSigSendIpLostDelay(QString infor)
{
    //这里, 把"SYSTEM", 修改成 "0#SYSTEM", 会引起掉线的问题, 所以还原2018/08/24 17:29:54的push代码
    QString sendStr = QString("SYSTEM") + infor;

    if(m_handler != NULL)
    {
        m_handler->sendLocalMessage(sendStr, true, false);
    }
}

void TrailBoard::openPolygonPanel(int points)
{
    emit sigToolWidgetShow();
}

void TrailBoard::openEllipsePanel()
{
    emit sigToolWidgetShow();
}

//改变橡皮大小
void TrailBoard::changeEraserSize(double size)
{
    m_eraserSize = size;
}
//操作权限
void TrailBoard::onSigAuthtrail(QMap<QString, QString> contents)
{

    m_userBrushPermissions.clear();
    m_userBrushPermissions = contents;
    QString str = m_userBrushPermissions.value(StudentData::gestance()->m_selfStudent.m_studentId, "");

    if(str.length() > 0)
    {
        TemporaryParameter::gestance()->m_userBrushPermissions = str;
    }
    else
    {
        if(TemporaryParameter::gestance()->m_isAlreadyClass)
        {
            TemporaryParameter::gestance()->m_userBrushPermissions = "0";
        }

    }

    if(TemporaryParameter::gestance()->m_isStartClass )
    {
        //权限改变
        emit sigPromptInterface("62");
    }
}

//撤销某条记录
void TrailBoard::undo()
{
    m_handler->undo();
}

//增加某一页
void TrailBoard::addPage()
{
    m_handler->addPage();
}

//删除某一页
void TrailBoard::deletePage()
{
    //如果是课件不能删除
    MessageModel model = m_handler->m_pages[m_handler->m_currentCourse][m_handler->m_currentPage];
    if(model.isCourware)
    {
        emit sigIsCourseWare();
        return;
    }
    m_handler->deletePage();
}

//跳转到某一页
void TrailBoard::goPage(int pageIndex)
{

    m_handler->goPage(pageIndex);
}

//清屏
void TrailBoard::clearScreen()
{
    //qDebug() << "=======TrailBoard::clearScreen========";
    m_handler->clearScreen();
}

//界面尺寸变化
void TrailBoard::onCtentsSizeChanged()
{
    m_tempTrail = QPixmap(this->width(), this->height());
    //m_tempTrail = QPixmap(boardSize);
    m_tempTrail.fill(QColor(255, 255, 255, 0));
    foreach (Msg mess, bufferModel.getMsgs())
    {
        this->parseTrail(mess.msg);
    }
    //qDebug() << "==TrailBoard::onCtentsSizeChanged==" << this->width() << this->height();
    update();
    GetOffsetImage::instance()->currentTrailBoardHeight = this->height();
}

//同步信息
void TrailBoard::onSigEnterOrSync(int sync)
{
    //登录错误
    if(sync == 0)
    {
        emit sigPromptInterface("0");
    }
    //同步课程
    if(sync == 1)
    {
        emit sigPromptInterface("1");
    }
    //同步结束
    if(sync == 2)
    {
        emit sigPromptInterface("2");
        if(TemporaryParameter::gestance()->m_isAlreadyClass)
        {
            //上过课
            emit sigPromptInterface("22");
        }
        else
        {
            //未上过课
            emit sigPromptInterface("23");
        }
    }
    //课件加载失败
    if(sync == 18)
    {
        emit sigPromptInterface("lodingCourseFail");
        return;
    }

    //学生连接信号
    if(sync == 4)
    {
        emit sigPromptInterface("51");
    }
    //掉线重连或者退出进入状态判断
    if(sync == 14)
    {
        emit sigPromptInterface("14");
    }
    //学生上课请求操作
    if(sync == 3)
    {
        if(TemporaryParameter::gestance()->m_isAlreadyClass )  //是否上过课
        {
            emit sigPromptInterface("4");//上过课弹窗信号
        }
        else
        {
            if(TemporaryParameter::gestance()->m_isStartClass)
            {
                emit sigPromptInterface("3");//继续上课提醒
            }
            else
            {
                emit sigPromptInterface("5");//未上过课弹窗
            }
        }
        return;
    }
    //为b学生的进入房间
    if(sync == 6)
    {
        QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"enterRoom\",\"content\":{\"userId\":\"%1\",\"auth\":\"1\"}}").arg( StudentData::gestance()->m_selfStudent.m_studentId );
        m_handler->sendLocalMessage(bstr, true, false);
        emit sigPromptInterface("6");
        return;
    }
    //学生申请控制分页权限
    if(sync == 8)
    {
        if(TemporaryParameter::gestance()->m_isAlreadyClass)
        {
            emit sigPromptInterface("8");
            return;
        }
    }
    if(sync == 9)
    {
        emit sigPromptInterface("9");
        return;
    }

    if(sync == 10)  //临时退出教室
    {
        emit sigPromptInterface("10");
        return;
    }
    //B学生进入教室
    if(sync == 11)
    {
        //A学生进入教室了B学生才能进入教室
        if(TemporaryParameter::gestance()->m_isAlreadyClass)
        {
            emit sigPromptInterface("11");
            return;
        }
        else  //但是要显示B学生在线状态
        {
            emit sigPromptInterface("b_Online");
            return;
        }
    }
    if(sync == 12)
    {
        emit sigPromptInterface("12");
        return;
    }
    if(sync == 13)
    {
        emit sigPromptInterface("13");
        return;
    }
    //未认真听讲提醒
    if(sync == 52)
    {
        emit sigPromptInterface("52");
        return;
    }
    //改变频道跟音频
    if(sync == 61)
    {
        emit sigPromptInterface("61");
        return;
    }
    //改变频道跟音频 通信状态
    if(sync == 68)
    {
        emit sigPromptInterface("68");
        return;
    }
    //申请结束课程
    if(sync == 50)
    {
        emit sigPromptInterface("50");
        return;
    }
    //主动断开
    if(sync == 88)
    {
        emit sigPromptInterface("88");
        return;
    }
}
//关闭摄像头操作
void TrailBoard::onSigUserIdCameraMicrophone(QString usrid, QString camera, QString microphone)
{
    QString names;
    //qDebug() << "TrailBoard::onSigUserIdCameraMicrophone" << usrid << camera << microphone;
    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
    {
        if(StudentData::gestance()->m_student[i].m_studentId == usrid )
        {
            if(camera != "1")
            {
                if(StudentData::gestance()->m_student[i].m_camera != camera )
                {
                    TemporaryParameter::gestance()->m_cameraNames = names;
                    emit sigUserIdCameraMicrophone(usrid, 16);
                }
            }
            StudentData::gestance()->m_student[i].m_camera = camera;
            if(microphone != "1")
            {
                if(StudentData::gestance()->m_student[i].m_microphone != microphone )
                {
                    TemporaryParameter::gestance()->m_cameraNames = names;
                    emit sigUserIdCameraMicrophone(usrid, 15);
                }
            }
            StudentData::gestance()->m_student[i].m_microphone = microphone;
        }
    }
}

void TrailBoard::onHttpFinished()
{
    emit sigEndWidget();
}

void TrailBoard::onSigSendUrl(QString urls, double width, double height)
{
    //qDebug() << "onSigSendUrl:" << urls;
    QString urlsh = urls;
    if(urlsh.contains("docId"))
    {
        QStringList list = urlsh.split("docId=");
        if(list.size() == 2)
        {
            /*QStringList list1 = urlsh
            QString docid;.split("?");
            QString userid;
            for(int i = 0 ;i < list1.count() ; i++) {
            if(i == 1) {
                QString list2 = list1[i];
                QStringList list3 = list2.split("&");
                for(int j = 0 ; j< list3.count() ;j++) {
                    QString strs = list3[j];
                    if(strs.contains("userId=")) {
                        userid = strs.replace("userId=","");
                    }
                    if(strs.contains("docId=")) {
                        docid = strs.replace("docId=","");
                    }
                }
            }
            }*/
            //qDebug() << "listString::" << list.at(1);
            QString docid = list.at(1);
            emit  sigSendDocIDPageNo(docid);
        }
        else
        {
            emit sigSendDocIDPageNo("");
        }
    }
    else
    {
        emit  sigSendDocIDPageNo( QString("") );
    }
}

//用户授权
void TrailBoard::setUserAuth(QString userId, QString authStatus)
{
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"control\",\"content\":{\"userId\":\"%1\",\"auth\":\"%2\"},\"domain\":\"auth\"}").arg(userId).arg(authStatus);
        m_handler->sendLocalMessage(str, true, false);
    }
}

void TrailBoard::onSigSendDocIDPageNo(QString docs)
{
    QList<QString> lista;
    lista.clear();
    QMap<QString, QList<QString> >::iterator ita =  TemporaryParameter::gestance()->m_coursewareName.begin();
    int j = -1;
    for( ; ita !=  TemporaryParameter::gestance()->m_coursewareName.end() ; ita++)
    {
        QList<QString> lists = ita.value();
        for(int i = 0; i < lists.count(); i++)
        {
            if(lists[i] == docs)
            {
                j = i + 1;
                break;
            }
        }
    }

    TemporaryParameter::gestance()->m_pageNo = j ;
    TemporaryParameter::gestance()->m_docs = docs;
    emit updateFileurlCOntent();

}

//处理结束课程
void TrailBoard::onStudentEndClass(QString usrid)
{
    //if(StudentData::gestance()->m_teacher.m_teacherId == usrid  ) {
    // if(StudentData::gestance()->m_selfStudent.m_studentType == "A") {
    //m_handler->setFirstPage(0);
    emit sigPromptInterface("65");//处理老师结束课程 为a学生
    //}
    //}
}

//解析数据发过来的信息
void TrailBoard::parseTrail(QString command)
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
                //qDebug() << "======width======" << width;
                this->drawBezier(pointFs, width * StudentData::gestance()->midHeight / this->height(), QColor("#" + color), type == "pencil" ? 1 : 2);
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

//画多边形
void TrailBoard::drawLine(const QVector<QPointF> &points, double brushWidth, QColor color, int type)
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

//本地画线
void TrailBoard::drawLocalLine()
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
    listt.clear();
    float x, y;
    for(int j = 0; j <= culist.size() - 3; j++)
    {
        for(int k = 0; k <= 10; k++)
        {
            //求出曲线上点的坐标
            x = A[k] * culist[j].x() + B[k] * culist[j + 1].x() + C[k] * culist[j + 2].x();
            y = A[k] * culist[j].y() + B[k] * culist[j + 1].y() + C[k] * culist[j + 2].y();
            listt.append(QPointF(x, y));
        }
    }

    QPainter painter;
    painter.begin(&m_tempTrail);
    if (m_operateStatus == 2)
        painter.setPen(QPen(QBrush(m_penColor), m_eraserSize, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    else
        painter.setPen(QPen(QBrush(m_penColor), m_brushSize * StudentData::gestance()->midHeight / this->height(), Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
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

//画椭圆
void TrailBoard::drawEllipse(const QRectF &rect, double brushWidth, QColor color, double angle)
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

//绘制贝塞尔曲线
void TrailBoard::drawBezier(const QVector<QPointF> &points, double size, QColor m_penColor, int type)
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
            if(j == 0)
            {
                x = x + 0.000001;
            }
            //求出曲线上点的坐标
            x = A[k] * points[j].x() + B[k] * points[j + 1].x() + C[k] * points[j + 2].x();
            y = A[k] * points[j].y() + B[k] * points[j + 1].y() + C[k] * points[j + 2].y();
            listr.append(QPointF(x, y));
        }
    }
    if(points.size() >= 3)
    {
        painter.drawPolyline(listr.data(), listr.size());

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
}

void TrailBoard::sendTrailMsg(const QVector<QPointF> &points)
{
    QJsonArray arr;
    for (int i = 0; i < points.size(); i++)
    {
        QJsonObject obj;
        double y = points.at(i).y();
        y = changeYPoinToSend(y);
        obj.insert("x", QString::number(points.at(i).x(), 'f', 6));
        obj.insert("y", QString::number(y, 'f', 6));
        arr.append(obj);
    }

    QJsonObject obj;
    obj.insert("trail", arr);
    obj.insert("width", QString::number(m_operateStatus == 1 ? m_brushSize : m_eraserSize));
    if (m_operateStatus == 1)
    {
        if (m_brushSize == 0.000977)
        {
            obj.insert("widthType", "0");
        }
        else if (m_brushSize == 0.003906)
        {
            obj.insert("widthType", "1");
        }
        else if (m_brushSize == 0.007812)
        {
            obj.insert("widthType", "2");
        }
    }
    obj.insert("color", QString(m_operateStatus == 1 ? m_penColor.name().mid(1) : "ffffff"));
    obj.insert("type", QString(m_operateStatus == 1 ? "pencil" : "eraser"));
    QJsonObject object;
    object.insert("domain", QString("draw"));
    object.insert("command", QString("trail"));
    object.insert("content", obj);
    QJsonDocument doc;
    doc.setObject(object);
    QString s(doc.toJson());
    s = s.replace("\r\n", "").replace("\n", "").replace("\r", "").replace("\t", "").replace(" ", "");
    m_handler->sendLocalMessage(s, true, false);
    bufferModel.addMsg("temp", s);
}
//设置鼠标形状
void TrailBoard::setCursorShape()
{
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

void TrailBoard::paint(QPainter *painter)
{
    painter->setRenderHint(QPainter::Antialiasing);
    QPixmap pixmap = m_tempTrail.scaled(this->width(), this->height(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation );
    painter->drawPixmap(0, 0, pixmap);
}

void TrailBoard::mousePressEvent(QMouseEvent *event)
{
    //qDebug() << "TrailBoard::mousePressEvent";// << event->pos() << this->width() << this->height();
    if (event->button() == Qt::LeftButton)
    {
        emit sigFocusTrailboard();
        if (m_operateStatus)//橡皮或者画笔
        {
            m_currentTrail.clear();
            m_currentPoint = QPointF((double)(event->pos().x()) / this->width()
                                     , (double)(event->pos().y()) / this->height());
            m_lastPoint = m_currentPoint;
            m_currentTrail.append(m_currentPoint);
        }
        else//教鞭
        {
            QPoint init = event->pos() - QPoint(5, 35); //7，35
            emit sigCursorPointer(true, init.x(), init.y() );

            double xPos = (init.x()) * 1.0  / this->width(); //-10
            double yPos = ( init.y()) * 1.0 / this->height(); //+ 12
            QString cmd = QString("0#{\"command\":\"cursor\",\"content\":{\"Y\":\"%1\",\"X\":\"%2\"},\"domain\":\"control\"}").arg(yPos).arg(xPos);
            if( m_handler != NULL )
            {
                m_handler->sendLocalMessage(cmd, false, false);
            }
            //发送教鞭命令
        }
        m_pointCount = 0;
        emit sigMousePress();
    }
}

void TrailBoard::mouseMoveEvent(QMouseEvent *event)
{
    if(event->buttons() &Qt::LeftButton)
    {
        m_pointCount++;
        if (m_operateStatus)
        {
            m_lastPoint = m_currentPoint;
            m_currentPoint = QPointF((double)(event->pos().x()) / this->width(), (double)(event->pos().y()) / this->height());
            //        qDebug()<<"m_lastPoint=="<<m_lastPoint<<"m_currentPoint=="<<m_currentPoint;
            m_currentTrail.append(m_currentPoint);
            this->drawLocalLine();
        }
        else//教鞭
        {
            QPoint init = event->pos() - QPoint(5, 35); //7，35
            emit sigCursorPointer(true, init.x(), init.y() );

            if(m_pointCount == 5 )
            {
                m_pointCount = 0;
                double xPos = (init.x()) * 1.0  / this->width();
                double yPos = ( init.y()) * 1.0 / this->height();
                QString cmd = QString("0#{\"command\":\"cursor\",\"content\":{\"Y\":\"%1\",\"X\":\"%2\"},\"domain\":\"control\"}").arg(yPos).arg(xPos);
                if( m_handler != NULL )
                {
                    m_handler->sendLocalMessage(cmd, false, false);
                }
            }
        }
    }
}

void TrailBoard::mouseReleaseEvent(QMouseEvent *event)
{
    //qDebug() << "TrailBoard::mouseReleaseEvent";
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
                sendTrailMsg(points);
            }
            // }
            m_currentTrail.clear();
        }
        emit sigMouseRelease();
    }
}

//点击栏目发送命令
void TrailBoard::selectedMenuCommand(int pageIndex, int planId, int cloumnId)
{
    //qDebug() << "TrailBoard::selectedMenuCommand" << pageIndex << planId << cloumnId;
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"column\",\"domain\":\"draw\",\"content\":{\"pageIndex\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\"}}").arg(pageIndex).arg(planId).arg(cloumnId);
        m_handler->sendLocalMessage(str, true, true);
    }
}

//点击讲义发送命令
void TrailBoard::lectureCommand(QJsonObject lectureObjecte)
{
    //qDebug() << "TrailBoard::lectureCommand";
    if(m_handler != NULL)
    {
        QString planId = lectureObjecte.value("planId").toString();
        QString planName = lectureObjecte.value("planName").toString();
        QJsonArray cloumnsArray = lectureObjecte.value("columns").toArray();//QString(QJsonDocument(cloumns).toJson());

        QJsonObject comandObj;
        comandObj.insert("command", "lessonPlan");
        comandObj.insert("domain", "draw");

        QJsonObject contentObj;
        contentObj.insert("planId", planId);
        contentObj.insert("planName", planName);
        contentObj.insert("columns", cloumnsArray);
        comandObj.insert("content", contentObj);

        QString columnsData = QString(QJsonDocument(comandObj).toJson());
        QString command = columnsData.replace("\n", "").replace(" ", "");
        m_handler->sendLocalMessage(command, true, false);
    }
}

//发送练习题命令
void TrailBoard::startExercise(QString questionId, int planId, int columnId)
{
    //qDebug() << "TrailBoard::startExercise" << questionId <<  planId << columnId;
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"question\",\"domain\":\"draw\",\"content\":{\"questionId\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\"}}").arg(questionId).arg(planId).arg(columnId);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//提交练习题命令
void TrailBoard::commitExercise(QString questionId, int planId, int columnId)
{
    //qDebug() << "TrailBoard::commitExercise" << planId << columnId;
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"questionAnswer\",\"domain\":\"draw\",\"content\":{\"questionId\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\"}}").arg(questionId).arg(planId).arg(columnId);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//传递自动转图片之后发送的讲义图片命令
void TrailBoard::autoConvertImage(int pageIndex, QString imageUrl, int imgWidth, int imgHeight, QString planId, int cloumnId, QString quetisonId)
{
    //qDebug() << "*****TrailBoard::autoConvertImage******" << quetisonId;
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"autoPicture\",\"domain\":\"draw\",\"content\":{\"pageIndex\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\",\"imageUrl\":\"%4\",\"questionId\":\"%5\",\"imgWidth\":\"%6\",\"imgHeight\":\"%7\"}}").arg(pageIndex).arg(planId).arg(cloumnId).arg(imageUrl).arg(quetisonId).arg(imgWidth).arg(imgHeight);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//老师结束练习命令
void TrailBoard::stopQuestion(QString questionId)
{
    //qDebug() << "TrailBoard::stopQuestion" << questionId;
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"stopQuestion\",\"domain\":\"draw\",\"content\":{\"questionId\":\"%1\"}}").arg(questionId);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//学生提交答案图片
void TrailBoard::commitAnswerPicture(QString imageUrl, int imgWidth, int imgHeight)
{
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"answerPicture\",\"domain\":\"draw\",\"content\":{\"questionId\":\"%1\",\"imgWidth\":\"%2\",\"imgHeight\":\"%3\"}}").arg(imageUrl).arg(imgWidth).arg(imgHeight);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//打开答案解析
void TrailBoard::openAnswerAnalysis(QString planId, int columnId, QString questionId, QString childQuestionId)
{
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"openAnswerParsing\",\"domain\":\"control\",\"content\":{\"planId\":\"%1\",\"columnId\":\"%2\",\"questionId\":\"%3\",\"childQuestionId\":\"%4\"}}").arg(planId).arg(columnId).arg(questionId).arg(childQuestionId);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//关闭答案解析
void TrailBoard::closeAnswerAnalysis(QString planId, int columnId, QString questionId)
{
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"closeAnswerParsing\",\"domain\":\"control\",\"content\":{\"planId\":\"%1\",\"columnId\":\"%2\",\"questionId\":\"%3\"}}").arg(planId).arg(columnId).arg(questionId);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//打开批改面板
void TrailBoard::openCorrect(QString planId, int columnId, QString questionId)
{
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"openCorrect\",\"domain\":\"control\",\"content\":{\"planId\":\"%1\",\"columnId\":\"%2\",\"questionId\":\"%3\"}}").arg(planId).arg(columnId).arg(questionId);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//批改命令
void TrailBoard::correctCommand(QString planId, int columnId, QString questionId, QString childQuestionId, int correctType, double score, QString errorReason, int errorTypeId)
{
    //qDebug() << "TrailBoard::correctCommand" << planId << columnId << questionId << childQuestionId << correctType << QString::number(score) << errorReason;
    if(m_handler != NULL)
    {
        QJsonObject comdObject;
        comdObject.insert("command", "correct");
        comdObject.insert("domain", "control");

        QJsonObject contentObj;
        contentObj.insert("planId", planId);
        contentObj.insert("columnId", QString::number(columnId));
        contentObj.insert("questionId", questionId);
        contentObj.insert("childQuestionId ", childQuestionId );
        contentObj.insert("correctType", QString::number(correctType));
        contentObj.insert("score", QString::number(score, 10, 1));
        contentObj.insert("errorReason", errorReason);
        contentObj.insert("errorTypeId", QString::number(errorTypeId));

        comdObject.insert("content", contentObj);

        QString comandStr =  QString(QJsonDocument(comdObject).toJson()).replace("\n", "").replace(" ", "");
        //qDebug() << "==TrailBoard::correctCommand==" << comandStr;
        //QString str = QString("{\"command\":\"correct\",\"domain\":\"control\",\"content\":{\"planId\":%1,\"columnId\":%2,\"questionId\":\"%3\",\"correctType\":%4,\"score\":%5,\"errorReason\":\"%6\",\"childQuestionId \":\"%7\",\"errorTypeId \":\"%8\"}}").arg(planId).arg(columnId).arg(questionId).arg(correctType).arg(score).arg(errorReason).arg(childQuestionId).arg(errorTypeId);
        m_handler->sendLocalMessage(comandStr, true, false);
    }
}

//关闭批改面板命令
void TrailBoard::closeModifyPanle(int planId, int columnId, QString questionId)
{
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"closeCorrect\",\"domain\":\"control\",\"content\":{\"planId\":\"%1\",\"columnId\":\"%2\",\"questionId\":\"%3\"}}").arg(planId).arg(columnId).arg(questionId); //questionId
        m_handler->sendLocalMessage(str, true, false);
    }
}

//滚动长图命令
void TrailBoard::updataScrollMap(double scrollY)
{
    double zoomRate = this->height() / this->width() / scrollRate;//算出图片高度为 设备高度的倍数
    //qDebug() << "==TrailBoard::updataScrollMap==" << scrollY << scrollRate;

    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"zoomInOut\",\"domain\":\"control\",\"content\":{\"offsetX\":\"0\",\"offsetY\":\"%1\",\"zoomRate\":\"%2\"}}").arg(scrollY).arg(1.0);
        m_handler->sendLocalMessage(str, true, false);
    }
}

//提交图片失败给学生发送命令
void TrailBoard::commitAnserFail(QString questionId, QString planId, QString columnId)
{
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"questionAnswerFailed\",\"domain\":\"draw\",\"content\":{\"questionId\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\"}}").arg(questionId).arg(planId).arg(columnId);
        m_handler->sendLocalMessage(str, true, false);
    }
}

#endif
