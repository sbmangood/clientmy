#include "pingthread.h"

PingThread::PingThread(QObject *parent): QThread(parent)
{
    connect(this, &PingThread::finished, this, &QObject::deleteLater);
}


PingThread::~PingThread()
{
    this->wait(); //等待线程执行完成, 不然程序有可能会崩溃, 崩溃的问题: QThread: Destroyed while thread is still running
}

//设置刷新记录
void PingThread::setPingAddress(QString address)
{
    m_address = address;
    this->start();
}

void PingThread::run()
{
    QProcess prcoss;
    QString str = "ping" ;
    prcoss.start(str, QStringList() << "-n" << "5" << "-w" << "1000" << m_address );
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

    qDebug() << "====m_address====" << m_address;

    QString tmpa;
    QString tmpb;
    QStringList tmpList = tmp.split("=");
    if(tmpList.size() >= 4)
    {
        tmpa = tmpList[tmpList.count() - 1];
        tmpb =  tmpList[tmpList.count() - 4];
        int posn1 = tmpb.indexOf("(");

        QString  tmpas = tmpb.mid(0, posn1 );
        //qDebug()<<tmpas << tmpa;
        emit sigSendPingInfor(m_address, tmpas, tmpa);
    }
    else
    {
        emit sigSendPingInfor(m_address, "1", "-1");
    }
}
