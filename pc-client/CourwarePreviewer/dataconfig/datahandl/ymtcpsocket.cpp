#include "ymtcpsocket.h"
#include "./datamodel.h"
// 调试结束 修改 udp  调试端口
YMTCPSocket::YMTCPSocket(QObject *parent) : QObject(parent)
{
    //qDebug()<<" StudentData::gestance()"<<StudentData::gestance()->m_isTcpProtocol;

    isTcpProtocol = StudentData::gestance()->m_isTcpProtocol;
    //初始化 tcp udp 协议

    //tcp协议
    message = "";
    autoConnect = true;
    isConnecting = false;
    socket = new QTcpSocket(this);
    connect(socket, SIGNAL(readyRead()), this, SLOT(readRead()));
    connect(socket, SIGNAL(connected()), this, SLOT(connected()));
    connect(socket, SIGNAL(disconnected()), this, SLOT(disconnected()));
    connect(socket, SIGNAL(error(QAbstractSocket::SocketError)), this,
            SLOT(displayError(QAbstractSocket::SocketError)));
    heartBeatTask = new QTimer(this);
    connect(heartBeatTask, &QTimer::timeout, this, &YMTCPSocket::heartBeat);
    reconnectTask = new QTimer(this);
    connect(reconnectTask, &QTimer::timeout, this, &YMTCPSocket::reConnectSlot);

    //udp协议
    // addr.setAddress(StudentData::gestance()->m_address);
    udpSocket = new QUdpSocket(this);

    //每5s发送心跳
    heartBeatTimer = new QTimer(this);
    connect(heartBeatTimer, &QTimer::timeout, this, &YMTCPSocket::heartBeat);

    //每20ms检查是否有新消息
    readMsgTimer = new QTimer(this);
    connect(readMsgTimer, &QTimer::timeout, this, &YMTCPSocket::readRead); //读消息

    //检测十秒之内有没有收到消息十秒 两个心跳的时间
    checkUdpOnlineStateTimer = new QTimer(this);
    checkUdpOnlineStateTimer->setInterval(10000);
    connect(checkUdpOnlineStateTimer, SIGNAL(timeout()), this, SLOT(disconnected())); //发送掉线信号
    checkUdpOnlineStateTimer->setSingleShot(true);
    //connect(checkUdpOnlineStateTimer,&QTimer::timeout,this,&YMTCPSocket::reConnectSlot);
}

YMTCPSocket::~YMTCPSocket()
{
    //    if (heartBeatTask->isActive()) {
    //        heartBeatTask->stop();
    //    }
    //    if (reconnectTask->isActive()) {
    //        reconnectTask->stop();
    //    }
}

void YMTCPSocket::changeSerIp()//**
{
    newConnect();
}

void YMTCPSocket::heartBeat()//**
{
    if(isTcpProtocol)
    {
        sendMsg("0#{\"command\":\"heartBeat\",\"domain\":\"system\"}");
    }
    else
    {
        sendMsg("0#SYSTEM{\"domain\":\"system\",\"command\":\"heartBeat\"}");
    }
}

void YMTCPSocket::connected()//**
{
    //qDebug()<<"dasfdaaaa connect isTcpProtocol"<<isTcpProtocol;
    //reconnectTask->stop();
    autoConnect = true;
    isConnecting = false;
    if (reconnectTask->isActive())
    {
        reconnectTask->stop();
    }
    if(isTcpProtocol)
    {
        heartBeatTask->start(5000);
        //重新登录
        emit readMsg("0#{null:1540127389}#{\"domain\":\"server\",\"command\":\"reLogin\"}");
        emit hasNetConnects(true);
    }
    else
    {
        heartBeatTimer->start(5000);
        readMsgTimer->start(20);
        emit readMsg("0#{null:1540127389}#{\"domain\":\"server\",\"command\":\"reLogin\"}");
        emit hasNetConnects(true);
    }
}

void YMTCPSocket::sendMsg(QString msg)//**
{
    //截取消息 增加新字段
    QString userLessonIdString = QString( ",\"userId\":\"%1\",\"lessonId\":\"%2\"}").arg(StudentData::gestance()->m_selfStudent.m_studentId, StudentData::gestance()->m_lessonId);

    msg.append("yxt__yxt");
    msg.remove("}yxt__yxt");
    msg.append(userLessonIdString);

    if(msg.contains("\"command\":\"enterRoom\""))
    {
        QString tempEnterRoomString = QString("content\":{\"flag\":\"%1\",\"logTime\":\"%2\",\"plat\":\"T\",\"userName\":\"%3\",").arg(TemporaryParameter::gestance()->enterRoomStatus, StudentData::gestance()->m_logTime, StudentData::gestance()->m_userName);
        msg.replace("content\":{", tempEnterRoomString);
        //qDebug()<<QStringLiteral("new enterRoom 1")<< userLessonIdString;
    }
    //qDebug()<<QStringLiteral("发送消息：")<<isTcpProtocol<<msg<<addr<<port << StudentData::gestance()->m_address <<StudentData::gestance()->m_port;
    if(isTcpProtocol)
    {
        QString enMsg = "AES" + YMCrypt::tcpencrypt(msg) + "\n";
        socket->write(enMsg.toUtf8());
        socket->flush();
    }
    else
    {
        udpSocket->writeDatagram(YMCrypt::encrypt(msg), addr, port);
    }
}

