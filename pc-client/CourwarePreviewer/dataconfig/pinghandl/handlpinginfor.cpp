#include "handlpinginfor.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"

HandlPingInfor::HandlPingInfor(QObject *parent) : QObject(parent)
    , m_httpAccessmanger(NULL)
    , m_netWorkMode("")
    , m_httpAccessmangerUpload(NULL)
{
    connect(this, SIGNAL( sigSendAddressLostDelay(QMap< QString, QPair<QString, QString > >  )), this, SLOT( onSendAddressLostDelay(QMap< QString, QPair<QString, QString > >  ))  );
    connect(this, SIGNAL( sigSendAddressLostDelay(QMap< QString, QPair<QString, QString > >  ) ), this, SLOT( onSigSendAddressLostDelayInfro(QMap<QString, QPair<QString, QString> >   ) )  );

    m_httpClient = YMHttpClient::defaultInstance();
    m_httpIp = m_httpClient->getRunUrl(1);
    m_ipPingThread.clear();
    QString localHostName = QHostInfo::localHostName();
    QHostInfo info = QHostInfo::fromName(localHostName); //根据上边获得的主机名来获取本机的信息

    int typess = 0;
    foreach(QHostAddress address, info.addresses()) //info.addresses()---QHostInfo的address函数获取本机ip地址
    {
        if(address.protocol() == QAbstractSocket::IPv4Protocol) //只取ipv4协议的地址
        {
            // qDebug()<<"IPV4 addresses:"<<address.toString();
            if(typess == 0 )
            {
                m_appIp =  address.toString();
            }
            typess++;
        }
        if(address.protocol() == QAbstractSocket::IPv6Protocol) //只取ipv6协议的地址
        {
            //qDebug()<<"IPV6 addresses:"<<address.toString();
        }
    }



    int types = 0;
    QList<QNetworkInterface> list = QNetworkInterface::allInterfaces();
    foreach (QNetworkInterface netInterface, list)
    {
        if (!netInterface.isValid())
            continue;

        //  qDebug() << "********************";

        QNetworkInterface::InterfaceFlags flags = netInterface.flags();
        if (flags.testFlag(QNetworkInterface::IsRunning)
            && !flags.testFlag(QNetworkInterface::IsLoopBack))    // 网络接口处于活动状态
        {
            if(types == 0)
            {
                m_netWorkMode = netInterface.hardwareAddress();
            }
            types++;

        }


    }
    m_netNeWork.clear();
    m_netNeWork.append( QStringLiteral("线路一:") );
    m_netNeWork.append( QStringLiteral("线路二:") );
    m_netNeWork.append( QStringLiteral("线路三:") );
    m_netNeWork.append( QStringLiteral("线路四:") );
    m_netNeWork.append( QStringLiteral("线路五:") );
    m_netNeWork.append( QStringLiteral("线路六:") );
    m_netNeWork.append( QStringLiteral("线路七:") );
    m_netNeWork.append( QStringLiteral("线路八:") );
    m_netNeWork.append( QStringLiteral("线路九:") );
    m_netNeWork.append( QStringLiteral("线路十:") );
    m_netNeWork.append( QStringLiteral("线路十一:") );
    m_netNeWork.append( QStringLiteral("线路十二:") );
    m_netNeWork.append( QStringLiteral("线路十三:") );
    m_netNeWork.append( QStringLiteral("线路十四:") );
    m_netNeWork.append( QStringLiteral("线路十五:") );
    m_netNeWork.append( QStringLiteral("线路十六:") );
    m_netNeWork.append( QStringLiteral("线路十七:") );
    m_netNeWork.append( QStringLiteral("线路十八:") );
    m_netNeWork.append( QStringLiteral("线路十九:") );
    m_netNeWork.append( QStringLiteral("线路二十:") );
    m_netNeWork.append( QStringLiteral("线路二十二:") );
    m_netNeWork.append( QStringLiteral("线路二十三:") );
    m_netNeWork.append( QStringLiteral("线路二十四:") );
    m_netNeWork.append( QStringLiteral("线路二十五:") );
    m_netNeWork.append( QStringLiteral("线路二十六:") );
    m_netNeWork.append( QStringLiteral("线路二十七:") );
    m_netNeWork.append( QStringLiteral("线路二十八:") );
    m_netNeWork.append( QStringLiteral("线路三十:") );

    getCurrentConnectServerDelay();

}

