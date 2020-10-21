/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  controlcenter.cpp
 *  Description: control center class
 *
 *  Author: ccb
 *  Date: 2019/06/20 11:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/06/20    V4.5.1       创建文件
*******************************************************************************/
#include <QDir>
#include <QFile>
#include <qDebug>
#include <QProcess>
#include <QFileInfo>
#include <QFileInfoList>
#include<QCoreApplication>
#include<QThread>
#include <QEventLoop>
#include<QNetworkReply>
#include<QNetworkRequest>
#include<QNetworkInterface>
#include<QNetworkAccessManager>
#include "controlcenter.h"
#include "curriculumdata.h"
#include "messagepack.h"
#include "messagetype.h"
#include "datamodel.h"
#include "datacenter.h"
#include "httpclient.h"
#include "answercenter.h"
#include "trophycenter.h"
#include "redpacketscenter.h"
#include "coursewarecenter.h"
#include "audiovideocenter.h"
#include "whiteboardcenter.h"
#include "socketmanagercenter.h"
#include "HandsUpCenter.h"
#include "devicetestcenter.h"
#define av_play 0 // 音视频播放状态
#define av_pause 1 // 音视频暂停状态
#define av_stop 2 // 音视频停止状态
#define user_tea       0 // 老师用户
#define user_stu       1 // 学生用户
#define user_assistant 2 // 助教用户
bool g_isAVDownloading = false;

QMutex ControlCenter::m_instanceMutex;
ControlCenter* ControlCenter::m_controlCenter = nullptr;
ControlCenter::ControlCenter(QObject *parent)
    :QObject(parent)
    ,m_httpClient(nullptr)
    ,m_answerCenter(nullptr)
    ,m_redPacketsCenter(nullptr)
    ,m_coursewareCenter(nullptr)
    ,m_audioVideoCenter(nullptr)
    ,m_whiteBoardCenter(nullptr)
    ,m_socketManagerCenter(nullptr)
    ,m_HandsUpCenter(nullptr)
    ,m_DeviceTestCenter(nullptr)
{

    QList<MessageModel> list;
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
    DataCenter::getInstance()->m_pages.insert("DEFAULT", list);
    qmlRegisterType<CurriculumData>("CurriculumData",1,0,"CurriculumData");
    qmlRegisterType<YMCoursewareManager>("YMCoursewareManager",1,0,"YMCoursewareManager");
    m_timerOut = new QTimer();
    m_timerOut->setInterval(60000);
    m_timerOut->setSingleShot(true);

}

ControlCenter::~ControlCenter()
{
    if(nullptr != m_httpClient)
    {
        delete m_httpClient;
        m_httpClient = nullptr;
    }
    if(nullptr != m_timerOut)
    {
        delete m_timerOut;
        m_timerOut = nullptr;
    }
}

ControlCenter* ControlCenter::getInstance()
{
    if(nullptr == m_controlCenter)
    {
        m_instanceMutex.lock();
        if(nullptr == m_controlCenter)
        {
            m_controlCenter = new ControlCenter();
        }
        m_instanceMutex.unlock();
    }
    return m_controlCenter;
}

int ControlCenter::initControlCenter(const QString &appId, const QString &appKey, const QString &classroomId,int groupId, const QString &userId, const QString &nickName, int userRole, int classType)
{

    QString appPath = QCoreApplication::applicationDirPath();
    QString pluginDirPath = appPath;

    DataCenter::getInstance()->m_nickName = nickName;
    DataCenter::getInstance()->m_userRole = userRole;
    DataCenter::getInstance()->m_appId = appId;
    DataCenter::getInstance()->m_classroomType = classType;
    StudentData::gestance()->m_groupId = groupId;
    StudentData::gestance()->m_currentUserId = userId;
    StudentData::gestance()->m_liveRoomId = classroomId;
    StudentData::gestance()->m_token = appKey;

    //遍历插件目录
    QStringList pluginPathNameList = getFilePathNameOfSplAndChildDir(pluginDirPath);
    foreach (QString pluginPathName, pluginPathNameList)
    {
        if(pluginPathName.endsWith("whiteboard.dll", Qt::CaseInsensitive))
        {
            m_whiteBoardCenter  = new WhiteBoardCenter(this);
            if(nullptr == m_whiteBoardCenter)
            {
                qWarning()<< "m_whiteBoardCenter create failed!";
                continue;
            }
            m_whiteBoardCenter->init(pluginPathName);
            m_whiteBoardCenter->setUserAuth(StudentData::gestance()->m_currentUserId, userRole, 0);
            qDebug()<< "m_whiteBoardCenter create success!";
        }
        else if(pluginPathName.endsWith("socketmanager.dll", Qt::CaseInsensitive))
        {
            m_socketManagerCenter  = new SocketManagerCenter(this);
            if(nullptr == m_socketManagerCenter)
            {
                qWarning()<< "m_socketManagerCenter create failed!";
                continue;
            }
            m_socketManagerCenter->init(pluginPathName);
            qDebug()<< "m_socketManagerCenter create success!";
        }
        else if(pluginPathName.endsWith("YMAudioVideoManager.dll", Qt::CaseInsensitive))
        {
            m_audioVideoCenter = new AudioVideoCenter(userRole);
            if(nullptr == m_audioVideoCenter)
            {
                qWarning()<< "m_audioVideoCenter create failed!";
                continue;
            }
            m_audioVideoCenter->init(pluginPathName);
            qDebug()<< "m_audioVideoCenter create success!";
        }
        else if(pluginPathName.endsWith("YMCoursewareManager.dll", Qt::CaseInsensitive))
        {
            m_coursewareCenter = new CoursewareCenter(this);
            if(nullptr == m_coursewareCenter)
            {
                qWarning()<< "m_coursewareCenter create failed!";
                continue;
            }
            m_coursewareCenter->init(pluginPathName);
            qDebug()<< "m_coursewareCenter create success!";
        }
        else if(pluginPathName.endsWith("YMHandsUpManager.dll", Qt::CaseInsensitive))
        {
            m_HandsUpCenter = new HandsUpCenter(this);
            if(nullptr == m_HandsUpCenter)
            {
                qWarning()<< "m_HandsUpCenter create failed!";
                continue;
            }
            m_HandsUpCenter->init(pluginPathName);
            qDebug()<< "m_HandsUpCenter create success!";
        }
        else if(pluginPathName.endsWith("redpacket.dll", Qt::CaseInsensitive))
        {
            m_redPacketsCenter = new RedPacketsCenter(this);
            if(nullptr == m_redPacketsCenter)
            {
                qWarning()<< "m_redPacketsCenter create failed!";
                continue;
            }
            m_redPacketsCenter->init(pluginPathName);
            qDebug()<< "m_redPacketsCenter create success!";
        }
        else if(pluginPathName.endsWith("trophy.dll", Qt::CaseInsensitive))
        {
            m_trophyCenter = new TrophyCenter(this);
            if(nullptr == m_trophyCenter)
            {
                qWarning()<< "m_trophyCenter create failed!";
                continue;
            }
            m_trophyCenter->init(pluginPathName);
            qDebug()<< "m_trophyCenter create success!";
        }
        else if(pluginPathName.endsWith("answer.dll", Qt::CaseInsensitive))
        {
            m_answerCenter = new AnswerCenter(this);
            if(nullptr == m_answerCenter)
            {
                qWarning()<< "m_answerCenter create failed!";
                continue;
            }
            m_answerCenter->init(pluginPathName);
            qDebug()<< "m_answerCenter create success!";
        }
        else if(pluginPathName.endsWith("YMDeviceTestManager.dll", Qt::CaseInsensitive))
        {
            m_DeviceTestCenter = new DeviceTestCenter(this);
            if(nullptr == m_DeviceTestCenter)
            {
                qWarning()<< "m_DeviceTestCenter create failed!";
                continue;
            }
            m_DeviceTestCenter->init(pluginPathName);
            qDebug()<< "m_DeviceTestCenter create success!";
        }
        else
        {
            qWarning()<< "plugin is invalid, pluginPathName is" << pluginPathName;
        }

    }

    if(m_audioVideoCenter)
    {
        connect(m_audioVideoCenter, SIGNAL(renderVideoFrameImage(uint,QImage,int)), this,SIGNAL(renderVideoFrameImage(uint,QImage,int)));
        connect(m_audioVideoCenter, SIGNAL(hideBeautyButton()), this, SIGNAL(hideBeautyButton()));
        connect(m_audioVideoCenter, SIGNAL(sigJoinroom(uint, QString, int)),this,SIGNAL(sigJoinroom(uint, QString, int)));
        connect(m_audioVideoCenter, SIGNAL(sigAudioVolumeIndication(uint,int)), this, SIGNAL(sigAudioVolumeIndication(uint,int)));
    }
    if(m_HandsUpCenter)
    {
        connect(m_HandsUpCenter,SIGNAL(updateStuList(QString, uint, int)), this, SIGNAL(updateStuList(QString,uint,int)));
        connect(m_HandsUpCenter, SIGNAL(sigHandsUpResponse(QString,uint,QString)), this, SIGNAL(sigHandsUpResponse(QString,uint,QString)));
    }
    if(m_DeviceTestCenter)
    {
        connect(m_DeviceTestCenter, SIGNAL(netQuailty(int)), this, SIGNAL(netQuailty(int)));
        connect(m_DeviceTestCenter, SIGNAL(renderVideoImage(QString)), this, SIGNAL(renderVideoImage(QString)));
        connect(m_DeviceTestCenter, SIGNAL(carmeraReady()), this, SIGNAL(carmeraReady()));
        connect(m_DeviceTestCenter, SIGNAL(noCarmerDevices()), this, SIGNAL(noCarmerDevices()));
        connect(m_DeviceTestCenter, SIGNAL(speakerVolume(int,int)), this, SIGNAL(speakerVolume(int,int)));
    }
    connect(GetOffsetImage::instance(),SIGNAL(sigCurrentImageHeight(double)),this, SIGNAL(sigCurrentImageHeight(double)));
    connect(GetOffsetImage::instance(),SIGNAL(reShowOffsetImage(int,int)), this, SIGNAL(reShowOffsetImage(int,int)));
    m_httpClient = new HttpClient(StudentData::gestance()->m_address, StudentData::gestance()->m_httpPort);
    return 0;
}
void ControlCenter::initControlCenter(const QString &pluginDirPath, const QString &configFilePath, int screenWidth, int screenHeight)
{
    int iRet = getConfigFileInfo(configFilePath);
    if(-1 == iRet)
    {
        return;
    }
    /*
    //遍历插件目录
    QStringList pluginPathNameList = getFilePathNameOfSplAndChildDir(pluginDirPath);
    foreach (QString pluginPathName, pluginPathNameList)
    {
        if(pluginPathName.endsWith("whiteboard.dll", Qt::CaseInsensitive))
        {
            m_whiteBoardCenter  = new WhiteBoardCenter(this);
            if(nullptr == m_whiteBoardCenter)
            {
                qWarning()<< "m_whiteBoardCenter create failed!";
                continue;
            }
            m_whiteBoardCenter->init(pluginPathName);
            qDebug()<< "m_whiteBoardCenter create success!";
        }
        else if(pluginPathName.endsWith("socketmanager.dll", Qt::CaseInsensitive))
        {
            m_socketManagerCenter  = new SocketManagerCenter(this);
            if(nullptr == m_socketManagerCenter)
            {
                qWarning()<< "m_socketManagerCenter create failed!";
                continue;
            }
            m_socketManagerCenter->init(pluginPathName);
            qDebug()<< "m_socketManagerCenter create success!";
        }
        else if(pluginPathName.endsWith("YMAudioVideoManager.dll", Qt::CaseInsensitive))
        {
            m_audioVideoCenter = new AudioVideoCenter(this);
            if(nullptr == m_audioVideoCenter)
            {
                qWarning()<< "m_audioVideoCenter create failed!";
                continue;
            }
            m_audioVideoCenter->init(pluginPathName);
            qDebug()<< "m_audioVideoCenter create success!";
        }
        else if(pluginPathName.endsWith("YMCoursewareManager.dll", Qt::CaseInsensitive))
        {
            m_coursewareCenter = new CoursewareCenter(this);
            if(nullptr == m_coursewareCenter)
            {
                qWarning()<< "m_coursewareCenter create failed!";
                continue;
            }
            m_coursewareCenter->init(pluginPathName);
            qDebug()<< "m_coursewareCenter create success!";
        }
        else if(pluginPathName.endsWith("YMHandsUpManager.dll", Qt::CaseInsensitive))
        {
            m_HandsUpCenter = new HandsUpCenter(this);
            if(nullptr == m_HandsUpCenter)
            {
                qWarning()<< "m_HandsUpCenter create failed!";
                continue;
            }
            m_HandsUpCenter->init(pluginPathName);
            qDebug()<< "m_HandsUpCenter create success!";
        }
        else if(pluginPathName.endsWith("redpacket.dll", Qt::CaseInsensitive))
        {
            m_redPacketsCenter = new RedPacketsCenter(this);
            if(nullptr == m_redPacketsCenter)
            {
                qWarning()<< "m_redPacketsCenter create failed!";
                continue;
            }
            m_redPacketsCenter->init(pluginPathName);
            qDebug()<< "m_redPacketsCenter create success!";
        }
        else if(pluginPathName.endsWith("trophy.dll", Qt::CaseInsensitive))
        {
            m_trophyCenter = new TrophyCenter(this);
            if(nullptr == m_trophyCenter)
            {
                qWarning()<< "m_trophyCenter create failed!";
                continue;
            }
            m_trophyCenter->init(pluginPathName);
            qDebug()<< "m_trophyCenter create success!";
        }
        else if(pluginPathName.endsWith("answer.dll", Qt::CaseInsensitive))
        {
            m_answerCenter = new AnswerCenter(this);
            if(nullptr == m_answerCenter)
            {
                qWarning()<< "m_answerCenter create failed!";
                continue;
            }
            m_answerCenter->init(pluginPathName);
            qDebug()<< "m_answerCenter create success!";
        }
        else
        {
            qWarning()<< "plugin is invalid, pluginPathName is" << pluginPathName;
        }

    }

    initRectInfo(screenWidth, screenHeight);
    if(m_audioVideoCenter)
    {
        connect(m_audioVideoCenter, SIGNAL(renderVideoFrameImage(uint,QImage,int)), this,SIGNAL(renderVideoFrameImage(uint,QImage,int)));
        connect(m_audioVideoCenter, SIGNAL(hideBeautyButton()), this, SIGNAL(hideBeautyButton()));
        connect(m_audioVideoCenter, SIGNAL(sigJoinroom(uint, QString, int)),this,SIGNAL(sigJoinroom(uint, QString, int)));
    }
    connect(GetOffsetImage::instance(),SIGNAL(sigCurrentImageHeight(double)),this, SIGNAL(sigCurrentImageHeight(double)));
    connect(GetOffsetImage::instance(),SIGNAL(reShowOffsetImage(int,int)), this, SIGNAL(reShowOffsetImage(int,int)));
    if(m_HandsUpCenter)
    {
        connect(m_HandsUpCenter,SIGNAL(updateStuList(QString, uint, int)), this, SIGNAL(updateStuList(QString,uint,int)));
    }
    */
}

