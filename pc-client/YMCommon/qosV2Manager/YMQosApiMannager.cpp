#include "YMQosApiMannager.h"
#include "YMQosManager.h"

YMQosApiMannager::YMQosApiMannager(QObject *parent) : QObject(parent)
{

}

YMQosApiMannager::~YMQosApiMannager()
{

}

void YMQosApiMannager::clickClass(const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_class;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickPointer(const QString& currentIp,const bool& isClick)
{
    QString msgType = YMQosManager::kXBK_Click_pointer;
    if(false == isClick)
    {
        msgType = YMQosManager::kXBK_Click_remove_pointer;
    }
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickTimer(const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_timer;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickSelection(const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_selection;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickResponder(const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_responder;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickStuResponder()
{
    QString msgType = YMQosManager::kXBK_Click_stu_responder;
    QJsonObject jsonObj;
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickStuResponderSuccess()
{
    QString msgType = YMQosManager::kXBK_Click_stu_responderResult;
    QJsonObject jsonObj;
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickCountdown(const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_countdown;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickReward(const QString& userId,const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_reward;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("student_id",userId);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickAuthorization(const QString& userId,const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_authorization;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("student_id",userId);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickMute(const QString& userId,const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_mute;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickAullmute(const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_allmute;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::clickGoingdown(const QString& userId,const int& status,const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_onStage;
    if(status == 1)
    {
        msgType = YMQosManager::kXBK_Click_downStage;
    }
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("student_id",userId);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::responderIsSuccess(const QString& userId,const bool& ifSelected,const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_responder;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("student_id",userId);
    jsonObj.insert("ifSelected",ifSelected);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::networkQuality(const QString& lost, const QString& delay,const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_HearTable_networkQuality;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("currentSocketIp",currentIp);
    jsonObj.insert("lost",lost);
    jsonObj.insert("delay",delay);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::JoinClassroom(const QString &lessonId, const QString &lessonType, const QString &lessonStartTime, const QString &lessonEndTime)
{
    QString msgType = YMQosManager::kXBK_Click_enterClassroom;
    QJsonObject jsonObj;
    jsonObj.insert("lessonId",lessonId);
    jsonObj.insert("lessonType",lessonType);
    jsonObj.insert("lessonPlanStartTime",lessonStartTime);
    jsonObj.insert("lessonPlanEndTime",lessonEndTime);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::enterClassroomSuccess(const QString& lessonStartTime, const QString& lessonEndTime,const QString& result, const QString& errMsg,const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_enterClassroomFInish;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("lessonPlanStartTime",lessonStartTime);
    jsonObj.insert("lessonPlanEndTime",lessonEndTime);
    jsonObj.insert("result",result);
    jsonObj.insert("errMsg",errMsg);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::openCameraStatus(const int& status, const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_camera;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    QString cameraStatus = "open";
    if(status == 1)
    {
        cameraStatus = "close";
    }
    jsonObj.insert("cameraStatus",cameraStatus);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::socketDisconnect(const QString& errMsg, const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_HearTable_socketDisconnect;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("errMsg",errMsg);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::audioQuality(const QString& channel, const QString& sendLossRate, const QString& recvLossRate, const QString& receivedFrameRate, const QString& videoLost, const QString& audioLost, const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_HearTable_audioQuality;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("channel",channel);
    jsonObj.insert("sendLossRate",sendLossRate);
    jsonObj.insert("recvLossRate",recvLossRate);
    jsonObj.insert("receivedFrameRate",receivedFrameRate);
    jsonObj.insert("videoLost",videoLost);
    jsonObj.insert("audioLost",audioLost);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::coursewareReport(const QString& url, const QString& downStartTime, const QString& downEndTime, const QString& fileName, const QString& fileType, const QString& downResult, const QString& currentIp)
{
    QString msgType = YMQosManager::kXBK_Click_courseware;
    QJsonObject jsonObj;
    jsonObj.insert("socketIp",currentIp);
    jsonObj.insert("coursewareUrl",url);
    jsonObj.insert("startDownLoadTime",downStartTime);
    jsonObj.insert("endDownLoadTime",downEndTime);
    jsonObj.insert("fileName",fileName);
    jsonObj.insert("fileType",fileType);
    jsonObj.insert("downLoadResult",downResult);
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

void YMQosApiMannager::registerClassroomInfo(const QString &serverip)
{
    YMQosManager::gestance()->registerClassroomInfo(serverip);
}








