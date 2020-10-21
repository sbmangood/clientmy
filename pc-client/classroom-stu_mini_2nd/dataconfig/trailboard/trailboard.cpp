#include "trailboard.h"

#include <QPainter>
#include <QMouseEvent>

#include <QMutexLocker>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>
//#include "./videovoice/operationchannel.h"
#include "../../pc-common/AudioVideoSDKs/AudioVideoManager.h"
#include "debuglog.h"

double A[11] = {0.500, 0.405, 0.320, 0.245, 0.180, 0.125, 0.080, 0.045, 0.020, 0.005, 0.000};
double B[11] = {0.500, 0.590, 0.660, 0.710, 0.740, 0.750, 0.740, 0.710, 0.660, 0.590, 0.500};
double C[11] = {0.000, 0.005, 0.020, 0.045, 0.080, 0.125, 0.180, 0.245, 0.320, 0.405, 0.500};
#if 1

TrailBoard::TrailBoard(QQuickPaintedItem *parent): QQuickPaintedItem(parent)
  , m_handler(NULL)
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
    m_operateStatus = 0;
    setCursor(Qt::PointingHandCursor);
    m_brushSize = 0.000997;
    m_handler = SocketHandler::getInstance();
    connect(m_handler, SIGNAL(sigMuteChange(QString,int)), this, SIGNAL(sigMuteChange(QString,int)));
    connect(m_handler, SIGNAL(sigAuthChange(QString,int,int,int,int,bool)), this, SIGNAL(sigAuthChange(QString,int,int,int,int,bool)));
    connect(m_handler, SIGNAL(sigTrophy(QString)), this, SIGNAL(sigTrophy(QString))) ;
    connect(m_handler,SIGNAL(sigResetTimerView(QJsonObject)),this,SIGNAL(sigResetTimerView(QJsonObject)));
    connect(m_handler,SIGNAL(sigPlayAv(QJsonObject)),this,SIGNAL(sigPlayAv(QJsonObject)));
    connect(m_handler,SIGNAL(sigStartResponder(QJsonObject)),this,SIGNAL(sigStartResponder(QJsonObject)));
    connect(m_handler,SIGNAL(sigStartRandomSelectView(QJsonObject)),this,SIGNAL(sigStartRandomSelectView(QJsonObject)));

    connect(m_handler, &SocketHandler::sigDrawPage, this, &TrailBoard::drawPage);
