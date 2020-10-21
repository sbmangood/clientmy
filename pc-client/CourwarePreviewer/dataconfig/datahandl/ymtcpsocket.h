#ifndef YMTCPSOCKET_H
#define YMTCPSOCKET_H

#include <QObject>
#include <QAbstractSocket>
#include <QTcpSocket>
#include <QUdpSocket>
#include <QTimer>
#include "./ymcrypt.h"

class QTcpSocket;

class YMTCPSocket : public QObject
{
        Q_OBJECT
    public:
        explicit YMTCPSocket(QObject *parent = 0);
        ~YMTCPSocket();
        void changeSerIp();

    signals:
        void readMsg(QString msg);


        void hasNetConnects(bool hasNetConnect);

        void tcpConnectFail();
    public slots:
        void heartBeat();
        void connected();
        void sendMsg(QString msg);
        void disConnect();
        void newConnect();
        void readRead();
        void disconnected();
        void displayError(QAbstractSocket::SocketError);

        //切换连接服务器的方式
        void changeConnectProtocol();

        void reConnectSlot();

        void resetDisConnect(bool disconnetType);//断开tcp 或者udp
    private:
        QString message;
        QTimer *heartBeatTask;
        QTimer *reconnectTask;
        QTcpSocket *socket;
        bool autoConnect;
        bool isConnecting;

        bool isTcpProtocol = true; //协议类型 true为tcp  false udp

        //udp
        QUdpSocket *udpSocket;      //UDP socket fd
        QTimer *heartBeatTimer;     //心跳任务
        QTimer *readMsgTimer;       //接收消息任务
        QHostAddress addr;          //udp server 地址
        quint16 port;               //udp server 端口

        //udp协议 检测掉线定时器 十秒 之内没有收到消息视为掉线
        QTimer *checkUdpOnlineStateTimer;

        bool timerIsStop = false;


};

#endif // YMTCPSOCKET_H
