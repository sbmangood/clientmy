#include "operationchannel.h"
#include <QPainter>
#include <debuglog.h>

OperationChannel * OperationChannel::m_operationChannel = NULL;
bool OperationChannel::m_wayBIsVideoMode = false;

OperationChannel::OperationChannel(QObject *parent) : QObject(parent)
    , m_processingAchannel(NULL)
    , m_isInitStartClass(false)
    , m_isWaysA(true)
{
    m_dateTime = QDateTime::currentDateTime().toMSecsSinceEpoch();
    cam = new CameraCapture(this);
    connect(cam, &CameraCapture::sendData, this, &OperationChannel::receiveData);
    ca = NULL;
    QString carmerId = getDefaultDevicesId("carmer");

    m_httpClient = YMHttpClient::defaultInstance();
    m_httpUrl = m_httpClient->getRunUrl(1);

    if (QCamera::availableDevices().size() > 0)
    {
        int indexCarmer = 0;
        for(int i = 0; i < QCamera::availableDevices().size(); i++)
        {
            QByteArray dataArray =  QCamera::availableDevices().at(i);
            QString carmerName;
            carmerName.prepend(dataArray);
            if(carmerName.contains(carmerId))
            {
                indexCarmer = i;
                //qDebug() << "carmerName" << indexCarmer;
            }
        }
        ca = new QCamera(QCamera::availableDevices().at(indexCarmer));
        ca->setCaptureMode(QCamera::CaptureStillImage);
        connect(ca, SIGNAL(statusChanged(QCamera::Status)), this, SLOT(openCameraError(QCamera::Status)));
        ca->setViewfinder(cam);
        ca->setCaptureMode(QCamera::CaptureVideo);
    }

    m_cameraImageTimes = new QTimer(this);
    connect(m_cameraImageTimes, SIGNAL(timeout() ), this, SLOT( onUploadImageTime() ) );

    m_processingAchannel =  new ProcessingAchannel(this);
    //视频画面信号
    connect(m_processingAchannel, SIGNAL(renderVideoFrameImage(unsigned int, QImage, int)), this, SIGNAL( renderVideoFrameImage(unsigned int, QImage, int ) ));

    connect(m_processingAchannel, SIGNAL(sigAudioVolumeIndication(unsigned int, int  )), this, SIGNAL(sigAudioVolumeIndication(unsigned int, int  ))  );

//    //默认初始化线路A
//    initializeVideoViewWayA();
//    initializeVideoViewWayB();
}

OperationChannel::~OperationChannel()
{

}

void OperationChannel::openCameraError(QCamera::Status err)
{
    //打开摄像头失败启用自定义图片推送
    if(err == QCamera::UnavailableStatus)
    {
        m_cameraImageTimes->start(100);
    }
    //qDebug() << "OperationChannel::openCameraError" << err;
    //DebugLog::gestance()->log("OperationChannel::openCameraError" + err);
}

//上传图片定时器
void OperationChannel::onUploadImageTime()
{
    int times = QDateTime::currentDateTime().toMSecsSinceEpoch();
    if( (times - m_dateTime ) > 500  )
    {
        QImage image(":/images/auvodio_sd_bg_onlinetwox.png");
        image = image.scaled(320, 240, Qt::IgnoreAspectRatio);
        image = image.convertToFormat(QImage::Format_RGB888);
        int length = image.width() * image.height();
        const uchar *bitss = image.bits();

        QVector<uchar> m_arrTimes;
        for (int i = 0; i < length; i++)
        {
            int index = i * 3;
            m_arrTimes.append(bitss[index + 2]);
            m_arrTimes.append(bitss[index + 1]);
            m_arrTimes.append(bitss[index]);
        }
        QImage image1(m_arrTimes.data(), image.width(), image.height(), QImage::Format_RGB888);

        receiveData(image1);
        return;
    }
}

