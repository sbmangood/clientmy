#include <qDebug>
#include "redpacket.h"

QMutex RedPacket::m_instanceMutex;
RedPacket* RedPacket::m_redPacket = nullptr;
RedPacket::RedPacket(QObject *parent)
    :QObject(parent)
    ,m_redPacketCallBack(nullptr)
{
    m_redPacket = this;
}

RedPacket::~RedPacket()
{

}

RedPacket* RedPacket::getInstance()
{
    if(nullptr == m_redPacket)
    {
        m_instanceMutex.lock();
        if(nullptr == m_redPacket)
        {
            qWarning()<< "RedPacket::get qml instance is null";
            m_redPacket = new RedPacket();
        }
        m_instanceMutex.unlock();
    }
    return m_redPacket;
}

void RedPacket::init(int rpId, int redCount, int redTime, int countDownTime, bool canClick)
{
    emit sigRedPacketsInfo(redCount, redTime, countDownTime, canClick);
}

void RedPacket::uninit()
{
    m_redPacketCallBack = nullptr;
}

void RedPacket::beginRedPackets()
{
    emit sigBeginRedPackets();
}

void RedPacket::endRedPackets(const QJsonObject &redPacketsDataObj)
{
    emit sigEndRedPackets(redPacketsDataObj);
}

void RedPacket::redPacketSize(int packetId, int packetSize)
{
    emit sigRedPacketSize(packetId, packetSize);
}

void RedPacket::setRedPacketsCallBack(IRedPacketCallBack* redPacketCallBack)
{
    m_redPacketCallBack = redPacketCallBack;
}

void RedPacket::startRedPackets()
{
    if(nullptr != m_redPacketCallBack)
        m_redPacketCallBack->onSendRedPackets();
}

void RedPacket::hitRedPacket(int packetId)
{
    if(nullptr != m_redPacketCallBack)
       m_redPacketCallBack->onHitRedPacket(packetId);
}