//    connect(m_handler, &SocketHandler::sigDrawLine, this, &TrailBoard::drawRemoteLine); //sigPointerPosition
//    connect(m_handler, SIGNAL( sigPointerPosition(double, double ) ), this, SLOT( onSigPointerPosition(double, double ) ) ) ;
    connect(m_handler, SIGNAL( sigSendHttpUrl(QString ) ), this, SIGNAL( sigSendHttpUrl(QString ) ) ) ;
    connect(m_handler, SIGNAL( sigEnterOrSync(int  ) ), this, SLOT( onSigEnterOrSync(int  ) ) ) ;
    connect(m_handler, SIGNAL( sigStartClassTimeData(QString   ) ), this, SIGNAL( sigStartClassTimeData(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigUserIdCameraMicrophone(QString, QString,  QString ) ), this, SLOT(onSigUserIdCameraMicrophone(QString, QString,  QString ))) ;
    connect(m_handler, SIGNAL( sigAuthtrail(QMap<QString, QString>) ), this, SLOT( onSigAuthtrail(QMap<QString, QString> ) )) ;
    connect(m_handler, SIGNAL( sigStudentEndClass(QString   ) ), this, SLOT( onStudentEndClass(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigExitRoomIds(QString   ) ), this, SIGNAL( sigExitRoomIds(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigDroppedRoomIds(QString   ) ), this, SIGNAL( sigDroppedRoomIds(QString   ) ) ) ;
    // connect(m_handler,SIGNAL( sigPointerPosition(double ,  double ) ) , this ,SIGNAL( sigPointerPosition(double ,  double ) ) ) ;
    //connect(m_handler,SIGNAL( sigUserIdCameraMicrophone(QString  , QString  ,  QString ) ) , this ,SIGNAL( sigUserIdCameraMicrophone(QString  , QString  ,  QString ) ) ) ;
    connect(m_handler, SIGNAL( sigAvUrl( QString, QString, QString, QString  ) ), this, SIGNAL( sigVideoAudioUrl( QString, QString, QString, QString  )  ) ) ;
    connect(m_handler, SIGNAL(justNetConnect(bool)), this, SIGNAL(justNetConnect(bool)));
    connect(m_handler, SIGNAL(autoChangeIpResult(QString)), this, SIGNAL(autoChangeIpResult(QString)));


    connect(m_handler, SIGNAL(sigShowNewCourseware(QJsonValue)), this, SIGNAL(sigShowNewCourseware(QJsonValue)));
    connect(m_handler, SIGNAL(sigShowNewCoursewareItem(QJsonValue)), this, SIGNAL(sigShowNewCoursewareItem(QJsonValue)));
    connect(m_handler, SIGNAL(sigStarAnswerQuestion(QJsonValue)), this, SIGNAL(sigStarAnswerQuestion(QJsonValue)));
    connect(m_handler, SIGNAL(sigStopAnswerQuestion(QJsonValue)), this, SIGNAL(sigStopAnswerQuestion(QJsonValue)));

    connect(m_handler, SIGNAL(sigOpenAnswerParsing(QJsonValue)), this, SIGNAL(sigOpenAnswerParsing(QJsonValue)));
    connect(m_handler, SIGNAL(sigCloseAnswerParsing(QJsonValue)), this, SIGNAL(sigCloseAnswerParsing(QJsonValue)));

    connect(m_handler, SIGNAL(sigOpenCorrect(QJsonValue, bool)), this, SLOT(reNewCloudModifyPageData(QJsonValue, bool)));

    // connect(m_handler,SIGNAL(sigOpenCorrect(QJsonValue,bool)),this,SIGNAL(sigOpenCorrect(QJsonValue,bool)));
    connect(m_handler, SIGNAL(sigCloseCorrect(QJsonValue)), this, SIGNAL(sigCloseCorrect(QJsonValue)));
    connect(m_handler, SIGNAL(sigCorrect(QJsonValue)), this, SIGNAL(sigCorrect(QJsonValue)));
    connect(m_handler, SIGNAL(sigAutoPicture(QJsonValue)), this, SIGNAL(sigAutoPicture(QJsonValue)));
    connect(m_handler,SIGNAL(sigPageOpera(QString)),this,SIGNAL(sigPageOpera(QString)));
    // connect(m_handler,SIGNAL(sigZoomInOut(double,double,double)),this,SIGNAL(sigZoomInOut(double,double,double)));
    //new
    connect(m_handler, SIGNAL(sigZoomInOut(double, double, double)), this, SLOT(getOffSetImage(double, double, double)));
    connect(m_handler,SIGNAL(sigPlayAnimation(QString,int)),this,SIGNAL(sigPlayAnimation(QString,int)));
    connect(m_handler, SIGNAL(sigGetLessonListFail()), this, SIGNAL(sigGetLessonListFail()));
    connect(m_handler, SIGNAL(sigInterNetChange(int)), this, SIGNAL(sigInterNetChange(int)));
    connect(m_handler,SIGNAL(sigH5Courseware(int,QString)),this,SIGNAL(sigH5Courseware(int,QString)));
    connect(this, SIGNAL( sigSendUrl(QString, double, double ) ), this, SLOT(  onSigSendUrl(QString, double, double )   )) ;

    connect(this, SIGNAL(sigSendDocIDPageNo(QString )), this, SLOT( onSigSendDocIDPageNo(QString  ) )  );
    connect(m_handler,SIGNAL(sigSynCoursewareInfo(QJsonObject)),this,SIGNAL(sigSynCoursewareInfo(QJsonObject)));
    connect(m_handler,SIGNAL(sigClearScreen()),this,SIGNAL(sigClearScreen()));
    connect(m_handler,SIGNAL(sigTeaOnline(QString,QString,bool)),this,SIGNAL(sigTeaOnline(QString,QString,bool)));
    connect(m_handler,SIGNAL(sigClassBegin()),this,SIGNAL(sigClassBegin()));
//    m_pointerTimer = new QTimer(this);
//    connect(m_pointerTimer, SIGNAL(timeout()), this, SLOT(onPointerTimerout() )  );
    //重设当前滚动条的大小
    connect(GetOffsetImage::instance(), SIGNAL(sigCurrentImageHeight(double)), this, SIGNAL(sigCurrentImageHeight(double)));

    setRenderTarget(QQuickPaintedItem::FramebufferObject);
}

int TrailBoard::getNetworkStatus()
{
    QString netTypeStr = TemporaryParameter::gestance()->m_netWorkMode;
    int netType = 3;
    if(netTypeStr.contains(QStringLiteral("wireless")))
    {
        netType = 3;
    }
    else
    {
        netType = 4;
    }
    return netType;
}

void TrailBoard::getOffSetImage(double offsetX, double offsetY, double zoomRate)
{

    if(zoomRate > 1.0)
    {
        GetOffsetImage::instance()->getOffSetImage( offsetY / zoomRate );
        currentImagaeOffSetY = GetOffsetImage::instance()->resetOffsetY( qAbs(offsetY / zoomRate), zoomRate); //记录当前图的偏移量
    }
    else
    {
        GetOffsetImage::instance()->getOffSetImage( offsetY );
        currentImagaeOffSetY = qAbs(offsetY);
    }
     qDebug() << "===getOffSetImage======" << offsetY << -currentImagaeOffSetY;
    //获取轨迹信息
    onCtentsSizeChanged();
    sigZoomInOut(offsetX, -currentImagaeOffSetY, zoomRate);

}
//网络画当前的页面内容
void TrailBoard::drawPage(MessageModel model)
{
    bufferModel.clear();
    bufferModel = model;
    //老讲义走以前的逻辑 包含截图 上传的图片 先逻辑只有截图走这里 课件以及传图走新的课件图片等比缩放模式
    bool isClipImage = false;
    if(0 < model.width && model.width < 1)
    {
        isClipImage = true;
    }

//    if( model.currentCoursewareType == 1)
//    {
//        //只有截图走这个逻辑
//        if(isClipImage)
//        {
//            emit sigSendUrl( model.bgimg, model.width, model.height);  //背景
//        }
//    }
    emit sigSendUrl( model.bgimg, model.width, model.height);  //背景
    //新讲义 没图 走sigShowNewCoursewareItem 信号 有图走下边
    QImage tempImage;
    GetOffsetImage::instance()->currentBeBufferedImage = tempImage;
    GetOffsetImage::instance()->currrentImageHeight = 0;

    qDebug() << "TrailBoard::drawPage isCourwareisssCourware" <<model.width<<model.height
             << GetOffsetImage::instance()->currentBeBufferedImage.height() << model.zoomRate \
             << model.bgimg << model.currentCoursewareType << model.offsetY << m_handler->currentPlanId << __LINE__;

    if(model.bgimg != "" && (model.currentCoursewareType == "2" || model.currentCoursewareType == "1") &&!isClipImage )
    {
        if(model.zoomRate > 1.0)
        {
            GetOffsetImage::instance()->getOffSetImage(model.bgimg, model.offsetY / model.zoomRate);
        }
        else
        {
            GetOffsetImage::instance()->getOffSetImage(model.bgimg, model.offsetY);
        }
    }

    if(model.zoomRate > 1.0)
    {
        currentImagaeOffSetY = GetOffsetImage::instance()->resetOffsetY( qAbs(model.offsetY / model.zoomRate), model.zoomRate); //记录当前图的偏移量
    }
    else
    {
        currentImagaeOffSetY = qAbs(model.offsetY);
    }

    emit sigChangeCurrentPage(model.getCurrentPage()); //当前页
    emit sigChangeTotalPage(model.getTotalPage()); //所有页
    if(model.offsetY != 0)
    {
        sigZoomInOut(model.offsetY, model.offsetY, model.zoomRate);
    }

    //qDebug() << "TrailBoard::drawPage 11222" << model.width << model.offSetY << model.zoomRate << model.bgimg << __LINE__;
    if(model.bgimg != "" || m_handler->currentPlanId == "DEFAULT" || model.currentCoursewareType == 1  )
    {
        //qDebug() << "TrailBoard::drawPage sigHideQuestionView" << model.columnType << m_handler->currentCourwareType << __LINE__;
        bool hideColumnMenu = true;

        if( m_handler->currentCourwareType != 1 )
        {
            hideColumnMenu = false;
            emit sigUpdateCloumMenuIndex( m_handler->currentColumnId.toInt() );
            if(model.currentCoursewareType == 2)
            {
                //重设批改和答案解析的界面 以及填充数据
                emit sigUpdateCloudModifyPageView(StudentData::gestance()->m_currentQuestionData);
            }
        }
        emit sigHideQuestionView(hideColumnMenu);
    }

    m_tempTrail = QPixmap(this->width(), this->height());
    //m_tempTrail = QPixmap(boardSize);
    m_tempTrail.fill(QColor(255, 255, 255, 0));
//    foreach (Msg mess, model.getMsgs())
//    {
//        this->parseTrail(mess.msg);
//    }
    update();
    qDebug() << "TrailBoard::drawPage222211111";
}

void TrailBoard::reNewCloudModifyPageData(QJsonValue questionData, bool isVisible)
{

    emit sigUpdateCloudModifyPageView(StudentData::gestance()->m_currentQuestionData);
    sigOpenCorrect(questionData, isVisible);
}

int TrailBoard::getCurrentCourwareType()
{
    return m_handler->currentCourwareType.toInt();
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
                        qDebug() << "TrailBoard::upLoadSendUrlHttp failed." << jsonObj << __LINE__;
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
    QTimer::singleShot(5000, &httploop, SLOT(quit()));
    m_httpAccessmanger = new QNetworkAccessManager(this);
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply *)), &httploop, SLOT(quit()));
    QNetworkReply * reply = m_httpAccessmanger->get(httpRequest);
    httploop.exec();

    QFile file(m_systemPublicFilePath + tempUrl);
    file.open(QIODevice::WriteOnly);
    file.write(reply->readAll());
    file.flush();
    file.close();
    qDebug() << "file:///" + m_systemPublicFilePath + tempUrl << "dsaaaaaaaaaaaaaaa";
    return "file:///" + m_systemPublicFilePath + tempUrl;
}