//抓取摄像头数据
void OperationChannel::receiveData(QImage image)
{
    //少于100毫秒不做处理
    //qDebug()<< "OperationChannel::receiveData" << image.size();
    int times = QDateTime::currentDateTime().toMSecsSinceEpoch();
    if( (times - m_dateTime ) <= 100 )
    {
        return;
    }
    m_dateTime = times;
    doRender(image);
    //qDebug() << "OperationChannel::receiveData" << StudentData::gestance()->m_selfStudent.m_studentId.toStdString().c_str();
    LiveVideoFrame frame;
    frame.identifier = StudentData::gestance()->m_selfStudent.m_studentId.toStdString().c_str();//用户Id
    frame.data = image.bits();
    frame.dataSize = image.width() * image.height() * 3;
    frame.desc.externalData = true;
    frame.desc.srcType = VIDEO_SRC_TYPE_SCREEN;
    frame.desc.colorFormat = COLOR_FORMAT_RGB24;
    frame.desc.width = image.width();
    frame.desc.height = image.height();
    frame.desc.rotate = 2;
    //推送到服务器
    int nRet = GetILive()->fillExternalCaptureFrame(frame);
    if (nRet != NO_ERR )
    {
    }
}

//画面旋转
void OperationChannel::doRender(QImage image)
{
    //画面旋转180度
//    long length = image.width() * image.height() * 3;
//    //DebugLog::gestance()->log("image::size2" + QString::number(image.width()) + QString::number(image.height()));
//    const uchar *bitss = image.bits();
//    QVector<uchar> arr;
//    for (int i = length - 1; i >= 0; i--) {
//        arr.append(bitss[i]);
//    }
    //画面不旋转旋转
//    int length = image.width() * image.height();
//    const uchar *bitss = image.bits();
//    QVector<uchar> arr;
//    for (int i = 0; i < length; i++) {
//        int index = i * 3;
//        arr.append(bitss[index+2]);
//        arr.append(bitss[index+1]);
//        arr.append(bitss[index]);
//    }
    //QImage images = QImage(arr.data(),image.width(),image.height(),QImage::Format_RGB888);
    emit renderVideoFrameImage(0, image.rgbSwapped(), 0); //老师的ID，图片，旋转角度
}

OperationChannel *OperationChannel::gestance()
{
    if(m_operationChannel == NULL)
    {
        m_operationChannel = new OperationChannel();
    }
    return m_operationChannel;

}
\
//远程摄像头
void OperationChannel::onRemoteVideo(const LiveVideoFrame *video_frame, void *data)
{
    QString idStr = QString(video_frame->identifier.c_str());
    QString userId = idStr;
    //qDebug()<<"userId =aaa="<<userId;
    if(userId.contains("|"))
    {
        QStringList userIdList = userId.split("|");
        userId = userIdList[0];
    }
    QString strName = TemporaryParameter::gestance()->m_phoneType.value(userId, "") ;//strName

    if(strName.contains("iOS", Qt::CaseInsensitive))
    {
        QImage image(video_frame->data, video_frame->desc.width, video_frame->desc.height, QImage::Format_RGB888);
        LiveVideoFrame *video_frames = const_cast<LiveVideoFrame*> (video_frame);
        video_frames->desc.rotate = 2;
        emit OperationChannel::gestance()->renderVideoFrameImage(userId.toInt(), image.rgbSwapped(), 90);

    }
    else
    {
        QImage image(video_frame->data, video_frame->desc.width, video_frame->desc.height, QImage::Format_RGB888);

        LiveVideoFrame *video_frames = const_cast<LiveVideoFrame*> (video_frame);
        video_frames->desc.rotate = 0;
        //qDebug()<<"OperationChannel::gestance()-> bbbbbbb";
        emit OperationChannel::gestance()->renderVideoFrameImage(userId.toInt(), image.rgbSwapped(), 0);

    }

}
//为了手动推送
void OperationChannel::deviceOpraCallBack(E_DeviceOperationType oper, int retCode, void *data)
{
    OperationChannel * window = (OperationChannel *) data;
    if (oper == E_OpenExternalCapture)
    {
        //启动摄像头
        if(window->ca != NULL)
        {
            window->ca->start();
        }
        window->m_cameraImageTimes->start(100);
        //qDebug() << "OperationChannel::deviceOpraCallBack::startCame"  ;
    }
    else if (oper == E_CloseExternalCapture)    //关闭自定义采集
    {
        if(window->ca != NULL)
        {
            window->ca->stop();
        }
        window->m_cameraImageTimes->stop();
    }
}
//退出房间成功
void OperationChannel::oniLiveQuitRoomSuc(void *data)
{
    DebugLog::gestance()->log("OperationChannel::oniLiveQuitRoomSuc");
    emit SignalClass::gestance()->sigEventLoop();
}
//退出房间失败
void OperationChannel::oniLiveQuitRoomErr(int code, const char *desc, void *data)
{
    DebugLog::gestance()->log("OperationChannel::oniLiveQuitRoomErr");
    emit SignalClass::gestance()->sigEventLoop();
}
//房间断开
void OperationChannel::onRoomDisconnect(int reason, const char *errorInfo, void *data)
{

}

