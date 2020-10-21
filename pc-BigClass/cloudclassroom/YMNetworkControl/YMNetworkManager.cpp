#include "YMNetworkManager.h"

YMNetworkManager::YMNetworkManager(QObject *parent)
    : QThread (parent)
{
    connect(this,&YMNetworkManager::finished,this, &QObject::deleteLater);
}


YMNetworkManager::~YMNetworkManager()
{
    this->wait();
}

void YMNetworkManager::startPingNetwork(QString ipAddress)
{
    m_address = ipAddress;
    this->start();
}

void YMNetworkManager::run()
{
    QProcess prcoss;
    QString str = "ping" ;
    prcoss.start(str, QStringList() << "-n" << "10" << "-w" << "1000" << m_address );
    prcoss.waitForFinished(-1);

    QByteArray arry = prcoss.readAll();
    QString astr(arry);
    QString tmp;
    for(int j = 0; j < astr.length(); j++)
    {
        if( ( astr[j] >= '0' && astr[j] <= '9' )  || astr[j] == '(' ||  astr[j] == '%' ||  astr[j] == ')'  ||  astr[j] == '=')
        {
            tmp.append( astr[j] );
        }
    }

    QString tmpa;
    QString tmpb;
    QStringList tmpList = tmp.split("=");
    if(tmpList.size() >= 4)
    {
        tmpa = tmpList[tmpList.count() - 1];
        tmpb =  tmpList[tmpList.count() - 4];
        int posn1 = tmpb.indexOf("(");

        QString tmpas = tmpb.mid(0, posn1);
        int cpuRate = this->getDeviceCpuRate();
        int netType = 3;//0~60: 优； 61~ 150:良；  151~999:差
        if(tmpa >= 0 && tmpa <= 60)
        {
            netType = 3;
        }
        if(tmpa >= 61 && tmpa <= 150)
        {
            netType = 2;
        }
        if(tmpa >= 151 && tmpa <= 999)
        {
            netType = 1;
        }
        emit sigNetworkStatus(QString::number( netType ),tmpa ,tmpas ,QString::number( cpuRate ));
    }
}

int YMNetworkManager::getDeviceCpuRate()
{
        HANDLE hEvent;
        FILETIME preidleTime;
        FILETIME prekernelTime;
        FILETIME preuserTime;
        GetSystemTimes( &preidleTime, &prekernelTime, &preuserTime );

        hEvent = CreateEvent (NULL, FALSE, FALSE, NULL); // 初始值为 nonsignaled ，并且每次触发后自动设置为nonsignaled
        WaitForSingleObject( hEvent, 1000); //等待1000毫秒

        FILETIME idleTime;
        FILETIME kernelTime;
        FILETIME userTime;
        GetSystemTimes( &idleTime, &kernelTime, &userTime );

        int idle = CompareFileTime( preidleTime, idleTime);
        int kernel = CompareFileTime( prekernelTime, kernelTime);
        int user = CompareFileTime(preuserTime, userTime);

        int cpuRate = qAbs((kernel + user - idle) * 100 / (kernel + user));
        return cpuRate;
}

int YMNetworkManager::CompareFileTime( FILETIME time1, FILETIME time2 )
{
    __int64 a = time1.dwHighDateTime << 32 | time1.dwLowDateTime ;
    __int64 b = time2.dwHighDateTime << 32 | time2.dwLowDateTime ;
    return   (b - a);
}
