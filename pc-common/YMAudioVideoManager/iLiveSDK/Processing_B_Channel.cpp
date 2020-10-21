#include "Processing_B_Channel.h"

Processing_B_Channel* Processing_B_Channel::m_processing_B_Channel = NULL;

Processing_B_Channel::Processing_B_Channel(): ca(NULL)
{

}

Processing_B_Channel::~Processing_B_Channel()
{
    if(NULL != ca)
    {
        delete ca;
        ca = NULL;
    }
    if(NULL != m_cameraImageTimes)
    {
        delete m_cameraImageTimes;
        m_cameraImageTimes = NULL;
    }
}

Processing_B_Channel* Processing_B_Channel::getInstance()
{
    if(NULL == m_processing_B_Channel)
    {
        m_processing_B_Channel = new Processing_B_Channel();
    }
    return m_processing_B_Channel;
}

void Processing_B_Channel::openCameraError(QCamera::Status err)
{
    //打开摄像头失败启用自定义图片推送
    if(err == QCamera::UnavailableStatus)
    {
        m_cameraImageTimes->start(100);
    }
    qDebug() << "Processing_B_Channel::openCameraError" << err;
}

// 上传图片
void Processing_B_Channel::onUploadImageTime()
{
    int times = QDateTime::currentDateTime().toMSecsSinceEpoch();
    if((times - m_dateTime) > 500)
    {
        QImage image(":/images/auvodio_sd_bg_onlinetwox.png");
        image = image.scaled(640, 360, Qt::IgnoreAspectRatio);
        image = image.convertToFormat(QImage::Format_RGB888);
        int length = image.width() * image.height();
        const uchar *bitss = image.bits();
        QVector<uchar> m_arrTimes;
        for(int i = 0; i < length; i++)
        {
            int index = i * 3;
            m_arrTimes.append(bitss[index + 2]);
            m_arrTimes.append(bitss[index + 1]);
            m_arrTimes.append(bitss[index]);
        }
        QImage image1(m_arrTimes.data(), image.width(), image.height(), QImage::Format_RGB888);
        receiveData(image1);
    }
}

// 摄像头采集数据
void Processing_B_Channel::receiveData(QImage image)
{
    // 少于100毫秒不做处理
    int times = QDateTime::currentDateTime().toMSecsSinceEpoch();
    if((times - m_dateTime) <= 100)
    {
        return;
    }
    m_dateTime = times;
    image = image.scaled(640, 360, Qt::IgnoreAspectRatio);
    emit renderVideoFrameImage(0, image.rgbSwapped(), 0); // 老师的ID，图片，旋转角度

    // for beautyImage
    QImage tImage = image.rgbSwapped();
    tImage.save("0","jpg");
    int tSize = BeautyList::getInstance()->hasBeautyImageList.size();
    if(tSize > 0 && BeautyList::getInstance()->beautyIsOn)
    {
        QImage tImg;
        tImg =  BeautyList::getInstance()->hasBeautyImageList.at(tSize - 1).scaled(640,360,Qt::IgnoreAspectRatio,Qt::SmoothTransformation);
        tImg = tImg.convertToFormat(QImage::Format_RGB888);

        if(tSize > 200 )
        {
            BeautyList::getInstance()->hasBeautyImageList.clear();
            BeautyList::getInstance()->hasBeautyImageList.append(tImg);
        }
        image = tImg.rgbSwapped();
    }

    LiveVideoFrame frame;
    frame.identifier = m_userId.toStdString().c_str();// 用户Id
    frame.data = image.bits();
    frame.dataSize = image.width() * image.height() * 3;
    frame.desc.externalData = true;
    frame.desc.srcType = VIDEO_SRC_TYPE_SCREEN;
    frame.desc.colorFormat = COLOR_FORMAT_RGB24;
    frame.desc.width = image.width();
    frame.desc.height = image.height();
    frame.desc.rotate = 2;
    // 角色是老师或学生才推送到服务器
    if(m_role == TEACHER ||m_role == STUDENT)
    {
        int nRet = GetILive()->fillExternalCaptureFrame(frame);
        if (nRet != NO_ERR )
        {
            qDebug()<<"GetILive()->fillExternalCaptureFrame(frame) failed.";
        }
    }
}

