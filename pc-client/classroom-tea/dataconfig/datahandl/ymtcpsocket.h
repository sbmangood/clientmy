#ifndef YMTCPSOCKET_H
#define YMTCPSOCKET_H

#include <QObject>
#include <QAbstractSocket>
#include <QTcpSocket>
#include <QTimer>
#include "./ymcrypt.h"
#include "../YMCommon/longLinkManager/NetworkService.h"

class YMTCPSocket : public QObject, public PushObserver, public StateObserver
{
        Q_OBJECT
    public:
        explicit YMTCPSocket(QObject *parent = 0);
        ~YMTCPSocket();

    signals:
        void readMsg(QString msg);
        void marsLongLinkStatus(bool status);

    public:
        void sendMsg(QString msg);

   public:
        // Mars Socket 推送消息(内部接口)
        virtual void OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend);
        // Mars Socket 连接状态(内部接口)
        virtual void OnState(int _status);

   public:
        // Mars 初始化服务
        bool initMarsService(void);
        // Mars 销毁服务
        void destroyMarsService(void);

    private:
        // 接收消息缓存
        QString message;
};

#endif // YMTCPSOCKET_H