void ControlCenter::uninitControlCenter()
{
    //    exitClassRoom();

    //    if(m_answerCenter)
    //    {
    //        m_answerCenter->uninit();
    //        delete m_answerCenter;
    //        m_answerCenter = nullptr;
    //    }
    if(m_socketManagerCenter)
    {
        m_socketManagerCenter->uninit();
        delete m_socketManagerCenter;
        m_socketManagerCenter = nullptr;
    }
    if(m_trophyCenter)
    {
        m_trophyCenter->uninit();
        delete m_trophyCenter;
        m_trophyCenter = nullptr;
    }
    if(m_redPacketsCenter)
    {
        m_redPacketsCenter->uninit();
        delete m_redPacketsCenter;
        m_redPacketsCenter = nullptr;
    }
    if(m_whiteBoardCenter)
    {
        m_whiteBoardCenter->uninit();
        delete m_whiteBoardCenter;
        m_whiteBoardCenter = nullptr;
    }
    if(m_coursewareCenter)
    {
        m_coursewareCenter->uninit();
        delete m_coursewareCenter;
        m_coursewareCenter = nullptr;
    }
    if(m_audioVideoCenter)
    {
        m_audioVideoCenter->uninit();
        delete m_audioVideoCenter;
        m_audioVideoCenter = nullptr;
    }
    if(m_DeviceTestCenter)
    {
        m_DeviceTestCenter->uninit();
        delete m_DeviceTestCenter;
        m_DeviceTestCenter = nullptr;
    }

    if(!DataCenter::getInstance()->m_pages.empty())
    {
        DataCenter::getInstance()->m_pages.clear();
    }
}

void ControlCenter::beginClass()
{

    if(nullptr != m_socketManagerCenter)
    {
        QString msg = MessagePack::getInstance()->startClassMsg();
        sendLocalMessage(msg,true,false);
    }
    else
    {
        qWarning()<< "m_socketManagerCenter is null!, begin class is failed" ;
    }
}

void ControlCenter::endClass()
{
    if(nullptr != m_socketManagerCenter)
    {
        TemporaryParameter::gestance()->m_isFinishLesson = true;
        QString message = MessagePack::getInstance()->finishMsg(DataCenter::getInstance()->m_bConfirmFinish);
        m_socketManagerCenter->asynSendMessage(message);
    }
    else
    {
        qWarning()<< "m_socketManagerCenter is null!, end class is failed" ;
    }
}

void ControlCenter::exitClassRoom()
{

    QString message = MessagePack::getInstance()->exitRoomReqMsg(DataCenter::getInstance()->m_bConfirmFinish);
    if(nullptr != m_socketManagerCenter)
    {
        m_socketManagerCenter->asynSendMessage(message);
    }
}

void ControlCenter::setUserAuth(QString userId, int up, int trail, int audio, int video)
{
    qDebug() << "==setUserAuth::userId==" << userId << up << trail << audio << video;
    QString message =  MessagePack::getInstance()->authReqMsg(userId, up, trail, audio, video);
    qDebug() << "===TrailBoard::setUserAuth===" << message;
    TemporaryParameter::gestance()->m_userBrushPermissionsId.insert(userId, QString::number(trail));
    sendLocalMessage(message, true, false);
}

ImageProvider* ControlCenter::getImageProvider()
{
    return GetOffsetImage::instance()->imageProvider;
}

GetOffsetImage* ControlCenter::getGetOffsetImageInstance()
{
    return GetOffsetImage::instance();
}

void ControlCenter::selectShape(int shapeType)
{
    if(nullptr != m_whiteBoardCenter)
    {
        m_whiteBoardCenter->selectShape(shapeType);
    }
    else
    {
        qWarning()<< "m_whiteBoardCenter is null!, select shape is failed" << shapeType;
    }

}

void ControlCenter::setPaintSize(double size)
{
    if(nullptr != m_whiteBoardCenter)
    {
        m_whiteBoardCenter->setPaintSize(size);
    }
    else
    {
        qWarning()<< "m_whiteBoardCenter is null!, set paint size is failed" << size;
    }
}

void ControlCenter::setPaintColor(int color)
{
    if(nullptr != m_whiteBoardCenter)
    {
        m_whiteBoardCenter->setPaintColor(color);
    }
    else
    {
        qWarning()<< "m_whiteBoardCenter is null!, set paint color is failed" << color;
    }
}

void ControlCenter::setErasersSize(double size)
{
    if(nullptr != m_whiteBoardCenter)
    {
        m_whiteBoardCenter->setErasersSize(size);
    }
    else
    {
        qWarning()<< "m_whiteBoardCenter is null!, set eraser size is failed" << size;
    }
}

void ControlCenter::drawImage(const QString &image)
{

}

void ControlCenter::drawGraph(const QString &graph)
{

}

void ControlCenter::drawExpression(const QString &expression)
{

}

void ControlCenter::drawPointerPosition(double xpoint, double  ypoint)
{
    if(nullptr != m_whiteBoardCenter)
    {
        m_whiteBoardCenter->drawPointerPosition(xpoint, ypoint);
    }
    else
    {
        qWarning()<< "m_whiteBoardCenter is null!, draw pointer position is failed" ;
    }
}

void ControlCenter::undoTrail()
{
    if(nullptr != m_whiteBoardCenter)
    {
        m_whiteBoardCenter->undoTrail();
    }
    else
    {
        qWarning()<< "m_whiteBoardCenter is null!, undo trail is failed" ;
    }
}

void ControlCenter::clearTrails()
{
    if(nullptr != m_whiteBoardCenter)
    {
        m_whiteBoardCenter->clearTrails();
    }
    else
    {
        qWarning()<< "m_whiteBoardCenter is null!, clear trails is failed" ;
    }
}

void ControlCenter::drawTrails()
{

}

void ControlCenter::setServerAddr(const QVariantList &goodIpList, int httpPort, const QString &imIp, int imPort)
{
    StudentData::gestance()->m_address = imIp;
    StudentData::gestance()->m_port = imPort;
    TemporaryParameter::gestance()->goodIpList = goodIpList;
    StudentData::gestance()->m_httpPort = httpPort;
}

