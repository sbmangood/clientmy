#include <QProcess>
#include "toolbar.h"
#include "./debugLog/debuglog.h"
#include "../classroom-sdk/sdk/inc/YMHandsUpManager/IHandsUpCtrl.h"

ToolBar::ToolBar(QObject *parent)
    :QObject(parent)
{
    connect(ControlCenter::getInstance(),SIGNAL(sigEnterOrSync(int)), this, SLOT(onSigEnterOrSync(int)));
    connect(ControlCenter::getInstance(),SIGNAL(sigJoinroom(uint,QString,int)),this,SIGNAL(sigJoinroom(uint,QString,int)));
    connect(ControlCenter::getInstance(),SIGNAL(sigAudioVolumeIndication(uint,int)),this,SIGNAL(sigAudioVolumeIndication(uint,int)));
    connect(ControlCenter::getInstance(),SIGNAL(sigCurrentImageHeight(double)),this,SIGNAL(sigCurrentImageHeight(double)));
    connect(ControlCenter::getInstance(),SIGNAL(sigDowloadAVFail()),this,SIGNAL(sigDowloadAVFail()));
    connect(ControlCenter::getInstance(),SIGNAL(sigDowloadAVSuccess()),this,SIGNAL(sigDowloadAVSuccess()));
    connect(ControlCenter::getInstance(),SIGNAL(reShowOffsetImage(int,int)),this,SIGNAL(reShowOffsetImage(int,int)));
    connect(ControlCenter::getInstance(),SIGNAL(sigPlayAv(QJsonObject)),this,SIGNAL(sigPlayAv(QJsonObject)));
    connect(ControlCenter::getInstance(),SIGNAL(updateStuList(QString, uint, int)), this, SIGNAL(updateStuList(QString,uint,int)));
    connect(ControlCenter::getInstance(),SIGNAL(sigHandsUpResponse(QString,uint,QString)),this,SIGNAL(sigHandsUpResponse(QString,uint,QString)));
    connect(ControlCenter::getInstance(),SIGNAL(sigJoinClassroom(QString, QString, QJsonObject)), this, SIGNAL(sigJoinClassroom(QString, QString, QJsonObject)));
    connect(ControlCenter::getInstance(),SIGNAL(sigLeaveClassroom(QString, QString, QJsonObject)), this, SIGNAL(sigLeaveClassroom(QString, QString, QJsonObject)));
    connect(ControlCenter::getInstance(),SIGNAL(sigResetTimerView(QJsonObject)),this,SIGNAL(sigResetTimerView(QJsonObject)));
    connect(ControlCenter::getInstance(),SIGNAL(sigBeginClassroom()),this,SIGNAL(sigBeginClassroom()));
    connect(ControlCenter::getInstance(),SIGNAL(sigEndClassroom()),this,SIGNAL(sigEndClassroom()));
    connect(ControlCenter::getInstance(),SIGNAL(sigClearScreen()),this,SIGNAL(sigClearScreen()));
    connect(ControlCenter::getInstance(),SIGNAL(sigExitClassroom()),this,SIGNAL(sigExitClassroom()));
    connect(ControlCenter::getInstance(),SIGNAL(sigExitRoom()),this,SIGNAL(sigExitRoom()), Qt::QueuedConnection);
    connect(ControlCenter::getInstance(),SIGNAL(sigNoBeginClass()),this,SIGNAL(sigNoBeginClass()));
    connect(ControlCenter::getInstance(),SIGNAL(netQuailty(int)), this, SIGNAL(netQuailty(int)));
    connect(ControlCenter::getInstance(),SIGNAL(renderVideoImage(QString)), this, SIGNAL(renderVideoImage(QString)));
    connect(ControlCenter::getInstance(),SIGNAL(carmeraReady()), this, SIGNAL(carmeraReady()));
    connect(ControlCenter::getInstance(),SIGNAL(noCarmerDevices()), this, SIGNAL(noCarmerDevices()));
    connect(ControlCenter::getInstance(),SIGNAL(speakerVolume(int,int)), this, SIGNAL(speakerVolume(int,int)));
    connect(ControlCenter::getInstance(),SIGNAL(sigkickOutClassroom()),this,SIGNAL(sigKickOutClassroom()));
    connect(ControlCenter::getInstance(), SIGNAL(sigAutoChangeIpResult(QString)),this,SIGNAL(sigAutoChangeIpResult(QString)));
    connect(ControlCenter::getInstance(), SIGNAL(sigAutoConnectionNetwork()), this, SIGNAL(sigAutoConnectionNetwork()));

}