void YMTCPSocket::disConnect()
{
    autoConnect = false;
    qDebug() << "**********YMTCPSocket::disConnect************" << reconnectTask->isActive() << isTcpProtocol << heartBeatTask->isActive();
    if (reconnectTask->isActive())
    {
        reconnectTask->stop();
    }
    if(isTcpProtocol)
    {
        //TemporaryParameter::gestance()->isAutoDisconnectServer = true;
        if (heartBeatTask->isActive())
        {
            heartBeatTask->stop();
        }
        socket->disconnectFromHost();
        socket->waitForDisconnected(3000);
    }
    else
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
}

void YMTCPSocket::newConnect()//**
{
    //TemporaryParameter::gestance()->isAutoDisconnectServer = false;
    isTcpProtocol = StudentData::gestance()->m_isTcpProtocol;
    // qDebug()<<"StudentData::gestance()->m_isTcpProtocol;"<<isTcpProtocol<<"autoConnect" <<autoConnect <<"isConnecting"<<isConnecting;
    if(isTcpProtocol)
    {
        if (isConnecting)
        {
            //  qDebug()<<"return adsad2222222sada  dasdsa ";
            return;
        }
        // qDebug()<<"return adsadsada  dasdsa sssssss"<<StudentData::gestance()->m_address<<StudentData::gestance()->m_port;
        isConnecting = true;
        // qDebug()<<" socket->abort();11111111111111";
        socket->abort();
        //  qDebug()<<" socket->abort();2222222222222";
        socket->bind(QHostAddress(StudentData::gestance()->m_address), StudentData::gestance()->m_port);

        socket->connectToHost(QHostAddress(StudentData::gestance()->m_address), StudentData::gestance()->m_port);
        if (!socket->waitForConnected(5000))
        {

            socket->abort();
            //   qDebug()<<"socket->waitForConnected(2000)";
            isConnecting = false;
            //emit hasNetConnects(true);
            tcpConnectFail();
        }
        isConnecting = false;
    }
    else
    {
        heartBeatTimer->stop();
        readMsgTimer->stop();
        checkUdpOnlineStateTimer->stop();
        timerIsStop = false;
        // qDebug()<<" checkUdpOnlineStateTimer->stop();"<< checkUdpOnlineStateTimer->isActive();
        addr.setAddress(StudentData::gestance()->m_address);
        port = StudentData::gestance()->m_udpPort;
        checkUdpOnlineStateTimer->start();
        connected();

        heartBeatTimer->start(5000);
        readMsgTimer->start(20);
    }
}

void YMTCPSocket::readRead()
{
    if(isTcpProtocol)
    {

        //每次接收到的消息 为 msg\n 或者 msg\nms 之类的格式
        //所以先把每次接收到的消息跟message变量拼接，然后以'\n'切割
        //产生的list ["msg",""] 或者 ["msg","ms"] 两种格式
        //list中的最后一条数据为 不完整消息(ms) 或者 "",前面的都是一条完整的消息
        //把list中的最后一条数据赋值给 message变量 用以下次接收消息时做拼接
        QString msg = socket->readAll();
        message += msg;
        if (message.contains('\n'))
        {
            QStringList stringlist = message.split("\n", QString::KeepEmptyParts);
            for (int i = 0; i < stringlist.size(); i++)
            {
                if (i == stringlist.size() - 1)
                {
                    message = stringlist.at(i);
                }
                else
                {
                    //处理一条消息
                    QString line = stringlist.at(i);
                    line = YMCrypt::tcpdecrypt(line);
                    emit readMsg(line);
                }
            }
        }
    }
    else
    {
        while(udpSocket->hasPendingDatagrams())  //是否有数据包
        {
            //  qDebug()<<"udp  hasPendingDatagrams "<<checkUdpOnlineStateTimer->isActive();
            if(checkUdpOnlineStateTimer->isActive() == false || timerIsStop == true)
            {
                //掉线中发送重连信号
                //      qDebug()<<"udp reconnect ";
                timerIsStop = false;
                connected();
            }

            checkUdpOnlineStateTimer->stop();//停用掉线定时器
            checkUdpOnlineStateTimer->start();//重新开启掉线定时器

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
                // emit sigMsgReceived(msg);
                emit readMsg(msg);

                totalDataLen += dataSize;
            }
        }

    }
}

