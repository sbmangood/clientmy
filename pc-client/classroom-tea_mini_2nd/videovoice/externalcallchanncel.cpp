#include <QCoreApplication>
#include "externalcallchanncel.h"
#include "AudioVideoCenter.h"

ExternalCallChanncel::ExternalCallChanncel(QObject *parent): QObject(parent)
{
    connect(AudioVideoCenter::getInstance(), SIGNAL(sigAudioVolumeIndication(unsigned int, int)), this, SIGNAL(sigAudioVolumeIndication(unsigned int, int)));
    connect(AudioVideoCenter::getInstance(), SIGNAL(sigAisleFinished(bool)), this, SIGNAL(sigAisleFinished(bool)));
    connect(AudioVideoCenter::getInstance(), SIGNAL(createRoomFail()), this, SIGNAL(createRoomFail()));
    connect(AudioVideoCenter::getInstance(), SIGNAL(createRoomSucess()), this, SIGNAL(createRoomSucess()));
    connect(AudioVideoCenter::getInstance(), SIGNAL(sigJoinroom(uint, QString, int)), this, SIGNAL(sigJoinroom(uint, QString, int)));
    connect(AudioVideoCenter::getInstance(), SIGNAL(pushAudioQualityToQos(QString, QString, QString, QString)), this, SLOT(sloAudioQuality(QString, QString, QString, QString)));
}

ExternalCallChanncel::~ExternalCallChanncel(){}

//初始化频道
void ExternalCallChanncel::initVideoChancel()
{
    QString exePath = QCoreApplication::applicationDirPath();
    exePath += "\\YMAudioVideoManager.dll";
    qDebug() << "=====ExternalCallChanncel::initVideoChancel====="<<exePath;
    AudioVideoCenter::getInstance()->init(exePath);
    changeChanncel();
}

//切换频道
void ExternalCallChanncel::changeChanncel()
{
    AudioVideoCenter::getInstance()->changeChanncel();
}

// 关闭音频
void ExternalCallChanncel::closeAudio(QString status)
{
    AudioVideoCenter::getInstance()->closeAudio(status);
}

// 关闭视频
void ExternalCallChanncel::closeVideo(QString status)
{
    AudioVideoCenter::getInstance()->closeVideo(status);
}

// 设置留在教室
void ExternalCallChanncel::setStayInclassroom()
{
    AudioVideoCenter::getInstance()->setStayInclassroom();
}

// 退出频道
void ExternalCallChanncel::exitChannel()
{
    AudioVideoCenter::getInstance()->exitChannel();
}

//关闭所有界面
void ExternalCallChanncel::closeAlllWidget()
{
    //先上传日志, 再退出所有通道(防止退出通道的时候, 程序出错, 导致日志没有上传)
    DebugLog::GetInstance()->doCloseLog();
    DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server(); //关闭进程前, 需要上传日志文件
    AudioVideoCenter::getInstance()->exitChannel(); //关闭进程前, 需要是否音视频的资源, 不然下次进去, 可能有问题, 尤其是C通道
    QProcess process;
    process.execute(QString("TASKKILL /IM %1 /F") .arg(StudentData::gestance()->strAppName));
    process.close();
}

void ExternalCallChanncel::sloAudioQuality(QString channel, QString frameValue, QString audioDelay, QString audioQuality)
{
    //后期再考虑埋这个点，目前没有丢包率这个参数
}
