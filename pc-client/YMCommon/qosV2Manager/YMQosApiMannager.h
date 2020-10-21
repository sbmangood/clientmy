#ifndef YMQOSAPIMANNAGER_H
#define YMQOSAPIMANNAGER_H

#include <QObject>

class YMQosApiMannager : public QObject
{
    Q_OBJECT
public:
    YMQosApiMannager(QObject *parent = 0);
    ~YMQosApiMannager();

    static YMQosApiMannager * gestance()
    {
        static YMQosApiMannager * qosApiManager = new YMQosApiMannager();
        return qosApiManager;
    }

public:
    Q_INVOKABLE void clickClass(const QString& currentIp);//点击上课
    Q_INVOKABLE void clickPointer(const QString& currentIp,const bool& isClick);//点击教鞭isClick：true 点击； false 为取消
    Q_INVOKABLE void clickTimer(const QString& currentIp);//点击计时器
    Q_INVOKABLE void clickSelection(const QString& currentIp);//随机选人
    Q_INVOKABLE void clickResponder(const QString& currentIp);//抢答器
    Q_INVOKABLE void clickStuResponder();//学生抢答
    Q_INVOKABLE void clickStuResponderSuccess();//学生抢中
    Q_INVOKABLE void clickCountdown(const QString& currentIp);//倒计时
    Q_INVOKABLE void clickReward(const QString& userId,const QString& currentIp);//课堂奖励
    Q_INVOKABLE void clickAuthorization(const QString& userId,const QString& currentIp);//授权
    Q_INVOKABLE void clickMute(const QString& userId,const QString& currentIp);//静音
    Q_INVOKABLE void clickAullmute(const QString& currentIp);//全体静音
    Q_INVOKABLE void clickGoingdown(const QString& userId,const int& status,const QString& currentIp);//上下台 status 0上台 1下台
    Q_INVOKABLE void responderIsSuccess(const QString& userId,const bool& ifSelected,const QString& currentIp);//学生抢答
    Q_INVOKABLE void networkQuality(const QString& lost,const QString& delay,const QString& currentIp);//网络质量
    Q_INVOKABLE void enterClassroomSuccess(const QString& lessonStartTime,const QString& lessonEndTime,const QString& result,const QString& errMsg,const QString& currentIp);//进入教室成功
    Q_INVOKABLE void JoinClassroom(const QString& lessonId,const QString& lessonType,const QString& lessonStartTime,const QString& lessonEndTime);//点击进入教室
    Q_INVOKABLE void openCameraStatus(const int& status,const QString& currentIp);//打开关闭摄像头 0：开 1：关
    Q_INVOKABLE void socketDisconnect(const QString& errMsg,const QString& currentIp);//socket掉线上报
    Q_INVOKABLE void audioQuality(const QString& channel,const QString& sendLossRate,const QString& recvLossRate,const QString& receivedFrameRate,const QString& videoLost,const QString& audioLost,const QString& currentIp);//音视频通话质量上报
    Q_INVOKABLE void coursewareReport(const QString& url,const QString& downStartTime,const QString& downEndTime,const QString& fileName,const QString& fileType,const QString& downResult,const QString& currentIp);//课件上报
    Q_INVOKABLE void registerClassroomInfo(const QString& serverip);
};

#endif // YMQOSAPIMANNAGER_H
