#include "Processing_B2_Channel.h"
#include <SDKDDKVer.h>
#include <Shlwapi.h>
#include "libyuv.h"
#include <string>
#pragma comment(lib,"shlwapi.lib")

const QString kTestAppId = "1400183730";
const QString kProduceAppId = "1400183738";

Processing_B2_Channel* Processing_B2_Channel::m_Processing_B2_Channel = NULL;

Processing_B2_Channel::Processing_B2_Channel(): m_LiteAVVideoRenderCallback(NULL),ca(NULL)
{
    m_nLenYUV = m_nWidth * m_nHeight * 3 / 2;
    m_lpBufferYUV = new unsigned char[m_nLenYUV];
    videoFrame.data = new char[m_nLenYUV];// 此处必须手动开辟内存
    m_LiteAVVideoRenderCallback = new LiteAVVideoRenderCallback();
    connect(m_LiteAVVideoRenderCallback, SIGNAL(renderVideoFrameImage(uint,QImage,int)), this, SIGNAL(renderVideoFrameImage(uint,QImage,int)));
}

Processing_B2_Channel::~Processing_B2_Channel()
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
    if(NULL != m_lpBufferYUV)
    {
        delete m_lpBufferYUV;
        m_lpBufferYUV = NULL;
    }
    if(NULL != videoFrame.data)
    {
        delete videoFrame.data;
        videoFrame.data = NULL;
    }
    if(NULL != m_LiteAVVideoRenderCallback)
    {
        delete m_LiteAVVideoRenderCallback;
        m_LiteAVVideoRenderCallback = NULL;
    }
    m_pTrtcCloud->removeCallback(this);
    m_pDestroyTRTCShareInstance;
}

Processing_B2_Channel* Processing_B2_Channel::getInstance()
{
    if(NULL == m_Processing_B2_Channel)
    {
        m_Processing_B2_Channel = new Processing_B2_Channel();
    }
    return m_Processing_B2_Channel;
}

void Processing_B2_Channel::openCameraError(QCamera::Status err)
{
    // 打开摄像头失败启用自定义图片推送
    if(err == QCamera::UnavailableStatus)
    {
        m_cameraImageTimes->start(100);
    }
    qDebug() << "Processing_B2_Channel::openCameraError" << err;
}

