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

    private slots:
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

    public:
        int m_currentPage;//当前页
        QString m_currentCourse;//当前课件
        QMap<QString, QList<MessageModel> > m_pages;//每个课件每一页的内容

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
        QString m_supplier;//音视频供应商 1声网 2 QQ
        QString m_videoType;//音视频状态 1仅音频 2音视频
        QString m_includeSelfMsg;

        bool m_isInit;//是不是第一次上课
        int m_firstPage;//是不是第一次翻页

    private:
        void parseMsg(QString &num, QString &fromUser, QString &msg);
        void newConnect();
        void startSendMsg();
        void stopSendMsg();
        void startSendAudioQuality();
        void stopSendAudioQuality();
        void checkTimeOut();

        ~SocketHandler();

};

#endif // SOCKETHANDLER_H