void OperationChannel::onMemStatusChange(E_EndpointEventId event_id, const Vector<String> &ids, void *data)
{

}
//创建房间成功
void OperationChannel::oniLiveCreateRoomSuc(void *data)
{
    //qDebug()<< "OperationChannel::oniLiveCreateRoomSuc";
    emit OperationChannel::gestance()->sigCreateClassroom();// sigCreateClassroom();
    emit SignalClass::gestance()->sigEventLoop();
    DebugLog::gestance()->log("OperationChannel::oniLiveCreateRoomSuc");
}
//创建房间失败
void OperationChannel::oniLiveCreateRoomErr(int code, const char *desc, void *data)
{
    emit OperationChannel::gestance()->wayBCreateRoomFail();
    emit SignalClass::gestance()->sigEventLoop();
    DebugLog::gestance()->log("OperationChannel::oniLiveCreateRoomErr");
}
//离开教室
void OperationChannel::oniLiveLoginSuccess(void *data)
{
    emit SignalClass::gestance()->sigEventLoop();
    DebugLog::gestance()->log("OperationChannel::oniLiveLoginSuccess");
}
//离开教室错误
void OperationChannel::oniLiveLoginError(int code, const char *desc, void *data)
{
    emit SignalClass::gestance()->sigEventLoop();
    DebugLog::gestance()->log("OperationChannel::oniLiveLoginError");
}
//退出登录成功
void OperationChannel::oniLiveLiveLogoutSuc(void *data)
{
    emit SignalClass::gestance()->sigEventLoop();
    DebugLog::gestance()->log("OperationChannel::oniLiveLiveLogoutSuc");
}
//退出登录失败
void OperationChannel::oniLiveLiveLogoutErr(int code, const char *desc, void *data)
{
    emit SignalClass::gestance()->sigEventLoop();
    DebugLog::gestance()->log("OperationChannel::oniLiveLiveLogoutErr");
}
//初始化频道状态
void OperationChannel::initChannelStatus()
{
    QString supplier =  TemporaryParameter::gestance()->m_supplier;
    QString videoType =  TemporaryParameter::gestance()->m_videoType;

    DebugLog::gestance()->log("OperationChannel::initChannelStatus:" + supplier + videoType);
    if(supplier == "1")
    {
        if(TemporaryParameter::gestance()->m_isStartClass)
        {
            exitVideoViewWayA();
        }
        exchangeToWayA();
        DebugLog::gestance()->log("exchangeToWayA");
        m_isWaysA = true;
    }
    else
    {
        exchangeToWayB();
        DebugLog::gestance()->log("exchangeToWayB");
        if(videoType == "0")
        {
            setAudioModeWayB();
        }
        else
        {
            setVideoModeWayB();
        }

        QString phone =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId );
        if(phone != "1")
        {
            //关闭麦克风
            if(m_micList.size() > 0)
            {
                GetILive()->closeMic();
            }
        }
        m_isInitStartClass = true;
        m_processingAchannel->setInitStartClass(m_isInitStartClass);
        m_isWaysA = false;
        DebugLog::gestance()->log("OperationChannel::initChannelStatus::B");
        return;
    }
    if(videoType == "0")
    {
        m_processingAchannel->setAudioMode();
        QString phone =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId );
        if(phone == "1")
        {
            m_processingAchannel->disableOrEnableAudio(false);
        }
        else
        {
            m_processingAchannel->disableOrEnableAudio(true);
        }
    }
    else
    {
        m_processingAchannel->setVideoMode();
        QString phone =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId );
        if(phone == "1")
        {
            m_processingAchannel->disableOrEnableAudio(false);
        }
        else
        {
            m_processingAchannel->disableOrEnableAudio(true);
        }
        QString camcera =  StudentData::gestance()->getUserCamcera(StudentData::gestance()->m_selfStudent.m_studentId );
        if(camcera == "1")
        {
            m_processingAchannel->disableOrEnableVideo( true );
        }
        else
        {
            m_processingAchannel->disableOrEnableVideo(false);
        }
    }
    m_isInitStartClass = true;
    m_processingAchannel->setInitStartClass(m_isInitStartClass);
    DebugLog::gestance()->log("OperationChannel::initChannelStatus::find");
}
//视频线路A初始化
void OperationChannel::initializeVideoViewWayA()
{
    QString idName = QString("YiMiThSd%1").arg(StudentData::gestance()->m_lessonId);
    //m_processingAchannel->joinChannel(idName.toStdString().c_str() ,"",StudentData::gestance()->m_selfStudent.m_studentId.toInt());
}

