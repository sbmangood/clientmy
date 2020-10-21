#ifndef SOCKETHANDLER_H
#define SOCKETHANDLER_H

#include <QObject>
#include <QAbstractSocket>
#include <QMutex>
#include <QTime>
#include <QMap>
#include <QDebug>
#include "../datahandl/messagemodel.h"
#include "./datamodel.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"
#include "miniClass/YMMiniLessonManager.h"
#include "../YMCommon/qosV2Manager/YMQosManager.h"
#include "H5datamodel.h"
#include "../classroom-sdk/sdk/inc/socketmanager/isocketmessgaecallback.h"
#include "../classroom-sdk/sdk/inc/socketmanager/isocketmessagectrl.h"
#include "../trailboard/miniwhiteboardctrl.h"
class QTcpSocket;
class QTimer;

class SocketHandler : public QObject, public ISocketMessageCallBack
{
        Q_OBJECT
    public:
        explicit SocketHandler(QObject *parent = 0);

        static  SocketHandler *getInstance()
        {
            static SocketHandler socketHandler;
            return &socketHandler;
        }
        void sendLocalMessage(QString message, bool append, bool drawPage);
        int getCurrentPage(QString docId);
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
        void sigIsCourseWare(bool isCourseware);
        void sigSendHttpUrl(QString urls);
        //处理结束课程
        void sigStudentEndClass( QString usrid);
        void sigStartClassTimeData(QString times);
        void sigNetworkOnline(bool online);//网络是否在线状态信号
        void sigChangedWay(QString supplier);//切换通道命令信号
        void sigChangedPage();//跳转分页
        void sigOneStartClass();//第一次开课重置讲义
        void sigStudentAppversion(bool status);//学生当前版本号 如果小于3.0版本则不支持新讲义
        void sigInterNetChange(int netWorkStatus);

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

        //getbackAisle 返回原来的通道
        void getbackAisle();

    public slots:
        void picture(QString url, double width, double height);
        void clearScreen();

    private slots:
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
        void sigAvUrl(int flag,int time,QString dockId);
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
        void sigJoinClassroom(QString userId);//学生动态加入教室
        void sigIsOnline(int uid,QString onlineStatus);
        void sigUserAuth(QString userId,int up,int trail,int audio,int video,bool isSynStatus);
        void sigStartResponder(QJsonObject responderData);//开始抢答
        void sigSynCoursewareType(int courseware,QString h5Url);
        void sigSynCoursewareInfo(QJsonObject jsonObj);
        void sigSynCoursewareStep(QString pageId,int step);
        void sigClearScreen();//清屏信号

private:
        //消息接收
        virtual void onRecvMessage(const QJsonObject &jsonMsg, const QString &message);
        virtual void onAutoChangeIpResult(const QString & result);
        virtual void onNetWorkMode(const QString &netWorkMode);
        virtual void onAutoConnectionNetwork();//自动连接服务器信号
        virtual void onPersonData(const QString &address, int port);
        virtual QString getNetWorkMode();

        void init(const QString &pluginPathName);
        void uninit();
        QObject* loadPlugin(const QString &pluginPath);
        void unloadPlugin(QObject* instance);

        ISocketMessageCtrl* m_socketMessageCtrl;

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

        int m_avFlag;
        int m_avPlayTime;
        QString m_avId;
        QString m_netType;

    private:
        QString m_message;//接收的消息
        QTimer *m_sendAudioQualityTask;//发送语音质量
        bool m_response;//服务端是否给消息响应
        QString m_lastSendMsg;//上一次发送的消息
        int m_sendMsgNum;//发送的消息编号
        QString m_lastRecvNum;
        QString m_lastRecvMsg;
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
        bool isOneStart = false;//是否第一次启动
        //记录当前的链接次数  便于切换ip
        int currentAutoChangeIpTimes = 0;
        int m_currentDocType;
        QString m_currentCourseUrl;

        YMHttpClient * m_httpClient;
        QString m_httpUrl;

