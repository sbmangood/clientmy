#include "toolbar.h"
#include "./debugLog/debuglog.h"

ToolBar::ToolBar(QObject *parent)
    :QObject(parent)
{
    connect(ControlCenter::getInstance(),SIGNAL(sigEnterOrSync(int)), this, SLOT(onSigEnterOrSync(int)));
    connect(ControlCenter::getInstance(),SIGNAL(sigJoinroom(uint,QString,int)),this,SIGNAL(sigJoinroom(uint,QString,int)));
    connect(ControlCenter::getInstance(),SIGNAL(sigCurrentImageHeight(double)),this,SIGNAL(sigCurrentImageHeight(double)));
    connect(ControlCenter::getInstance(),SIGNAL(reShowOffsetImage(int,int)),this,SIGNAL(reShowOffsetImage(int,int)));
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
    ControlCenter::getInstance()->uninitControlCenter();
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
    DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server();
}

// 处理同步信号
void ToolBar::onSigEnterOrSync(int sync)
{
    if(sync == 201)//同步完成进入教室打开摄像头
    {
        emit sigPromptInterface("opencarm");
    }
}