//视频线路A的退出
void OperationChannel::exitVideoViewWayA()
{
    m_processingAchannel->leaveChannel();
}
//切换到wayA
void OperationChannel::exchangeToWayA()
{
    QString names =  "YiMiThSd" + StudentData::gestance()->m_lessonId;
    m_processingAchannel->exchangeToWaysA();
    m_processingAchannel->joinChannel(names.toStdString().c_str(), "", StudentData::gestance()->m_selfStudent.m_studentId.toInt());
    //qDebug() << "OperationChannel::exchangeToWayA" << StudentData::gestance()->m_selfStudent.m_studentId;
    //DebugLog::gestance()->log("OperationChannel::exchangeToWayA:");
}
//初始化线路B
bool OperationChannel::initializeVideoViewWayB()
{
    m_wayBIsVideoMode = true;

    QEventLoop loop;
    connect(SignalClass::gestance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
    //初始化线路引擎
    GetILive()->init(1400012351, 7286, false);
    //GetILive()->setLocalVideoCallBack(onLocalVideo,this);
    //初始化远端视频
    GetILive()->setRemoteVideoCallBack(onRemoteVideo, this);
    GetILive()->setDeviceOperationCallback(deviceOpraCallBack, this);

    QNetworkAccessManager * httpAccessmanger = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;
    QDateTime dateStr = QDateTime::currentDateTime();
    QString timeStr = QString("%1").arg(dateStr.toTime_t());
    QString teahcStr =  StudentData::gestance()->m_selfStudent.m_studentId + "|" + timeStr;
    QString url("http://" + m_httpUrl + "/lesson/getQQSign?");
    QMap<QString, QString> maps;
    maps.insert("key", teahcStr);
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
    maps.insert("umengAppKey", "597ac22d75ca350dd600227a");
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", dateStr.toString("yyyyMMddhhmmss"));

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

    QByteArray post_data;
    post_data.append(urls);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded"); //QNetworkRequest::ContentLengthHeader, post_data.length());
    httpRequest.setUrl(url);
    QNetworkReply * httpReply = httpAccessmanger->post(httpRequest, post_data);

    QEventLoop httploop;
    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));

    httploop.exec();
    QByteArray bytes = httpReply->readAll();
    QString backData(bytes);

    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(backData.toUtf8(), &error);
    if(error.error == QJsonParseError::NoError)
    {
        if(documet.isObject())
        {
            QJsonObject jsonObjs = documet.object();
            if(jsonObjs.contains("data"))
            {
                QJsonObject jsonObj = jsonObjs.take("data").toObject();
                QString qqSign = jsonObj.take("qqSign").toString();
                StudentData::gestance()->m_qqSign = qqSign;
            }
        }
    }

    //登录  需请求？
    QString userSig =   StudentData::gestance()->m_qqSign;
    QString roomIds = teahcStr;
    QString userId = StudentData::gestance()->m_lessonId + "_" + roomIds + "_main";
    QString md5Id =  QString(QCryptographicHash::hash(userId.toLatin1(), QCryptographicHash::Md5).toHex().toLower());
    StudentData::gestance()->m_audioName = "3933_" + md5Id;
    //qDebug() << "login::roomId" <<  roomIds;
    GetILive()->login(teahcStr.toStdString().c_str(), userSig.toStdString().c_str(), oniLiveLoginSuccess, oniLiveLoginError, this);
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    loop.exec();
    DebugLog::gestance()->log("OperationChannel::initializeVideoViewWayB:");
    return true;
}

