#ifndef REDPACKETSCENTER_H
#define REDPACKETSCENTER_H
#include "controlcenter.h"
#include "../redpacket/iredpacketcallback.h"
#include "../redpacket/iredpacketctrl.h"

class RedPacketsCenter : public QObject, public IRedPacketCallBack
{
    Q_OBJECT
public:
    RedPacketsCenter(ControlCenter* controlCenter);
    virtual ~RedPacketsCenter();

    void init(const QString &pluginPathName);
    void uninit();

    void beginRedPackets();
    void endRedPackets(const QJsonObject &redPacketsDataObj);
    void redPacketSize(int packetId, int packetSize);
    void queryRedPackets();

    virtual bool onSendRedPackets();
    virtual bool onHitRedPacket(int packetId);

public slots:
    void onHttpReply(QNetworkReply *reply);

private:
    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

private:
    QObject* m_instance;
    IRedPacketCtrl* m_redPacketCtrl;
    ControlCenter* m_controlCenter;
    QNetworkAccessManager *m_httpAccessMgr;
};

#endif // REDPACKETSCENTER_H