//开始上课
void TrailBoard::startClassBegin()
{
    //    if(m_handler != NULL) {
    //        m_handler->clearRecord();
    //        QString str;
    //        if(TemporaryParameter::gestance()->m_supplier == "2") {
    //            str =QString("SYSTEM{\"command\":\"startClass\",\"content\":{\"videoType\":\"%1\",\"supplier\":\"%2\",\"audioName\":\"%3\"},\"domain\":\"system\"}").arg(TemporaryParameter::gestance()->m_videoType).arg(TemporaryParameter::gestance()->m_supplier).arg(StudentData::gestance()->m_audioName);
    //        }else {
    //            str =QString("SYSTEM{\"command\":\"startClass\",\"content\":{\"videoType\":\"%1\",\"supplier\":\"%2\",\"audioName\":\"shengwang\"},\"domain\":\"system\"}").arg(TemporaryParameter::gestance()->m_videoType).arg(TemporaryParameter::gestance()->m_supplier);

    //        }
    //        m_handler->sendLocalMessage(str,true,false);
    //        QString pageStr = QString("{\"domain\":\"page\",\"command\":\"goto\",\"content\":{\"page\":\""+QString::number( m_handler->m_currentPage )+"\"}}");
    //        m_handler->sendLocalMessage(pageStr,true,false);


    //    }

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
    if(enters)
    {
        QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"enterRoom\",\"content\":{\"userId\":\"%1\",\"auth\":\"1\"}}").arg( TemporaryParameter::gestance()->m_enterRoomRequest );
        m_handler->sendLocalMessage(bstr, true, false);

    }
    else
    {
        QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"enterRoom\",\"content\":{\"userId\":\"%1\",\"auth\":\"0\"}}").arg( TemporaryParameter::gestance()->m_enterRoomRequest );
        m_handler->sendLocalMessage(bstr, true, false);

    }
}
//临时退出
void TrailBoard::temporaryExitWidget()
{
    //================================
    //OperationChannel::gestance()->doExitAllChannel(); //关闭进程前, 需要是否音视频的资源, 不然下次进去, 可能有问题, 尤其是C通道
    //DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server(); //关闭进程前, 需要上传日志文件

    //================================
    if(m_handler != NULL)
    {
        m_handler->sendLocalMessage("0#SYSTEM{\"domain\":\"system\",\"command\":\"exitRoom\"}", false, false);
        m_handler->disconnectSocket(true);
        emit sigCloseAllWidgets();
    }
}
//家庭作业
void TrailBoard::sendTopicContent(QString tags, QString names, bool status)
{
    QNetworkAccessManager * httpAccessmanger = new QNetworkAccessManager(this);

    QNetworkRequest httpRequest;
    QEventLoop httploop;
    QTimer::singleShot(5000, &httploop, SLOT(quit()));
    connect(this, SIGNAL(sigEndWidget()), &httploop, SLOT(quit()));
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/lesson/finishLesson?");
    QByteArray post_data;
    QString param1 ;
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
    maps.insert("apiVersion", "3.0"); //接口标注3.0
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
        // m_handler->sendLocalMessage("0#{\"command\":\"finishClass\",\"domain\":\"control\"}",false,false);
        //m_handler->disconnectSocket(true);
        emit sigCloseAllWidgets();
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
//设置音频的播放
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

        //qDebug()<<"str  aahh=="<<str;

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
        m_handler->disconnectSocket(true);
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
    if(types == 2)
    {
        TemporaryParameter::gestance()->m_isFinishClass = true;
        m_handler->sendLocalMessage("0#{\"command\":\"finishClass\",\"domain\":\"control\"}", false, false);
        m_handler->disconnect();
    }

}