ToolBar::~ToolBar()
{

}

//设置鼠标形状
void ToolBar::selectShape(int shapeType)
{
    ControlCenter::getInstance()->selectShape(shapeType);
}

//设置画笔尺寸
void ToolBar::setPaintSize(double size)
{
    ControlCenter::getInstance()->setPaintSize(size);
}

//设置画笔颜色
void ToolBar::setPaintColor(int color)
{
    ControlCenter::getInstance()->setPaintColor(color);
}

//设置橡皮大小
void ToolBar::setErasersSize(double size)
{
    ControlCenter::getInstance()->setErasersSize(size);
}

//回撤轨迹数据
void ToolBar::undoTrail()
{
    ControlCenter::getInstance()->undoTrail();
}

//清除多个轨迹数据
void ToolBar::clearTrails()
{
    ControlCenter::getInstance()->clearTrails();
}

void ToolBar::uninit()
{
    QProcess process;
    process.execute(QString("TASKKILL /IM %1 /F") .arg(StudentData::gestance()->strAppName));
    process.close();
}

// 加载课件
void ToolBar::insertCourseWare(QJsonArray imgUrlList, QString fileId, QString h5Url, int coursewareType)
{
    ControlCenter::getInstance()->insertCourseWare(imgUrlList, fileId, h5Url, coursewareType);
}

// 跳转课件页 type 1翻页 2加页 3减页
void ToolBar::goCourseWarePage(int type,int pageNo,int totalNumber)
{
    ControlCenter::getInstance()->goCourseWarePage(type, pageNo, totalNumber);
}

// H5动画播放
void ToolBar::sendH5PlayAnimation(int step)
{
    ControlCenter::getInstance()->sendH5PlayAnimation(step);
}

void ToolBar::getOffsetImage(QString imageUrl, double offsetY)
{
    ControlCenter::getInstance()->getOffsetImage(imageUrl, offsetY);
}

void ToolBar::updataScrollMap(double scrollY)
{
    ControlCenter::getInstance()->updataScrollMap(scrollY);
}

void ToolBar::setCurrentImageHeight(int height)
{
    ControlCenter::getInstance()->setCurrentImageHeight(height);
}

void ToolBar::setAVCourseware(QString types, QString state, QString times, QString address, QString fileId, QString suffix)
{
    ControlCenter::getInstance()->setAVCourseware(types, state, times, address, fileId, suffix);
}

QString ToolBar::downLoadAVCourseware(QString mediaUrl)
{
    return ControlCenter::getInstance()->downLoadAVCourseware(mediaUrl);
}

void ToolBar::initVideoChancel()// 初始化频道
{
    ControlCenter::getInstance()->initVideoChancel();
}

void ToolBar::changeChanncel()// 切换频道
{
    ControlCenter::getInstance()->changeChanncel();
}

void ToolBar::closeAudio(QString status)// 关闭音频
{
    ControlCenter::getInstance()->closeAudio(status);
}

void ToolBar::closeVideo(QString status)// 关闭视频
{
    ControlCenter::getInstance()->closeVideo(status);
}

void ToolBar::setStayInclassroom()// 设置留在教室
{
    ControlCenter::getInstance()->setStayInclassroom();
}

