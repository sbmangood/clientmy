#ifndef PINGTHREADMANAGERADAPTER_H
#define PINGTHREADMANAGERADAPTER_H

#include <QObject>
#include <QTimer>

class PingThreadManagerAdapter : public QObject
{
        Q_OBJECT
    public:
        PingThreadManagerAdapter(QObject * parent = 0);
        ~PingThreadManagerAdapter();

    public:
        //获取当前网络状态：有线 、无线
        Q_INVOKABLE void getCurrentInternetStatus();

        //检测当前路由器有多少设备
        Q_INVOKABLE void getRoutingDeviceNumber();

    private:
        //ping路由器延迟
        void getRoutingNetwork();


    private:
        QTimer * m_netTime;//5s检测一下网络ping值
        QTimer * m_InternetTime;//1分钟检测一下当前网络(无线、有线)
        QString m_IpAddress;
        int m_currentDeviceCount;

    signals:
        //返回网络状态
        void sigCurrentNetworkStatus(int netStatus, int netValue); //netStatus(3 好，2 一般 ，1 差 ，0无网络)
        void sigCurrentInternetStatus(int internetStatus);//当前网络：有线、无线
        void sigWifiDeviceCount(int count);//wifi设备总个数
        void sigCurrentRoutingValue(int netStatus, int routingValue); //当前路由ping值

    public slots:
        void getPingIpNet();//ping 当前Ip值
        void getCurrentIpNetValue(QString delay);//获取当前ping值并且返回网络状态
        void getRoutingValue(QString delay);//获取路由ping值
        void getDeviceCount();//wifi连接时设备统计
        void getDeviceComplete();//wifi连接统计完成
        void getInternetStatus();
        void getRoutingTowDeviceNumber(int startNumber, int endNumber); //第二次执行ping设备函数
};

#endif // PINGTHREADMANAGERADAPTER_H
