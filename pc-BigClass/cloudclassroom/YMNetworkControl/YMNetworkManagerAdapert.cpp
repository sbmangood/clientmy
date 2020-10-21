#include "YMNetworkManagerAdapert.h"
#include "YMNetworkManager.h"
#include <QtNetwork>

YMNetworkManagerAdapert::YMNetworkManagerAdapert(QObject *parent )
    : QObject(parent)
{
    m_netTime = new QTimer();
    m_netTime->setInterval(60000);
    connect(m_netTime, SIGNAL(timeout()), this, SLOT(getNetworkStatus()));
    m_netTime->start();

    QProcess cmd_pro ;
    QString cmd_str = QString("route print");
    cmd_pro.start("cmd.exe", QStringList() << "/c" << cmd_str);
    cmd_pro.waitForStarted();
    cmd_pro.waitForFinished();
    QString result = cmd_pro.readAll();
    QString pattern("0\.0\.0\.0 *(0|128)\.0\.0\.0 *([0-9\.]*)");
    QRegExp rx(pattern);
    int pos = result.indexOf(rx);
    if (pos >= 0)
    {
        qDebug() << "===reg::==" << rx.cap(2);
        m_IpAddress = rx.cap(2);
    }
    int types = 0;
    QList<QNetworkInterface> list = QNetworkInterface::allInterfaces();
    QString m_netWorkMode;
    foreach (QNetworkInterface netInterface, list)
    {
        if (!netInterface.isValid())
        {
            continue;
        }

        QNetworkInterface::InterfaceFlags flags = netInterface.flags();
        if (flags.testFlag(QNetworkInterface::IsRunning) && !flags.testFlag(QNetworkInterface::IsLoopBack))
        {
            if(types == 0)
            {
                m_netWorkMode = netInterface.name();//netInterface.hardwareAddress();
            }
            types++;
        }
    }

    m_netWorkMode.remove("#");
    m_netWorkMode.remove("\n");
    QString netTypeStr = m_netWorkMode;

    qDebug() << "====netTypeStr====" << netTypeStr;

    m_netType = 3;
    if(netTypeStr.contains(QStringLiteral("wireless")))
    {
        m_netType = 3;
    }
    else
    {
        m_netType = 4;
    }

}

YMNetworkManagerAdapert::~YMNetworkManagerAdapert()
{

}

void YMNetworkManagerAdapert::getNetworkStatus()
{
    YMNetworkManager * networkThread = new YMNetworkManager(this);
    connect(networkThread, SIGNAL(sigNetworkStatus(QString,QString,QString,QString)), this, SIGNAL(sigNetworkInfo(QString,QString,QString,QString)));
    networkThread->startPingNetwork(m_ipAddres);
}

void YMNetworkManagerAdapert::setNetIp(QString IPAddress)
{
    m_ipAddres = IPAddress;
}

void YMNetworkManagerAdapert::getRoutingNetwork()
{
    this->getNetworkStatus();

    YMNetworkManager * pingThread = new YMNetworkManager(this);
    connect(pingThread, SIGNAL(sigNetworkStatus(QString,QString,QString,QString)), this, SLOT(getRoutingValue(QString,QString,QString,QString)));
    pingThread->startPingNetwork(m_IpAddress);
    emit sigNetworkType(m_netType);
}

void YMNetworkManagerAdapert::getRoutingValue(QString netType, QString delay, QString lossRate, QString cpuRate)
{
    emit sigRouting(delay);
}