void ToolBar::exitChannel()// 退出频道
{
    ControlCenter::getInstance()->exitChannel();
}

int ToolBar::setUserRole(int role)// 设置用户角色
{
    return ControlCenter::getInstance()->setUserRole(role);
}

int ToolBar::setVideoResolution(int resolution)// 设置视频分辨率
{
    return ControlCenter::getInstance()->setVideoResolution(resolution);
}

// 设置用户授权
void ToolBar::setUserAuth(QString userId, int up, int trail, int audio, int video)
{
    ControlCenter::getInstance()->setUserAuth(userId, up, trail, audio, video);
}

// 全体禁言
void ToolBar::allMute(int muteStatus)
{
    ControlCenter::getInstance()->allMute(muteStatus);
}

// 日志上传
void ToolBar::uploadLog()
{
    DebugLog::GetInstance()->doCloseLog();
    //DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server();
}

int ToolBar::raiseHandForUp(QString userId, QString groupId)
{
    return ControlCenter::getInstance()->raiseHandForUp(userId, groupId);
}

int ToolBar::cancelHandsUp(QString userId, QString groupId)
{
    return ControlCenter::getInstance()->cancelHandsUp(userId, groupId);
}

int ToolBar::processResponse(QString userId, int operation)
{
    return ControlCenter::getInstance()->processResponse(userId, operation);
}

int ToolBar::processHandsUp(QString userId, uint groupId, int operation)
{
    TEA_OPERATION oper;
    if(operation == 1)
    {
        oper = FORCE_UP;
    }
    else if(operation == 2)
    {
        oper = FORCE_DOWN;
    }
    else if(operation == 3)
    {
        oper = AGREE;
    }
    else if(operation == 4)
    {
        oper = REFUSE;
    }
    int ret = ControlCenter::getInstance()->processHandsUp(userId, groupId, oper);
    return ret;
}

int ToolBar::getUid(QString UserId)
{
    return ControlCenter::getInstance()->getUid(UserId);
}

QJsonObject ToolBar::getUserInfo()
{
    return ControlCenter::getInstance()->getUserInfo();
}

void ToolBar::sendTimer(int timerType, int flag, int timesec)
{
    ControlCenter::getInstance()->sendTimer(timerType, flag, timesec);
}

void ToolBar::beginClass()
{
    ControlCenter::getInstance()->beginClass();
}

void ToolBar::endClass()
{
    ControlCenter::getInstance()->endClass();
}

void ToolBar::exitClassRoom()
{
    ControlCenter::getInstance()->exitClassRoom();
}

QJsonArray ToolBar::getUserDeviceList(int type)
{
    return ControlCenter::getInstance()->getUserDeviceList(type);
}

void ToolBar::setCarmerDevice(QString deviceName)
{
    ControlCenter::getInstance()->setCarmerDevice(deviceName);
}

void ToolBar::setPlayerDevice(QString deviceName)
{
    ControlCenter::getInstance()->setPlayerDevice(deviceName);
}

void ToolBar::setRecorderDevice(QString deviceName)
{
    ControlCenter::getInstance()->setRecorderDevice(deviceName);
}

void ToolBar::startOrStopAudioTest(bool isStart)
{
    ControlCenter::getInstance()->startOrStopAudioTest(isStart);
}

void ToolBar::startOrStopVideoTest(bool isStart)
{
    ControlCenter::getInstance()->startOrStopVideoTest(isStart);
}

void ToolBar::startOrStopNetTest(bool isStart)
{
    ControlCenter::getInstance()->startOrStopNetTest(isStart);
}

void ToolBar::releaseDevice()
{
    ControlCenter::getInstance()->releaseDevice();
}

// 处理同步信号
void ToolBar::onSigEnterOrSync(int sync)
{
	if(sync == 201)//同步完成进入教室打开摄像头
    {
        emit sigPromptInterface("opencarm");
    }
}