// 初始化频道
bool Processing_B_Channel::initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                                       QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath)
{
    m_courseType = courseType;
    m_role = role;
    m_userId = userId;
    m_camera = camera;
    m_microphone = microphone;
    m_lessonId = lessonId;
    m_apiVersion = apiVersion;
    m_appVersion = appVersion;
    m_token = token;
    m_strDllFile = strDllFile;
    m_strAppName = strAppName;
    m_logFilePath = logFilePath;
    m_dateTime = QDateTime::currentDateTime().toMSecsSinceEpoch();
    cam = new CameraCapture();
    connect(cam, &CameraCapture::sendData, this, &Processing_B_Channel::receiveData);
    QString carmerId = getDefaultDevicesId("carmer");
    m_httpClient = YMHttpClientUtils::getInstance();
    m_httpUrl = m_httpClient->getRunUrl(1, m_strDllFile, m_strAppName);
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
            }
        }
        ca = new QCamera(QCamera::availableDevices().at(indexCarmer));
        ca->setCaptureMode(QCamera::CaptureStillImage);
        connect(ca, SIGNAL(statusChanged(QCamera::Status)), this, SLOT(openCameraError(QCamera::Status)));
        ca->setViewfinder(cam);
        ca->setCaptureMode(QCamera::CaptureVideo);
    }
    m_cameraImageTimes = new QTimer(this);
    connect(m_cameraImageTimes, SIGNAL(timeout()), this, SLOT(onUploadImageTime()));
    // 初始化线路引擎
    GetILive()->init(1400012351, 7286, false);
    // 初始化远端视频
    GetILive()->setRemoteVideoCallBack(onRemoteVideo, this);
    GetILive()->setDeviceOperationCallback(deviceOpraCallBack, this);
    return true;
}