//发送结束课程请求
void TrailBoard::setSendEndLessonRequest()
{
    if(m_handler != NULL)
    {
        double version = 0;
        QString sysInfo;
        QMap<QString, QString>::iterator it;
        for (it = TemporaryParameter::gestance()->deviceVersion.begin(); it != TemporaryParameter::gestance()->deviceVersion.end(); ++it)
        {
            if(it.key() != StudentData::gestance()->m_selfStudent.m_studentId)
            {
                QString m_version = it.value();
                QStringList versionList = m_version.split(".");
                if(versionList.size() > 1)
                {
                    version = QString(versionList.at(0) + "." + versionList.at(1)).toDouble();
                }
            }
        }

        QMap<QString, QString>::iterator its;
        for(its = TemporaryParameter::gestance()->deviceSysInfo.begin(); its != TemporaryParameter::gestance()->deviceSysInfo.end(); ++its)
        {
            if(its.key() != StudentData::gestance()->m_selfStudent.m_studentId)
            {
                sysInfo = its.value();
            }
        }

        qDebug() << "==========version::data========" << version;
        QString cmd =  QString("{\"domain\":\"auth\",\"command\":\"finishReq\",\"content\":{\"userId\":\"%1\",\"auth\":\"0\"}}").arg(StudentData::gestance()->m_selfStudent.m_studentId);
        QString finishCmd = "0#{\"command\":\"finishClass\",\"domain\":\"control\"}";
        if(sysInfo.contains("Window"))
        {
            if(version <= 2.3)
            {
                //qDebug() << "===========Window::version::2.3======" << version << sysInfo;
                TemporaryParameter::gestance()->m_isFinishClass = true;
                m_handler->sendLocalMessage(finishCmd, false, false);
                emit sigPromptInterface("65");
            }
            else
            {
                //qDebug() << "******************Window::version::2.3**************"<< version << sysInfo;
                m_handler->sendLocalMessage(cmd, true, false);
            }
        }
        else
        {
            if(version <= 2.11)
            {
                //qDebug() << "===========IOS::version::2.11======"<< version << sysInfo;
                TemporaryParameter::gestance()->m_isFinishClass = true;
                m_handler->sendLocalMessage(finishCmd, false, false);
                emit sigPromptInterface("65");
            }
            else
            {
                //qDebug() << "*************IOS::version::2.11***************"<< version << sysInfo;
                m_handler->sendLocalMessage(cmd, true, false);
            }
        }
    }
}

