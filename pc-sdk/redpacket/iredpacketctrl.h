#ifndef IREDPACKETCTRL_H
#define IREDPACKETCTRL_H
#include <QString>
#include <QJsonObject>
#include "iredpacketcallback.h"

class IRedPacketCtrl
{
public:

    virtual ~IRedPacketCtrl(){}
    virtual void init(int rpId, int redCount, int redTime, int countDownTime, bool canClick) = 0;
    virtual void uninit() = 0;
    virtual void beginRedPackets() = 0;
    virtual void endRedPackets(const QJsonObject &redPacketsDataObj) = 0;
    virtual void redPacketSize(int packetId, int packetSize) = 0;

    //设置红包回调
    virtual void setRedPacketsCallBack(IRedPacketCallBack* redPacketCallBack = 0) = 0;
};

Q_DECLARE_INTERFACE(IRedPacketCtrl,"org.qt-project.Qt.Plugin.IRedPacketCtrl/1.0")
#endif // IREDPACKETCTRL_H
