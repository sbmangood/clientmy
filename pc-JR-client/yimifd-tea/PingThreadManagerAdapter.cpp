#include "PingThreadManagerAdapter.h"
#include "PingThreadManager.h"
#include <QtNetwork>
#include <winsock2.h>

PingThreadManagerAdapter::PingThreadManagerAdapter(QObject * parent) : QObject(parent)
{
    m_netTime = new QTimer();
    m_netTime->setInterval(5000);
    connect(m_netTime, SIGNAL(timeout()), this, SLOT(getPingIpNet()));
    m_netTime->start();

    m_InternetTime = new QTimer();
    m_InternetTime->setInterval(60000);
    connect(m_InternetTime, SIGNAL(timeout()), this, SLOT(getInternetStatus()));
    m_InternetTime->start();
	
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
        m_IpAddress = rx.cap(2);
    }
}

PingThreadManagerAdapter::~PingThreadManagerAdapter()
{
    m_netTime->stop();
    m_InternetTime->stop();
}

//ping当前路由网络
void PingThreadManagerAdapter::getRoutingNetwork()
{
    QString newIp;
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
        newIp = rx.cap(2);
    }

    PingThreadManager * pingThread = new PingThreadManager(this);
    connect(pingThread, SIGNAL(sigPingRouting(QString)), this, SLOT(getRoutingValue(QString)));
    pingThread->startPing(newIp, 3, "8");
}

//当前路由网络状态
void PingThreadManagerAdapter::getRoutingValue(QString delay)
{
    if(delay.contains("%"))
    {
        emit sigCurrentRoutingValue(0, 0);
        return;
    }
    int netValue = delay.toInt();
    if(netValue >= 0 && netValue <= 60)
    {
        emit sigCurrentRoutingValue(3, netValue);
    }
    if(netValue >= 61 && netValue <= 150)
    {
        emit sigCurrentRoutingValue(2, netValue);
    }
    if(netValue >= 151 && netValue <= 999)
    {
        emit sigCurrentRoutingValue(1, netValue);
    }

}

//查看当前路由有多少设备
void PingThreadManagerAdapter::getRoutingDeviceNumber()
{
    QStringList ipList = m_IpAddress.split(".");
    if(ipList.size() < 2)
    {
        return;
    }
    m_currentDeviceCount = 1;
    for(int i = 2; i <= 20; i++)
    {
        QString newIp = ipList.at(0) + "." + ipList.at(1) + "." + ipList.at(2) + "." + QString::number(i);
        //qDebug() << "*****newIp*******" << newIp;
        if(newIp == m_IpAddress)
        {
            //qDebug() << "======continue======" << newIp << m_IpAddress;
            continue;
        }

        PingThreadManager * pingThread = new PingThreadManager(this);
        connect(pingThread, SIGNAL(sigDeviceCount()), this, SLOT(getDeviceCount()));
        connect(pingThread, SIGNAL(sigPingComplete()), this, SLOT(getDeviceComplete()));
        connect(pingThread, SIGNAL(sigPingTowRouting(int, int)), this, SLOT(getRoutingTowDeviceNumber(int, int)));
        pingThread->startPing(newIp, 2, "3");
    }
}

//第二次开启线程操作
void PingThreadManagerAdapter::getRoutingTowDeviceNumber(int startNumber, int endNumber)
{
    QStringList ipList = m_IpAddress.split(".");
    if(ipList.size() < 2)
    {
        return;
    }
    for(int i = startNumber; i <= endNumber; i++)
    {
        QString newIp = ipList.at(0) + "." + ipList.at(1) + "." + ipList.at(2) + "." + QString::number(i);
        //qDebug() << "*****newIp*******" << newIp;
        if(newIp == m_IpAddress)
        {
            //qDebug() << "======continue======" << newIp << m_IpAddress;
            continue;
        }

        PingThreadManager * pingThread = new PingThreadManager(this);
        connect(pingThread, SIGNAL(sigDeviceCount()), this, SLOT(getDeviceCount()));
        connect(pingThread, SIGNAL(sigPingComplete()), this, SLOT(getDeviceComplete()));
        connect(pingThread, SIGNAL(sigPingTowRouting(int, int)), this, SLOT(getRoutingTowDeviceNumber(int, int)));
        pingThread->startPing(newIp, 2, "3");
    }
}

void PingThreadManagerAdapter::getDeviceCount()
{
    m_currentDeviceCount++;
}

void PingThreadManagerAdapter::getDeviceComplete()
{
    qDebug() << "====PingThreadManagerAdapter::getDeviceComplete=====" << m_currentDeviceCount;
    emit sigWifiDeviceCount(m_currentDeviceCount);
    getRoutingNetwork();
}

void PingThreadManagerAdapter::getCurrentInternetStatus()
{
    getInternetStatus();
}

//获取当前网络属于有线还是无线
void PingThreadManagerAdapter::getInternetStatus()
{
    QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();
    QStringList ipList = m_IpAddress.split(".");
    QString comperIp;
    if(ipList.size() > 2)
    {
        comperIp = ipList.at(0);
    }

    foreach(QHostAddress ipItem, ipAddressesList)
    {
        if(ipItem.protocol() == QAbstractSocket::IPv4Protocol && ipItem != QHostAddress::Null
           && ipItem != QHostAddress::LocalHost && ipItem.toString().left(3) == comperIp)
        {
            m_IpAddress = ipItem.toString();
            qDebug() << "===aaa===" << ipItem.toString();
            break;
        }
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
            // 网络接口处于活动状态
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

    int netType = 3;
    if(netTypeStr.contains(QStringLiteral("wireless")))
    {
        netType = 3;
    }
    else
    {
        netType = 4;
    }
    emit sigCurrentInternetStatus(netType);
}

//5秒ping一下服务器查看服务器网络
void PingThreadManagerAdapter::getPingIpNet()
{
    PingThreadManager * pingThread = new PingThreadManager(this);
    connect(pingThread, SIGNAL(sigPingInfo(QString)), this, SLOT(getCurrentIpNetValue(QString)) );
    pingThread->startPing("uctest.1mifd.com", 1, "5");
}

//获取网络状态： 良好、一般、差、无网络
void PingThreadManagerAdapter::getCurrentIpNetValue(QString delay)
{
    //qDebug() << "====delay====" << delay;
    if(delay.contains("%"))
    {
        emit sigCurrentNetworkStatus(0, 0);
        return;
    }
    int netValue = delay.toInt();
    if(netValue >= 0 && netValue <= 60)
    {
        emit sigCurrentNetworkStatus(3, netValue);
    }
    if(netValue >= 61 && netValue <= 150)
    {
        emit sigCurrentNetworkStatus(2, netValue);
    }
    if(netValue >= 151 && netValue <= 999)
    {
        emit sigCurrentNetworkStatus(1, netValue);
    }
    if(delay.contains("-1"))
    {
        emit sigCurrentNetworkStatus(0, 0);
    }
}
