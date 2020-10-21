
#ifndef PINGTHREAD_H
#define PINGTHREAD_H

#include <QThread>
#include <QProcess>
#include <QDebug>
#include <QStringList>
#include <QByteArray>
#include <Windows.h>
#include <QRegExp>
#include <QRegExpValidator>

class PingThread : public QThread
{
        Q_OBJECT

    public:
        PingThread(QObject *parent = 0);
        virtual  ~PingThread();

        //设置刷新记录
        void setPingAddress(QString address);


    signals:
        void sigSendPingInfor(QString address, QString lost, QString delay);

    protected:
        void run() ;

    private:
        QString m_address;
};

#endif // PINGTHREAD_H
