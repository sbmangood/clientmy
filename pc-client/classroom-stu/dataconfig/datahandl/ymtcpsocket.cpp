#include "ymtcpsocket.h"
#include "./datamodel.h"

const int kWindowsTaskNo = 1001;

YMTCPSocket::YMTCPSocket(QObject *parent) : QObject(parent)
{
    message = "";

    initMarsService();
}

YMTCPSocket::~YMTCPSocket()
{
    destroyMarsService();
}

void YMTCPSocket::sendMsg(QString msg)
{
    static int mars_taskid_ = 0;

    //截取消息 增加新字段
    QString userLessonIdString = QString( ",\"userId\":\"%1\",\"lessonId\":\"%2\"}").arg(StudentData::gestance()->m_selfStudent.m_studentId, StudentData::gestance()->m_lessonId);

    msg.append("yxt__yxt");
    msg.remove("}yxt__yxt");
    msg.append(userLessonIdString);

    if(msg.contains("\"command\":\"enterRoom\""))
    {
        QString tempEnterRoomString = QString("content\":{\"flag\":\"%1\",\"logTime\":\"%2\",\"plat\":\"S\",\"userName\":\"%3\",").arg(TemporaryParameter::gestance()->enterRoomStatus, StudentData::gestance()->m_logTime, StudentData::gestance()->m_userName);
        msg.replace("content\":{", tempEnterRoomString);
    }

    //QString enMsg = "AES" + YMCrypt::tcpencrypt(msg) + "\n";

    CommTask* pCommTask = new CommTask();

    pCommTask->cmdid_ = kWindowsTaskNo;
    pCommTask->taskid_ = mars_taskid_++;
    pCommTask->channel_select_ = ChannelType_LongConn;
    pCommTask->cgi_ = "flow/windows";
    pCommTask->text_ = msg.toStdString();

    NetworkService::Instance().startTask(pCommTask);
}

void YMTCPSocket::OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend)
{
    Q_UNUSED(_channel_id);
    Q_UNUSED(_cmdid);
    Q_UNUSED(_taskid);
    Q_UNUSED(_extend);

    message = "";
    message.append((const char*)_body.Ptr());

    if (message[message.length() -1 ] != "}")
    {
        qDebug() << "OnPush(S):" << message;

        int lastRightBracePos = message.lastIndexOf("}");
        message = message.mid(0, lastRightBracePos + 1);
    }

    //QString line = YMCrypt::tcpdecrypt(message);
    emit readMsg(message);
}

void YMTCPSocket::OnState(int _status)
{
    if (_status == 2) // tcp socket 建立连接成功
    {
        emit readMsg("0#{null:1540127389}#{\"domain\":\"server\",\"command\":\"reLogin\"}");
        marsLongLinkStatus(true);
    }
    else if (_status == 3) // 断开连接
    {
        marsLongLinkStatus(false);
    }
}

bool YMTCPSocket::initMarsService()
{
    // 获得所有 IP 地址，将其设置为本地DNS解析数据仓库
    std::vector<std::string> allip;
    for(int i = 0; i < TemporaryParameter::gestance()->goodIpList.size(); ++i)
    {
        allip.push_back(TemporaryParameter::gestance()->goodIpList.at(i).toMap()["ip"].toString().toStdString());
    }

    NetworkService::Instance().setLongLinkAddress(StudentData::gestance()->m_address.toStdString(), 5125);
    NetworkService::Instance().setClientLocalDnsIPs(allip);
    NetworkService::Instance().setPushObserver(kWindowsTaskNo, this);
    NetworkService::Instance().setStateObserver(kLongLinkStateCallbackId, this);

    NetworkService::Instance().start();

    return true;
}

void YMTCPSocket::destroyMarsService()
{
    NetworkService::Instance().destroy();
}
