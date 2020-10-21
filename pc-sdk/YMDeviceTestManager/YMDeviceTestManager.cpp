#include "YMDeviceTestManager.h"
#include <QDebug>
#include <QTextCodec>

RtcEngineContext ctx;

YMDeviceTestManager* YMDeviceTestManager::m_YMDeviceTestManager = NULL;

YMDeviceTestManager::YMDeviceTestManager()
{
    bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    engine = (IRtcEngine*)createAgoraRtcEngine();
    ctx.eventHandler = &handler;
    ctx.appId = "6bdd1aedee814f1fade7ef5e42578ff7";
    if(0 != engine->initialize(ctx))
    {
        qDebug() << QStringLiteral("initialize failed");
    }
    //engine->enableVideo();
    engine->enableAudio();

    videoDeviceManger = new AVideoDeviceManager(engine);
    audioDeviceManger = new AAudioDeviceManager(engine);
    mediaEngine.queryInterface(engine, agora::AGORA_IID_MEDIA_ENGINE);
    if (mediaEngine)
    {
        mediaEngine->registerVideoFrameObserver(&observer);
    }

    //connect(&observer, SIGNAL(renderVideoFrame(uint, int, int, int, void*, int, void*, int, void*)), this, SLOT(renderVideoFrame(uint, int, int, int, void*, int, void*, int, void*)));
    connect(&videoFrameCapture, SIGNAL(renderVideoFrame(QImage)), this, SLOT(onRenderVideoFrame(QImage)));

    connect(&handler, SIGNAL(netQuality(int)), this, SIGNAL(netQuailty(int)));
    fileDir = QCoreApplication::applicationDirPath().remove("/release");
    connect(&handler, SIGNAL(carmeraReady()), this, SIGNAL(carmeraReady()));

    RtcEngineParameters rep(*engine);
    rep.enableAudioVolumeIndication(200, 10);
    connect(&handler, SIGNAL(speakerVolume(int, int)), this, SIGNAL(speakerVolume(int, int)));
}

YMDeviceTestManager* YMDeviceTestManager::getInstance()
{
    if(NULL == m_YMDeviceTestManager)
    {
        m_YMDeviceTestManager = new YMDeviceTestManager();
    }
    return m_YMDeviceTestManager;
}

void YMDeviceTestManager::release()
{
    m_YMDeviceTestManager = NULL;
}

YMDeviceTestManager::~YMDeviceTestManager()
{
    QFile::remove(bufferFilePath + "/" + tempName + ".jpg");
    if(NULL != engine)
    {
        engine->disableAudio();
        engine->disableLastmileTest();
        //engine->disableVideo();
        engine->stopEchoTest();
        //engine->stopPreview();
        //disconnect(&observer, SIGNAL(renderVideoFrame(uint, int, int, int, void*, int, void*, int, void*)), this, SLOT(renderVideoFrame(uint, int, int, int, void*, int, void*, int, void*)));
    }
    disconnect(&handler, SIGNAL(netQuality(int)), this, SIGNAL(netQuailty(int)));

    disconnect(&handler, SIGNAL(carmeraReady()), this, SIGNAL(carmeraReady()));
    disconnect(&handler, SIGNAL(speakerVolume(int, int)), this, SIGNAL(speakerVolume(int, int)));

    if(videoDeviceCollect != NULL)
    {
        videoDeviceCollect->release();
    }
    if(videoDeviceManger != NULL)
    {
        videoDeviceManger->release();
    }
    if(audioDeviceCollection != NULL)
    {
        audioDeviceCollection->release();
    }
    if(audioDeviceManger != NULL)
    {
        audioDeviceManger->release();
    }
    if(engine != NULL)
    {
        engine->release();
    }
}

void YMDeviceTestManager::renderVideoFrame(unsigned int uid, int w, int h, int y, void *yb, int u, void *ub, int v, void *vb)
{
    uchar *ybc = (uchar*)yb;
    uchar *ubc = (uchar*)ub;
    uchar *vbc = (uchar*)vb;
    arr.clear();
    int iy, iu, iv;
    int r, g, b;
    for (int i = 0; i < h; i++)
    {
        for (int j = 0; j < y; j++)
        {
            iy = i * y + j;
            iu = i / 2 * y / 2 + j / 2;
            iv = i / 2 * y / 2 + j / 2;
            b = ybc[iy] + 1.772 * (ubc[iu] - 128);
            g = ybc[iy] - 0.34413 * (ubc[iu] - 128) - 0.71414 * (vbc[iv] - 128);
            r = ybc[iy] + 1.402 * (vbc[iv] - 128);
            arr.append(r < 0 ? 0 : (r > 255 ? 255 : r));
            arr.append(g < 0 ? 0 : (g > 255 ? 255 : g));
            arr.append(b < 0 ? 0 : (b > 255 ? 255 : b));
        }
    }

    m_image = QImage(arr.data(), y, h, QImage::Format_RGB888).copy(0, 0, w, h);

    QTime time = QTime::currentTime();
    QFile::remove( bufferFilePath + "/" + tempName + ".jpg");
    tempName = QString::number( time.msecsSinceStartOfDay());

    m_image.save( bufferFilePath + "/" + tempName + ".jpg", 0);
    emit renderVideoImage(bufferFilePath + "/" + tempName + ".jpg");

}