QString OperationChannel::getDefaultDevicesId(QString deviceKey)
{
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";

    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
        return "";
    }
    QSettings deviceSetting(m_systemPublicFilePath + "deviceInfo.dll", QSettings::IniFormat);

    deviceSetting.beginGroup("Device");
    DebugLog::gestance()->log("OperationChannel::getDefaultDevicesId:");
    return deviceSetting.value(deviceKey).toString();
}

//视频线路B的退出
void OperationChannel::exitVideoViewWayB()
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(SignalClass::gestance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
    // GetILive()->closeCamera();
    GetILive()->closeMic();
    GetILive()->closePlayer();
    GetILive()->quitRoom(oniLiveQuitRoomSuc, oniLiveQuitRoomErr, this);
    m_cameraImageTimes->stop();
    if (ca != NULL)
    {
        ca->stop();
    }

    loop.exec();
    DebugLog::gestance()->log("OperationChannel::exitVideoViewWayB");
}
// 切换到线路B
void OperationChannel::exchangeToWayB()
{
    //创建、加入房间
    wayBCreateRoom();
    //GetILive()->getCameraList(m_cameraList);
    Vector< Pair<String/*id*/, String/*name*/> > playerList;
    GetILive()->getPlayerList(playerList);

    GetILive()->getMicList(m_micList);
    if(playerList.size() > 0)
    {
        QString playerId = getDefaultDevicesId("player");
        bool isHasDefaultDevice = false;
        for(int a = 0 ; a < playerList.size(); a++)
        {
            if(playerId == playerList.at(a).first.c_str())
            {
                isHasDefaultDevice = true;
                GetILive()->openPlayer(playerList.at(a).first.c_str());
                break;
            }
        }
        if(!isHasDefaultDevice)
        {
            GetILive()->openPlayer(playerList.at(0).first.c_str());
        }
    }

    // 默认初始化第一个摄像设备
    GetILive()->openExternalCapture();

    //打开麦克风
    QString microphone =  StudentData::gestance()->m_microphone;
    // qDebug() << "microphone:" << microphone;

    //将本地摄像头麦克风状态添加到列表
    QPair<QString, QString> pairStatus("1", microphone);
    StudentData::gestance()->m_cameraPhone.insert("0", pairStatus);

    if(microphone == "1")
    {
        GetILive()->closeMic();
        StudentData::gestance()->m_microphone = "1";
        return;
    }
    //打开麦克风
    if(m_micList.size() > 0)
    {
        QString recorderId = getDefaultDevicesId("recorder");
        bool isHasDefaultDevice = false;
        for(int a = 0 ; a < m_micList.size(); a++)
        {
            if(recorderId == m_micList.at(a).first.c_str())
            {
                isHasDefaultDevice = true;
                GetILive()->openMic( m_micList.at(a).first.c_str());
                break;
            }
        }
        if(!isHasDefaultDevice)
        {
            GetILive()->openMic( m_micList.at(0).first.c_str());
        }
        StudentData::gestance()->m_microphone = "0";
    }

    DebugLog::gestance()->log("OperationChannel::exchangeToWayB:");
}
// 创建加入房间
void OperationChannel::wayBCreateRoom()
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(SignalClass::gestance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
    //创建房间
    //qDebug() << "wayBCreateRoom::" << StudentData::gestance()->m_lessonId.toInt();
    iLiveRoomOption roomOption;
    roomOption.roomId = StudentData::gestance()->m_lessonId.toInt();        //需请求？
    roomOption.authBuffer = "";
    roomOption.controlRole = "LiveMaster";
    roomOption.audioCategory = AUDIO_CATEGORY_MEDIA_PLAY_AND_RECORD;//互动直播场景
    roomOption.autoRequestCamera = true ; //VIDEO_RECV_MODE_MANUAL ;//VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO; //半自动模式
    roomOption.autoRequestScreen = true;// SCREEN_RECV_MODE_MANUAL; //SCREEN_RECV_MODE_SEMI_AUTO_RECV_SCREEN_VIDEO;//半自动模式
    roomOption.authBits = AUTH_BITS_DEFAULT;
    roomOption.roomDisconnectListener = onRoomDisconnect;
    roomOption.memberStatusListener = onMemStatusChange;
    roomOption.data = this;
    GetILive()->createRoom(roomOption, oniLiveCreateRoomSuc, oniLiveCreateRoomErr, this);

    loop.exec();
    //qDebug()<< "OperationChannel::wayBCreateRoom";
    //DebugLog::gestance()->log("OperationChannel::wayBCreateRoom");
}
//设置b通道音频
void OperationChannel::setAudioModeWayB()
{
    if(m_wayBIsVideoMode)
    {
        m_wayBIsVideoMode = false;
    }
}

