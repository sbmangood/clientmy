#include "trailboard.h"
#include <QPainter>
#include <QMouseEvent>
#include <QMutexLocker>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>
#include <debuglog.h>
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"
#include "getoffsetimage.h"

#if 1

TrailBoard::TrailBoard(QObject *parent): QObject(parent)
    , m_handler(NULL)
#ifdef USE_OSS_AUTHENTICATION
    , bufferModel(0, "", 1.0, 1.0, "", "0", 0, false, 0)
#else
    , bufferModel(0, "", 1.0, 1.0, "", "0", 0, false)
#endif
    , currentImagaeOffSetY(0.0)
{
    m_httpClient = YMHttpClient::defaultInstance();
    m_httpUrl = m_httpClient->getRunUrl(1);
    m_handler = SocketHandler::getInstance();

    connect(m_handler, &SocketHandler::sigDrawPage, this, &TrailBoard::drawPage);
    connect(m_handler, SIGNAL( sigSendHttpUrl(QString ) ), this, SIGNAL( sigSendHttpUrl(QString ) ) ) ;
    connect(m_handler, SIGNAL( sigEnterOrSync(int  ) ), this, SLOT( onSigEnterOrSync(int  ) ) ) ;
    connect(m_handler, SIGNAL( sigStartClassTimeData(QString   ) ), this, SLOT(slotsStartClass(QString)));// SIGNAL( sigStartClassTimeData(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigSendUserId(QString )), this, SIGNAL(sigSendUserId(QString)));
    connect(m_handler, SIGNAL( sigUserIdCameraMicrophone(QString, QString,  QString ) ), this, SLOT(onSigUserIdCameraMicrophone(QString, QString,  QString ))) ;
    connect(m_handler, SIGNAL( sigAuthtrail(QMap<QString, QString>) ), this, SLOT( onSigAuthtrail(QMap<QString, QString> ) )) ;
    connect(m_handler, SIGNAL( sigExitRoomIds(QString   ) ), this, SIGNAL( sigExitRoomIds(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigDroppedRoomIds(QString   ) ), this, SIGNAL( sigDroppedRoomIds(QString   ) ) ) ;
    connect(m_handler, SIGNAL( sigAvUrl(int,int,QString) ), this, SIGNAL( sigVideoAudioUrl(int,int,QString) ) ) ;
    connect(m_handler, SIGNAL( sigNetworkOnline(bool)), this, SIGNAL(sigNetworkOnline(bool)));
    connect(m_handler, SIGNAL( sigChangedWay(QString)), this, SLOT(changedWay(QString)));
    connect(m_handler, SIGNAL( autoChangeIpResult(QString)), this, SIGNAL(autoChangeIpResult(QString)));
    connect(m_handler, SIGNAL(sigAutoConnectionNetwork()), this, SIGNAL(sigAutoConnectionNetwork()));
    connect(m_handler, SIGNAL(sigCurrentLessonTimer(int)), this, SIGNAL(sigCurrentLessonTimer(int)));
    connect(m_handler, SIGNAL(sigOffsetY(double)), this, SIGNAL(sigOffsetY(double)));
    connect(m_handler, SIGNAL(sigOneStartClass()), this, SIGNAL(sigOneStartClass()));
    connect(m_handler, SIGNAL(sigStudentAppversion(bool)), this, SIGNAL(sigStudentAppversion(bool)));
    connect(m_handler, SIGNAL(sigZoomInOut(double, double, double)), this, SLOT(getOffSetImage(double, double, double)));
    connect(m_handler, SIGNAL(sigInterNetChange(int)), this, SIGNAL(sigInterNetChange(int)));
    connect(m_handler, SIGNAL(sigJoinClassroom(QString)),this,SIGNAL(sigJoinClassroom(QString)));
    connect(m_handler,SIGNAL(sigIsCourseWare(bool)),this,SIGNAL(sigIsCourseWare(bool)));
    connect(m_handler,SIGNAL(sigSynCoursewareType(int,QString)),this,SIGNAL(sigSynCoursewareType(int,QString)));
    connect(this, SIGNAL(sigSendUrl(QString,double,double,bool,QString)), this, SLOT(onSigSendUrl(QString, double, double )   )) ;
    connect(this, SIGNAL(sigSendDocIDPageNo(QString )), this, SLOT( onSigSendDocIDPageNo(QString  ) )  );
    connect(GetOffsetImage::instance(), SIGNAL(sigCurrentImageHeight(double)), this, SIGNAL(sigCurrentImageHeight(double)));
    connect(m_handler,SIGNAL(sigSynCoursewareInfo(QJsonObject)),this,SIGNAL(sigSynCoursewareInfo(QJsonObject)));

    //小班课新增信号
    connect(m_handler,SIGNAL(sigUserAuth(QString,int,int,int,int,bool)),this,SIGNAL(sigUserAuth(QString,int,int,int,int,bool)));
    connect(m_handler,SIGNAL(sigStartResponder(QJsonObject)),this,SIGNAL(sigStartResponder(QJsonObject)));
    connect(m_handler,SIGNAL(sigIsOnline(int,QString)),this,SIGNAL(sigIsOnline(int,QString)));
    connect(m_handler,SIGNAL(sigSynCoursewareStep(QString,int)),this,SIGNAL(sigSynCoursewareStep(QString,int)));
    connect(m_handler,SIGNAL(sigClearScreen()),this,SIGNAL(sigClearScreen()));
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

void TrailBoard::slotsStartClass(QString startTimer)
{
    emit sigStartClassTimeData(startTimer);
    if(m_handler->m_isGotoPageRequst)
    {
        emit sigPromptInterface("8");
        m_handler->m_isGotoPageRequst = false;
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
    qDebug() << "===TrailBoard::setCourseware===" << message;
    if(m_handler != NULL)
    {
        QJsonObject dataObj = QJsonDocument::fromJson(message.toLocal8Bit().data()).object();
        QJsonObject contentObj = dataObj.value("content").toObject();
        QJsonArray urlArray = contentObj.value("urls").toArray();
        if(urlArray.size() == 0)
        {
            qDebug() << "=====url::null======" << urlArray;
            emit sigGetCoursewareFaill();
            return;
        }
        m_handler->sendLocalMessage(message, true, true);
    }
    // qDebug() << "TrailBoard::setCourseware" << message;
}

void TrailBoard::setCurrentImageHeight(int height)
{
    m_currentImageHeight = height;
    GetOffsetImage::instance()->currrentImageHeight = height;
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
    //onCtentsSizeChanged();
}

//网络画当前的页面内容
void TrailBoard::drawPage(MessageModel model)
{
    emit sigOffsetY(model.offsetY);
    bool isLongImg = (model.questionId == "") ? false :  (model.bgimg == ""  ? false : true);
    emit sigSendUrl(model.bgimg, model.width, model.height, isLongImg, model.questionId);
    qDebug() << "==TrailBoard::drawPage::new==" << currentImagaeOffSetY
             << model.height
             << model.questionId
             << model.offsetY
             << model.bgimg;
    //qDebug() << "=======TrailBoard::drawPage========" <<  model.bgimg << isLongImg  << model.width << model.height << "question:" + model.questionId;

    emit sigChangeCurrentPage(model.getCurrentPage());
    emit sigChangeTotalPage(model.getTotalPage());
}


int TrailBoard::getCursorPage(QString docId)
{
    if(m_handler != NULL)
    {
        return m_handler->getCurrentPage(docId);
    }
    return 1;
}

//开始上课
void TrailBoard::startClassBegin()
{
    if(m_handler != NULL)
    {
        QString msg = m_handler->startClassMsgTemplate();
        m_handler->sendLocalMessage(msg,true,false);
    }
}


void TrailBoard::disconnectSocket(bool autoReconnect)
{
    if(m_handler != NULL)
    {
        m_handler->disconnectSocket(autoReconnect);
    }
}

//退出教室
void TrailBoard::temporaryExitWidget()
{
    qDebug() << "TrailBoard::temporaryExitWidget()" << __LINE__;

    //================================
    //OperationChannel::gestance()->doExitAllChannel(); //关闭进程前, 需要是否音视频的资源, 不然下次进去, 可能有问题, 尤其是C通道
    //DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server(); //关闭进程前, 需要上传日志文件

    //================================
    if( m_handler != NULL )
    {
        QString message = m_handler->exitRoomReqMsgTemplate();
        m_handler->sendLocalMessage(message, true, false);
    }
}

//结束课程
void TrailBoard::finishClassRoom()
{
    if( m_handler != NULL )
    {
        TemporaryParameter::gestance()->m_isFinishLesson = true;
        QString message = m_handler->finishMsgTemplate();
        m_handler->sendLocalMessage(message, true, false);
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

void TrailBoard::disconnectSocket()
{
    if( m_handler != NULL )
    {
        m_handler->sendLocalMessage("0#SYSTEM{\"domain\":\"system\",\"command\":\"exitRoom\"}", false, false);
        m_handler->disconnectSocket(false);
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
    TemporaryParameter::gestance()-> m_tempSupplier = TemporaryParameter::gestance()->m_supplier;
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

//同步信息
void TrailBoard::onSigEnterOrSync(int sync)
{
    qDebug() << "===onSigEnterOrSync===" << sync;
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
    if(sync == 201)//同步完成进入教室打开摄像头
    {
        emit sigPromptInterface("opencarm");
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

void TrailBoard::sendH5PlayAnimation(int step)
{
    if(m_handler != NULL)
    {
        QString message = m_handler->playAnimationMsgTemplate(step);
        qDebug() << "==sendH5PlayAnimation==" << message;
        m_handler->sendLocalMessage(message,false,false);
    }
}

//用户授权
void TrailBoard::setUserAuth(QString userId, int up, int trail,int audio,int video)
{
    if(m_handler != NULL)
    {
        qDebug() << "==setUserAuth::userId==" << userId << up << trail << audio << video;
        QString message = m_handler->authReqMsgTemplate(userId, up, trail, audio, video);
        qDebug() << "===TrailBoard::setUserAuth===" << message;
        TemporaryParameter::gestance()->m_userBrushPermissionsId.insert(userId, QString::number(trail));
        m_handler->sendLocalMessage(message, true, false);
    }
}

//全体禁音、恢复
void TrailBoard::allMute(int muteStatus)
{
    if(m_handler != NULL)
    {
        QString message = m_handler->muteAllReqMsgTemplate(muteStatus);
        qDebug() << "===TrailBoard::setUserAuth===" << message;
        m_handler->sendLocalMessage(message, true, false);
    }
}

//1翻页 2加页 3减页
void TrailBoard::miniClassGoPage(int type,int pageNo,int totalNumber)
{
    if(m_handler != NULL)
    {
        qDebug() << "====miniClassGoPage====" << type << pageNo << totalNumber;

        QString coursewareId = "";
        if(m_handler->m_currentCourse == "DEFAULT")
        {
            coursewareId = "000000";
        }
        else
        {
            coursewareId = m_handler->m_currentCourse;
        }

        QString msg = m_handler->pageReqMsgTemplate(type, pageNo, totalNumber, coursewareId);
        m_handler->sendLocalMessage(msg, true, true);
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

//滚动长图命令
void TrailBoard::updataScrollMap(double scrollY)
{
    if(m_handler != NULL)
    {

        QString coursewareId = "";
        if(m_handler->m_currentCourse == "DEFAULT")
        {
            coursewareId = "000000";
        }
        else
        {
            coursewareId = m_handler->m_currentCourse;
        }
        QString message = m_handler->zoomMsgTemplate(coursewareId,0.0,0.0,scrollY);      
        m_handler->sendLocalMessage(message, true, false);
    }
}

//课件加载失败(目前: 失败的时候, 才会报)
void TrailBoard::uploadLoadingImgFailLog(QString data)
{
    if(m_handler != NULL)
    {
        QJsonObject dataObj = QJsonDocument::fromJson(data.toLocal8Bit().data()).object();
        qDebug() << "==TrailBoard::uploadLoadingImgFailLog==" << data << dataObj;
        m_handler->sendLocalMessage(QString("0#SYSTEM") + data, false, false);
    }
}


void TrailBoard::insertCourseWare(QJsonArray imgUrlList, QString fileId,QString h5Url,int coursewareType)
{
    //云盘显示课件测试
    qDebug() << "==insertCourseWare==" << imgUrlList.size();

    if(m_handler != NULL && imgUrlList.size() > 0)
    {
        m_handler->cacheDocInfo(imgUrlList, fileId,coursewareType);

        int currPageNo = m_handler->getCurrentPage(fileId);
        int pageTotal = imgUrlList.size();
        QString coursewareId = fileId;
        QString message = m_handler->docReqMsgTemplate(currPageNo, pageTotal, coursewareId,imgUrlList,h5Url,coursewareType);
        qDebug() << "===insertCourseWare::message===" << message;
        m_handler->sendLocalMessage(message, true, true);
    }
}

void TrailBoard::sendRandomSelectMsg(QString userId, int type, QString userName)
{
    qDebug()<<"TrailBoard::sendRandomSelectMsg"<<userId<<type;
    if(NULL != m_handler)
    {
        QString message = m_handler->rollMsgTemplate(userId,type,userName);
        m_handler->sendLocalMessage(message, true, false);
    }
}


void TrailBoard::sendResponderMsg(int runTimes, int types)
{
    if(NULL != m_handler)
    {
        QString message = m_handler->responderMsgTemplate(types,runTimes);
        m_handler->sendLocalMessage(message, true, false);
    }
}

//给学生发送音频、视频播放命令
void TrailBoard::setVideoStream(QString types, QString staues, QString times, QString address,QString fileId,QString suffix)
{
    int status = 0;
    if(staues.contains("pause"))
    {
        status = 1;
    }else if(staues.contains("stop"))
    {
        status = 2;
    }
    qDebug()<<"TrailBoard::setVideoStream"<<types<<staues<<times.toInt()<<address<<fileId;
    if( m_handler != NULL )
    {
        QString message = m_handler->avReqMsgTemplate(status,times.toInt(),fileId,address,suffix);
        m_handler->sendLocalMessage(message, true, false);
    }
}

void TrailBoard::sendReward(QString userId, QString userName)
{
    if(m_handler != NULL)
    {
        int rewardType = 1;
        int millisecond = 5000;
        QString message = m_handler->rewardMsgTemplate(userId,rewardType,millisecond,userName);
        m_handler->sendLocalMessage(message, true, false);
    }
}

void TrailBoard::sendTimerMsg(int timerType, int flag, int timesec)
{
    if(m_handler != NULL)
    {
        QString message = m_handler->timerMsgTemplate(timerType,flag,timesec);
        m_handler->sendLocalMessage(message, true, false);
    }
}



#endif
