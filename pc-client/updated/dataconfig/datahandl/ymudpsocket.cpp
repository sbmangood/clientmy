#include "ymudpsocket.h"
#include "./ymcrypt.h"
#include <QDebug>

YMUDPSocket::YMUDPSocket(QObject *parent) : QObject(parent)
{
    addr.setAddress(StudentData::gestance()->m_address);
    port = StudentData::gestance()->m_port;
    udpSocket = new QUdpSocket(this);
    //每5s发送心跳
    heartBeatTimer = new QTimer(this);
    connect(heartBeatTimer, &QTimer::timeout, this, &YMUDPSocket::heartBeat);

    //每20ms检查是否有新消息
    readMsgTimer = new QTimer(this);
    connect(readMsgTimer, &QTimer::timeout, this, &YMUDPSocket::readFromSer);

}

YMUDPSocket::~YMUDPSocket()
{
    heartBeatTimer->stop();
    readMsgTimer->stop();
}

void YMUDPSocket::heartBeat()
{
    sendMsg("0#SYSTEM{\"domain\":\"system\",\"command\":\"heartBeat\"}");
}

void YMUDPSocket::newConnect()
{
    heartBeatTimer->start(5000);
    readMsgTimer->start(20);
    emit sigMsgReceived("0#{null:1540127389}#{\"domain\":\"server\",\"command\":\"reLogin\"}");
}

void YMUDPSocket::readFromSer()
{
    while(udpSocket->hasPendingDatagrams())  //是否有数据包
    {
        QByteArray arr;
        arr.resize(udpSocket->pendingDatagramSize());//把接收的数组大小设置为数据包大小
        quint16 t_port = this->port;
        QHostAddress t_addr = this->addr;
        udpSocket->readDatagram(arr.data(), arr.size(), &t_addr, &t_port);
        //拆包 数据包结构 包头+消息体+包尾，包头2个字节代表整个数据包的大小，包尾为一个字节值为'\n'。
        unsigned int totalDataLen = 0;
        for (;;)
        {
            if (arr.size() < totalDataLen + 4)
            {
                break;
            }
            //解析数据包大小 Little Endian
            quint32 dataSize = 0;
            dataSize = ((quint32)(quint8)(arr[totalDataLen])) | (((quint32)(quint8)(arr[totalDataLen + 1])) << 8);
            if (arr.size() - totalDataLen < dataSize)
            {
                break;
            }
            if (arr[totalDataLen + dataSize - 1] != '\n')
            {
                break;
            }
            QString msg = YMCrypt::decrypt(arr.mid(totalDataLen + 2, dataSize - 3));
            if (msg.startsWith("0#"))
            {
                if ( !msg.contains("heartBeat") && !msg.contains("response"))
                {
                    sendMsg("0#SYSTEM{\"domain\":\"system\",\"command\":\"response\",\"content\":{\"currentIndex\":\"0\"}}");
                }
            }
            emit sigMsgReceived(msg);
            totalDataLen += dataSize;
        }
    }
}

void YMUDPSocket::sendMsg(QString msg)
{
    udpSocket->writeDatagram(YMCrypt::encrypt(msg), addr, port);
}

void YMUDPSocket::changeSerIp(QString ip)
{
    addr.setAddress(ip);
}

void YMUDPSocket::disConnect()
{
    if (heartBeatTimer != NULL && heartBeatTimer->isActive())
    {
        heartBeatTimer->stop();
    }
    if (readMsgTimer != NULL && readMsgTimer->isActive())
    {
        readMsgTimer->stop();
    }
}
