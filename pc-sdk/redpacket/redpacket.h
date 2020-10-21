#ifndef REDPACKET_H
#define REDPACKET_H

#include <QMutex>
#include <QGenericPlugin>
#include "iredpacketcallback.h"

class RedPacket : public QObject
{
    Q_OBJECT
public:
    RedPacket(QObject *parent = 0);
    ~RedPacket();

    static RedPacket* getInstance();
    void init(int rpId, int redCount, int redTime, int countDownTime, bool canClick);
    void uninit();
    void beginRedPackets();
    void endRedPackets(const QJsonObject &redPacketsDataObj);
    void redPacketSize(int packetId, int packetSize);
    //设置红包回调
    virtual void setRedPacketsCallBack(IRedPacketCallBack* redPacketCallBack = 0);

    //启动红包雨
    Q_INVOKABLE void startRedPackets();
    //击中红包
    Q_INVOKABLE void hitRedPacket(int packetId);

signals:
    //红包雨信息
    void sigRedPacketsInfo(int redCount, int redTime, int countDownTime, bool canClick);
    //开始红包雨
    void sigBeginRedPackets();
    //结束红包雨
    void sigEndRedPackets(const QJsonObject redPacketsDataObj);
    //红包积分大小
    void sigRedPacketSize(int packetId, int packetSize);

private:
    static QMutex m_instanceMutex;
    static RedPacket* m_redPacket;
    IRedPacketCallBack* m_redPacketCallBack;
};

#endif // REDPACKET_H