//设发送评价
void TrailBoard::setSendTopicContent(bool status1, bool status2, bool status3, QString tags)
{
    //=====================================
    QString paramId1 = "param1";
    QString paramId2 = "param2";
    QString paramId3 = "param3";

    QString paramTitle1 = "知识掌握情况";
    QString paramTitle2 = "课堂表现";
    QString paramTitle3 = "老师评价";

    for(int i = 0; i < StudentData::gestance()->lessonCommentConfigInfo.size(); i++)
    {
        QJsonObject lessonObj = StudentData::gestance()->lessonCommentConfigInfo.at(i).toObject();
        QString paramId = lessonObj.value("paramId").toString();
        QString paramTitle = lessonObj.value("paramTitle").toString();
        if(i == 0)
        {
            paramId1 = paramId;
            paramTitle1 = paramTitle;
        }
        if(i == 1)
        {
            paramId2 = paramId;
            paramTitle2 = paramTitle;
        }
        if(i == 2)
        {
            paramId3 = paramId;
            paramTitle3 = paramTitle;
        }
    }

    //=====================================
    QNetworkRequest httpRequest;
    QEventLoop httploop;
    QTimer::singleShot(5000, &httploop, SLOT(quit()));
    m_httpAccessmanger = new QNetworkAccessManager(this);
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply *)), this, SLOT(onFinishedReply(QNetworkReply*) )  );
    connect(this, SIGNAL(sigEndWidget()), &httploop, SLOT(quit()));
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/lesson/finishLesson?");
    QByteArray post_data;
    QString param1 ;
    QString param2 ;
    QString param3 ;
    if(status1)
    {
        param1 = QStringLiteral("是");
    }
    else
    {
        param1 = QStringLiteral("否");
    }
    if(status2)
    {
        param2 = QStringLiteral("是");
    }
    else
    {
        param2 = QStringLiteral("否");
    }
    if(status3)
    {
        param3 = QStringLiteral("是");
    }
    else
    {
        param3 = QStringLiteral("否");
    }
    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("userId", StudentData::gestance()->m_selfStudent.m_studentId);
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("type", "STU");
    maps.insert("apiVersion", "3.0");
    maps.insert("appVersion", "3.0"); //StudentData::gestance()->m_appVersion 接口标注传3.0
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    maps.insert(paramId1, param1);
    maps.insert(paramId2, param2);
    maps.insert(paramId3, param3);

    maps.insert("param4", tags);
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
    QMap<QString, QString>::iterator its =  maps.begin();

    maps.insert("param4", tags.toUtf8().toPercentEncoding());
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
    post_data.append(urls);
    httpRequest.setUrl(url);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    qDebug() << QString("param1param1param1") << param1 << param2 << param3;

    httploop.exec();
    if( m_handler != NULL )
    {
        m_handler->sendLocalMessage("0#{\"command\":\"finishClass\",\"domain\":\"control\"}", false, false);
        m_handler->disconnectSocket(false);

        QProcess process;
        process.execute(QString("TASKKILL /IM %1 /F") .arg(StudentData::gestance()->strAppName));
        process.close();
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
//控制本地摄像头
void TrailBoard::setOperationVideoOrAudio(QString userId, QString videos, QString audios)
{
    QString userIds = userId;
    if(userIds == "0")
    {
        userIds = StudentData::gestance()->m_selfStudent.m_studentId;
    }
    QPair<QString, QString > pair(videos, audios);
    StudentData::gestance()->m_cameraPhone.insert(userIds, pair);
    QString sendStr = QString("0#{\"command\":\"settinginfo\",\"content\":{\"infos\":{\"camera\":\"%1\",\"networktype\":\"1\",\"microphone\":\"%2\",\"volume\":\"3\",\"ishideapp\":\"0\"},\"userId\":\"%3\"},\"domain\":\"control\"}")
            .arg(videos).arg(audios).arg(StudentData::gestance()->m_selfStudent.m_studentId);

    if(m_handler != NULL)
    {
        m_handler->sendLocalMessage(sendStr, false, false);

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

//操作权限
void TrailBoard::onSigAuthtrail(QMap<QString, QString> contents)
{

    m_userBrushPermissions.clear();
    m_userBrushPermissions = contents;
    QString str = m_userBrushPermissions.value(StudentData::gestance()->m_selfStudent.m_studentId, "");
    //qDebug()<<"sssssssssssssssssssaaaascccccc"<<str;
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
    emit sigPromptInterface("62");
    //    if(TemporaryParameter::gestance()->m_isStartClass ) {
    //        //权限改变
    //        emit sigPromptInterface("62");
    //    }


}

//增加某一页
void TrailBoard::addPage()
{
    m_handler->addPage();
}

void TrailBoard::deletePage()
{
    m_handler->deletePage();
}

void TrailBoard::goPage(int pageIndex)
{
    //    if(!m_isloadImage) {
    //        m_handler->goPage(pageIndex);
    //    }
    m_handler->goPage(pageIndex);
}

//界面尺寸变化
void TrailBoard::onCtentsSizeChanged()
{
    qDebug() << "========TrailBoard::onCtentsSizeChanged==" << this->scale() << this->width() << this->height();
    //m_tempTrail = QPixmap(this->width(),this->height());
    //    if(m_tempTrail.size().width() > 0) {

    //        m_tempTrail = m_tempTrail.scaled(this->width() ,this->height() );

    //    }else {
    //        m_tempTrail =  QPixmap(this->width() ,this->height() );
    //        m_tempTrail.fill(QColor(255,255,255,0));
    //    }
    m_tempTrail = QPixmap(this->width(), this->height());
    //m_tempTrail = QPixmap(boardSize);
    m_tempTrail = m_tempTrail.scaled(this->width(), this->height() );
    m_tempTrail.fill(QColor(255, 255, 255, 0));
//    foreach (Msg mess, bufferModel.getMsgs())
//    {
//        this->parseTrail(mess.msg);
//    }
    update();

    GetOffsetImage::instance()->currentTrailBoardHeight = this->height();
}

//同步信息
void TrailBoard::onSigEnterOrSync(int sync)
{
    qDebug() << "onSigEnterOrSync(int sync)" << sync;
    if(sync == 201)//同步完成进入教室打开摄像头
    {
        emit sigPromptInterface("opencarm");
    }
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
        if(TemporaryParameter::gestance()->m_isAlreadyClass && StudentData::gestance()->m_selfStudent.m_studentType == "A")
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

    //退线掉线处理 退出进入状态判断
    if(sync == 4)
    {
        emit sigPromptInterface("51");
    }

    //    if(sync == 3) {
    //        if(TemporaryParameter::gestance()->m_isAlreadyClass ) {
    //            emit sigPromptInterface("4");
    //        }else {
    //            emit sigPromptInterface("5");
    //        }

    //    }
    //为b学生的进入房间
    if(sync == 6)
    {
        QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"enterRoomRequest\",\"content\":{\"userId\":\"%1\",\"auth\":\"1\"}}").arg( StudentData::gestance()->m_selfStudent.m_studentId );
        m_handler->sendLocalMessage(bstr, true, false);
        emit sigPromptInterface("6");
        return;
    }

    if(sync == 8)
    {
        emit sigPromptInterface("8");

    }
    if(sync == 9)
    {
        emit sigPromptInterface("9");
    }

    if(sync == 10)
    {
        emit sigPromptInterface("10");
    }

    if(sync == 11)
    {
        emit sigPromptInterface("11");
    }
    if(sync == 12)
    {
        emit sigPromptInterface("12");
    }
    if(sync == 13)
    {
        emit sigPromptInterface("13");
    }
    if(sync == 52)
    {
        emit sigPromptInterface("52");
    }
    //申请结束课程
    if(sync == 56)
    {
        emit sigPromptInterface("56");
        return;
    }
    //改变频道跟音频
    if(sync == 61)
    {
        emit sigPromptInterface("61");
    }
    //改变频道跟音频 通信状态
    if(sync == 68)
    {
        emit sigPromptInterface("68");
    }

    //申请离开教室的返回
    if(sync == 63 || sync == 64)
    {
        emit sigPromptInterface(QString("%1").arg(sync));

    }
    //申请进路教室的返回 b
    if(sync == 66 || sync == 67)
    {
        emit sigPromptInterface(QString("%1").arg(sync));

    }
    //申请翻页
    if(sync == 70 || sync == 71 || sync == 72)
    {
        emit sigPromptInterface(QString("%1").arg(sync));
    }
    //账号在其他地方登录
    if(sync == 80)
    {
        qDebug() << QStringLiteral("账号在其他地方登录 被迫下线80");
        emit sigPromptInterface("80");
    }

}
//关闭摄像头操作
void TrailBoard::onSigUserIdCameraMicrophone(QString usrid, QString camera, QString microphone)
{
    QString names;
    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
    {
        if(StudentData::gestance()->m_student[i].m_studentId == usrid )
        {
            if(camera != "1")
            {
                if(StudentData::gestance()->m_student[i].m_camera != camera )
                {
                    TemporaryParameter::gestance()->m_cameraNames = names;
                    // m_popupMessageNew->setContentLabel(names + QStringLiteral("学生已关闭本地的摄像头"));
                    emit sigPromptInterface("14");
                }

            }
            else
            {

            }
            StudentData::gestance()->m_student[i].m_camera = camera;

            if(microphone != "1")
            {
                if(StudentData::gestance()->m_student[i].m_microphone != microphone )
                {
                    TemporaryParameter::gestance()->m_cameraNames = names;
                    // m_popupMessageNew->setContentLabel(names + QStringLiteral("学生已关闭本地的话筒"));
                    emit sigPromptInterface("15");
                }


            }
            else
            {

            }
            StudentData::gestance()->m_student[i].m_microphone = microphone;
        }
    }

    emit sigUserIdCameraMicrophone(usrid, camera,  microphone );
}

void TrailBoard::onHttpFinished()
{
    emit sigEndWidget();
}

void TrailBoard::onSigSendUrl(QString urls, double width, double height)
{
    urls = urls.replace("https", "http");
    QString urlsh = urls;
    if(urlsh.contains("docId"))
    {
        QStringList list1 = urlsh.split("?");
        QString userid;
        QString docid;
        for(int i = 0 ; i < list1.count() ; i++)
        {
            if(i == 1)
            {
                QString list2 = list1[i];
                QStringList list3 = list2.split("&");
                for(int j = 0 ; j < list3.count() ; j++)
                {
                    QString strs = list3[j];
                    if(strs.contains("userId="))
                    {
                        userid = strs.replace("userId=", "");
                    }
                    if(strs.contains("docId="))
                    {
                        docid = strs.replace("docId=", "");

                    }
                }
            }
        }
        emit  sigSendDocIDPageNo( docid );
    }
    else
    {
        emit  sigSendDocIDPageNo( QString("") );
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
//上传评价成功
void TrailBoard::onFinishedReply(QNetworkReply *reply)
{
    qDebug() << "railBoard::onFinishedReply" << QString::fromUtf8( reply->readAll());
    emit sigEndWidget();
}
//处理结束课程
void TrailBoard::onStudentEndClass(QString usrid)
{
    if(StudentData::gestance()->m_teacher.m_teacherId == usrid  )
    {
        if(StudentData::gestance()->m_selfStudent.m_studentType == "A")
        {
            m_handler->setFirstPage(0);
            emit sigPromptInterface("65");//处理老师结束课程 为a学生
        }
    }
}

//不用了
bool TrailBoard::currentPointShouldShow(double pointY)
{
    double minY = currentImagaeOffSetY * this->height() / GetOffsetImage::instance()->currentBeBufferedImage.height();
    double maxY = (currentImagaeOffSetY + 1) * this->height()  / GetOffsetImage::instance()->currentBeBufferedImage.height();
    qDebug() << "TrailBoard::currentPointShouldShow" << minY << maxY;
    if(pointY >= minY && pointY <= maxY)
    {
        return true;
    }
    return false;
}

double TrailBoard::changeYPoinToLocal(double pointY)
{

    double tempHeight = GetOffsetImage::instance()->currrentImageHeight > this->height() ? GetOffsetImage::instance()->currrentImageHeight : this->height();

    //qDebug()<<"changeYPoinToLocal"<<currentImagaeOffSetY<<tempHeight<<GetOffsetImage::instance()->currrentImageHeight<<this->height();
    pointY = ((pointY * tempHeight) - (currentImagaeOffSetY * this->height())) / this->height();

    return pointY;
}
double TrailBoard::changeYPoinToSend(double pointY)
{
    //qDebug() << "changeYPoinToSend" << pointY << currentImagaeOffSetY  << StudentData::gestance()->midWidth << StudentData::gestance()->midHeight<<  GetOffsetImage::instance()->currrentImageHeight << this->height();

    double tempHeight = GetOffsetImage::instance()->currrentImageHeight > this->height() ? GetOffsetImage::instance()->currrentImageHeight : this->height();
    pointY = (pointY + currentImagaeOffSetY) * this->height() / tempHeight;
    //qDebug() << "********TrailBoard::changeYPoinToLocal::new**********" << pointY;
    return pointY;
}

void TrailBoard::sendTrailMsg(const QVector<QPointF> &points)
{
    qint32 factorVal = 0; int  factor = 1000000; double y = 0;
    QJsonArray arr;
    for (int i = 0; i < points.size(); ++i)
    {
        y = points.at(i).y();
        y = changeYPoinToSend(y);

        factorVal = qint32(points.at(i).x() * factor);
        arr.append(factorVal);

        factorVal = qint32(y * factor);
        arr.append(factorVal);
    }

    QJsonObject obj;
    obj.insert("pts", arr);

    //画笔宽度
    factorVal = qint32(m_operateStatus == 1 ? (m_brushSize * factor) : (m_eraserSize * factor));
    obj.insert("width", factorVal);

    //颜色
    obj.insert("color", QString(m_operateStatus == 1 ? m_penColor.name().mid(1) : "ffffff"));

    //类型(1:画笔 0:橡皮)
    obj.insert("type",  (m_operateStatus == 1 ? 1 : 0));

    QString s(m_handler->trailReqMsgTemplate(obj));
    s = s.replace("\r\n", "").replace("\n", "").replace("\r", "").replace("\t", "").replace(" ", "");

    m_handler->sendLocalMessage(s, true, false);
    bufferModel.addMsg("temp", s);
}

void TrailBoard::paint(QPainter *painter)
{
    painter->setRenderHint(QPainter::Antialiasing);
    QPixmap pixmap = m_tempTrail.scaled(this->width(), this->height(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation );
    painter->drawPixmap(0, 0, pixmap);
}

void TrailBoard::mousePressEvent(QMouseEvent *event)
{

}

void TrailBoard::mouseMoveEvent(QMouseEvent *event)
{

}

void TrailBoard::mouseReleaseEvent(QMouseEvent *event)
{

}

void TrailBoard::mouseDoubleClickEvent(QMouseEvent *event)
{
    qDebug() << "TrailBoard::mouseDoubleClickEvent(";
}


void TrailBoard::sendStudentAnswerToTeacher(QJsonObject questionInfo)
{
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"questionAnswer\",\"domain\":\"draw\",\"content\":{\"questionId\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\"}}").arg(questionInfo.value("questionId").toString()).arg(questionInfo.value("planId").toString()).arg(questionInfo.value("columnId").toString());
        m_handler->sendLocalMessage(str, true, false);
    }
}

void TrailBoard::sendOpenAnswerParse(QString planId, QString columnId, QString questionId, QString childQuestionId, bool isOpen)
{
    if(m_handler != NULL)
    {
        if(isOpen)
        {
            QString str = QString("{\"command\":\"openAnswerParsing\",\"domain\":\"control\",\"content\":{\"questionId\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\",\"childQuestionId\":\"%4\"}}").arg(questionId).arg(planId).arg(columnId).arg(childQuestionId);
            m_handler->sendLocalMessage(str, true, false);
        }
        else
        {
            QString str = QString("{\"command\":\"closeAnswerParsing\",\"domain\":\"control\",\"content\":{\"questionId\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\",\"childQuestionId\":\"%4\"}}").arg(questionId).arg(planId).arg(columnId).arg(childQuestionId);
            m_handler->sendLocalMessage(str, true, false);
        }
    }
}

void TrailBoard::sendOpenCorrect(QString planId, QString columnId, QString questionId, QString childQuestionId, bool isOpen)
{
    if(m_handler != NULL)
    {
        if(isOpen)
        {
            QString str = QString("{\"command\":\"openCorrect\",\"domain\":\"control\",\"content\":{\"questionId\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\"}}").arg(questionId).arg(planId).arg(columnId);
            m_handler->sendLocalMessage(str, true, false);
        }
        else
        {
            QString str = QString("{\"command\":\"closeCorrect\",\"domain\":\"control\",\"content\":{\"questionId\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\"}}").arg(questionId).arg(planId).arg(columnId);
            m_handler->sendLocalMessage(str, true, false);
        }
    }
}

//点击栏目发送命令
void TrailBoard::selectedMenuCommand(int pageIndex, int planId, int cloumnId)
{
    qDebug() << "TrailBoard::selectedMenuCommand" << pageIndex << planId << cloumnId;
    if(m_handler != NULL)
    {
        QString str = QString("{\"command\":\"column\",\"domain\":\"draw\",\"content\":{\"pageIndex\":\"%1\",\"planId\":\"%2\",\"columnId\":\"%3\"}}").arg(QString::number(pageIndex)).arg(QString::number(planId)).arg(QString::number(cloumnId));
        m_handler->sendLocalMessage(str, true, true);
    }
}

//滚动长图命令
void TrailBoard::updataScrollMap(double scrollY)
{
    //double zoomRate = this->height() / this->width() / scrollRate;//算出图片高度为 设备高度的倍数
    qDebug() << "==TrailBoard::updataScrollMap==" << scrollY << scrollRate;
    double zoomRate = 1.0;
    if(m_handler != NULL)
    {
        //new
        // QString str = QString("{\"command\":\"zoomInOut\",\"domain\":\"control\",\"content\":{\"offsetX\":\"0\",\"offsetY\":\"%1\",\"zoomRate\":\"%2\"}}").arg(QString::number( -scrollY / this->height() )).arg(QString::number(zoomRate));
        QString str = QString("{\"command\":\"zoomInOut\",\"domain\":\"control\",\"content\":{\"offsetX\":\"0\",\"offsetY\":\"%1\",\"zoomRate\":\"%2\"}}").arg(QString::number( -scrollY  )).arg(QString::number(zoomRate));
        m_handler->sendLocalMessage(str, true, false);
    }
}




void TrailBoard::getUnsatisfactoryOptions()
{
    QNetworkRequest m_request;
    m_httpAccessmanger = new QNetworkAccessManager(this);
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply *)), this, SLOT(onGetUnsatisfactoryOptionsFinished(QNetworkReply*) )  );

    QMap<QString, QString> maps;
    maps.insert("lessonId", StudentData::gestance()->m_lessonId); //
    maps.insert("token", StudentData::gestance()->m_token);
    //maps.insert("timestamp",times.toString("yyyyMMddhhmmss"));
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
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toLatin1(), QCryptographicHash::Md5).toHex().toUpper());
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/reduceLesson/getUnsatisfactoryOptions?");
    QByteArray post_data;//上传的数据可以是QByteArray或者file类型
    QString str = urls;

    post_data.append(str);

    m_request.setHeader(QNetworkRequest::ContentLengthHeader, post_data.length());
    m_request.setUrl(url);
    m_httpAccessmanger->post(m_request, post_data); //通过发送数据，返回值保存在reply指针里.

}