void ControlCenter::asynSendMessage(const QString &message)
{
    if(nullptr != m_socketManagerCenter)
    {
        m_socketManagerCenter->asynSendMessage(message);
    }
    else
    {
        qWarning()<< "m_socketManagerCenter is null!, insert courseWare is failed" << message;
    }
}

void ControlCenter::syncSendMessage(const QString &message)
{
    if(nullptr != m_socketManagerCenter)
    {
        m_socketManagerCenter->syncSendMessage(message);
    }
    else
    {
        qWarning()<< "m_socketManagerCenter is null!, insert courseWare is failed" << message;
    }
}

// 加载课件
void ControlCenter::insertCourseWare(QJsonArray imgUrlList, QString fileId, QString h5Url, int coursewareType)// 加载课件
{
    if(nullptr != m_coursewareCenter)
    {
        m_coursewareCenter->insertCourseWare(imgUrlList, fileId, h5Url, coursewareType);
    }
    else
    {
        qWarning()<< "m_coursewareCenter is null!, insert courseWare is failed" << imgUrlList << h5Url<< coursewareType;
    }
}

// 跳转课件页,type 1翻页 2加页 3减页
void ControlCenter::goCourseWarePage(int type, int pageNo, int totalNumber)
{
    if(nullptr != m_coursewareCenter)
    {
        m_coursewareCenter->goCourseWarePage(type, pageNo, totalNumber);
    }
    else
    {
        qWarning()<< "m_coursewareCenter is null!, go courseWare page is failed"<< type<< pageNo<< totalNumber;
    }
}

//根据偏移量截图
void ControlCenter::getOffsetImage(QString imageUrl, double offsetY)
{
    QImage tempImage;
    GetOffsetImage::instance()->currentBeBufferedImage = tempImage;
    DataCenter::getInstance()->m_currentImagaeOffSetY = offsetY;
    GetOffsetImage::instance()->getOffSetImage(imageUrl, offsetY);
}

// 设置当前图片高度
void ControlCenter::setCurrentImageHeight(int height)
{
    DataCenter::getInstance()->m_currentImageHeight = height;
    GetOffsetImage::instance()->currrentImageHeight = height;
}

// 滚动长图
void ControlCenter::updataScrollMap(double scrollY)
{
    const double scrollRate = 0.618;//屏幕比例常量
    QString coursewareId = "";
    if(DataCenter::getInstance()->m_currentCourse == "DEFAULT")
    {
        coursewareId = "000000";
    }
    else
    {
        coursewareId = DataCenter::getInstance()->m_currentCourse;
    }
    QString message = MessagePack::getInstance()->zoomMsg(coursewareId, 0.0, 0.0, scrollY, DataCenter::getInstance()->m_currentPage);
    //QString str = QString("{\"command\":\"zoomInOut\",\"domain\":\"control\",\"content\":{\"offsetX\":\"0\",\"offsetY\":\"%1\",\"zoomRate\":\"%2\"}}").arg(scrollY).arg(1.0);
    sendLocalMessage(message, true, false);
}

// H5动画播放
void ControlCenter::sendH5PlayAnimation(int step)
{
    QString message = MessagePack::getInstance()->playAnimationMsg(step, DataCenter::getInstance()->m_currentCourse, DataCenter::getInstance()->m_currentPage);
    qDebug() << "==sendH5PlayAnimation==" << message;
    sendLocalMessage(message, true, false);
}

void ControlCenter::drawCoursewarePage()
{
    if(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() < 1)  //画一页
    {
        sigEnterOrSync(18);
        return;
    }
    MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
    model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);
    if(m_coursewareCenter)
    {
        m_coursewareCenter->sendSigDrawPage(model);
    }
}

void ControlCenter::setAVCourseware(QString types, QString state, QString times, QString address, QString fileId, QString suffix)
{
    int status = av_play;
    if(state.contains("pause"))
    {
        status = av_pause;
    }
    else if(state.contains("stop"))
    {
        status = av_stop;
    }
    qDebug() << "===ControlCenter::setAVCourseware===" << types << state<< times.toInt() << address << fileId;
    QString message = MessagePack::getInstance()->avReqMsg(status, times.toInt(), fileId, address, suffix);
    sendLocalMessage(message, true, false);
}

QString ControlCenter::downLoadAVCourseware(QString mediaUrl)
{
    if(true == g_isAVDownloading)
    {
        qDebug()<<"AVCourseware is downLoading";
        return "";
    }
    g_isAVDownloading = true;
    qint64 startDownLoadTime = QDateTime::currentMSecsSinceEpoch();
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    docPath += "/YIMI/Media/";
    QDir dir;
    if(!dir.exists(docPath))
    {
        dir.mkdir(docPath);
    }
    int index = mediaUrl.indexOf("?");
    QString fileUrl = mediaUrl.mid(0, index);
    int lastIndex = fileUrl.lastIndexOf("/");
    QString fileName = fileUrl.mid(lastIndex + 1, fileUrl.length() - 1);
    QString fileNames = docPath.append(fileName);
    QString suffix = fileName.mid(fileName.lastIndexOf(".") + 1);

    QFile file(fileNames);
    if(file.exists())
    {
        g_isAVDownloading = false;
        return fileNames;
    }
    emit sigLoadingAV();
    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    httpRequest.setUrl(QUrl(mediaUrl));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader,"application/x-www-form-urlencoded");
    QEventLoop httploop;
    QNetworkAccessManager *networkMgr = new QNetworkAccessManager();
    connect(networkMgr,SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    connect(m_timerOut,&QTimer::timeout,&httploop,&QEventLoop::quit);
    QNetworkReply *httpReply;
    httpReply = networkMgr->get(httpRequest);
    m_timerOut->start();
    httploop.exec();
    QByteArray readData;
    if(m_timerOut->isActive())
    {
        if(httpReply->error() == QNetworkReply::NoError)
        {
            readData = httpReply->readAll();
            file.open(QIODevice::WriteOnly);
            file.write(readData);
            file.flush();
            file.close();
            networkMgr->deleteLater();
            emit sigDowloadAVSuccess();
        }
    }
    else
    {
        emit sigDowloadAVFail();
        fileNames = "";
        networkMgr->deleteLater();
    }
    if(NULL != networkMgr)
    {
        delete networkMgr;
        networkMgr = NULL;
    }
    g_isAVDownloading = false;
    return fileNames;
}

void ControlCenter::initVideoChancel()// 初始化频道
{
    if(nullptr != m_audioVideoCenter)
    {
        m_audioVideoCenter->initVideoChancel();
    }
    else
    {
        qWarning()<< "m_audioVideoCenter is null!, init video chancel is failed" ;
    }
}

void ControlCenter::changeChanncel()// 切换频道
{
    if(nullptr != m_audioVideoCenter)
    {
        m_audioVideoCenter->changeChanncel();
    }
    else
    {
        qWarning()<< "m_audioVideoCenter is null!, change chancel is failed" ;
    }
}

void ControlCenter::closeAudio(QString status)// 关闭音频
{
    if(nullptr != m_audioVideoCenter)
    {
        m_audioVideoCenter->closeAudio(status);
    }
    else
    {
        qWarning()<< "m_audioVideoCenter is null!, close audio is failed" << status ;
    }
}

void ControlCenter::closeVideo(QString status)// 关闭视频
{
    if(nullptr != m_audioVideoCenter)
    {
        m_audioVideoCenter->closeVideo(status);
    }
    else
    {
        qWarning()<< "m_audioVideoCenter is null!, close video is failed" << status ;
    }
}

void ControlCenter::setStayInclassroom()// 设置留在教室
{
    if(nullptr != m_audioVideoCenter)
    {
        m_audioVideoCenter->setStayInclassroom();
    }
    else
    {
        qWarning()<< "m_audioVideoCenter is null!, set stay in classroom is failed" ;
    }
}

void ControlCenter::exitChannel()
{
    if(nullptr != m_audioVideoCenter)
    {
        m_audioVideoCenter->exitChannel();
    }
    else
    {
        qWarning()<< "m_audioVideoCenter is null!, exit channel is failed" ;
    }
}

// 全体禁音
void ControlCenter::allMute(int muteStatus)
{
    QString message = MessagePack::getInstance()->muteAllReqMsgTemplate(muteStatus);
    sendLocalMessage(message, true, false);
}

// 设置美颜
void ControlCenter::enableBeauty(bool isBeauty)
{
    if(NULL != m_audioVideoCenter)
    {
        m_audioVideoCenter->enableBeauty(isBeauty);
    }
    else
    {
        qWarning()<< "m_audioVideoCenter is null!, exit channel is failed" ;
    }
}

// 得到美颜状态
bool ControlCenter::getBeautyIsOn()
{
    if(NULL != m_audioVideoCenter)
    {
        return m_audioVideoCenter->getBeautyIsOn();
    }
    return false;
}

void ControlCenter::setRedPackets(int sumCredit, int redCount, int normalRange, int limitRange, int creditMax, int redTime, int countDownTime)
{
    DataCenter::getInstance()->m_sumCredit = sumCredit;
    DataCenter::getInstance()->m_redCount = redCount;
    DataCenter::getInstance()->m_normalRange = normalRange;
    DataCenter::getInstance()->m_limitRange = limitRange;
    DataCenter::getInstance()->m_max = creditMax;
    DataCenter::getInstance()->m_redTime = redTime;
    DataCenter::getInstance()->m_countDownTime = countDownTime;
}

void ControlCenter::sendTimer(int timerType, int flag, int timesec)
{
    if(m_socketManagerCenter != nullptr)
    {
        QString message = MessagePack::getInstance()->timerMsg(timerType,flag,timesec);
        m_socketManagerCenter->asynSendMessage(message);
    }
}

// 设置用户角色
int ControlCenter::setUserRole(int role)
{
    CLIENT_ROLE userRole;
    if(role == 1)
    {
        userRole = BROADCASTER;
    }
    else if(role == 2)
    {
        userRole = AUDIENCE;
    }
    int ret = -1;
    if(NULL != m_audioVideoCenter)
    {
        ret = m_audioVideoCenter->setUserRole(userRole);
    }
    return ret;
}

// 设置视频分辨率
int ControlCenter::setVideoResolution(int resolution)
{
    VIDEO_RESOLUTION res;
    if(resolution == 1)
    {
        res = STANDARD_DEFINITION;
    }
    else if(resolution == 2)
    {
        res = HIGH_DEFINITION;
    }
    else if(resolution == 3)
    {
        res = SUPER_DEFINITION;
    }
    int ret = -1;
    if(NULL != m_audioVideoCenter)
    {
        ret = m_audioVideoCenter->setVideoResolution(res);
    }
    return ret;
}