// 进入频道
bool Processing_B_Channel::enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan)
{
    qDebug() << "Processing_B_Channel::enterChannel";
    // 先登录
    login();
    // 创建、加入房间
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(SignalClass::getInstance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
    iLiveRoomOption roomOption;
    roomOption.roomId = m_lessonId.toInt();
    roomOption.authBuffer = "";
    if(Processing_B_Channel::getInstance()->m_role == TEACHER)
    {
        roomOption.controlRole = "LiveMaster";
    }
    else if(Processing_B_Channel::getInstance()->m_role == STUDENT)
    {
        roomOption.controlRole = "LiveGuestA";
    }
    else
    {
        roomOption.controlRole = "LiveGuestB";
    }
    roomOption.audioCategory = AUDIO_CATEGORY_MEDIA_PLAY_AND_RECORD;//互动直播场景
    roomOption.autoRequestCamera = true ; //VIDEO_RECV_MODE_MANUAL ;//VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO; //半自动模式
    roomOption.autoRequestScreen = true;// SCREEN_RECV_MODE_MANUAL; //SCREEN_RECV_MODE_SEMI_AUTO_RECV_SCREEN_VIDEO;//半自动模式
    roomOption.authBits = AUTH_BITS_DEFAULT;
    roomOption.roomDisconnectListener = onRoomDisconnect;
    roomOption.memberStatusListener = onMemStatusChange;
    roomOption.data = this;
    GetILive()->createRoom(roomOption, oniLiveCreateRoomSuc, oniLiveCreateRoomErr, this);
    loop.exec();
    // 初始化设备
    Vector<Pair<String, String> > playerList;
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
    // 将本地摄像头麦克风状态添加到列表
    QPair<QString, QString> pairStatus("1", m_microphone);
    cameraPhone.insert("0", pairStatus);
    if(m_microphone == "1")
    {
        GetILive()->closeMic();
        return false;
    }
    // 打开麦克风
    if(m_micList.size() > 0)
    {
        QString recorderId = getDefaultDevicesId("recorder");
        bool isHasDefaultDevice = false;
        for(int a = 0 ; a < m_micList.size(); a++)
        {
            if(recorderId == m_micList.at(a).first.c_str())
            {
                isHasDefaultDevice = true;
                if(Processing_B_Channel::getInstance()->m_role == TEACHER)
                {
                    GetILive()->openMic(m_micList.at(a).first.c_str()); // 持麦者, 则打开麦克风
                }
                else
                {
                    GetILive()->closeMic(); // 旁听则关闭麦克风
                }
                break;
            }
        }
        if(!isHasDefaultDevice)
        {
            if(Processing_B_Channel::getInstance()->m_role == TEACHER)
            {
                GetILive()->openMic( m_micList.at(0).first.c_str()); // 持麦者, 则打开麦克风
            }
            else
            {
                GetILive()->closeMic(); // 旁听则关闭麦克风
            }
        }
    }
    return true;
}

// 房间断开
void Processing_B_Channel::onRoomDisconnect(int reason, const char *errorInfo, void *data)
{

}

void Processing_B_Channel::onMemStatusChange(E_EndpointEventId event_id, const Vector<String> &ids, void *data)
{

}

// 创建房间成功
void Processing_B_Channel::oniLiveCreateRoomSuc(void *data)
{
    emit Processing_B_Channel::getInstance()->createRoomSucess();
    emit SignalClass::getInstance()->sigEventLoop();
}

// 创建房间失败
void Processing_B_Channel::oniLiveCreateRoomErr(int code, const char *desc, void *data)
{
    qDebug() << "Processing_B_Channel::oniLiveCreateRoomErr" << code << desc;
    if(code != 8024) // 房间已经存在, 第二次创建的时候, 返回失败: 8024 createRoom(): already in room.
    {
        emit Processing_B_Channel::getInstance()->createRoomFail();
        emit SignalClass::getInstance()->sigEventLoop();
    }
}

// 离开频道
bool Processing_B_Channel::leaveChannel()
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(SignalClass::getInstance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
    GetILive()->closeCamera();
    GetILive()->closeMic();
    GetILive()->closePlayer();
    GetILive()->quitRoom(oniLiveQuitRoomSuc, oniLiveQuitRoomErr, this);
    m_cameraImageTimes->stop();
    if (ca != NULL)
    {
        ca->stop();
    }
    loop.exec();
    return true;
}

// 退出房间成功
void Processing_B_Channel::oniLiveQuitRoomSuc(void *data)
{
    qDebug() << "====Processing_B_Channel::oniLiveQuitRoomSuc==";
    if(Processing_B_Channel::getInstance()->m_role == TEACHER)//老师端需要logout, 学生端不需要logout
    {
        exitBLoginUserName();
    }

    emit SignalClass::getInstance()->sigEventLoop();
}

// 退出房间失败
void Processing_B_Channel::oniLiveQuitRoomErr(int code, const char *desc, void *data)
{
    qDebug() << "Processing_B_Channel::oniLiveQuitRoomErr" << code << desc;
    if(Processing_B_Channel::getInstance()->m_role == TEACHER)// 老师端需要logout, 学生端不需要logout
    {
        exitBLoginUserName();
    }
    emit SignalClass::getInstance()->sigEventLoop();
}

// 退出登录
void Processing_B_Channel::exitBLoginUserName()
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(SignalClass::getInstance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
    GetILive()->logout(oniLiveLiveLogoutSuc, oniLiveLiveLogoutErr, NULL);
    loop.exec();

}

// 退出登录成功
void Processing_B_Channel::oniLiveLiveLogoutSuc(void *data)
{
    qDebug() << "=========Processing_B_Channel::oniLiveLiveLogoutSuc====";
    emit SignalClass::getInstance()->sigEventLoop();
}

// 退出登录失败
void Processing_B_Channel::oniLiveLiveLogoutErr(int code, const char *desc, void *data)
{
    qDebug() << "Processing_B_Channel::oniLiveLiveLogoutErr" << code << desc;
    emit SignalClass::getInstance()->sigEventLoop();
}

// 登录成功
void Processing_B_Channel::oniLiveLoginSuccess(void *data)
{
    qDebug() << "Processing_B_Channel::oniLiveLoginSuccess";
}

// 登录错误
void Processing_B_Channel::oniLiveLoginError(int code, const char *desc, void *data)
{
    qDebug() << "Processing_B_Channel::oniLiveLoginError" << code << desc;
    if(code == 8024)
    {
        return;
    }
    emit SignalClass::getInstance()->sigEventLoop();
}

// 登录
void Processing_B_Channel::login()
{
    qDebug() << "Processing_B_Channel::login";
    //==================================================
    QEventLoop loop;
    connect(SignalClass::getInstance(), SIGNAL(sigEventLoop()), &loop, SLOT(quit()) );
    QNetworkAccessManager * httpAccessmanger = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;

    QString teahcStr;
    QDateTime dateStr;
    if(m_role == TEACHER)
    {
        dateStr = QDateTime::currentDateTime();
        QString timeStr = QString("%1").arg(dateStr.toTime_t());
        teahcStr =  m_userId + "|" + timeStr;
    }
    else
    {
        teahcStr =  m_userId;
    }

    QString url("http://" + m_httpUrl + "/lesson/getQQSign?");
    QMap<QString, QString> maps;
    maps.insert("key", teahcStr);
    maps.insert("apiVersion", m_apiVersion);
    maps.insert("umengAppKey", "597ac22d75ca350dd600227a");
    maps.insert("appVersion", m_appVersion);
    maps.insert("token", m_token);

    if(m_role == TEACHER)
    {
        maps.insert("timestamp", dateStr.toString("yyyyMMddhhmmss"));
    }

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
                m_qqSign = jsonObj.take("qqSign").toString();
            }
        }
    }

    //登录  需请求？
    QString userSig = m_qqSign;
    QString roomIds = teahcStr;
    QString userId = m_lessonId + "_" + roomIds + "_main";
    QString md5Id =  QString(QCryptographicHash::hash(userId.toLatin1(), QCryptographicHash::Md5).toHex().toLower());
    m_audioName = "3933_" + md5Id;
    emit Processing_B_Channel::getInstance()->sigAudioName(m_audioName);
    GetILive()->login(teahcStr.toStdString().c_str(), userSig.toStdString().c_str(), oniLiveLoginSuccess, oniLiveLoginError, this);
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    loop.exec();
}