void TrailBoard::onGetUnsatisfactoryOptionsFinished(QNetworkReply *reply)
{
    qDebug() << "onGetUnsatisfactoryOptionsFinished" << reply->error();
    if(reply->error() == QNetworkReply::NoError)
    {

        QByteArray bytes = reply->readAll();
        QString result(bytes);  //转化为字符串
        // QJsonObject obj = QJsonDocument::fromJson(bytes).object();
        emit sigGetUnsatisfactoryOptions(QJsonDocument::fromJson(bytes).object());

    }
}
void TrailBoard::setSaveStuEvaluationContents(int stuSatisfiedFlag, QString optionId, QString otherReason)
{
    QNetworkRequest httpRequest;
    QEventLoop httploop;
    QTimer::singleShot(5000, &httploop, SLOT(quit()));
    m_httpAccessmanger = new QNetworkAccessManager(this);
    //  connect(m_httpAccessmanger ,SIGNAL(finished(QNetworkReply *)) ,this ,SLOT(onFinishedReply(QNetworkReply*) )  );
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/reduceLesson/saveStuEvaluation?");
    QByteArray post_data;
    QMap<QString, QString> maps;
    maps.insert("lessonId", StudentData::gestance()->m_lessonId); //
    maps.insert("token", StudentData::gestance()->m_token); //
    maps.insert("stuSatisfiedFlag", QString::number(stuSatisfiedFlag));
    maps.insert("otherReason", otherReason);
    maps.insert("optionId", optionId);
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
    QMap<QString, QString>::iterator its =  maps.begin();

    //  maps.insert("param4",tags.toUtf8().toPercentEncoding());
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
    post_data.append(urls);
    httpRequest.setUrl(url);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QNetworkReply *reply = m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    httploop.exec();
    QString replyData = reply->readAll();
    if(reply->error() == QNetworkReply::NoError)
    {

        if(replyData.contains("success\":true"))
        {
            if( m_handler != NULL )
            {
                m_handler->sendLocalMessage("0#{\"command\":\"finishClass\",\"domain\":\"control\"}", false, false);
                m_handler->disconnectSocket(false);

                QProcess process;
                process.execute(QString("TASKKILL /IM %1 /F") .arg(StudentData::gestance()->strAppName));
                process.close();
            }
        }
        else
        {
            qDebug() << "TrailBoard::setSaveStuEvaluationContents" << replyData << __LINE__;
        }
    }

}