void YMDeviceTestManager::onRenderVideoFrame(QImage image)
{
    m_mutex.lock();
    QTime time = QTime::currentTime();
    QFile::remove(bufferFilePath + "/" + tempName + ".jpg");
    tempName = QString::number(time.msecsSinceStartOfDay());
    image.save(bufferFilePath + "/" + tempName + ".jpg", 0);
    emit renderVideoImage(bufferFilePath + "/" + tempName + ".jpg");
    m_mutex.unlock();
}

void YMDeviceTestManager::startOrStopAudioTest(bool isStart)
{
    // 语音检测
    if(NULL != engine)
    {
        if(isStart)
        {
            engine->enableAudio();
            engine->startEchoTest();//启动音频测试
        }
        else
        {
            engine->stopEchoTest();
        }
    }
}

void YMDeviceTestManager::startOrStopNetTest(bool isStart)
{
    //网络监测
    if(NULL != engine)
    {
        if(isStart)
        {
            engine->enableLastmileTest();
        }
        else
        {
            engine->disableLastmileTest();
        }
    }
}

void YMDeviceTestManager::startOrStopVideoTest(bool isStart)
{
    if(isStart)
    {
        engine->enableVideo();
        videoDeviceCollect = (*videoDeviceManger)->enumerateVideoDevices();
        if(videoDeviceCollect != NULL)
        {
            if(videoDeviceCollect->getCount() > 0)
            {
                //engine->startPreview();
                videoFrameCapture.startCapture();
            }
            else
            {
                //无设备可用
                emit noCarmerDevices();
            }
        }
        else
        {
            emit noCarmerDevices();
        }
    }
    else
    {
        //engine->disableVideo();
        //engine->stopPreview();
        videoFrameCapture.stopCapture();
    }
}

void YMDeviceTestManager::releaseDevice()
{
    QFile::remove(tempName + ".jpg");
    if(NULL != engine)
    {
        engine->disableAudio();
        engine->disableLastmileTest();
        //engine->disableVideo();
        engine->stopEchoTest();
        //engine->stopPreview();
    }
    videoFrameCapture.stopCapture();
}

QJsonArray YMDeviceTestManager::getUserDeviceList(int type)
{
    QJsonArray dataArray;
    if(type == 1)
    {
        videoDeviceCollect = (*videoDeviceManger)->enumerateVideoDevices();
        char caName[MAX_DEVICE_ID_LENGTH], caId[MAX_DEVICE_ID_LENGTH];
        if(videoDeviceCollect != NULL)
        {
            if(videoDeviceCollect->getCount() > 0)
            {
                for(int a = 0; a < videoDeviceCollect->getCount(); a++)
                {
                    videoDeviceCollect->getDevice(a, caName, caId);
                    dataArray.append(caName);
                }
                return dataArray;
            }
        }
        else
        {
            dataArray.append(QStringLiteral("No available devices."));
            return dataArray;
        }
    }

    if(type == 2)
    {
        audioDeviceCollection = (*audioDeviceManger)->enumeratePlaybackDevices();
        char caName[MAX_DEVICE_ID_LENGTH], caId[MAX_DEVICE_ID_LENGTH];
        if(audioDeviceCollection != NULL)
        {
            if(audioDeviceCollection->getCount() > 0)
            {
                for(int a = 0; a < audioDeviceCollection->getCount(); a++)
                {
                    audioDeviceCollection->getDevice(a, caName, caId);
                    dataArray.append(caName);
                }
                return dataArray;
            }
        }
        else
        {
            dataArray.append(QStringLiteral("No available devices."));
            return dataArray;
        }
    }

    if(type == 3)
    {
        audioDeviceCollection = (*audioDeviceManger)->enumerateRecordingDevices();
        char caName[MAX_DEVICE_ID_LENGTH], caId[MAX_DEVICE_ID_LENGTH];
        if(audioDeviceCollection != NULL )
        {
            if(audioDeviceCollection->getCount() > 0)
            {
                for(int a = 0; a < audioDeviceCollection->getCount(); a++)
                {
                    audioDeviceCollection->getDevice(a, caName, caId);
                    dataArray.append(caName);
                }
                return dataArray;
            }
        }
        else
        {
            dataArray.append(QStringLiteral("No available devices."));
            return dataArray;
        }
    }
    return dataArray;
}