// 上传图片
void Processing_B2_Channel::onUploadImage()
{
    qDebug()<<"============== Processing_B2_Channel::onUploadImage() ==========";
    int times = QDateTime::currentDateTime().toMSecsSinceEpoch();
    if((times - m_dateTime) > 500)
    {
        QImage image(":/images/auvodio_sd_bg_onlinetwox.png");
        image = image.scaled(640, 368, Qt::IgnoreAspectRatio);
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
void Processing_B2_Channel::receiveData(QImage image)
{
    // 少于100毫秒不做处理
    int times = QDateTime::currentDateTime().toMSecsSinceEpoch();
    if((times - m_dateTime) <= 100)
        return;
    m_dateTime = times;
    image = image.scaled(640, 368, Qt::IgnoreAspectRatio);
    emit renderVideoFrameImage(0, image.rgbSwapped(), 0); // 老师的ID，图片，旋转角度

    // for beautyImage
    QImage tImage = image.rgbSwapped();
    tImage.save("0","jpg");
    int tSize = BeautyList::getInstance()->hasBeautyImageList.size();
    if(tSize > 0 && BeautyList::getInstance()->beautyIsOn)
    {
        QImage tImg;
        tImg =  BeautyList::getInstance()->hasBeautyImageList.at(tSize - 1).scaled(640,368,Qt::IgnoreAspectRatio,Qt::SmoothTransformation);
        tImg = tImg.convertToFormat(QImage::Format_RGB888);

        if(tSize > 200)
        {
            BeautyList::getInstance()->hasBeautyImageList.clear();
            BeautyList::getInstance()->hasBeautyImageList.append(tImg);
        }
        image = tImg.rgbSwapped();
    }

    // 发送到服务器的帧
    videoFrame.length = m_nWidth * m_nHeight * 3 / 2;
    videoFrame.videoFormat = LiteAVVideoPixelFormat_I420;
    videoFrame.width = m_nWidth;
    videoFrame.height = m_nHeight;
    videoFrame.bufferType = LiteAVVideoBufferType_Buffer;

    // 先将Format_RGB888转为ARGB32
    image = image.convertToFormat(QImage::Format_ARGB32);
    image = image.rgbSwapped();
    // ARGB32转I420格式
    unsigned char* src_frame = image.bits();
    unsigned char* pBuffer_dst_y = m_lpBufferYUV;
    int ndst_stride_y = m_nWidth;
    unsigned char* pBuffer_dst_u = m_lpBufferYUV + m_nWidth * m_nHeight;
    int ndst_stride_u = m_nWidth / 2;
    unsigned char* pBuffer_dst_v = m_lpBufferYUV + m_nWidth * m_nHeight  + m_nWidth * m_nHeight /4;
    int ndst_stride_v = m_nWidth / 2;
    libyuv::ARGBToI420((unsigned char*)src_frame, m_nWidth * 4, pBuffer_dst_y, ndst_stride_y, pBuffer_dst_u, ndst_stride_u, pBuffer_dst_v, ndst_stride_v, m_nWidth, m_nHeight);

    // I420数据拷贝到videoFrame.data
    memcpy(videoFrame.data, pBuffer_dst_y, m_nWidth * m_nHeight);
    memcpy(videoFrame.data + m_nWidth * m_nHeight, pBuffer_dst_u, m_nWidth * m_nHeight / 4);
    memcpy(videoFrame.data + m_nWidth * m_nHeight * 5 / 4, pBuffer_dst_v, m_nWidth * m_nHeight / 4);

    // 发送自定义的视频帧
    if(m_role == STUDENT || m_role == TEACHER)
    {
        if(NULL != m_pTrtcCloud)
            m_pTrtcCloud->sendCustomVideoData(&videoFrame);
    }
}

// 初始化频道
bool Processing_B2_Channel::initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                                        QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath, ENVIRONMENT_TYPE enType)
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

    // 初始化TRTC，动态加载dll库
    TCHAR exePath[MAX_PATH];
    GetModuleFileName(nullptr, exePath, MAX_PATH);
    PathRemoveFileSpec(exePath);
    wcscat(exePath, L"\\LiteAV\\");
    SetDllDirectory(exePath);
    m_hLiteAV = LoadLibrary(L"liteav.dll");
    if (!m_hLiteAV)
    {
        qDebug() << "载入liteav.dll失败: " << GetLastError();
        return false;
    }
    m_pGetTRTCShareInstance = (getTRTCShareInstanceMtd)GetProcAddress(m_hLiteAV, "getTRTCShareInstance");
    if (!m_pGetTRTCShareInstance)
    {
        qDebug() << "载入函数getTRTCShareInstance失败";
        return false;
    }
    m_pDestroyTRTCShareInstance = (destroyTRTCShareInstanceMtd)GetProcAddress(m_hLiteAV, "destroyTRTCShareInstance");
    if (!m_pDestroyTRTCShareInstance)
    {
        qDebug() << "载入函数destroyTRTCShareInstance失败";
        return false;
    }
    m_pTrtcCloud = m_pGetTRTCShareInstance();
    if (!m_pTrtcCloud)
    {
        qDebug() << "创建TRTC实例失败";
        return false;
    }
    m_pTrtcCloud->addCallback(this);
    SetDllDirectory(nullptr);
    qDebug() << "TRTC初始化成功\n";
    // 启用视频自定义采集模式
    if(m_role == STUDENT || m_role == TEACHER)
    {
        if(NULL != m_pTrtcCloud)
            m_pTrtcCloud->enableCustomVideoCapture(true);
    }

    m_dateTime = QDateTime::currentDateTime().toMSecsSinceEpoch();
    cam = new CameraCapture();
    connect(cam, &CameraCapture::sendData, this, &Processing_B2_Channel::receiveData);
    QString carmerId = getDefaultDevicesId("carmer");
    m_httpClient = YMHttpClientUtils::getInstance();
    m_httpUrl = m_httpClient->getRunUrl(1, m_strDllFile, m_strAppName);
    if(YMHttpClientUtils::getInstance()->getCurrentEnvironmentType() == "api" || YMHttpClientUtils::getInstance()->getCurrentEnvironmentType() == "test" )// 正式环境
    {
        m_trtcAppId = kTestAppId;
    }
    else
    {
        m_trtcAppId = kProduceAppId;
    }

    // 使用本地摄像头采集
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
    connect(m_cameraImageTimes, SIGNAL(timeout()), this, SLOT(onUploadImage()));
    return true;
}

