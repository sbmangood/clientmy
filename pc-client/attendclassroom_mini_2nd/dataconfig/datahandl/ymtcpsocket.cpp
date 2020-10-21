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

    message.append((const char*)_body.Ptr());
    message = message.mid(0, _body.Length());

    emit readMsg(message);

    message = "";
}

void YMTCPSocket::OnState(int _status)
{
    if (_status == 2) // tcp socket 建立连接成功
    {
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

    NetworkService::Instance().setLongLinkAddress(StudentData::gestance()->m_address.toStdString(), StudentData::gestance()->m_port);
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