   public:
        //新协议消息模板函数-begin
        QString ackServerMsgTemplate(quint32 serverSn);
        QString keepAliveReqMsgTemplate(void);
        QString enterRoomReqMsgTemplate(void);
        QString syncUserHistroyReqMsgTemplate(quint8 self);
        QString syncUserHistroyFinMsgTemplate(void);
        QString trailReqMsgTemplate(QJsonObject content);
        QString pointReqMsgTemplate(qint32 x, qint32 y);
        QString docReqMsgTemplate(int currPageNo, int pageTotal, QString coursewareId,QJsonArray imgUrlList,QString h5Url,int docType);
        QString avReqMsgTemplate(int playStatus, int timeSec, QString coursewareId,QString path,QString suffix);
        QString pageReqMsgTemplate(int opType, int currPageNo, int pageTotal, QString coursewareId);
        QString authReqMsgTemplate(QString whoUid, qint8 upState, qint8 trailState, qint8 audioState, qint8 videoState);
        QString muteAllReqMsgTemplate(int muteAllState);
        QString kickOutReqMsgTemplate(void);
        QString exitRoomReqMsgTemplate(void);
        QString finishMsgTemplate(void);
        QString zoomMsgTemplate(QString coursewareId, double ratio, double offsetX, double offsetY);
        QString operationMsgTemplate(int opType,int pageNo,int totalNum,QString coursewareId);
        QString rewardMsgTemplate(QString whoUid, int rewardType, int millisecond, QString userName);
        QString rollMsgTemplate(QString whoUid, int rollType, QString userName);
        QString responderMsgTemplate(int respType, int timesec);
        QString timerMsgTemplate(int timerType, int flag, int timesec);
        QString startClassMsgTemplate(void);
        QString playAnimationMsgTemplate(int step);
        //新协议消息模板函数-end

        //缓存课件信息
        void cacheDocInfo(QJsonArray coursewareUrls, QString coursewareId,int coursewareType);

    private:
        //毫秒级别时间邮戳--begin
        quint64 createTimeStamp(void);
        //毫秒级别时间邮戳--end

        //创建消息模板函数--begin
        QString createMessageTemplate(QString command, quint64 lid, quint64 uid, QJsonObject content);
        //创建消息模板函数--end

        //确认退出房间
        void finishRespExitRoom(void);

        //更新课件信息-begin
        bool updateCoursewareInfo(QString& coursewareId, QString &coursewareMsg);
        //更新课件信息-end

        //协议中的数据缓存管理-begin
        bool cacheCoursewareInfo(QString& message);
        void cacheTrailMessage(QString& fromUid, QString& message);
        void cachePonitMessage(QString& fromUid, QString& message);
        void cacheDocMessage(QString& fromUid, QString& message);
        void cacheAVMessage(QString& fromUid, QString& message);
        void cachePageMessage(QString& fromUid, QString& message);
        void cacheAuthMessage(QString& fromUid, QString& message);
        void cacheMuteAllMessage(QString& fromUid, QString& message);
        void cacheZoomMessage(QString& fromUid, QString& message);
        void cacheOperationMessage(QString& fromUid, QString& message);
        void cacheReward(QString& fromUid, QString& message);
        void cacheResponder(QString& fromUid, QString& message);
        void cacheStartClass(void);
        void cachePlayAnimation(QString message);
        //协议中的数据缓存管理-end

        //解析协议中的控制指令--begin
        QString parseMessageCommand(QString& message);
        QString parseMessageUid(QString& message);
        QString parseMessageDockId(QString& message);
        QString parseMessagePageId(QString& message);
        int parseMessageDocType(QString& message);
        //解析协议中的控制指令--end

        //同步历史记录-begin
        bool syncUserHistroyReq(QJsonArray& userHistroyData);
        void fixUserSnFromServer(qint32 nMySn);
        void parseUserCommandOp(QString& command, QString& message);
        void syncUserHistroyComplete(void); //同步完成
        //同步历史记录-end

        //新协议数据解析函数管理-begin
        void updateUserState(QJsonValue content);
        //新协议数据解析函数管理-end

        //H5课件同步处理
        void updateH5SynCousewareInfo();

        //新协议数据-begin
        quint32   m_uMessageNum;//发送给服务器时的消息编号
        quint32   m_uServerSn;//服务器sn消息序列号
        QMutex  m_mMessageNumMutex;//消息序号锁
        //新协议数据-end

        quint64 m_uLastSendTimeStamp;   //毫秒级别
        bool   m_bCanSend;                      //是否能发送消息
        bool   m_bServerResp;                  //服务器是否已回复
        bool  m_bConfirmFinish;               //确认结束(退出教室)
        bool m_isRemoverPage;
        int m_currentStep;
        QList<H5dataModel> m_h5Model;

        YMMiniLessonManager m_miniLessonManager;
        MiniWhiteBoardCtrl* m_miniWhiteBoardCtrl;
    private:
        void parseMsg(QString &num, QString &fromUser, QString &msg);
        void newConnect();
        void startSendAudioQuality();
        void stopSendAudioQuality();
        ~SocketHandler();

};

#endif // SOCKETHANDLER_H
