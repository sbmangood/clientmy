#ifndef PINGTHREADMANAGER_H
#define PINGTHREADMANAGER_H

#include <QObject>
#include <QThread>
#include <QProcess>
#include <QDebug>

class PingThreadManager: public QThread
{
        Q_OBJECT
    public:
        PingThreadManager(QObject * parent = 0);
        ~PingThreadManager();

    public:
        void startPing(QString ipAddres, int isRouting, QString pingNumber);

    private:
        QString m_currentIp;//当前IP
        QString m_pingNumber;//ping的次数
        int m_isRouting;//是否ping路由器 1:ping互联网 2：ping路由统计设备 3：ping路由

    protected:
        void run();

    signals:
        void sigPingInfo(QString delay);
        void sigPingRouting(QString delay);
        void sigDeviceCount();
        void sigPingComplete();
        void sigPingTowRouting(int startNumber, int endNumber);
};

#endif // PINGTHREADMANAGER_H
