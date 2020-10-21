﻿#ifndef HANDLPINGINFOR_H
#define HANDLPINGINFOR_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <QList>
#include <QMap>
#include <QPair>
#include <QHostInfo>
#include <QNetworkInterface>
#include <QSysInfo>
#include <QTimer>
#include "./pingthread.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"
#include "../datahandl/datamodel.h"
#include"../YMCommon/qosManager/YMQosManager.h"
class HandlPingInfor : public QObject
{
        Q_OBJECT
    public:
        explicit HandlPingInfor(QObject *parent = 0);
        ~HandlPingInfor();

        //请求云服务器的ip地址
        Q_INVOKABLE void requestSeverAddress();

        //上传服务器的地址信息
        Q_INVOKABLE void uploadSeverAddress();

        //主动处理的ping的信息
        Q_INVOKABLE void handlPingInforThread( QList<QString >  ipList);

        //定时启动
        Q_INVOKABLE void requestSeverPing();

        //设置选择ip
        Q_INVOKABLE void setSelectItemIp(QString ips);

        //获得文件的历史数据
        Q_INVOKABLE void getAllItemInfor();

        //检测当前连接的服务器延迟
        Q_INVOKABLE void getCurrentConnectServerDelay();
        //检测百度延迟
        Q_INVOKABLE void getBaiDuServerDelay();

        //获取通道开关状态
        Q_INVOKABLE bool getChannelSwitch(QString channelNumber);

    private:
        void getRoutingNetwork();//获取当前路由IP

    signals:
        void sigSendAddressLostDelay(QMap< QString, QPair<QString, QString > > addressLostDelay );

        //发送延迟的信息
        void sigSendIpLostDelay(QString strList);

        void sigSendAddressLostDelayInfro(QList<QString > list);

        //发送网络状态
        void sigSendAddressLostDelayStatues(QList<QString > list);

        //发送当前网络状态
        void sigSendCurrentNetwork(QString status);
        //切换ip
        void sigChangeOldIpToNew();

        //返回网络状态
        void sigCurrentNetworkStatus(int netStatus, int netValue); //3 好，2 一般 ，1 差 ，0无网络

    public slots:
        void getAllWebAddressList(QNetworkReply* reply );
        void onUploadAllWebAddressList(QNetworkReply * reply );
        void onSigSendPingInfor(QString address, QString lost, QString delay);
        void onSigTimeSendPingInfor(QString address, QString lost, QString delay);
        //处理信息
        void onSendAddressLostDelay(QMap< QString, QPair<QString, QString > > addressLostDelay );
        //处理信息
        void onSigSendAddressLostDelayInfro(QMap<QString, QPair<QString, QString> > addressLostDelay  );
        //处理当前服务器延迟信息
        void onCurrentConnectServerDelay(QString address, QString lost, QString delay);
        void onBaiDuServerDelay(QString address, QString lost, QString delay);
        void getPingIpNet();//ping 当前Ip值
        void getCurrentIpNetValue(QString address, QString lost, QString delay); //获取当前ping值并且返回网络状态
    private:
        //处理返回的字符串
        void handlListInfor(QString infor);
        //当前IP网络情况（延时、丢包）, 将容器转化为字符串
        void handlIpLostDelay();

    private:
        YMHttpClient * m_httpClient;
        QNetworkAccessManager * m_httpAccessmanger;

        QNetworkAccessManager * m_httpAccessmangerUpload;

        QList<QString > m_addressList;

        QMap< QString, QPair<QString, QString > > m_addressLostDelay;
        QString m_netWorkMode;
        QString m_appIp;
        QString m_httpIp;
        QString m_currentRoutIp;

        QList<QString> m_ipList;
        QMap<QString, PingThread* > m_ipPingThread;
        QMap< QString, QPair<QString, QString > > m_ipLostDelay;
        QList<QString > m_netNeWork;
        QTimer *m_netTime;

        QMap< QString, QPair<QString, QString > > m_addressLostDelayTemp;

        int currentServerDelay = -100; //当前服务器的延迟信息
        int currentServerLost = -100;//当前服务器的丢包信息
};

#endif // HANDLPINGINFOR_H