int ControlCenter::setAudioVideoInfo(const QString &channelKey,const QString &channelName,const QString &token,
                                     const QString &uid, const QString &chatRoomId)
{
    StudentData::gestance()->m_agoraChannelKey = channelKey;
    StudentData::gestance()->m_agoraChannelName = channelName;
    StudentData::gestance()->m_agoraToken = token;
    StudentData::gestance()->m_agoraUid =uid;
    StudentData::gestance()->m_chatRoomId = chatRoomId;
    return 0;
}

int ControlCenter::initHandsUp(QJsonObject json)
{
    int ret = -1;
    if(NULL != m_HandsUpCenter)
    {
        ret = m_HandsUpCenter->initHandsUp(json);
    }
    return ret;
}

int ControlCenter::raiseHandForUp(QString userId, QString groupId)
{
    int ret = -1;
    if(NULL != m_HandsUpCenter)
    {
        ret = m_HandsUpCenter->raiseHandForUp(userId, groupId);
    }
    return ret;
}

int ControlCenter::cancelHandsUp(QString userId, QString groupId)
{
    int ret = -1;
    if(NULL != m_HandsUpCenter)
    {
        ret = m_HandsUpCenter->cancelHandsUp(userId, groupId);
    }
    return ret;
}

int ControlCenter::processResponse(QString userId, int operation)
{
    int ret = -1;
    if(NULL != m_HandsUpCenter)
    {
        ret = m_HandsUpCenter->processResponse(userId, operation);
    }
    return ret;
}

int ControlCenter::processHandsUp(QString userId, uint groupId, TEA_OPERATION operation)
{
    if(NULL != m_HandsUpCenter)
    {
        m_HandsUpCenter->processHandsUp(userId, groupId, operation);
    }
    else
    {
        return -1;
    }
    return 0;
}

int ControlCenter::parseHandsUpMsg(const QJsonObject &msg)
{
    //qDebug()<<"\n===========ControlCenter::parseHandsUpMsg========"<<msg<<"\n";
    if(NULL != m_HandsUpCenter)
    {
        m_HandsUpCenter->parseHandsUpMsg(msg);
    }
    else
    {
        return -1;
    }
    return 0;
}

QJsonArray ControlCenter::getUserDeviceList(int type)
{
    QJsonArray arr;
    if(NULL != m_DeviceTestCenter)
    {
        arr = m_DeviceTestCenter->getUserDeviceList(type);
    }
    return arr;
}

void ControlCenter::setCarmerDevice(QString deviceName)
{
    if(NULL != m_DeviceTestCenter)
    {
        m_DeviceTestCenter->setCarmerDevice(deviceName);
    }
}

void ControlCenter::setPlayerDevice(QString deviceName)
{
    if(NULL != m_DeviceTestCenter)
    {
        m_DeviceTestCenter->setPlayerDevice(deviceName);
    }
}

void ControlCenter::setRecorderDevice(QString deviceName)
{
    if(NULL != m_DeviceTestCenter)
    {
        m_DeviceTestCenter->setRecorderDevice(deviceName);
    }
}

void ControlCenter::startOrStopAudioTest(bool isStart)
{
    if(NULL != m_DeviceTestCenter)
    {
        m_DeviceTestCenter->startOrStopAudioTest(isStart);
    }
}

void ControlCenter::startOrStopVideoTest(bool isStart)
{
    if(NULL != m_DeviceTestCenter)
    {
        m_DeviceTestCenter->startOrStopVideoTest(isStart);
    }
}

void ControlCenter::startOrStopNetTest(bool isStart)
{
    if(NULL != m_DeviceTestCenter)
    {
        m_DeviceTestCenter->startOrStopNetTest(isStart);
    }
}

void ControlCenter::releaseDevice()
{
    if(NULL != m_DeviceTestCenter)
    {
        m_DeviceTestCenter->releaseDevice();
    }
}

void ControlCenter::processMsg(const QString &command, const QJsonObject &jsonMsg, const QString& message)
{
    //  qDebug()<< "processMsg" <<message;
    QJsonValue contentValue;
    QString msg = message;
    DataCenter::getInstance()->m_uServerSn = getMessageSN(jsonMsg);
    if(kSocketHb == command)
    {
        return;
    }
    else if(kSocketAck == command)
    {
        doSocketAck(jsonMsg);
        return;
    }

    if(jsonMsg.contains(kSocketContent))
        contentValue = jsonMsg[kSocketContent];

    if (kSocketEnterRoom == command)
    {
        doSocketEnterRoom(jsonMsg);
    }
    else if(command == kSocketEnterFailed)
    {
        bool bExitRoom = m_socketManagerCenter->checkServerResponse(kSocketEnterRoom, DataCenter::getInstance()->m_bConfirmFinish);
        if(bExitRoom)
        {
            finishRespExitRoom();
        }
        //提示进入房间失败
        emit sigEnterOrSync(0);
    }
    else if (command == kSocketKickOut)
    {
        emit sigkickOutClassroom();//账号在其他地方登录 被迫下线
        qDebug() << QStringLiteral("账号在其他地方登录 被迫下线");
    }
    else if(command == kSocketFinish)
    {
        QString message = MessagePack::getInstance()->finishMsg(DataCenter::getInstance()->m_bConfirmFinish);
        m_socketManagerCenter->syncSendMessage(message);

        //退出教室
        StudentData::gestance()->removeOnlineId(StudentData::gestance()->m_currentUserId);
        if(StudentData::gestance()->m_teacher.m_teacherId == StudentData::gestance()->m_currentUserId )
        {
            TemporaryParameter::gestance()->m_isStartClass = false;
        }
        emit sigEndClassroom();

    }
    else if(kSocketTrail == command || kSocketDoc == command || kSocketPage == command || kSocketZoom == command ||  kSocketOperation == command) //此处为及时通讯信息-需要重绘画板
    {
        doSocketDrawTrails(command, jsonMsg, msg);
    }
    else if(kSocketReward == command || kSocketAV == command || kSocketAuth == command || kSocketMuteAll == command || kSocketResponder == command || kSocketSpeak == command
            || kSocketTimer == command || kSocketStartClass == command || kSocketPlayAnimation == command) //此处为及时通讯信息-但不需要重绘画板
    {
        //回复服务器-发送回执信息
        QString replyMessage = MessagePack::getInstance()->ackServerMsg(DataCenter::getInstance()->m_uServerSn);
        if(m_socketManagerCenter)
            m_socketManagerCenter->syncSendMessage(replyMessage);

        //处理及时协议命令操作
        processUserCommandOp(command, jsonMsg, msg);
    }
    else if(kSocketPoint == command) //实时教鞭-不需要ack服务器
    {
        //处理及时协议命令操作
        processUserCommandOp(command, jsonMsg, msg);
    }
    else if(kSocketUsersStatus == command)
    {
        doSocketUsersStatus(contentValue);
    }
    else if(kSocketExitRoom == command) //防止服务器狂发exitRoom协议
    {
        doSocketExitRoom(jsonMsg);
    }
    else if(kSocketSendRedPackets == command)
    {
        //回复服务器-发送回执信息
        QString replyMessage = MessagePack::getInstance()->ackServerMsg(DataCenter::getInstance()->m_uServerSn);
        if(m_socketManagerCenter)
            m_socketManagerCenter->syncSendMessage(replyMessage);

        QJsonObject obj = contentValue.toObject();
        if(!obj.empty() && obj.contains("redPacketNum"))
        {
            DataCenter::getInstance()->m_redPacketsId = obj["redPacketNum"].toInt();
        }
        if(!obj.empty() && obj.contains("redPacketURL"))
        {
            DataCenter::getInstance()->m_redPacketURL = obj.value("redPacketURL").toString();
        }
        doBeginRedPackets();
    }
    else if(kSocketEndRedPackets == command)
    {
        //回复服务器-发送回执信息
        QString replyMessage = MessagePack::getInstance()->ackServerMsg(DataCenter::getInstance()->m_uServerSn);
        if(m_socketManagerCenter)
            m_socketManagerCenter->syncSendMessage(replyMessage);
        doEndRedPackets(contentValue.toObject());
    }
    else if(kSocketQuestion == command)
    {
        //回复服务器-发送回执信息
        QString replyMessage = MessagePack::getInstance()->ackServerMsg(DataCenter::getInstance()->m_uServerSn);
        if(m_socketManagerCenter)
            m_socketManagerCenter->syncSendMessage(replyMessage);

        QJsonObject obj = contentValue.toObject();
        if(!obj.empty() && obj.contains("type"))
        {
            QString type = obj["type"].toString();
            if(type == "start")
            {
                DataCenter::getInstance()->m_itemId = obj["itemId"].toInt();
                doDrawAnswer(obj);
            }
            else if(type == "statistics")
            {
                doAnswerStatistics(obj);
            }
            else if(type == "cancel")
            {
                doAnswerCancel();
            }
            else if(type == "forceFin")
            {
                doAnswerForceFin();
            }

        }



    }
    else //防止服务器狂发垃圾协议
    {
        //回复服务器-发送回执信息
        QString replyMessage = MessagePack::getInstance()->ackServerMsg(DataCenter::getInstance()->m_uServerSn);
        if(m_socketManagerCenter)
            m_socketManagerCenter->syncSendMessage(replyMessage);
    }
}

void ControlCenter::processHttpMsg(const QString &command, const QJsonObject &jsonMsg)
{
    QJsonObject contentObj;
    if(jsonMsg.contains(kSocketContent))
    {
        contentObj = jsonMsg[kSocketContent].toObject();
    }
    else
    {
        return ;
    }

    qWarning()<< "http msg command is not match," <<command;

}

void ControlCenter::sendLocalMessage(QString message, bool asynSend, bool drawPage)
{
    if(nullptr == m_socketManagerCenter)
        return;
    if(message.contains("courware")) //如果课件默认值是1则改为总页数
    {
        if(DataCenter::getInstance()->m_pages.contains("DEFAULT"))
        {
            message.replace("\"pageIndex\":\"1\"", "\"pageIndex\":\"" + QString::number(DataCenter::getInstance()->m_pages.value("DEFAULT").size()) + "\"");
        }
    }

    QJsonObject jsonObj = stringToJsonParse(message);
    if(jsonObj.isEmpty())
        return;
    QString command = getMessageCommand(jsonObj);
    if(!command.isEmpty())
    {
        processUserCommandOp(command, jsonObj, message); //本地缓存
    }

    if (drawPage)
    {
        if(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() < 1)  //画一页
        {
            sigEnterOrSync(18);
            return;
        }

        MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
        model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);
        if(m_coursewareCenter)
        {
            m_coursewareCenter->sendSigDrawPage(model);
        }
        if(m_whiteBoardCenter)
            m_whiteBoardCenter->drawTrails(model.bgimg, model.width, model.height, model.offsetY, model.questionId);

    }

    if(!command.isEmpty() && !DataCenter::getInstance()->m_isRemovePage)
    {
        if(asynSend) //仅且需要服务器回执的消息加入队列中
        {
            m_socketManagerCenter->asynSendMessage(message);
        }
        else
        {
            m_socketManagerCenter->syncSendMessage(message);
        }
    }
}