void YMTCPSocket::disconnected()//掉线重连
{
    //  qDebug()<<"disconnected()";
    TemporaryParameter::gestance()->enterRoomStatus = "R";
    emit hasNetConnects(false);
    if(isTcpProtocol)
    {
        if (!reconnectTask->isActive())
        {
            reconnectTask->start(5000);
        }
    }
    else
    {
        // qDebug()<<"udp disConnect~~~~~~~~~~~~~~~~";
        timerIsStop == true;

        heartBeatTimer->stop();
        readMsgTimer->stop();
        checkUdpOnlineStateTimer->stop();
        timerIsStop = false;
        //qDebug()<<" checkUdpOnlineStateTimer->stop();"<< checkUdpOnlineStateTimer->isActive();
        addr.setAddress(StudentData::gestance()->m_address);
        //addr.setAddress("123.59.155.57");//测试完毕进行修改
        port = StudentData::gestance()->m_udpPort;
        // port = 5120;//测试完毕进行修改
        //udpSocket->abort();
        //udpSocket->bind(addr, port);
        checkUdpOnlineStateTimer->start();
        // qDebug() << "finishLesson::" << TemporaryParameter::gestance()->m_isFinishLesson;
        if(TemporaryParameter::gestance()->m_isFinishLesson)
        {
            heartBeatTimer->stop();
            readMsgTimer->stop();
            checkUdpOnlineStateTimer->stop();
            return;
        }
        connected();
        heartBeatTimer->start(5000);
        readMsgTimer->start(20);

    }
}

void YMTCPSocket::displayError(QAbstractSocket::SocketError)
{
    //qDebug()<<"displayError(QAbstractSocket::SocketError)";
    if(isTcpProtocol)
    {
        if (!reconnectTask->isActive())
        {
            reconnectTask->start(5000);
        }
    }
    else
    {

    }
}

void YMTCPSocket::changeConnectProtocol()
{
    isTcpProtocol = StudentData::gestance()->m_isTcpProtocol;
    if(isTcpProtocol)
    {
        //停用 udp
    }
    else
    {

    }
}

void YMTCPSocket::reConnectSlot()
{
    isTcpProtocol = StudentData::gestance()->m_isTcpProtocol;
    //  qDebug()<<" reconnect"<<isTcpProtocol;
    if(isTcpProtocol)
    {
        if (!autoConnect || isConnecting)
        {
            //   qDebug()<<"return reconnect vreconnect ";
            return;
        }
        //  qDebug()<<"reconnectreconnectreconnect111111111111111"<<StudentData::gestance()->m_address<<StudentData::gestance()->m_port;
        isConnecting = true;
        //   qDebug()<<" socket->abort();1111111111111reconnect1";
        socket->abort();
        //  qDebug()<<" socket->abort();222222222222 reconnect2";
        socket->connectToHost(QHostAddress(StudentData::gestance()->m_address), StudentData::gestance()->m_port);
        if (!socket->waitForConnected(3000))
        {
            socket->abort();
        }
        isConnecting = false;
    }
    else
    {
        heartBeatTimer->stop();
        readMsgTimer->stop();
        checkUdpOnlineStateTimer->stop();
        timerIsStop = false;
        //   qDebug()<<" checkUdpOnlineStateTimer->stop();"<< checkUdpOnlineStateTimer->isActive();
        addr.setAddress(StudentData::gestance()->m_address);
        //addr.setAddress("123.59.155.57");//测试完毕进行修改
        port = StudentData::gestance()->m_udpPort;
        // port = 5120;//测试完毕进行修改
        //udpSocket->abort();
        //udpSocket->bind(addr, port);
        checkUdpOnlineStateTimer->start();
        connected();

        heartBeatTimer->start(5000);
        readMsgTimer->start(20);
    }
}
void YMTCPSocket::resetDisConnect(bool disconnetType)
{
    //   qDebug()<<"isdisconnectisdisconnectisdisconnect3"<<socket->error()<< socket->state()<<disconnetType;
    if(disconnetType)
    {
        //TemporaryParameter::gestance()->isAutoDisconnectServer = true;
        if (heartBeatTask->isActive())
        {
            heartBeatTask->stop();
        }
        if (reconnectTask->isActive())
        {
            reconnectTask->stop();
        }
        autoConnect = false;

        // qDebug()<<"isdisconnectisdisconnectisdisconnect3"<<socket->error()<< socket->state();
        // bool isdisconnect =  socket->waitForDisconnected(3000);
        socket->abort();
        socket->reset();
        socket->close();

        //   qDebug()<<"isdisconnectisdisconnectisdisconnect111111111111111111"<<socket->error()<< socket->state();

    }
    else
    {
        if (heartBeatTimer != NULL && heartBeatTimer->isActive())
        {
            heartBeatTimer->stop();
        }
        if (readMsgTimer != NULL && readMsgTimer->isActive())
        {
            readMsgTimer->stop();
        }
        udpSocket->abort();
        udpSocket->close();
        checkUdpOnlineStateTimer->stop();
        timerIsStop == true;
        //  emit hasNetConnects(false);
    }
}
