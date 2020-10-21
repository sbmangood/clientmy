#ifndef REDPACKETPLUGIN_H
#define REDPACKETPLUGIN_H

#include <QQmlExtensionPlugin>
#include "redpacket.h"
#include "iredpacketctrl.h"
#include "iredpacketcallback.h"

class RedPacketPlugin : public QQmlExtensionPlugin, public IRedPacketCtrl
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.Plugin.IRedPacketCtrl/1.0")
    Q_INTERFACES(IRedPacketCtrl)

public:
    RedPacketPlugin(QObject *parent = 0);
    virtual ~RedPacketPlugin();

   virtual void init(int rpId, int redCount, int redTime, int countDownTime, bool canClick);
    virtual void uninit();
    virtual void beginRedPackets();
    virtual void endRedPackets(const QJsonObject &redPacketsDataObj);
    virtual void redPacketSize(int packetId, int packetSize);
    //设置红包回调
    virtual void setRedPacketsCallBack(IRedPacketCallBack* redPacketCallBack = 0);
    virtual void registerTypes(const char *uri);

};

#endif // REDPACKETPLUGIN_H