// 打开本地音频
bool Processing_B_Channel::openLocalAudio()
{
    GetILive()->getMicList(m_micList);
    if(m_micList.size() > 0)
    {
        QString recorderId = getDefaultDevicesId("recorder");
        bool isHasDefaultDevice = false;
        for(int a = 0 ; a < m_micList.size(); a++)
        {
            if(recorderId == m_micList.at(a).first.c_str())
            {
                isHasDefaultDevice = true;
                GetILive()->openMic(m_micList.at(a).first.c_str());
                break;
            }
        }
        if(!isHasDefaultDevice)
        {
            GetILive()->openMic(m_micList.at(0).first.c_str());
        }
    }
    return true;
}

// 关闭本地音频
bool Processing_B_Channel::closeLocalAudio()
{
    GetILive()->closeMic();
    return true;
}

// 打开本地视频
bool Processing_B_Channel::openLocalVideo()
{
    QString camera =  m_camera;
    if(camera == "1" && NULL != ca)
    {
        ca->start();
    }
    return true;
}

// 关闭本地视频
bool Processing_B_Channel::closeLocalVideo()
{
    if (ca != NULL)
    {
        ca->stop();
    }
    return true;
}

QString Processing_B_Channel::getDefaultDevicesId(QString deviceKey)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString m_systemPublicFilePath;
    QDir dir;
    if (docPath == "" || !dir.exists(docPath)) //docPath是空, 或者不存在
    {
        m_systemPublicFilePath = "C:/";
    }
    else
    {
        m_systemPublicFilePath = docPath + "/";
    }

    m_systemPublicFilePath += "/YiMi/temp/";

    QDir isDir;
    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
        return "";
    }
    QSettings deviceSetting(m_systemPublicFilePath + "deviceInfo.dll", QSettings::IniFormat);
    deviceSetting.setIniCodec(QTextCodec::codecForName("UTF-8"));

    deviceSetting.beginGroup("Device");

    qDebug() << "Processing_B_Channel::getDefaultDevicesId" << deviceSetting.value(deviceKey).toString() << __LINE__;
    return deviceSetting.value(deviceKey).toString();
}

// 远程摄像头
void Processing_B_Channel::onRemoteVideo(const LiveVideoFrame *video_frame, void *data)
{
    QString idStr = QString(video_frame->identifier.c_str());
    QString userId = idStr;
    if(userId.contains("|"))
    {
        QStringList userIdList = userId.split("|");
        userId = userIdList[0];
    }
    int iRotation = 0; //旋转的角度
    //======================= >>>
    //通过宽度, 和高度的比例, 判断图像是否需要旋转
    //正常情况下, 是宽度大于高度, 如果高度大于宽度的时候, 就旋转
    int iRate = video_frame->desc.width / video_frame->desc.height;
    if(iRate >= 1)
    {
        iRotation = 0;
    }
    else
    {
        iRotation = 90;
    }
    QImage image(video_frame->data, video_frame->desc.width, video_frame->desc.height, QImage::Format_RGB888);
    LiveVideoFrame *video_frames = const_cast<LiveVideoFrame*> (video_frame);
    video_frames->desc.rotate = 0;
    emit Processing_B_Channel::getInstance()->renderVideoFrameImage(userId.toInt(), image.rgbSwapped(), iRotation);
}

// 为了手动推送
void Processing_B_Channel::deviceOpraCallBack(E_DeviceOperationType oper, int retCode, void *data)
{
    Processing_B_Channel * window = (Processing_B_Channel *) data;
    if (oper == E_OpenExternalCapture)
    {
        //启动摄像头
        if(window->ca != NULL)
        {
            window->ca->start();
        }
        window->m_cameraImageTimes->start(100);
        qDebug() << "Processing_B_Channel::deviceOpraCallBack::startCame"  ;
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