void ControlCenter::sendHttpMsg(const QString &url, const QString &message)
{
    if(nullptr != m_httpClient)
    {
        m_httpClient->asynRequestMsg(url, message);
    }
    else
    {
        qWarning()<< "send http msg is failed, m_httpClient is null"<< message;
    }
}

int ControlCenter::getUid(QString UserId)
{
    int uid;
    for(int i = 0; i < StudentData::gestance()->m_student.count(); i++)
    {
        if(StudentData::gestance()->m_student.at(i).m_studentId== UserId)
        {
            uid = StudentData::gestance()->m_student[i].m_uid;
            break;
        }
    }
    return uid;
}

void ControlCenter::setUserInfo(QJsonObject userInfo)
{
    m_mutex.lock();
    m_userInfo = userInfo;
    m_mutex.unlock();
}

QJsonObject ControlCenter::getUserInfo()
{
    QJsonObject infoObj;
    m_mutex.lock();
    infoObj = m_userInfo;
    m_mutex.unlock();
    return infoObj;
}

void ControlCenter::doSocketAck(const QJsonObject &jsonObj)
{
    if(nullptr == m_socketManagerCenter)
        return;
    if(jsonObj.contains(kSocketContent))
    {
        qint32 nMySn = 0;
        QJsonObject contentJsonObj = jsonObj[kSocketContent].toObject();
        if(contentJsonObj.contains(kSocketSn))
        {
            nMySn = contentJsonObj.take(kSocketSn).toVariant().toLongLong();
        }

        QString target = QString("\"") + kSocketSn + QString("\":") + QString::number(nMySn);
        bool bExitRoom = m_socketManagerCenter->checkServerResponse(target, DataCenter::getInstance()->m_bConfirmFinish);
        if(bExitRoom)
        {
            qDebug()<< " sigExitRoom" << DataCenter::getInstance()->m_bConfirmFinish;
            emit sigExitRoom();
        }
    }
}

void ControlCenter::doSocketEnterRoom(const QJsonObject & jsonMsg)
{
    if(nullptr == m_socketManagerCenter)
        return;
    QString userId = QString::number(jsonMsg[kSocketUid].toVariant().toLongLong());
    qDebug() << "enterRoom::userId===" << userId << StudentData::gestance()->m_currentUserId;
    if (userId == StudentData::gestance()->m_currentUserId)//自己进入房间 开始同步
    {
        emit sigEnterOrSync( 1 ) ;
        StudentData::gestance()->insertIntoOnlineId(userId);
        bool bExitRoom = m_socketManagerCenter->checkServerResponse(kSocketEnterRoom, DataCenter::getInstance()->m_bConfirmFinish);
        if(bExitRoom)
        {
            finishRespExitRoom();
        }

        QJsonObject avJsonMsg;
        //同步历史记录
        QJsonArray userHistroyMsgs;
        if(syncUserHistroyReq(userHistroyMsgs))
        {
            //回复服务器-同步历史记录完成
            QString replyMessage = MessagePack::getInstance()->syncUserHistroyFinMsg();
            qDebug() << "======replyMessage======" << replyMessage;
            m_socketManagerCenter->syncSendMessage(replyMessage);

            //同步历史记录成功-深入解析对应数据
            QString hisCommand, hisMessage;
            int size = userHistroyMsgs.size();
            for(int i = 0; i < size; ++i)
            {
                QJsonObject userHistroyMsg = userHistroyMsgs.at(i).toObject();
                //单条协议的全部消息
                if(userHistroyMsg.isEmpty())
                {
                    hisMessage = userHistroyMsgs.at(i).toString();
                }
                QJsonObject jsonObj = stringToJsonParse(hisMessage);
                if(jsonObj.isEmpty())
                    continue;

                //单条协议消息的关键协议命令
                if(hisMessage.contains(kSocketCmd))
                {
                    hisCommand = getMessageCommand(jsonObj);
                }
                //                qDebug() << "==hisCommand==" << hisCommand;
                if(kSocketTrail == hisCommand || kSocketPoint == hisCommand || kSocketDoc == hisCommand ||
                        kSocketAuth == hisCommand || kSocketMuteAll == hisCommand || kSocketPage == hisCommand || kSocketZoom == hisCommand || kSocketPlayAnimation == hisCommand ||
                        kSocketOperation == hisCommand || kSocketStartClass == hisCommand)  //暂时同步历史记录权限全部放开, 后面与服务器协商, 垃圾消息不予通过
                {
                    processUserCommandOp(hisCommand, jsonObj, hisMessage);//执行历史记录操作
                }
                else if(kSocketAV == hisCommand)
                {
                    avJsonMsg = jsonObj;
                }
                else if(kSocketFinish == hisCommand)
                {
                    TemporaryParameter::gestance()->m_isFinishLesson = true;
                    qDebug()<< "sigEndClassroom--"<<hisCommand;
                    emit sigEndClassroom();
                    return;
                }

                //临时方案-同步历史记录时每100条发一条心跳进行保活
                if((i % 100) == 0)
                {
                    QString keepAliveMessage = MessagePack::getInstance()->keepAliveReqMsg();
                    m_socketManagerCenter->syncSendMessage(keepAliveMessage);
                }
            }

            //同步历史数据后更新白板界面
            if(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() > DataCenter::getInstance()->m_currentPage)
            {

                MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
                model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);
                GetOffsetImage::instance()->getOffSetImage(model.bgimg, model.offsetY);
                if(m_whiteBoardCenter)
                    m_whiteBoardCenter->drawTrails(model.bgimg, model.width, model.height, model.offsetY, model.questionId);

            }
        }
        if(DataCenter::getInstance()->m_isOneStart == false)
        {
            emit sigEnterOrSync(201);
        }

        DataCenter::getInstance()->m_isOneStart = true;
        syncUserHistroyComplete();
        if(!avJsonMsg.empty())
        {
            QString fromUid = "";
            cacheAVMessage(fromUid, avJsonMsg);
        }
    }
    else
    {
        if(userId == StudentData::gestance()->m_selfStudent.m_studentId)
        {
            for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
            {
                if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                {
                    emit sigSendUserId(StudentData::gestance()->m_student[i].m_studentId);
                    emit sigEnterOrSync(3);
                    //qDebug()<< "=============userId========" << userId << m_isInit;
                    break;
                }
            }
            return;
        }
        StudentData::gestance()->m_dataInsertion = true;
        StudentData::gestance()->insertIntoOnlineId(userId);
        for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
        {
            if(userId == StudentData::gestance()->m_student[i].m_studentId)
            {
                if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                {
                    emit sigSendUserId(userId);
                    emit sigEnterOrSync(3);
                    break;
                }
            }
        }
    }

}

void ControlCenter::doSocketExitRoom(const QJsonObject & jsonObj)
{
    //回复服务器-发送回执信息
    QString replyMessage = MessagePack::getInstance()->ackServerMsg(DataCenter::getInstance()->m_uServerSn);
    if(m_socketManagerCenter)
        m_socketManagerCenter->syncSendMessage(replyMessage);
    emit sigExitClassroom();

}

void ControlCenter::doSocketDrawTrails(const QString &command, const QJsonObject &jsonObj, QString &msg)
{
    if(nullptr == m_socketManagerCenter)
        return;
    //回复服务器-发送回执信息
    QString replyMessage = MessagePack::getInstance()->ackServerMsg(DataCenter::getInstance()->m_uServerSn);
    m_socketManagerCenter->syncSendMessage(replyMessage);

    //处理及时协议命令操作
    processUserCommandOp(command, jsonObj, msg);

    MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
    model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);

    if(m_whiteBoardCenter)
        m_whiteBoardCenter->drawTrails(model.bgimg, model.width, model.height, model.offsetY, model.questionId);
}

void ControlCenter::doSocketUsersStatus(QJsonValue &contentValue)
{
    //回复服务器-发送回执信息
    QString replyMessage = MessagePack::getInstance()->ackServerMsg(DataCenter::getInstance()->m_uServerSn);
    if(m_socketManagerCenter)
        m_socketManagerCenter->syncSendMessage(replyMessage);

    //更新用户状态信息
    updateUserState(contentValue);
}

void ControlCenter::doBeginRedPackets()
{
    if(nullptr != m_redPacketsCenter)
    {
        m_redPacketsCenter->beginRedPackets();
    }
    else
    {
        qWarning()<< "begin red packets is failed, m_redPacketsCenter is null!";
    }
}

void ControlCenter::doEndRedPackets(QJsonObject &contentObj)
{
    if(nullptr != m_redPacketsCenter)
    {
        m_redPacketsCenter->queryRedPackets();
    }
    else
    {
        qWarning()<< "end red packets is failed, m_redPacketsCenter is null!"<< contentObj;
    }
}

void ControlCenter::doDrawAnswer(QJsonObject &contentObj)
{
    if(nullptr != m_answerCenter)
    {
        m_answerCenter->drawAnswer(contentObj);
    }
    else
    {
        qWarning()<< "draw answer is failed, m_answerCenter is null!"<< contentObj;
    }
}

void ControlCenter::doAnswerCancel()
{
    if(nullptr != m_answerCenter)
    {
        m_answerCenter->answerCancel();
    }
    else
    {
        qWarning()<< "answer cancel is failed, m_answerCenter is null!";
    }
}

void ControlCenter::doAnswerForceFin()
{
    if(nullptr != m_answerCenter)
    {
        m_answerCenter->answerForceFin();
    }
    else
    {
        qWarning()<< "answer force fin is failed, m_answerCenter is null!";
    }
}

void ControlCenter::doAnswerStatistics(const QJsonObject &contentObj)
{
    if(nullptr != m_answerCenter)
    {
        m_answerCenter->answerStatistics(contentObj);
    }
    else
    {
        qWarning()<< "answer statistics is failed, m_answerCenter is null!"<< contentObj;
    }
}

QStringList ControlCenter::getFilePathNameOfSplAndChildDir(QString dirPath)
{
    QStringList filePathNames;
    //得到这个目录下面的文件全部
    filePathNames << getFilePathNameOfSplDir(dirPath);

    QStringList childDirs;
    childDirs << getDirPathOfSplDir(dirPath);

    QString tempChildDir;
    foreach (tempChildDir, childDirs) {
        // 取其子文件夹内容
        filePathNames << getFilePathNameOfSplAndChildDir(tempChildDir);
    }
    return filePathNames;
}

