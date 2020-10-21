#include "PingThreadManager.h"

PingThreadManager::PingThreadManager(QObject *parent) : QThread(parent)
{
    connect(this, &PingThreadManager::finished, this, &QObject::deleteLater);
}

PingThreadManager::~PingThreadManager()
{
    this->wait(); //等待线程执行完成, 不然程序有可能会崩溃, 崩溃的问题: QThread: Destroyed while thread is still running
}

void PingThreadManager::startPing(QString ipAddres, int isRouting, QString pingNumber)
{
    m_currentIp = ipAddres;
    m_isRouting = isRouting;
    m_pingNumber = pingNumber;
    this->start();
}

void PingThreadManager::run()
{
    QProcess prcoss;
    QString str = "ping";
    prcoss.start(str, QStringList() << "-n" << m_pingNumber << "-w" << "300" << m_currentIp );
    prcoss.waitForFinished(-1);

    QString astr = QString::fromLocal8Bit(prcoss.readAll());
    QString tmp;
    //qDebug() << "====astr====" << astr;
    for(int j = 0; j < astr.length(); j++)
    {
        if( ( astr[j] >= '0' && astr[j] <= '9' )  || astr[j] == '(' ||  astr[j] == '%' ||  astr[j] == ')'  ||  astr[j] == '=')
        {
            tmp.append( astr[j] );
        }
    }

    QString tmpa;
    QStringList tmpList = tmp.split("=");

    if(tmpList.size() >= 4)
    {
        tmpa = tmpList[tmpList.count() - 1];
        //qDebug() << "=====tmpa====" << tmpa;
        if(m_isRouting == 3)
        {
            emit sigPingRouting(tmpa);
            return;
        }
        if(m_isRouting == 2)//检测当前连接路由有多少个设备
        {
            if(!tmpa.contains("("))
            {
                sigDeviceCount();
            }
            QStringList ipList = m_currentIp.split(".");
            QString ipNumber =  ipList.at(3);
            int currentIpValue = ipNumber.toInt();
            //qDebug() << "********aaa********" << currentIpValue % 15 << m_currentIp;
            if(currentIpValue % 20 == 0 && currentIpValue < 255)
            {
                //qDebug() << "====values====" << currentIpValue + 1 << currentIpValue + 20;
                int startNumber = currentIpValue + 1;
                int endNumber = currentIpValue + 20;
                if(endNumber > 255)
                {
                    endNumber = 255;
                }
                emit sigPingTowRouting(startNumber, endNumber);
                return;
            }
            if(ipList.at(3) == "255")
            {
                qDebug() << "====255=====";
                sigPingComplete();
            }
            return;
        }
        if(m_isRouting == 1)
        {
            emit sigPingInfo(tmpa);
        }
    }
    else
    {
        qDebug() << "===ping::fail====" << m_isRouting;
        emit sigPingInfo("-1");
    }
}