//设置b通道视频显示模式
void OperationChannel::setVideoModeWayB()
{
    if(!m_wayBIsVideoMode)
    {
        QString camcera =  StudentData::gestance()->getUserCamcera(StudentData::gestance()->m_selfStudent.m_studentId );
        if(camcera == "1")
        {
            m_wayBIsVideoMode = true;
        }
        else
        {
            m_wayBIsVideoMode = false;
        }
    }
}
//改变频道
void OperationChannel::changeChanncel()
{
    QString  supplier =  TemporaryParameter::gestance()->m_supplier;

    if(supplier == "1")
    {
        if(!m_isWaysA)
        {
            exitVideoViewWayB();//b
            exchangeToWayA();
            m_isWaysA = true;
        }

    }
    else
    {
        if(m_isWaysA)
        {
            exitVideoViewWayA();
            exchangeToWayB();
            m_isWaysA = false;
        }
    }
    changeAudio();
}

//改变音频
void OperationChannel::changeAudio()
{
    QString  supplier =  TemporaryParameter::gestance()->m_supplier;
    QString videoType = TemporaryParameter::gestance()->m_videoType;
    if(supplier == "1")
    {
        if(videoType == "0")
        {
            m_processingAchannel->setAudioMode();
            QString phone =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId );
            if(phone == "1")
            {
                m_processingAchannel->disableOrEnableAudio(false);
            }
            else
            {
                m_processingAchannel->disableOrEnableAudio(true);
            }
        }
        else
        {
            m_processingAchannel->setVideoMode();
            QString phone =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId );
            if(phone == "1")
            {
                m_processingAchannel->disableOrEnableAudio(false);
            }
            else
            {
                m_processingAchannel->disableOrEnableAudio(true);
            }
            QString camcera =  StudentData::gestance()->getUserCamcera(StudentData::gestance()->m_selfStudent.m_studentId );
            if(camcera == "1")
            {
                m_processingAchannel->disableOrEnableVideo(true);
            }
            else
            {
                m_processingAchannel->disableOrEnableVideo(false);
            }
        }

    }
    else
    {
        if(videoType == "0")
        {
            setAudioModeWayB();
        }
        else
        {
            setVideoModeWayB();
        }
        QString phone =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId );
        if(phone != "1")
        {
            //关闭麦克风
            if(m_micList.size() > 0)
            {
                GetILive()->closeMic();
            }
        }
    }
    sigAisleFinish();
}
//关闭音频
void OperationChannel::closeAudio(QString status)
{
    QString  supplier =  TemporaryParameter::gestance()->m_supplier;
    StudentData::gestance()->setUserPhone(StudentData::gestance()->m_selfStudent.m_studentId, status);
    if(supplier == "1")
    {
        if(status == "1")
        {
            m_processingAchannel->disableOrEnableAudio(false);
        }
        else
        {
            m_processingAchannel->disableOrEnableAudio(true);
        }
        StudentData::gestance()->m_microphone = status;
    }
    else
    {
        if(status == "1")
        {
            if(m_micList.size() > 0)
            {
                QString recorderId = getDefaultDevicesId("recorder");
                bool isHasDefaultDevice = false;
                for(int a = 0 ; a < m_micList.size(); a++)
                {
                    if(recorderId == m_micList.at(a).first.c_str())
                    {
                        isHasDefaultDevice = true;
                        GetILive()->openMic( m_micList.at(a).first.c_str());
                        break;
                    }
                }
                if(!isHasDefaultDevice)
                {
                    GetILive()->openMic( m_micList.at(0).first.c_str());
                }
                StudentData::gestance()->m_microphone = status;
            }

        }
        else
        {
            //关闭麦克风
            if(m_micList.size() > 0)
            {
                GetILive()->closeMic();
            }
            StudentData::gestance()->m_microphone = status;
        }
    }
}


