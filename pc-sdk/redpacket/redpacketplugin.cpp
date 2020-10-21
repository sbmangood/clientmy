#include <qqml.h>
#include "redpacketplugin.h"

RedPacketPlugin::RedPacketPlugin(QObject *parent)
    :QQmlExtensionPlugin(parent)
{

}

RedPacketPlugin::~RedPacketPlugin()
{

}

void RedPacketPlugin::init(int rpId, int redCount, int redTime, int countDownTime, bool canClick)
{
    RedPacket::getInstance()->init(rpId, redCount, redTime, countDownTime, canClick);
}

void RedPacketPlugin::uninit()
{
    RedPacket::getInstance()->uninit();
}

void RedPacketPlugin::beginRedPackets()
{
    RedPacket::getInstance()->beginRedPackets();
}

void RedPacketPlugin::endRedPackets(const QJsonObject &redPacketsDataObj)
{
    RedPacket::getInstance()->endRedPackets(redPacketsDataObj);
}

void RedPacketPlugin::redPacketSize(int packetId,int packetSize)
{
   RedPacket::getInstance()->redPacketSize(packetId, packetSize);
}

void RedPacketPlugin::setRedPacketsCallBack(IRedPacketCallBack* redPacketCallBack)
{
    RedPacket::getInstance()->setRedPacketsCallBack(redPacketCallBack);
}

void RedPacketPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<RedPacket>(uri, 1, 0, "RedPacket");
}