HandlPingInfor::~HandlPingInfor()
{

}
//请求云服务器的ip地址
void HandlPingInfor::requestSeverAddress()
{
    m_httpAccessmanger = new QNetworkAccessManager(this);

    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), this, SLOT( getAllWebAddressList(QNetworkReply * ) ) );

    QNetworkRequest httpRequest;

    QUrl url("http://" + m_httpIp + "/server/getCloudServerIpList?"); //getCloudServerList?");

    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("userId", StudentData::gestance()->m_selfStudent.m_studentId ); //"900000386"
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));

    QString sign;
    QString urls;
    QMap<QString, QString>::iterator it =  maps.begin();
    for(int i = 0; it != maps.end() ; it++, i++)
    {
        if(i == 0)
        {
            sign.append(it.key());
            sign.append("=" + it.value());
        }
        else
        {
            sign.append("&" + it.key());
            sign.append("=" + it.value());
        }
    }
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toUtf8(), QCryptographicHash::Md5).toHex().toUpper());

    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    httpRequest.setUrl(url);
    m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.


}
//上传服务器的地址信息
void HandlPingInfor::uploadSeverAddress()
{

    QJsonArray jsona;
    QMap< QString, QPair<QString, QString > >::iterator it =  m_addressLostDelay.begin();
    for( ; it !=  m_addressLostDelay.end() ; it++ )
    {
        QJsonObject json1;
        json1.insert("testIp", it.key() );
        json1.insert("pingTime", it.value().second );
        json1.insert("packetLoss", it.value().first );
        QString pingResult("");
        if(it.value().first.toInt() > 0 )
        {
            pingResult = QStringLiteral("差");
        }
        if(pingResult.length() <= 0)
        {
            if(it.value().second.toInt() <= 30)
            {
                pingResult = QStringLiteral("优");
            }
            else if(it.value().second.toInt() <= 100)
            {
                pingResult = QStringLiteral("良");
            }
            else
            {
                pingResult = QStringLiteral("差");

            }
        }
        json1.insert("pingResult", pingResult);

        jsona.append(json1);

    }

    QJsonDocument documents;
    documents.setArray(jsona);
    QString testList(documents.toJson(QJsonDocument::Compact));


    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
    maps.insert("testList", testList);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("sysInfo", StudentData::gestance()->m_sysInfo);
    maps.insert("deviceInfo", StudentData::gestance()->m_deviceInfo  );
    maps.insert("appSource", "YIMI");
    maps.insert("appNetwork", m_netWorkMode);
    maps.insert("appIp", m_appIp);
    maps.insert("userId", StudentData::gestance()->m_selfStudent.m_studentId );
    maps.insert("userType", "STU");



    QString sign;
    QString urls;
    QMap<QString, QString>::iterator ita =  maps.begin();
    for(int i = 0; ita != maps.end() ; ita++, i++)
    {
        if(i == 0)
        {
            sign.append(ita.key());
            sign.append("=" + ita.value());
        }
        else
        {
            sign.append("&" + ita.key());
            sign.append("=" + ita.value());
        }
    }
    urls.append(sign);

    m_httpAccessmangerUpload = new QNetworkAccessManager(this);

    connect(m_httpAccessmangerUpload, SIGNAL(finished(QNetworkReply*)), this, SLOT( onUploadAllWebAddressList(QNetworkReply * ) ) );

    QNetworkRequest httpRequest;

    QUrl url("http://" + m_httpIp + "/device/uploadPingTest?");
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    httpRequest.setUrl(url);
    m_httpAccessmangerUpload->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.


}

