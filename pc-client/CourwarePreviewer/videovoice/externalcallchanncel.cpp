#include "externalcallchanncel.h"



ExternalCallChanncel::ExternalCallChanncel(QObject *parent): QObject(parent)
{
    connect(OperationChannel::gestance(), SIGNAL(sigAudioVolumeIndication(unsigned int, int  )), this, SIGNAL(sigAudioVolumeIndication(unsigned int, int  ))  );
    connect(OperationChannel::gestance(), SIGNAL(sigAisleFinish()), this, SIGNAL(sigAisleFinished()));
    connect(OperationChannel::gestance(), SIGNAL(sigCreateClassroom()), this, SIGNAL(sigCreateClassroom()));
    connect(OperationChannel::gestance(), SIGNAL(wayBCreateRoomFail()), this, SIGNAL(createRoomFail()));
}

ExternalCallChanncel::~ExternalCallChanncel()
{

}

//初始化频道
void ExternalCallChanncel::initVideoChancel()
{
    OperationChannel::gestance()->initChannelStatus();
}

//切换频道
void ExternalCallChanncel::changeChanncel()
{
    OperationChannel::gestance()->changeChanncel();
}

//关闭所有界面
void ExternalCallChanncel::closeAlllWidget()
{
    //================================
    DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server(); //关闭进程前, 需要上传日志文件

    //================================
    QProcess process;
    process.execute("TASKKILL /IM CourwarePreviewer.exe /F");
    process.close();
}

//关闭音频
void ExternalCallChanncel::closeAudio(QString status)
{
    OperationChannel::gestance()->closeAudio(status);
}
//关闭视频
void ExternalCallChanncel::closeVideo(QString status)
{
    OperationChannel::gestance()->closeVideo(status);
}
//设置留在教室
void ExternalCallChanncel::setStayInclassroom()
{
    OperationChannel::gestance()->setStayInclassroom();
}

void ExternalCallChanncel::exitWayB()
{
    OperationChannel::gestance()->exitVideoViewWayB();
}
