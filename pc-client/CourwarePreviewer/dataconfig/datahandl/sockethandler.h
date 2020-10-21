#ifndef SOCKETHANDLER_H
#define SOCKETHANDLER_H

#include <QObject>
#include <QAbstractSocket>
#include <QMutex>
#include <QTime>
#include <QMap>
#include <QDebug>
#include "./messagemodel.h"
#include "./datamodel.h"
#include "./ymtcpsocket.h"
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"

class QTcpSocket;
class QTimer;

class SocketHandler : public QObject
{
        Q_OBJECT
    public:
        explicit SocketHandler(QObject *parent = 0);
        void sendLocalMessage(QString cmd, bool append, bool drawPage);
        int getCurrentPage(QString docId);

        void excuteMsg(QString &msg, QString &fromUser);

        void clearRecord();

        //ip切换
        void onChangeOldIpToNew();

        void setFirstPage(int pages);
        void disconnectSocket(bool reconnect);
    signals:
        void sigEnterOrSync(int  sync);
        void sigExitRoomIds(QString ids);//退出教室的id
        void sigDroppedRoomIds(QString ids); //掉线
        void sigSendUserId(QString userId);
        void sigUserIdExitClassroom(QString userId);
        void sigEnterRoomRequest(QString userId);
        void sigIsCourseWare();
        void sigSendHttpUrl(QString urls);
        //处理结束课程
        void sigStudentEndClass( QString usrid);
        void sigStartClassTimeData(QString times);
        void sigNetworkOnline(bool online);//网络是否在线状态信号
        void sigChangedWay(QString supplier);//切换通道命令信号
        void sigChangedPage();//跳转分页
        void sigOneStartClass();//第一次开课重置讲义
        void sigStudentAppversion(bool status);//学生当前版本号 如果小于3.0版本则不支持新讲义

        /*讲义信号
         *属性介绍：当前题目ID：讲义Id,栏目Id，题目Id, 题目类型(0:题目，1:课件截图，2:空白页),offsetY:坐标，questionBtnStatus：题目状态
         */
        void sigCurrentQuestionId(
            QString planId,
            QString columnId,
            QString questionId,
            double offsetY,
            bool questionBtnStatus);

        //关闭摄像头操作
        void  sigUserIdCameraMicrophone(QString usrid, QString camera,  QString microphone);

        //允许操作权限
        void sigAuthtrail(QMap<QString, QString>);

        //教鞭坐标
        void sigPointerPosition(double xPoint, double yPoint);

    public slots:
        void undo();
        void addPage();
        void deletePage();
        void goPage(int pageIndex);
        void picture(QString url, double width, double height);
        void clearScreen();
        //判断自动切换ip的结果
        void justChangeIp(bool isSuccess);
        void autoChangeIp();

    public slots:
        void readMessage(QString line);//接收消息
        void sendMessage(QString message);
        void sendMessage();
        void sendAudioQuality();

    signals:
        void sigUsersInRoom(QList<QString> users);
        void sigBrushPermisions(QMap<QString, QString> brushPermisions);
        void sigPagePermisions(QMap<QString, QString> pagePermisions);
        void sigSupplier(QString supplier);
        void sigVideoType(QString videoType);
        void sigDrawPage(MessageModel model);
        void sigDrawLine(QString command);
        // void sigAuthtrail(QMap<QString, QString>);
        void sigEnterFailed();
        //视频控制
        void sigAvUrl( QString avType, QString startTime, QString controlType, QString avUrl );
        //自动切换线路结果
        // autoChangeIpStatus 自动切换IP状态 showAutoChangeIpview 显示网络不好; autoChangeIpSuccess 自动切换ip 成功; autoChangeIpFail 自动切换ip失败
        void autoChangeIpResult(QString autoChangeIpStatus);
        void sigCurrentLessonTimer(int lessonTimer);//当前上课总时间
        void sigAutoConnectionNetwork();//自动连接服务器信号
        void sigAnalysisQuestionAnswer(long lessonId, QString questionId, QString planId, QString columnId); //提交练习题命令解析信号
        void sigOffsetY(double offsetY);
        void sigZoomInOut(double offsetX, double offsetY, double zoomRate); //
        void sigPlanChange(long lessonId, long planId, long itemId); //当前讲义信号
        void sigCurrentColumn(long planId, long columnId); //当前栏目
        void sigIsOpenCorrect(bool isOpenStatus);//打开关闭批改面板
        void sigIsOpenAnswer(bool isOpenStatus, QString questionId, QString childQuestionId); //打开关闭答案解析
        void sigSynColumn(QString planId, QString columnId); //同步菜单栏
        void sigSynQuestionStatus(bool status);//同步开始做题按钮状态 true 开始做题，false 停止做题

    public:
        int m_currentPage;//当前页
        bool m_sysnStatus;//是否同步
        QString m_currentCourse;//当前课件
        QString m_currentPlanId;//当前讲义Id
        QString m_currentColumnId;//当前栏目Id
        QString m_currentQuestionId;//当前题目Id
        bool m_currentQuestionButStatus;//当前开始做题按钮状态
        double offsetY;//当前滚动的坐标
        bool m_isGotoPageRequst;
        QMap<QString, QList<MessageModel> > m_pages;//每个课件每一页的内容
        //重设优选ip列表
        void restGoodIpList();

    private:
        YMTCPSocket *m_socket;
        QString m_message;//接收的消息
        QTimer *m_sendMsgTask;
        QTimer *m_sendAudioQualityTask;//发送语音质量
        QList<QString> m_sendMsgs;
        QMutex m_sendMsgsMutex;
        bool m_response;//服务端是否给消息响应
        QString m_lastSendMsg;//上一次发送的消息
        int m_sendMsgNum;//发送的消息编号
        QString m_lastRecvNum;
        QString m_lastRecvMsg;
        QTime m_lastHBTime;//上次心跳时间
        QString m_enterRoomMsg;
        bool m_canSend;//是否已经成功进入教室可发送其他消息

        QMap<QString, int> m_pageSave;//每个课件的当前显示页码
        QMap<QString, QString> m_userBrushPermissions;//每个用户的书写权限
        QMap<QString, QString> m_userPagePermissions;//每个用户的翻页权限
        QString m_supplier;//音视频供应商 1声网 2 腾讯
        QString m_videoType;//音视频状态 1仅音频 2音视频
        QString m_includeSelfMsg;

        bool m_isInit;//是不是第一次上课
        int m_firstPage;//是不是第一次翻页

        int currentReloginTimes;//记录当前重新登录的次数
        bool isAutoChangeIping = false;//是否正在自动切换ip
        bool isFirstConnect = true;
        bool isDisconnectBySelf = true;
        //记录当前的链接次数  便于切换ip
        int currentAutoChangeIpTimes = 0;
        YMHttpClient * m_httpClient;
        QString m_httpUrl;
        bool isInitFromServe = false;

    private:
        void parseMsg(QString &num, QString &fromUser, QString &msg);
        void newConnect();
        void startSendMsg();
        void stopSendMsg();
        void startSendAudioQuality();
        void stopSendAudioQuality();
        void checkTimeOut();
#ifdef USE_OSS_AUTHENTICATION
        QString getOssSignUrl(QString key);//获取OSS重新签名的URL
        QString checkOssSign(QString imgUrl);//检查是否需要验签
#endif
        ~SocketHandler();

};

#endif // SOCKETHANDLER_H