void HandlPingInfor::handlPingInforThread(QList<QString> ipList)
{
    m_ipList.clear();
    m_ipLostDelay.clear();
    m_ipList = ipList;
    for(int i = 0 ; i < m_ipList.count() ; i++ )
    {
        PingThread * pingThread = new PingThread(this);
        connect(pingThread, SIGNAL(sigSendPingInfor(QString, QString, QString)), this, SLOT(onSigTimeSendPingInfor(QString, QString, QString)) );
        pingThread->setPingAddress(m_ipList[i]);

    }


}
//定时启动
void HandlPingInfor::requestSeverPing()
{
    QStringList list =   SettingFile::gestance()->getAllIpList();
    if(list.count() > 0)
    {
        QList<QString> lista(list);
        handlPingInforThread(lista);
    }
    else
    {
        requestSeverAddress();
    }

}
//设置选择ip
void HandlPingInfor::setSelectItemIp(QString ips)
{
    if( StudentData::gestance()->m_selectItemAddress !=  ips)
    {
        SettingFile::gestance()->setSelectItem("ipitem", ips );
        StudentData::gestance()->m_address = ips;
        StudentData::gestance()->m_selectItemAddress = ips;

        emit sigChangeOldIpToNew();
        QMap< QString, QPair<QString, QString > > addressLostDelayTemps(m_addressLostDelayTemp);
        onSigSendAddressLostDelayInfro(addressLostDelayTemps);
    }
    TemporaryParameter::gestance()->m_selectItem = true;

}
//获得文件的历史数据
void HandlPingInfor::getAllItemInfor()
{
    QStringList list =   SettingFile::gestance()->getAllIpList();
    if(list.count() > 0)
    {
        QList<QString> lista(list);
        QMap< QString, QPair<QString, QString > > addressLostDelayTemps;
        for(int i = 0 ; i < lista.count() ; i++)
        {
            QString ipstr = lista[i];
            QPair<QString, QString > pair;
            pair.first = SettingFile::gestance()->getIpLost(ipstr);
            pair.second = SettingFile::gestance()->getIpDelay(ipstr);
            addressLostDelayTemps.insert(ipstr, pair);

        }
        onSigSendAddressLostDelayInfro(addressLostDelayTemps);
    }
    else
    {
        requestSeverAddress();
    }

}

void HandlPingInfor::getAllWebAddressList(QNetworkReply *reply)
{

    if(reply->error() == QNetworkReply::NetworkError::NoError)
    {
        QByteArray bytes = reply->readAll();
        QString result(bytes);  //转化为字符串
        if(result.length() > 0)
        {
            handlListInfor(result);
        }
        else
        {
            QMap< QString, QPair<QString, QString > > addressLostDelay ;
            emit sigSendAddressLostDelay(addressLostDelay);
        }

    }
    else
    {
        //处理错误
        // download_Btn->setText("failed");
        QMap< QString, QPair<QString, QString > > addressLostDelay ;
        emit sigSendAddressLostDelay(addressLostDelay);
    }
}

void HandlPingInfor::onUploadAllWebAddressList(QNetworkReply *reply)
{
    // qDebug()<<"HandlPingInfor::onUploadAllWebAddressList=="<<reply->error() ;
    if(reply->error() == QNetworkReply::NetworkError::NoError)
    {

        QByteArray bytes = reply->readAll();
        QString result(bytes);  //转化为字符串
    }
    else
    {


    }

}

void HandlPingInfor::onSigSendPingInfor(QString address, QString lost, QString delay)
{
    QPair<QString, QString> conents(lost, delay );

    m_addressLostDelay.insert(address, conents);
    if(m_addressLostDelay.count() == m_addressList.count() )
    {
        emit sigSendAddressLostDelay(m_addressLostDelay);
        uploadSeverAddress();
    }
}

