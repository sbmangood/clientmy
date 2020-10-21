#include "ymdevicetesting.h"
#include <QDebug>
#include <QTextCodec>

RtcEngineContext ctx;
YMDeviceTesting::YMDeviceTesting(QObject *parent) : QObject(parent)
{
    bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);

    engine = (IRtcEngine*)createAgoraRtcEngine();
    ctx.eventHandler = &handler;
    ctx.appId = "6bdd1aedee814f1fade7ef5e42578ff7";
    if(0 != engine->initialize(ctx))//初始化
    {
        qDebug() << QStringLiteral("声网 初始化失败");
    }

    engine->enableVideo();
    engine->enableAudio();

    videoDeviceManger = new AVideoDeviceManager(engine);
    audioDeviceManger = new AAudioDeviceManager(engine);
    mediaEngine.queryInterface(engine, agora::rtc::AGORA_IID_MEDIA_ENGINE);
    if (mediaEngine)
    {
        mediaEngine->registerVideoFrameObserver(&observer);
    }

    connect(&observer, SIGNAL(renderVideoFrame(uint, int, int, int, void*, int, void*, int, void*)), this, SLOT(renderVideoFrame(uint, int, int, int, void*, int, void*, int, void*)));

    connect(&handler, SIGNAL(netQuality(int)), this, SIGNAL(netQuailty(int)));
    fileDir = QCoreApplication::applicationDirPath().remove("/release");
    connect(&handler, SIGNAL(carmerReady()), this, SIGNAL(carmerReady()));


    RtcEngineParameters rep(*engine);
    rep.enableAudioVolumeIndication(200, 10);
    connect(&handler, SIGNAL(speakerVolume(int, int)), this, SIGNAL(speakerVolume(int, int)));

//rep.startAudioRecording("C:/Users/Administrator/Documents/YiMi/temp/1.wav",AUDIO_RECORDING_QUALITY_LOW);
}
YMDeviceTesting::~YMDeviceTesting()
{
    QFile::remove(bufferFilePath + "/" + tempName + ".jpg");
    engine->disableAudio();
    engine->disableLastmileTest();
    engine->disableVideo();
    engine->stopEchoTest();
    engine->stopPreview();
    disconnect(&observer, SIGNAL(renderVideoFrame(uint, int, int, int, void*, int, void*, int, void*)), this, SLOT(renderVideoFrame(uint, int, int, int, void*, int, void*, int, void*)));

    disconnect(&handler, SIGNAL(netQuality(int)), this, SIGNAL(netQuailty(int)));

    disconnect(&handler, SIGNAL(carmerReady()), this, SIGNAL(carmerReady()));
    disconnect(&handler, SIGNAL(speakerVolume(int, int)), this, SIGNAL(speakerVolume(int, int)));

    if(videoDeviceCollect != NULL)
    {
        //videoDeviceCollect->release();
        videoDeviceCollect = NULL;
    }
    if(videoDeviceManger != NULL)
    {
        // videoDeviceManger->release();
        videoDeviceManger = NULL;
    }
    if(audioDeviceCollection != NULL)
    {
        audioDeviceCollection = NULL;
    }
    if(audioDeviceManger != NULL)
    {
        audioDeviceManger = NULL;
    }

    if(engine != NULL)
    {
        //engine->release();
        //delete engine;
        engine = NULL;
    }
}
void YMDeviceTesting::renderVideoFrame(unsigned int uid, int w, int h, int y, void *yb, int u, void *ub, int v, void *vb)
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
    emit imageChange(bufferFilePath + "/" + tempName + ".jpg");

}
void YMDeviceTesting::startOrStopAudioTest(bool isStart)
{
    //语音检测
    if(isStart)
    {
        qDebug() << "start";
        engine->enableAudio();
        engine->startEchoTest();//启动音频测试
    }
    else
    {
        engine->stopEchoTest();
    }
}

void YMDeviceTesting::startOrStopNetTest(bool isStart)
{
    //网络监测
    isStart ?  engine->enableLastmileTest() : engine->disableLastmileTest();

}
void YMDeviceTesting::startOrStopVideoTest(bool isStart)
{
    if(isStart)
    {
        engine->enableVideo();
        videoDeviceCollect = (*videoDeviceManger)->enumerateVideoDevices();
        if(videoDeviceCollect != NULL)
        {
            if(videoDeviceCollect->getCount() > 0)
            {
                engine->startPreview();
            }
            else
            {
                //无设备可用
                emit noCarmerDevices();
                qDebug() << QStringLiteral("无可用camera");
            }
        }
        else
        {
            emit noCarmerDevices();
            qDebug() << QStringLiteral("无可用camera  22");
        }
    }
    else
    {
        engine->disableVideo();
        engine->stopPreview();
    }
}

void YMDeviceTesting::releaseDevice()
{
    QFile::remove(tempName + ".jpg");
    engine->disableAudio();
    engine->disableLastmileTest();
    engine->disableVideo();
    engine->stopEchoTest();
    engine->stopPreview();
}

QJsonArray YMDeviceTesting::getUserDeviceList(int type)
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
            qWarning() << QStringLiteral("未发现摄像设备");
            dataArray.append(QStringLiteral("无可用设备"));
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
            qWarning() << QStringLiteral("未发现播放设备");
            dataArray.append(QStringLiteral("无可用设备"));
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
            qWarning() << QStringLiteral("未发现录音设备");
            dataArray.append(QStringLiteral("无可用设备"));
            return dataArray;
        }
    }
    return dataArray;
}

void YMDeviceTesting::setCarmerDevice(QString deviceName)
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
                qDebug() << "start1";
                if(deviceName == caName)
                {
                    videoDeviceCollect->setDevice(caId);
                    saveDeviceInformation(1, caId, caName);
                }
            }
        }
    }
}


void YMDeviceTesting::setPlayerDevice(QString deviceName)
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

void YMDeviceTesting::setRecorderDevice(QString deviceName)
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

void YMDeviceTesting::saveDeviceInformation(int type, QString value, QString strDeviceName)
{
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";

    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
    }

    //qDebug() << "m_systemPublicFilePath" << m_systemPublicFilePath;

    QSettings deviceSetting(m_systemPublicFilePath + "deviceInfo.dll", QSettings::IniFormat);
//    deviceSetting.setIniCodec(QTextCodec::codecForName("UTF-8"));

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
        //qDebug() << "3323244444444444444444" << strDeviceName << __LINE__;
    }

    if(type == 3)
    {
        deviceSetting.setValue("recorder", value);
        //因为网易C通道
        //不能得到设备的ID, 比如: {0.0.1.00000000}.{18b91d67-bed2-4f0a-a16a-c384b6795d7e}
        //只能得到设备的名称, 比如: 麦克风 (High Definition Audio 设备)
        deviceSetting.setValue("recorder_device_name", strDeviceName);
        //qDebug() << "3323244444444444444444" << strDeviceName << __LINE__;
    }

    deviceSetting.endGroup();
}
