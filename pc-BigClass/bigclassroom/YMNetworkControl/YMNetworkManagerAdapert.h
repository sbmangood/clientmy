#ifndef YMNETWORKMANAGERADAPERT_H
#define YMNETWORKMANAGERADAPERT_H

#include <QObject>
#include <QTimer>

class YMNetworkManagerAdapert : public QObject
{
    Q_OBJECT
public:
    YMNetworkManagerAdapert(QObject *parent = 0);
    ~YMNetworkManagerAdapert();

    Q_INVOKABLE void setNetIp(QString IPAddress);
    Q_INVOKABLE void getRoutingNetwork();//获取路由网络状态

private:
    QTimer *m_netTime;
    QString m_ipAddres;
    QString m_IpAddress;
    int m_netType;

public slots:
    void getNetworkStatus();
    void getRoutingValue(QString netType,QString delay,QString lossRate,QString cpuRate);

signals:
    void sigNetworkInfo(QString netType,QString delay,QString lossRate,QString cpuRate);
    void sigRouting(QString delay);
    void sigNetworkType(int netType);
};

#endif // YMNETWORKMANAGERADAPERT_H