QStringList ControlCenter::getDirPathOfSplDir(QString dirPath)
{
    QStringList dirPaths;
    QDir splDir(dirPath);
    QFileInfoList fileInfoListInSplDir = splDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    QFileInfo tempFileInfo;
    foreach (tempFileInfo, fileInfoListInSplDir) {
        dirPaths << tempFileInfo.absoluteFilePath();
    }
    return dirPaths;
}

QStringList ControlCenter::getFilePathNameOfSplDir(const QString &dirPath)
{
    QDir splDir(dirPath);
    QStringList filePathNames;

    //获取目录下dll文件列表
    QFileInfoList fileInfoListInSplDir = splDir.entryInfoList(QDir::Files);
    foreach (QFileInfo tempFileInfo, fileInfoListInSplDir)
    {
        if(tempFileInfo.absoluteFilePath().endsWith("whiteboard.dll", Qt::CaseInsensitive) ||
                tempFileInfo.absoluteFilePath().endsWith("socketmanager.dll", Qt::CaseInsensitive)||
                tempFileInfo.absoluteFilePath().endsWith("YMAudioVideoManager.dll", Qt::CaseInsensitive)||
                tempFileInfo.absoluteFilePath().endsWith("YMCoursewareManager.dll", Qt::CaseInsensitive)||
                tempFileInfo.absoluteFilePath().endsWith("YMHandsUpManager.dll", Qt::CaseInsensitive)||
                tempFileInfo.absoluteFilePath().endsWith("redpacket.dll", Qt::CaseInsensitive)||
                tempFileInfo.absoluteFilePath().endsWith("answer.dll", Qt::CaseInsensitive)||
                tempFileInfo.absoluteFilePath().endsWith("trophy.dll", Qt::CaseInsensitive)||
                tempFileInfo.absoluteFilePath().endsWith("YMDeviceTestManager.dll", Qt::CaseInsensitive))
        {
            filePathNames << tempFileInfo.absoluteFilePath();
        }
    }
    return filePathNames;
}

int ControlCenter::getConfigFileInfo(const QString &configFilePath)
{
    QString strAppFileName = QCoreApplication::applicationDirPath();
    //    QMessageBox::critical(NULL, "aaa", strAppFileName, QMessageBox::Ok, QMessageBox::Ok); //测试中文乱码
    StudentData::gestance()->strAppFullPath  = strAppFileName;
    strAppFileName = strAppFileName.mid(strAppFileName.lastIndexOf("\\") + 1);
    StudentData::gestance()->strAppName = strAppFileName;

    if (!QFile::exists(configFilePath)) //"stutemp.ini")){
    {
        qDebug() << QString("!QFile.exists") << configFilePath + "miniTemp.ini" << __LINE__;
        return -1;
    }

    QFile file(configFilePath); //"stutemp.ini");

    if(!file.open(QIODevice::ReadOnly))
    {
        qDebug() << QString("!file.open") << __LINE__;
        return -1;
    }

    QByteArray arrys = file.readAll();
    QString backData(arrys);
    file.close();

    if(backData.length() < 1)
    {
        qDebug() << QString("backData.length() < 1") << __LINE__;
        return -1;
    }
    //qDebug()<<"docPath =="<<backData;
    StudentData::gestance()->setDocumentParsing(backData);

    backData.replace("liveroomId","lessonId");
    return 0;
}

void ControlCenter::finishRespExitRoom()
{
    //结束进程
    QProcess process;
    process.execute(QString("TASKKILL /IM %1 /F") .arg(StudentData::gestance()->strAppName));
    process.close();
}

void ControlCenter::updateUserState(QJsonValue content)
{
    QJsonArray contentArray = content.toArray();

    TemporaryParameter::gestance()->m_teacherIsOnline  = false;
    TemporaryParameter::gestance()->m_astudentIsOnline = false;
    qDebug() << "==userState::data===" <<  contentArray;
    if (contentArray.size() > 0)
    {
        foreach (QJsonValue value, contentArray)
        {
            QJsonObject userStates = value.toObject();

            QString uid  = userStates.take(kSocketUid).toString();
            QString state = QString::number(userStates.take(kSocketOnlineState).toInt());
            QString userType = userStates.take(kSocketUserType).toString();

            QString exterInfoStr = userStates.take(kSocketExtraInfo).toString();
            QJsonObject extraInfoObj = QJsonDocument::fromJson(exterInfoStr.toUtf8().data()).object();

            if("1" == state)
            {
                StudentData::gestance()->insertIntoOnlineId(uid);
            }
            else
            {
                StudentData::gestance()->removeOnlineId(uid);
            }

            if(uid == StudentData::gestance()->m_teacher.m_teacherId)
            {
                TemporaryParameter::gestance()->m_teacherIsOnline = true;
            }
            qDebug() << "======uid=" << uid <<",state=" << state;
            // 动态添加、减少在线学生进入教室
            if(StudentData::gestance()->m_currentUserId != uid && state == "1")
            {
                emit sigJoinClassroom(uid, userType, extraInfoObj);
            }
            else if(StudentData::gestance()->m_currentUserId != uid && state == "0")
            {
                if(DataCenter::getInstance()->m_sysnStatus == true)
                {
                    emit sigLeaveClassroom(uid, userType, extraInfoObj);
                }
            }
        }
    }
}

bool ControlCenter::syncUserHistroyReq(QJsonArray& userHistroyData)
{
    QNetworkRequest netRequest;
    QString qsUrl = QString("http://") + StudentData::gestance()->m_address + QString("/socks/sync");
    QUrl url(qsUrl);
    url.setPort(StudentData::gestance()->m_httpPort); //HTTP端口5251
    netRequest.setUrl(url);

    netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");
    netRequest.setRawHeader("TOKEN", StudentData::gestance()->m_token.toUtf8());

    QNetworkReply *netReply;

    QString postData = MessagePack::getInstance()->syncUserHistroyReqMsg(1, DataCenter::getInstance()->m_uServerSn);

    QNetworkAccessManager *httpAccessMgr = new QNetworkAccessManager();
    netReply = httpAccessMgr->post(netRequest, postData.toUtf8());
    qDebug() << "==syncUserHistroyReq==" << url <<  StudentData::gestance()->m_httpPort << StudentData::gestance()->m_token.toUtf8() << postData;
    QEventLoop httploop;
    connect(netReply, SIGNAL(finished()), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray replyData = netReply->readAll();
    QJsonObject jsonObj = QJsonDocument::fromJson(replyData).object();

    if(!jsonObj.contains(kSocketCode))
    {
        return false;
    }

    int res = jsonObj.value(kSocketCode).toInt();
    if(0 == res)
    {
        if(jsonObj.contains(kSocketHttpData))
        {
            QJsonObject jsonData = jsonObj.take(kSocketHttpData).toObject();
            if(jsonData.contains(kSocketMn))
            {
                //fix: 同步历史记录(当前房间的最大mn)
                qint32 nRoomMn = jsonData.take(kSocketMn).toInt();
                if(nRoomMn > 0)
                {
                    DataCenter::getInstance()->m_uServerSn = nRoomMn;
                }

                //fix: 同步历史记录(我发送给服务器的最后sn)
                qint32 nMySn = jsonData.take(kSocketSn).toInt();
                if(nMySn > 0)
                {
                    nMySn += 1;
                    MessagePack::getInstance()->fixUserSnFromServer(nMySn);
                }
            }

            //同步历史-是否正在上课
            if(jsonData.contains(kSocketIsHavingClass))
            {
                bool isHavingClass = jsonData.take(kSocketIsHavingClass).toBool();
                qDebug() << "==isHavingClass==" << isHavingClass;
                TemporaryParameter::gestance()->m_isStartClass = isHavingClass;//是否开始上课属性
            }

            //同步历史-是否已经上过课
            if(jsonData.contains(kSocketIsAlreadyClass))
            {
                bool isAlreadyClass = jsonData.take(kSocketIsAlreadyClass).toBool();
                qDebug() << "==isAlreadyClass==" << isAlreadyClass;
                TemporaryParameter::gestance()->m_isAlreadyClass = isAlreadyClass;//isAlreadyClass;//是否上过课属性
            }

            if(jsonData.contains(kSocketHttpMsgs))
            {
                //解析:同步历史记录
                userHistroyData = jsonData.take(kSocketHttpMsgs).toArray();
                return true;
            }
        }
    }

    return false;
}

void ControlCenter::syncUserHistroyComplete()
{
    //同步完成
    if(!DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].empty())
    {
        DataCenter::getInstance()->m_currentPage = DataCenter::getInstance()->m_currentPage >= DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() ? DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() - 1 : DataCenter::getInstance()->m_currentPage;
        qDebug() << "====syncUserHistroyComplete===" << DataCenter::getInstance()->m_currentPage << DataCenter::getInstance()->m_currentCourse << DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size();
        MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
        model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);
    }

    if(m_coursewareCenter)
        m_coursewareCenter->syncCoursewareHistroy();
    DataCenter::getInstance()->m_sysnStatus = true;
    qDebug()<< "sync User Histroy Complete"<< TemporaryParameter::gestance()->m_isStartClass;
    if(TemporaryParameter::gestance()->m_isStartClass == true && DataCenter::getInstance()->m_userRole == USER_ROLE::TEA)
    {
        emit sigBeginClassroom();
    }
    if(TemporaryParameter::gestance()->m_isStartClass == false && DataCenter::getInstance()->m_userRole != USER_ROLE::TEA)
    {
        emit sigNoBeginClass();
    }

}

void ControlCenter::processUserCommandOp(const QString& command, const QJsonObject &jsonMsg, QString& message)
{
    if(command.isEmpty() || jsonMsg.isEmpty())
        return;

    QString fromUser = getMessageUid(jsonMsg);
    if(fromUser.isEmpty())
        return;

    if(kSocketTrail == command)
    {
        parseTrailMessage(fromUser, message);// 解析trail消息
    }
    else if(kSocketPoint == command)
    {
        cachePonitMessage(fromUser, jsonMsg);
    }
    else if(kSocketDoc == command)
    {
        parseDocMessage(fromUser, message);// 解析课件Doc消息
    }
    else if(kSocketAV == command)
    {
        cacheAVMessage(fromUser, jsonMsg);
    }
    else if(kSocketPage == command)
    {
        parsePageMessage(fromUser, message);// 解析课件翻页处理消息
    }
    else if(kSocketAuth == command)
    {
        cacheAuthMessage(fromUser, jsonMsg);
    }
    else if(kSocketMuteAll == command)
    {
        cacheMuteAllMessage(fromUser, jsonMsg);
    }
    else if(kSocketTimer == command)
    {
        cacheTimer(fromUser, message);
    }
    else if(kSocketZoom == command)
    {
        cacheZoomMessage(fromUser, jsonMsg);
    }
    else if(kSocketOperation == command)
    {
        parseOperationMessage(fromUser, message);
    }
    else if(kSocketReward == command)
    {
        cacheReward(fromUser, message);
    }
    else if(kSocketStartClass == command)
    {
        cacheStartClass();
    }
    else if(kSocketPlayAnimation == command)
    {
        parseAnimationMessage(message);
    }
    else if(kSocketSpeak == command)
    {
        parseHandsUpMsg(jsonMsg);
    }
    else
    {
        qDebug() << QString("Error:暂不解析此协议中的数据,") << command;
    }
}

