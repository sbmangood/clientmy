#include "YMNetworkManagerAdapert.h"
#include "YMNetworkManager.h"

YMNetworkManagerAdapert::YMNetworkManagerAdapert(QObject *parent )
    : QObject(parent)
{
    m_netTime = new QTimer();
    m_netTime->setInterval(60000);
    connect(m_netTime, SIGNAL(timeout()), this, SLOT(getNetworkStatus()));
    m_netTime->start();
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