// 进入频道
bool Processing_B2_Channel::enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone, int videoSpan)
{
    if(!getQQSign())// 获取签名等信息
    {
        return false;
    }
    if (m_pTrtcCloud)
    {
        TRTCParams params;

        params.sdkAppId = (unsigned int)m_trtcAppId.toInt();

        std::string userIdStr = m_userId.toStdString();
        params.userId = userIdStr.c_str();

        std::string userSigStr = m_trtcUserSig.toStdString();
        params.userSig = userSigStr.c_str();

        params.roomId = (unsigned int)m_trtcRoomId.toInt();

        int record_id = (videoSpan << 25) + m_lessonId.toInt();
        std::string businessInfo("{\"Str_uc_params\":{\"uc_biz_type\":40685,\"record_id\":" + std::to_string(record_id) + "}}");
        params.businessInfo = businessInfo.c_str();

        m_pTrtcCloud->enterRoom(params, TRTCAppScene::TRTCAppSceneVideoCall);

        return true;
    }
    return false;
}

// 离开频道
bool Processing_B2_Channel::leaveChannel()
{
    if(m_pTrtcCloud == NULL)
        return false;
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    m_cameraImageTimes->stop();
    if (ca != NULL)
    {
        ca->stop();
    }
    loop.exec();
    m_pTrtcCloud->stopLocalAudio();
    m_pTrtcCloud->exitRoom();
    return true;
}

// 打开本地音频
bool Processing_B2_Channel::openLocalAudio()
{
    if(m_pTrtcCloud == NULL)
        return false;
    m_pTrtcCloud->startLocalAudio();
    return true;
}

// 关闭本地音频
bool Processing_B2_Channel::closeLocalAudio()
{
    if(m_pTrtcCloud == NULL)
        return false;
    m_pTrtcCloud->stopLocalAudio();
    return true;
}

// 打开本地视频
bool Processing_B2_Channel::openLocalVideo()
{
    QString camera =  m_camera;
    if(camera == "1" && NULL != ca)
    {
        ca->start();
    }
    return true;
}

// 关闭本地视频
bool Processing_B2_Channel::closeLocalVideo()
{
    if (ca != NULL)
    {
        ca->stop();
    }
    return true;
}

// 设置用户角色
int Processing_B2_Channel::setUserRole(CLIENT_ROLE role)
{
    return 0;
}

// 设置视频分辨率
int Processing_B2_Channel::setVideoResolution(VIDEO_RESOLUTION resolution)
{
    return 0;
}

QString Processing_B2_Channel::getDefaultDevicesId(QString deviceKey)
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
    qDebug() << "Processing_B2_Channel::getDefaultDevicesId" << deviceSetting.value(deviceKey).toString() << __LINE__;
    return deviceSetting.value(deviceKey).toString();
}