QString ControlCenter::getMessageCommand(const QJsonObject &jsonMsg)
{
    if(jsonMsg.contains(kSocketCmd))
    {
        return jsonMsg[kSocketCmd].toString();
    }

    return "";
}

QString ControlCenter::getMessageUid(const QJsonObject &jsonMsg)
{
    if(jsonMsg.contains(kSocketUid))
    {
        return QString::number(jsonMsg[kSocketUid].toVariant().toLongLong());
    }

    return "";
}

quint32 ControlCenter::getMessageSN(const QJsonObject &jsonMsg)
{
    if(jsonMsg.contains(kSocketSn))
    {
        QJsonValue snValue = jsonMsg[kSocketSn];
        quint32 nSn = snValue.toVariant().toLongLong();
        if(0 != nSn)
        {
            DataCenter::getInstance()->m_uServerSn = nSn;
        }
    }

    return DataCenter::getInstance()->m_uServerSn;
}

// 通过docId得到当前页
int ControlCenter::getCurrentPage(QString docId)
{
    int currentPage = 1;
    currentPage = DataCenter::getInstance()->m_pageSave.value(docId, 1);
    //qDebug() << "===ControlCenter::getCurrentPage=====" << currentPage << m_pages[docId].size() << m_pageSave.value(docId, 1);
    return currentPage;
}

int ControlCenter::getCurrentCoursewarePage()
{
    return DataCenter::getInstance()->m_currentPage;
}

QString ControlCenter::parseMessageDockId(QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains("content"))
    {
        contentJsonObj = jsonObj.take("content").toObject();
    }
    QString coursewareId = "";
    if(contentJsonObj.contains("dockId"))
    {
        coursewareId = contentJsonObj.take("dockId").toString();
    }
    return coursewareId;
}

QString ControlCenter::parseMessagePageId(QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains("content"))
    {
        contentJsonObj = jsonObj.take("content").toObject();
    }

    QString pageId = "";
    if(contentJsonObj.contains("pageId"))
    {
        pageId = contentJsonObj.take("pageId").toString();
    }

    return pageId;
}

void ControlCenter::parseDocMessage(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }
    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains("content"))
    {
        contentJsonObj = jsonObj.take("content").toObject();
    }
    qint32 nPageNo = 0;
    qint32 nPageTotalNum = 0;
    QString coursewareId = "";
    QString coursewareH5Url = "";
    int docType = 0;
    if(contentJsonObj.contains("pageNo"))
    {
        nPageNo = contentJsonObj.take("pageNo").toInt();
    }

    if(contentJsonObj.contains("totalNum"))
    {
        nPageTotalNum = contentJsonObj.take("totalNum").toInt();
    }

    if(contentJsonObj.contains("dockId"))
    {
        coursewareId = contentJsonObj.take("dockId").toString();
    }

    if(contentJsonObj.contains("h5Url"))
    {
        coursewareH5Url =  contentJsonObj.take("h5Url").toString();
    }
    if(contentJsonObj.contains("docType"))
    {
        docType =  contentJsonObj.take("docType").toInt();
    }
    DataCenter::getInstance()->m_currentDocType = docType;
    DataCenter::getInstance()->m_currentCourseUrl = coursewareH5Url;
    qDebug() << "===kSocketDocType::h5URL==" << docType << coursewareH5Url << coursewareId;
    if(m_coursewareCenter)
    {
        m_coursewareCenter->sendSigSynCoursewareType(docType,coursewareH5Url);
        qDebug()<<"m_coursewareCenter->sendSigSynCoursewareType=====================";
    }

    //同步课件状态
    if(!coursewareId.isEmpty())
    {
        if(!DataCenter::getInstance()->m_pages.contains(coursewareId))
        {
            parseCoursewareInfo(message);
        }
        else
        {
            DataCenter::getInstance()->m_currentPage = nPageNo;
            DataCenter::getInstance()->m_currentCourse = coursewareId;

            QJsonArray coursewareUrls;
            if(m_coursewareCenter)
                m_coursewareCenter->cacheDocInfo(coursewareUrls, coursewareId,docType);
        }
    }
}

//清屏、撤销数据解析
void ControlCenter::parseOperationMessage(QString &fromUid, QString &message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }
    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains("content"))
    {
        contentJsonObj = jsonObj.take("content").toObject();
    }

    int currPageOp = 0;
    if(contentJsonObj.contains("type"))
    {
        currPageOp = contentJsonObj.take("type").toVariant().toLongLong();
    }

    //安全性检查
    DataCenter::getInstance()->m_currentPage = (DataCenter::getInstance()->m_currentPage >= DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size()) ? (DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() - 1) : DataCenter::getInstance()->m_currentPage;
    switch(currPageOp)
    {
    case 1: //清屏
    {
        DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage].clear();
    }
    case 2: //撤销
    {
        qDebug() << "=====undo===" << DataCenter::getInstance()->m_currentCourse << fromUid;
        DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage].undo(fromUid);
    }
    default:
    {
        qDebug() << QString("翻页/加页/删页操作类型不在范围内!").toLatin1();
    }
    }

    if(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() > DataCenter::getInstance()->m_currentPage)
    {
        MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
        model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);
        if(m_coursewareCenter)
        {
            m_coursewareCenter->sendSigDrawPage(model);
        }
    }
}

void ControlCenter::parseTrailMessage(QString& fromUid, QString& message)
{
    QString coursewareId = parseMessageDockId(message);
    if(!coursewareId.isEmpty() && parseCoursewareInfo(message))
    {
        DataCenter::getInstance()->m_currentPage = DataCenter::getInstance()->m_currentPage >= DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() ? DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() - 1 : DataCenter::getInstance()->m_currentPage;
        DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage].addMsg(fromUid, message);
    }
}

void ControlCenter::parsePageMessage(QString &fromUid, QString &message)
{
    Q_UNUSED(fromUid);
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }
    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains("content"))
    {
        contentJsonObj = jsonObj.take("content").toObject();
    }
    if(contentJsonObj.contains("type"))
    {
        DataCenter::getInstance()->m_currPageOp = contentJsonObj.take("type").toVariant().toLongLong();
    }
    if(contentJsonObj.contains("pageNo"))
    {
        DataCenter::getInstance()->m_currPageNo = contentJsonObj.take("pageNo").toVariant().toLongLong();
    }
    if(contentJsonObj.contains("totalNum"))
    {
        DataCenter::getInstance()->m_currPageTotalNum = contentJsonObj.take("totalNum").toVariant().toLongLong();
    }
    DataCenter::getInstance()->m_isRemovePage = false;
    switch(DataCenter::getInstance()->m_currPageOp)
    {
    case 1:// 翻页
    {
        if(m_coursewareCenter)
            m_coursewareCenter->goPage(DataCenter::getInstance()->m_currPageNo);
    }
        break;
    case 2:// 增页
    {
        if(m_coursewareCenter)
            m_coursewareCenter->addPage();
    }
        break;
    case 3:// 删页
    {
        if(m_coursewareCenter)
            m_coursewareCenter->delPage();
    }
        break;
    default:
        qDebug() << "翻页/加页/删页操作类型不在范围内!";
        break;
    }
}

void ControlCenter::parseAnimationMessage(QString message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();

    contentJsonObj = jsonObj.take(kSocketContent).toObject();
    int step = contentJsonObj.take(kSocketStep).toInt();
    QString pageId = contentJsonObj.take(kSocketPageId).toString();
    int pageNo = contentJsonObj.take(kSocketPageNo).toInt();
    QString dockId = contentJsonObj.take(kSocketDocDockId).toString();
    DataCenter::getInstance()->m_h5Model.append(H5dataModel(dockId,"3",QString::number(pageNo),"",step));
    DataCenter::getInstance()->m_currentStep = step;

    QJsonObject userInfo = getUserInfo();
    int userRole = user_tea;
    if(userInfo.contains("userRole"))
    {
        userRole = userInfo.take("userRole").toInt();
    }
    if(userRole != user_tea && m_coursewareCenter != NULL)
    {
        m_coursewareCenter->setPlayAnimation(pageId,step);
    }
}

bool ControlCenter::parseCoursewareInfo(QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }
    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains("content"))
    {
        contentJsonObj = jsonObj.take("content").toObject();
    }
    QString dockId;
    if(contentJsonObj.contains("dockId"))
    {
        dockId = contentJsonObj.take("dockId").toString();
    }
    QString pageId;
    if(contentJsonObj.contains("pageId"))
    {
        pageId = contentJsonObj.take("pageId").toString();
    }

    if(dockId == "000000")
    {
        dockId = "DEFAULT";
    }
    if(DataCenter::getInstance()->m_currentCourse != dockId)
    {
        if(!DataCenter::getInstance()->m_pages.contains(dockId) && nullptr != m_coursewareCenter)
        {
            if(!m_coursewareCenter->updateCoursewareInfo(dockId,message))
            {
                return false;
            }
        }
    }
    else
    {
        QString qsCurrPageId(DataCenter::getInstance()->m_currentPage);
        if(qsCurrPageId != pageId)
        {
            if(!DataCenter::getInstance()->m_pages.contains(dockId))
            {
                QJsonArray qsStringList;
                qsStringList.append(pageId);
                if(m_coursewareCenter)
                    m_coursewareCenter->cacheDocInfo(qsStringList, dockId, 1);
            }
        }
    }
    return true;
}

void ControlCenter::cachePonitMessage(QString& fromUid, const QJsonObject &jsonMsg)
{
    QJsonObject contentJsonObj;
    if(jsonMsg.contains(kSocketContent))
    {
        contentJsonObj = jsonMsg[kSocketContent].toObject();
    }

    qint32 xPos = -1, yPos = -1;

    if(contentJsonObj.contains(kSocketPointX))
    {
        xPos = contentJsonObj.take(kSocketPointX).toInt();
    }

    if(contentJsonObj.contains(kSocketPointY))
    {
        yPos = contentJsonObj.take(kSocketPointY).toInt();
    }

    //调节精度
    double  factor = 1000000.000000;

    double factorX = (xPos / factor);
    double factorY = (yPos / factor);

    //同步教鞭位置信息
    drawPointerPosition(factorX, factorY);
}

