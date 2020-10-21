#ifndef YMNETWORKMANAGER_H
#define YMNETWORKMANAGER_H

#include <QObject>
#include <QThread>
#include <QProcess>
#include <QtQuick>

class YMNetworkManager : public QThread
{
    Q_OBJECT
public:
    YMNetworkManager(QObject * parent = 0);

    ~YMNetworkManager();

    void startPingNetwork(QString ipAddress);

protected:
    void run();

private:
    int getDeviceCpuRate();
    int CompareFileTime(FILETIME time1, FILETIME time2 );

private:
    QString m_address;//ping服务器的IP地址

signals:
    void sigNetworkStatus(QString netType,QString delay,QString lossRate,QString cpuRate);

};

#endif // YMNETWORKMANAGER_H