bool TrailBoard::checkReduceLesson()
{
    QNetworkRequest httpRequest;
    QEventLoop httploop;
    QTimer::singleShot(5000, &httploop, SLOT(quit()));
    m_httpAccessmanger = new QNetworkAccessManager(this);
    //  connect(m_httpAccessmanger ,SIGNAL(finished(QNetworkReply *)) ,this ,SLOT(onFinishedReply(QNetworkReply*) )  );
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/reduceLesson/checkReduceLesson?");
    QByteArray post_data;
    QMap<QString, QString> maps;
    // maps.insert("lessonId",StudentData::gestance()->m_lessonId);//
    maps.insert("token", StudentData::gestance()->m_token); //StudentData::gestance()->m_token);//
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
    QMap<QString, QString>::iterator its =  maps.begin();

    //  maps.insert("param4",tags.toUtf8().toPercentEncoding());
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
    post_data.append(urls);
    httpRequest.setUrl(url);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QNetworkReply *reply = m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    httploop.exec();
    QString replyData = reply->readAll();

    qDebug() << "checkReduceLesson Data :" << replyData;

    if(reply->error() == QNetworkReply::NoError && replyData.contains("data\":\"1"))
    {
        return true;
    }
    return false;
}

void TrailBoard::creatRoomFail()
{
    QString msg = QString(QStringLiteral("{\"command\":\"changeAudioResponse\",\"domain\":\"control\",\"content\":{\"supplier\":\"%1\",\"audioName\":\"%2\",\"videoType\":\"%3\",\"responseStatus\":\"0\",\"message\":\"\"}}")).arg(TemporaryParameter::gestance()->m_supplier).arg(TemporaryParameter::gestance()->m_supplier == "1" ? QStringLiteral("agora") : QStringLiteral("tecent")).arg(TemporaryParameter::gestance()->m_videoType);
    m_handler->sendLocalMessage(msg, true, false);
    qDebug() << msg << "TrailBoard::creatRoomFail";
}