void ControlCenter::cacheAVMessage(QString& fromUid, const QJsonObject &jsonMsg)
{
    QJsonObject contentJsonObj;
    if(jsonMsg.contains(kSocketContent))
    {
        contentJsonObj = jsonMsg[kSocketContent].toObject();
    }

    int flagState = -1;
    int playTimeSec = -1;
    QString coursewareId = "";
    if(contentJsonObj.contains(kSocketAVFlag))
    {
        flagState = contentJsonObj[kSocketAVFlag].toInt();
    }

    if(contentJsonObj.contains(kSocketTime))
    {
        playTimeSec = contentJsonObj[kSocketTime].toInt();
    }

    if(contentJsonObj.contains(kSocketDocDockId))
    {
        coursewareId = contentJsonObj[kSocketDocDockId].toString();
    }

    if((flagState != -1) && (playTimeSec != -1) && !coursewareId.isEmpty())
    {
        //有值时, 才发信号更新AV播放状态
        DataCenter::getInstance()->m_avFlag = flagState;
        DataCenter::getInstance()->m_avPlayTime = playTimeSec;
        DataCenter::getInstance()->m_avId = coursewareId;
        if(DataCenter::getInstance()->m_sysnStatus)
        {
            QJsonObject avFileInfo;
            avFileInfo.insert(kSocketAVSuffix, contentJsonObj.value(kSocketAVSuffix).toString());
            avFileInfo.insert(kSocketAVPath, contentJsonObj.value(kSocketAVPath).toString());
            avFileInfo.insert("flagState", DataCenter::getInstance()->m_avFlag);
            avFileInfo.insert("playTimeSec", DataCenter::getInstance()->m_avPlayTime);
            emit sigPlayAv(avFileInfo);
        }
    }
}

//同步授权、上下台、视频状态
void ControlCenter::cacheAuthMessage(QString& fromUid, const QJsonObject &jsonMsg)
{
    QJsonObject contentJsonObj;
    if(jsonMsg.contains(kSocketContent))
    {
        contentJsonObj = jsonMsg[kSocketContent].toObject();
    }

    QString qsUid = "";
    if(contentJsonObj.contains(kSocketUid))
    {
        qsUid = contentJsonObj.take(kSocketUid).toString();
    }

    QString qsCurrUid = StudentData::gestance()->m_currentUserId;

    //    if(qsUid == qsCurrUid) //谨慎处理授权状态更新, 防止误操作
    //      此判断如果加了则无法同步其它学生的上下台等权限信息
    //    {
    int upState = -1, trailState = -1, audioState = -1, videoState = -1;

    if(contentJsonObj.contains(kSocketAuthUp))
    {
        upState = contentJsonObj.take(kSocketAuthUp).toInt();
    }

    if(contentJsonObj.contains(kSocketTrail))
    {
        trailState = contentJsonObj.take(kSocketTrail).toInt();
    }

    if(contentJsonObj.contains(kSocketAuthAudio))
    {
        audioState = contentJsonObj.take(kSocketAuthAudio).toInt();
    }

    if(contentJsonObj.contains(kSocketAuthVideo))
    {
        videoState = contentJsonObj.take(kSocketAuthVideo).toInt();
    }

    if((upState != -1) && (trailState != -1) && (audioState != -1) && (videoState != -1))
    {
        //有值时, 才发信号更新授权状态
        TemporaryParameter::gestance()->m_userBrushPermissionsId.insert(qsUid, QString::number(trailState));
        //            StudentData::gestance()->m_userAuth.insert(qsUid,QString::number(trailState));
        QPair<QString, QString> cameraPhonePair(QString::number(videoState),QString::number(audioState));
        StudentData::gestance()->m_cameraPhone.insert(qsUid,cameraPhonePair);
        StudentData::gestance()->m_userUp.insert(qsUid,QString::number(upState));
        emit sigUserAuth(qsUid,upState,trailState,audioState,videoState,DataCenter::getInstance()->m_sysnStatus);
        qDebug() << "====userAuth::data====" << qsUid << upState << trailState << audioState << videoState << TemporaryParameter::gestance()->m_userBrushPermissionsId.size();
    }
    //}
}

void ControlCenter::cacheMuteAllMessage(QString& fromUid, const QJsonObject &jsonMsg)
{
    QJsonObject contentJsonObj;
    if(jsonMsg.contains(kSocketContent))
    {
        contentJsonObj = jsonMsg[kSocketContent].toObject();
    }

    if(contentJsonObj.contains(kSocketMuteAllRet))
    {
        int nRet = contentJsonObj.take(kSocketMuteAllRet).toInt();

        //有值时,才发信号更新全体静音状态
    }
}

void ControlCenter::cacheZoomMessage(QString& fromUid, const QJsonObject &jsonMsg)
{
    QJsonObject contentJsonObj;
    if(jsonMsg.contains(kSocketContent))
    {
        contentJsonObj = jsonMsg[kSocketContent].toObject();
    }

    QString dockId = "";
    qint64 ratio = 0, offsetX = 0, offsetY = 0;

    if(contentJsonObj.contains(kSocketDocDockId) && contentJsonObj.contains(kSocketRatio) &&
            contentJsonObj.contains(kSocketOffsetX) && contentJsonObj.contains(kSocketOffsetY))
    {
        dockId  = contentJsonObj.take(kSocketDocDockId).toString();
        ratio = contentJsonObj.take(kSocketRatio).toVariant().toLongLong();
        offsetX = contentJsonObj.take(kSocketOffsetX).toVariant().toLongLong();
        offsetY = contentJsonObj.take(kSocketOffsetY).toVariant().toLongLong();

        //调节精度
        double  factor = 1000000.000000;

        double factorOffsetRatio = (ratio / factor);
        double factorX = (offsetX / factor);
        double factorY = (offsetY / factor);
        DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage].offsetY = factorY;
        //有值时,才发信号更新放大缩放
    }
}

void ControlCenter::cacheStartClass()
{
    //第一次开始上课清除所有操作
    QString bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QString saveFilePath = bufferFilePath + "/bigClassBegin.dll";
    QFile file(saveFilePath);
    QTextStream textOpera(&file);

    TemporaryParameter::gestance()->m_isStartClass = true;
    if(DataCenter::getInstance()->m_sysnStatus == true)
    {
        emit sigBeginClassroom();
    }

    qDebug() << "==cacheStartClass::saveUserInfo==" << saveFilePath;
    if(file.open(QFile::ReadWrite))
    {
        if(file.exists())
        {
            QString  liveRoom = textOpera.readAll();
            if(liveRoom.contains(StudentData::gestance()->m_liveRoomId))
            {
                textOpera.flush();
                return;
            }
        }
        textOpera.seek(0);
        textOpera << StudentData::gestance()->m_liveRoomId;
        textOpera.flush();
    }
    DataCenter::getInstance()->m_pages.clear();
    DataCenter::getInstance()->m_pageSave.clear();
    TemporaryParameter::gestance()->m_pageSave.clear();
    TemporaryParameter::gestance()->m_userBrushPermissionsId.clear();
    StudentData::gestance()->m_reward.clear();
    StudentData::gestance()->m_userUp.clear();
    StudentData::gestance()->m_cameraPhone.clear();

    QList<MessageModel> list;
    list.append(MessageModel(0, "", 1.0, 1.0, "", "1", 0, false));
    DataCenter::getInstance()->m_pages.insert("DEFAULT", list);
    DataCenter::getInstance()->m_currentPage = 0;
    DataCenter::getInstance()->m_currentCourse = "DEFAULT";
    MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
    model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);
    if(nullptr != m_whiteBoardCenter)
    {
        m_whiteBoardCenter->clearTrails();
    }
    emit sigClearScreen();
}

void ControlCenter::cacheReward(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    QString whoUid  = "";
    if(contentJsonObj.contains(kSocketUid))
    {
        whoUid = contentJsonObj.take(kSocketUid).toString();
    }

    qint32 rewardType = 0;
    if(contentJsonObj.contains(kSocketType))
    {
        rewardType = contentJsonObj.take(kSocketType).toInt();
    }

    qint32 millisecond = 0;
    if(contentJsonObj.contains(kSocketTime))
    {
        millisecond = contentJsonObj.take(kSocketTime).toInt();
    }
    qDebug() << "===reward::userId===" << whoUid;
    //缓存奖励累计信息
    StudentData::gestance()->addReward(whoUid);
    if(nullptr != m_trophyCenter)
    {
        m_trophyCenter->drawTrophy();
    }
}

void ControlCenter::cacheTimer(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    if(!contentJsonObj.isEmpty())
    {
        sigResetTimerView(contentJsonObj);
        return;
    }

    qint32 timerType = 0;
    if(contentJsonObj.contains(kSocketTime))
    {
        timerType = contentJsonObj.take(kSocketType).toInt();
    }

    qint32 timerFlag = 0;
    if(contentJsonObj.contains(kSocketFlag))
    {
        timerFlag = contentJsonObj.take(kSocketFlag).toInt();
    }

    qint32 timeSec = 0;
    if(contentJsonObj.contains(kSocketTime))
    {
        timeSec = contentJsonObj.take(kSocketTime).toInt();
    }

    //缓存计时信息
}

//时间邮戳
quint64 ControlCenter::createTimeStamp()
{
    quint64 timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();
    return timestamp;
}

void ControlCenter::initRectInfo(int width, int height)
{
    double  widths = width / 16.0 ;
    double  heights = (height - width / 16 ) / 9.0 ;
    double fixLength = widths > heights ? heights : widths;

    //全屏高度
    int fullWidth = (int) fixLength * 16;
    int fullHeight = (int) fixLength * 9;

    //左边宽度
    int leftWidth =  width * 86 / 1440 ;
    int leftHeight = height * 900 / 900;
    //右边宽度
    int rightWidth = width * 200 / 1440 ;
    int rightHeight = height * 900 / 900;

    double midWidths = ( width - leftWidth  - rightWidth) / 16.0 ;
    double midFixLength = midWidths > heights ? heights : midWidths;

    //中间高度
    int midWidth = (int) midFixLength * 16;
    int midHeight = (int) midFixLength * 9;

    StudentData::gestance()->midHeight = midHeight;
    StudentData::gestance()->midWidth = midWidth;
    StudentData::gestance()->fullWidth = fullWidth;
    StudentData::gestance()->fullHeight = fullHeight;
}

QJsonObject ControlCenter::stringToJsonParse(const QString &message)
{
    QJsonObject jsonObj;
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError == jsonParseError.error && document.isObject())
    {
        jsonObj = document.object();
    }
    else
    {
        qWarning() << QString("Error:Json parse is failed!").toLatin1();
    }

    return jsonObj;
}