void YMDeviceTestManager::setCarmerDevice(QString deviceName)
{
    videoDeviceCollect = (*videoDeviceManger)->enumerateVideoDevices();
    char caName[MAX_DEVICE_ID_LENGTH], caId[MAX_DEVICE_ID_LENGTH];
    if(videoDeviceCollect != NULL )
    {
        if(videoDeviceCollect->getCount() > 0)
        {
            for(int a = 0; a < videoDeviceCollect->getCount(); a++)
            {
                videoDeviceCollect->getDevice(a, caName, caId);
                if(deviceName == caName)
                {
                    videoDeviceCollect->setDevice(caId);
                    saveDeviceInformation(1, caId, caName);
                }
            }
        }
    }
}

void YMDeviceTestManager::setPlayerDevice(QString deviceName)
{
    audioDeviceCollection = (*audioDeviceManger)->enumeratePlaybackDevices();
    char caName[MAX_DEVICE_ID_LENGTH], caId[MAX_DEVICE_ID_LENGTH];
    if(audioDeviceCollection != NULL)
    {
        if(audioDeviceCollection->getCount() > 0)
        {
            for(int a = 0; a < audioDeviceCollection->getCount(); a++)
            {
                audioDeviceCollection->getDevice(a, caName, caId);
                if(deviceName == caName)
                {
                    (*audioDeviceManger)->setPlaybackDevice(caId);
                    saveDeviceInformation(2, caId, caName);
                }
            }
        }
    }
}

void YMDeviceTestManager::setRecorderDevice(QString deviceName)
{
    audioDeviceCollection = (*audioDeviceManger)->enumerateRecordingDevices();
    char caName[MAX_DEVICE_ID_LENGTH], caId[MAX_DEVICE_ID_LENGTH];
    if(audioDeviceCollection != NULL)
    {
        if(audioDeviceCollection->getCount() > 0)
        {
            for(int a = 0; a < audioDeviceCollection->getCount(); a++)
            {
                audioDeviceCollection->getDevice(a, caName, caId);
                if(deviceName == caName)
                {
                    (*audioDeviceManger)->setRecordingDevice(caId);
                    saveDeviceInformation(3, caId, caName);
                }
            }
        }
    }
}

QString YMDeviceTestManager::getDocumentDir()
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString systemPublicFilePath;
    QDir dir;
    if (docPath == "" || !dir.exists(docPath))
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }

    return systemPublicFilePath;
}

void YMDeviceTestManager::saveDeviceInformation(int type, QString value, QString strDeviceName)
{
    qDebug() << "YMDeviceTestManager::saveDeviceInformation" << strDeviceName << __LINE__;
    QString m_systemPublicFilePath = getDocumentDir();
    m_systemPublicFilePath += "/YiMi/temp/";
    QDir isDir;
    // 设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
    }
    QSettings deviceSetting(m_systemPublicFilePath + "deviceInfo.dll", QSettings::IniFormat);
    deviceSetting.beginGroup("Device");
    if(type == 1)
    {
        deviceSetting.setValue("carmer", value);
    }

    if(type == 2)
    {
        deviceSetting.setValue("player", value);
        //因为网易C通道
        //不能得到设备的ID, 比如: {0.0.0.00000000}.{1b7f4899-e266-4183-bc85-712694ecc71a}
        //只能得到设备的名称, 比如: 扬声器 (High Definition Audio 设备)
        deviceSetting.setValue("player_device_name", strDeviceName);
    }

    if(type == 3)
    {
        deviceSetting.setValue("recorder", value);
        //因为网易C通道
        //不能得到设备的ID, 比如: {0.0.1.00000000}.{18b91d67-bed2-4f0a-a16a-c384b6795d7e}
        //只能得到设备的名称, 比如: 麦克风 (High Definition Audio 设备)
        deviceSetting.setValue("recorder_device_name", strDeviceName);
    }
    deviceSetting.endGroup();
}
