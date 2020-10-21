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

private:
    QTimer *m_netTime;
    QString m_ipAddres;

public slots:
    void getNetworkStatus();

signals:
    void sigNetworkInfo(QString netType,QString delay,QString lossRate,QString cpuRate);
};

#endif // YMNETWORKMANAGERADAPERT_H