void HandlPingInfor::onSigTimeSendPingInfor(QString address, QString lost, QString delay)
{
    QPair<QString, QString> conents(lost, delay );

    m_ipLostDelay.insert(address, conents);
    if(m_ipLostDelay.count() == m_ipList.count() )
    {
        emit sigSendAddressLostDelay(m_ipLostDelay);
        handlIpLostDelay();

    }

}
//处理信息
void HandlPingInfor::onSendAddressLostDelay(QMap<QString, QPair<QString, QString> > addressLostDelay)
{
    QList<QString > list;

    QMap<QString, QPair<QString, QString> >::iterator it  =  addressLostDelay.begin() ;
    for( ; it != addressLostDelay.end() ; it++)
    {
        QString items = it.key();
        items += "=" + it.value().first + "=" + it.value().second;
        list.append(list);

    }
    emit sigSendAddressLostDelayInfro( list );


}
//处理信息
void HandlPingInfor::onSigSendAddressLostDelayInfro(QMap<QString, QPair<QString, QString> > addressLostDelay)
{
    // qDebug()<<"addressLostDelay ==="<<addressLostDelay;
    m_addressLostDelayTemp.clear();
    m_addressLostDelayTemp = addressLostDelay;
    QList<QString > listinfor;
    QMap<QString, QPair<QString, QString> >::iterator it  =  addressLostDelay.begin() ;
    for(int i = 0 ; it != addressLostDelay.end() ; i++, it++)
    {
        QString items = it.key();
        int firstInt = it.value().first.toInt() ;
        int secondInt = it.value().second.toInt() ;
        QString selectItem = "0.0.0.0";
        SettingFile::gestance()->setIpLost(it.key(), it.value().first);
        SettingFile::gestance()->setIpDelay(it.key(), it.value().second);
        if(SettingFile::gestance()->getSelectItem("ipitem").length() > 0 && ( SettingFile::gestance()->getSelectItem("ipitem") == it.key() || StudentData::gestance()->m_selectItemAddress == it.key() ))
        {
            if( SettingFile::gestance()->getSelectItem("ipitem") != it.key() && StudentData::gestance()->m_selectItemAddress == it.key() )
            {
                SettingFile::gestance()->setSelectItem("ipitem", StudentData::gestance()->m_selectItemAddress);
            }
            selectItem = items;
        }
        else
        {
            if(  StudentData::gestance()->m_selectItemAddress == it.key() )
            {
                //SettingFile::gestance()->setSelectItem("ipitem",StudentData::gestance()->m_selectItemAddress);
                selectItem = StudentData::gestance()->m_selectItemAddress;
            }
        }

        QString infora;
        QString infors ;
        if(firstInt > 0)
        {
            infors =  QStringLiteral("差");
            infora = QString("3");
        }
        else
        {
            if(secondInt <= 30)
            {
                infors = QStringLiteral("优");
                infora = QString("1");
            }
            else if(secondInt <= 100)
            {
                infors = QStringLiteral("良");
                infora = QString("2");
            }
            else
            {
                infors = QStringLiteral("差");
                infora = QString("3");
            }
        }
        if(items == selectItem)
        {
            emit sigSendCurrentNetwork(infora);

        }
        QString listI;
        listI = items + "=" + m_netNeWork[i] + "=" + infors + "=" + selectItem;
        listinfor.append(listI);

    }

    emit sigSendAddressLostDelayStatues( listinfor);


}
//处理返回的字符串
void HandlPingInfor::handlListInfor(QString infor)
{
    m_addressList.clear();
    m_addressLostDelay.clear();
    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(infor.toUtf8(), &error);
    if(error.error == QJsonParseError::NoError)
    {
        /*if(documet.isObject())
        {
            QJsonObject jsonObj = documet.object();
            if(jsonObj.contains("data")) {
                QJsonObject datas = jsonObj.take("data").toObject();
                if(datas.contains("serverList")) {
                    QJsonArray  emotions = datas.take("serverList").toArray();
                    foreach(QJsonValue emotion , emotions ) {
                        QString address  =  emotion.toString();
                        m_addressList.append(address);
                    }
                }
            }

        }*/
        if(documet.isObject())
        {
            QJsonObject jsonObj = documet.object();
            if(jsonObj.contains("data"))
            {
                QJsonArray  emotions = jsonObj.take("data").toArray();
                foreach(QJsonValue emotion, emotions )
                {
                    QString address  =  emotion.toVariant().toMap()["ip"].toString();
                    m_addressList.append(address);
                }
            }
        }
    }

    for(int i = 0 ; i < m_addressList.count() ; i++ )
    {
        PingThread * pingThread = new PingThread(this);
        connect(pingThread, SIGNAL(sigSendPingInfor(QString, QString, QString)), this, SLOT(onSigSendPingInfor(QString, QString, QString)) );
        pingThread->setPingAddress(m_addressList[i]);
    }

}