#ifdef USE_OSS_AUTHENTICATION
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

    qDebug() << "==TrailBoard::getOssSignUrl==" << isKey << buffer_second << current_second << key;

    if(current_second - buffer_second >= 1800 || isKey == false)//如果该key存在则判断是否过期
    {
        QVariantMap  reqParm;
        reqParm.insert("key", key);
        reqParm.insert("expiredTime", 1800 * 1000);
        reqParm.insert("token", YMUserBaseInformation::token);

        QString signSort = YMEncryption::signMapSort(reqParm);
        QString sign = YMEncryption::md5(signSort).toUpper();
        reqParm.insert("sign", sign);

        QString httpUrl = StudentData::gestance()->apiUrl;
        QString url = "https://" + httpUrl + "/api/oss/make/sign";
        QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
        QJsonObject allDataObj = QJsonDocument::fromJson(dataArray).object();

        //qDebug() << "======TrailBoard::getOssSignUrl::pram====" << reqParm;
        //qDebug() << "======TrailBoard::getOssSignUrl::key====" << key;
        //qDebug() << "======TrailBoard::getOssSignUrl::url====" << url;
        //qDebug() << "***********allDataObj********" << dataArray.length() << allDataObj;

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
            qDebug() << "TrailBoard::getOssSignUrl" << allDataObj << __LINE__;
        }
    }
    emit sigOssSignUrl(ImgUrl);
}

//修改老课件验签状态
void TrailBoard::updateOssSignStatus(bool status)
{
    StudentData::gestance()->coursewareSignOff = status;
}
#endif // #ifdef USE_OSS_AUTHENTICATION
#endif


void TrailBoard::sendResponderMsg(int types, QString userName)
{
    if(NULL != m_handler)
    {
        QString message = m_handler->responderMsgTemplate(types,0,userName);
        m_handler->sendLocalMessage(message, true, false);
    }
}
