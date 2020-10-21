#ifndef YMUDPSOCKET_H
#define YMUDPSOCKET_H

#include <QObject>
#include <QUdpSocket>
#include <QTimer>
#include "./datamodel.h"

class YMUDPSocket : public QObject
{
        Q_OBJECT
    public:
        explicit YMUDPSocket(QObject *parent = 0);
        ~YMUDPSocket();

    signals:
        void sigMsgReceived(QString msg);
    public slots:
        //心跳
        void heartBeat();

        void newConnect();
        //接收消息
        void readFromSer();
        //发送消息
        void sendMsg(QString msg);
        //切换服务器
        void changeSerIp(QString ip);

        void disConnect();


    private:

    private:
        QUdpSocket *udpSocket;      //UDP socket fd
        QTimer *heartBeatTimer;     //心跳任务
        QTimer *readMsgTimer;       //接收消息任务
        QHostAddress addr;          //udp server 地址
        quint16 port;               //udp server 端口
};

#endif // YMUDPSOCKET_H