//将容器转化为字符串
void HandlPingInfor::handlIpLostDelay()
{
    QJsonObject jsona;
    QJsonArray jsonb;
    QMap< QString, QPair<QString, QString > >::iterator it =  m_ipLostDelay.begin();
    for( ; it !=  m_ipLostDelay.end() ; it++ )
    {
        QJsonObject json1;
        json1.insert("serverIp", it.key() );
        json1.insert("delay", it.value().second );
        json1.insert("lost", it.value().first );
        QString pingResult("");
        if(it.value().first.toInt() > 0 )
        {
            pingResult = QStringLiteral("差");
        }
        if(pingResult.length() <= 0)
        {
            if(it.value().second.toInt() <= 30)
            {
                pingResult = QStringLiteral("优");
            }
            else if(it.value().second.toInt() <= 100)
            {
                pingResult = QStringLiteral("良");
            }
            else
            {
                pingResult = QStringLiteral("差");

            }
        }
        json1.insert("result", pingResult);
        jsonb.append(json1);

    }
    jsona.insert("content", jsonb);
    jsona.insert("command", "serverDelay");
    jsona.insert("domain", "system");

    QJsonDocument documents;
    documents.setObject(jsona);
    QString testList(documents.toJson(QJsonDocument::Compact));
    // qDebug()<<"HandlPingInfor::handlIpLostDelay  testList =="<<testList;

    emit sigSendIpLostDelay(testList);

}

//检测当前连接的服务器延迟
void HandlPingInfor::getCurrentConnectServerDelay()
{
    PingThread * pingThread = new PingThread(this);
    connect(pingThread, SIGNAL(sigSendPingInfor(QString, QString, QString)), this, SLOT(onCurrentConnectServerDelay(QString, QString, QString)) );
    pingThread->setPingAddress(StudentData::gestance()->m_address);

}
void HandlPingInfor::onCurrentConnectServerDelay(QString address, QString lost, QString delay)
{
    //qDebug()<<"current server Delay Data"<<address << lost << delay;
    QString delayString = QString("{\"domain\":\"system\",\"command\":\"currentDelay\",\"content\":{\"delay\":\"%1\",\"lost\":\"%2\",\"serverIp\":\"%3\"}}").arg(delay).arg(lost).arg(address);

    //第一次上传
    if(currentServerDelay == -100)
    {
        currentServerDelay = delay.toInt();
        currentServerLost = lost.toInt();
        emit sigSendIpLostDelay(delayString);
        return;
    }

    //判断是否符合上传条件
    if((lost.toInt() > 0) || (currentServerLost > 0 && lost.toInt() == 0 ) || (currentServerLost == 0 && lost.toInt() == 0 && qAbs(delay.toInt() - currentServerDelay) >= 20 ) )
    {
        //qDebug()<<"up  Delay Data" << currentServerLost << currentServerDelay<<qAbs(delay.toInt() - currentServerDelay);
        currentServerDelay = delay.toInt();
        currentServerLost = lost.toInt();
        emit sigSendIpLostDelay(delayString);
    }

}