//关闭视频
void OperationChannel::closeVideo(QString status)
{
    StudentData::gestance()->setUserCamcera(StudentData::gestance()->m_selfStudent.m_studentId, status);

    QString  supplier =  TemporaryParameter::gestance()->m_supplier;
    if(supplier == "1")
    {
        if(status == "1")
        {
            m_processingAchannel->setVideoMode();
            m_processingAchannel->disableOrEnableVideo(true);
        }
        else
        {
            m_processingAchannel->disableOrEnableVideo(false);
        }
        StudentData::gestance()->m_camera = status;
    }
    else
    {
        if(status == "1")
        {
            m_wayBIsVideoMode = true;
        }
        else
        {
            m_wayBIsVideoMode = false;
        }
        StudentData::gestance()->m_camera = status;
    }
}
//设置留在教室
void OperationChannel::setStayInclassroom()
{
    QString supplier =  TemporaryParameter::gestance()->m_supplier;
    //qDebug() << "OperationChannel::setStayInclassroom" << supplier;
    if( supplier == "1")
    {
        exitVideoViewWayA();
    }
    else
    {
        exitVideoViewWayB();
        exitBLoginUserName();
        QNetworkAccessManager * httpAccessmanger = new QNetworkAccessManager(this);
        QNetworkRequest httpRequest;
        QDateTime dateStr = QDateTime::currentDateTime();
        QString teahcStr = StudentData::gestance()->m_selfStudent.m_studentId  + "|" + QString::number(dateStr.toTime_t()); // StudentData::gestance()->m_teacher.m_teacherId +"|"+QString::number(dateStr.toTime_t());
        QString url("http://" + m_httpUrl + "/lesson/getQQSign?");
        QMap<QString, QString> maps;
        maps.insert("key", teahcStr);
        maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
        maps.insert("umengAppKey", "597ac22d75ca350dd600227a");
        maps.insert("appVersion", StudentData::gestance()->m_appVersion);
        maps.insert("token", StudentData::gestance()->m_token);
        maps.insert("timestamp", dateStr.toString("yyyyMMddhhmmss"));
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


        QByteArray post_data;
        post_data.append(urls);
        httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded"); //QNetworkRequest::ContentLengthHeader, post_data.length());
        httpRequest.setUrl(url);
        QNetworkReply * httpReply = httpAccessmanger->post(httpRequest, post_data);

        QEventLoop httploop;
        connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));

        httploop.exec();
        QByteArray bytes = httpReply->readAll();
        QString backData(bytes);
        // qDebug()<<"backData =="<<backData;
        DebugLog::gestance()->log("OperationChannel::setStayInclassroom::data");
        QJsonParseError error;
        QJsonDocument documet = QJsonDocument::fromJson(backData.toUtf8(), &error);
        if(error.error == QJsonParseError::NoError)
        {
            if(documet.isObject())
            {
                QJsonObject jsonObjs = documet.object();
                if(jsonObjs.contains("data"))
                {
                    QJsonObject jsonObj = jsonObjs.take("data").toObject();

                    QString qqSign = jsonObj.take("qqSign").toString();

                    StudentData::gestance()->m_qqSign = qqSign;
                }
            }
        }

        //登录
        QEventLoop loop;
        connect(SignalClass::gestance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
        QString userSig =   StudentData::gestance()->m_qqSign;

        QString timeStr = QString("%1").arg(dateStr.toTime_t());
        QString roomIds = teahcStr;
        QString userId = StudentData::gestance()->m_lessonId + "_" + roomIds + "_main";
        //  qDebug() << "ilive login"<<userId<<"0000000000000000000000"<<userSig;
        QString md5Id =  QString(QCryptographicHash::hash(userId.toLatin1(), QCryptographicHash::Md5).toHex().toLower());
        StudentData::gestance()->m_audioName = "3933_" + md5Id;
        // qDebug() << "ilive login"<<md5Id<<"0000000000000000000000"<<userSig;
        GetILive()->login(teahcStr.toStdString().c_str(), userSig.toStdString().c_str(), oniLiveLoginSuccess, oniLiveLoginError, this);
        QTimer::singleShot(5000, &loop, SLOT(quit()));
        loop.exec();
        DebugLog::gestance()->log("OperationChannel::setStayInclassroom::login");
    }
}

//退出教室 b
void OperationChannel::exitBLoginUserName()
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(SignalClass::gestance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
    GetILive()->logout(oniLiveLiveLogoutSuc, oniLiveLiveLogoutErr, this);
    loop.exec();
}