// 重写父类错误事件回调函数
void Processing_B2_Channel::onError(TXLiteAVError errCode, const char *errMsg, void *arg)
{
    if(errCode == ERR_ROOM_ENTER_FAIL                     ||
            errCode == ERR_ROOM_HEARTBEAT_FAIL                    ||
            errCode == ERR_ROOM_REQUEST_IP_FAIL                   ||
            errCode == ERR_ROOM_CONNECT_FAIL                      ||
            errCode == ERR_ROOM_REQUEST_AVSEAT_FAIL               ||
            errCode == ERR_ROOM_REQUEST_TOKEN_HTTPS_TIMEOUT       ||
            errCode == ERR_ROOM_REQUEST_IP_TIMEOUT                ||
            errCode == ERR_ROOM_REQUEST_ENTER_ROOM_TIMEOUT        ||
            errCode == ERR_ROOM_REQUEST_VIDEO_FLAG_TIMEOUT        ||
            errCode == ERR_ROOM_REQUEST_VIDEO_DATA_ROOM_TIMEOUT   ||
            errCode == ERR_ROOM_REQUEST_CHANGE_ABILITY_TIMEOUT    ||
            errCode == ERR_ROOM_REQUEST_STATUS_REPORT_TIMEOUT     ||
            errCode == ERR_ROOM_REQUEST_CLOSE_VIDEO_TIMEOUT       ||
            errCode == ERR_ROOM_REQUEST_SET_RECEIVE_TIMEOUT       ||
            errCode == ERR_ROOM_REQUEST_TOKEN_INVALID_PARAMETER   ||
            errCode == ERR_SERVER_SSO_APPID_NOT_FOUND             ||
            errCode == ERR_SERVER_SSO_SIG_INVALID                 ||
            errCode == ERR_SERVER_SSO_LIMITED_BY_SECURITY         ||
            errCode == ERR_SERVER_SSO_INVALID_LOGIN_STATUS        ||
            errCode == ERR_SERVER_SSO_TICKET_VERIFICATION_FAILED  ||
            errCode == ERR_SERVER_SSO_TICKET_EXPIRED              ||
            errCode == ERR_SERVER_SSO_ACCOUNT_IN_BLACKLIST        ||
            errCode == ERR_SERVER_SSO_ACCOUNT_EXCEED_PURCHASES    ||
            errCode == ERR_ENTER_ROOM_PARAM_NULL)
    {
        emit createRoomFail();
    }
    qDebug()<<"=====Processing_B2_Channel::errCode="<<errCode<<"====="<<errMsg;
}

// 重写父类警告事件回调函数
void Processing_B2_Channel::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *arg)
{

}

// 重写父类加入房间事件回调函数
void Processing_B2_Channel::onEnterRoom(uint64_t elapsed)
{
    qDebug()<<"================================Processing_B2_Channel::onEnterRoom success=========";
    emit createRoomSucess();
}

// 重写父类退出房间事件回调函数
void Processing_B2_Channel::onExitRoom(int reason)
{
    qDebug()<<"==================================Processing_B2_Channel::onExitRoom success=========";
}

// 重写父类用户加入事件回调函数
void Processing_B2_Channel::onUserEnter(const char *userId)
{
    m_pTrtcCloud->setRemoteVideoRenderCallback(userId, LiteAVVideoPixelFormat_BGRA32, LiteAVVideoBufferType_Buffer, m_LiteAVVideoRenderCallback);
    qDebug() << "==================================Processing_B2_Channel::onUserEnter ======userId: " << userId;
}

// 重写父类用户退出事件回调函数
void Processing_B2_Channel::onUserExit(const char* userId, int reason)
{
    qDebug() << "userId " << userId << "exit room";
}

// 登录
bool Processing_B2_Channel::getQQSign()
{
    qDebug() << "Processing_B2_Channel::getQQSign()";
    QEventLoop loop;
    QNetworkAccessManager * httpAccessmanger = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;
    QString url("http://" + m_httpUrl + "/lesson/getQQSign?");
    QMap<QString, QString> maps;
    //QDateTime dateStr = QDateTime::currentDateTime();
    maps.insert("key", m_userId);
    maps.insert("apiVersion", m_apiVersion);
    maps.insert("umengAppKey", "597ac22d75ca350dd600227a");
    maps.insert("appVersion", m_appVersion);
    maps.insert("token", m_token);
    //maps.insert("timestamp", dateStr.toString("yyyyMMddhhmmss"));

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
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    httpRequest.setUrl(url);
    QNetworkReply * httpReply = httpAccessmanger->post(httpRequest, post_data);

    QEventLoop httploop;
    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray bytes = httpReply->readAll();

    // 检查post结果是否为success
    QJsonObject dataObj = QJsonDocument::fromJson(bytes).object();
    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug()<<"=====Processing_B2_Channel::getQQSign() ========= post fail ========="<< dataObj.value("message").toString().toLower();
        return false;
    }

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
                m_qqSign = jsonObj.take("qqNewSign").toString();
            }
        }
    }
    m_trtcUserSig = m_qqSign;
    m_trtcRoomId = m_lessonId;
    QString userId = m_lessonId + "_" + m_trtcRoomId + "_main";
    QString md5Id =  QString(QCryptographicHash::hash(userId.toLatin1(), QCryptographicHash::Md5).toHex().toLower());
    m_audioName = "3933_" + md5Id;
    emit Processing_B2_Channel::getInstance()->sigAudioName(m_audioName);
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    loop.exec();
    return true;
}
