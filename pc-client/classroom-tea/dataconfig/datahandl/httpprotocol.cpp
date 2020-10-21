#include "httpprotocol.h"

HttpProtocol::HttpProtocol(QObject *parent) : QObject(parent)
{
    timeoutTimer = new QTimer(this);
    timeoutTimer->setInterval(10000);
    timeoutTimer->setSingleShot(true);

    getMessageTimer = new QTimer(this);
    connect(getMessageTimer, &QTimer::timeout, this, &HttpProtocol::httpDealDataContral);
}

HttpProtocol::~HttpProtocol()
{

}

void HttpProtocol::httpDealDataContral()
{
    getMessageTimer->stop();
    //qDebug() << "HttpProtocol::httpDealDataContral()";
    QByteArray serverData = "";
    bool isHeartBeat = true;
    currentMessage = "";
    if( allBufferMessageList.size() > 0 )
    {
        isHeartBeat = false;
        currentMessage = allBufferMessageList.takeFirst();
        //qDebug()<<"HttpProtocol::httpDealDataContral() size > 0"<<getMessageTimer->isActive()<<allBufferMessageList;
        serverData = getServerData(currentMessage);
    }
    else
    {
        ++currentMessageTimeLength;
        if(currentMessageTimeLength < 10)
        {
            //间隔不到一秒 不发送心跳 继续检测数据
            getMessageTimer->start(100);
            return;
        }
        currentMessage = QString("0#SYSTEM{\"domain\":\"server\",\"command\":\"heartBeat\"}");
        serverData = getServerData(currentMessage);
    }

    if(serverData == "TimeoutYxt")
    {
        qDebug() << "timeout223kjkjk";
        emit timeOut("autoChangeIpFail");
        return;
    }

    if(serverData == "")
    {
        //qDebug()<<"timeout223kjkjk11111111111";
        if(!isHeartBeat)
        {
            allBufferMessageList.push_front(currentMessage);
        }
        getMessageTimer->start(100);
        return;
    }

    currentMessageTimeLength = 0 ;//数据接收成功之后 再重置心跳计数
    //数据处理 "{\"code\":1,\"message\":\"\",\"data\":[],
    // \"isStartClass\":false,\"onlineUsers\":[\"10001399\"],\"serverNum\":1000}
    QJsonObject dataObj = QJsonDocument::fromJson(serverData).object();

    //几种特殊类型
    if(dataObj.value("code").toInt() == 1)//code 为1 代表成功 0为失败
    {
        if(!dataObj.value("isStartClass").toBool())
        {
            //老师发送开始上课
        }
        //在线人员
        QJsonArray tempArray =  dataObj.value("onlineUsers").toArray();
        onlineUserList.clear();
        for(int a = 0 ; a < tempArray.size(); a++)
        {
            onlineUserList.append(tempArray.at(a).toString());
        }
        //服务端消息编号
        currentServerMessageNUmber = dataObj.value("serverNum").toInt();

        //发送消息
        tempArray = dataObj.value("data").toArray();
        for( int a = 0 ; a < tempArray.size() ; a++ )
        {
            emit readMessage(tempArray.at(a).toString());
        }

        //消息返回不为空的时候 要立即再次请求
        if( tempArray.size() > 0 )
        {
            if(allBufferMessageList.size() <= 0)
            {
                allBufferMessageList.append(QString("0#SYSTEM{\"domain\":\"server\",\"command\":\"heartBeat\"}"));
            }
        }
    }
    else
    {
        //失败了再次发送该消息
        if(!isHeartBeat)
        {
            allBufferMessageList.push_front(currentMessage);
        }
        getMessageTimer->start(100);
        return;
    }

    getMessageTimer->start(100);
}

QByteArray HttpProtocol::getServerData(QString message)
{
    //除了0# 以外 重新维护消息编号
    if(message.split("#").size() > 1 && message.contains("0#"))
    {
        // 不做操作
    }
    else
    {
        if(message.split("#").size() > 1)
        {
            message = message.replace( message.split("#").at(0) + "#", QString::number( ++currentMessageNumber ) + "#" );
        }
        else
        {
            message = QString::number( ++currentMessageNumber ) + "#" + message;
        }
    }

    //qDebug() << "HttpProtocol::getServerData" <<message.split("#").size()<<StudentData::gestance()->m_address<<currentMessageNumber<<message<<StudentData::gestance()->m_lessonId<<StudentData::gestance()->m_selfStudent.m_studentId;
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;

    httpRequest.setUrl(QUrl(QString("http://%1:5121/httpMsg").arg(httpAddress)));

    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);

    QMap<QString, QString> reqParam;
    reqParam.insert("lessonId", StudentData::gestance()->m_lessonId);
    reqParam.insert("userId", StudentData::gestance()->m_selfStudent.m_studentId);
    reqParam.insert("number", QString::number(currentServerMessageNUmber)); //上次接受到的serverNumber
    reqParam.insert("message", message.toUtf8().toPercentEncoding()); //要发送的消息
    //加密
    QString sign;
    QString urls;
    QMap<QString, QString>::iterator it =  reqParam.begin();
    for(int i = 0; it != reqParam.end() ; it++, i++)
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
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toLatin1(), QCryptographicHash::Md5).toHex().toUpper());

    QByteArray post_data;
    post_data.append(urls);

    QEventLoop httploop;
    connect(timeoutTimer, SIGNAL(timeout()), &httploop, SLOT(quit()));
    timeoutTimer->stop();
    QNetworkReply * reply = httpAccessmanger->post(httpRequest, urls.toLatin1());
    connect(reply, SIGNAL(finished()), &httploop, SLOT(quit()));
    timeoutTimer->start();
    httploop.exec();
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    //qDebug()<<"HttpProtocol::getServerData reply statusCode"<<statusCode<<timeoutTimer->isActive()<<urls;

    QByteArray byteArray = "";
    if(timeoutTimer->isActive())
    {
        timeoutTimer->stop();
        if(reply->error() == QNetworkReply::NoError && statusCode == 200)
        {
            byteArray = reply->readAll();
            reply->deleteLater();
            httpAccessmanger->deleteLater();
            //qDebug()<<"HttpProtocol::getServerData reply byteArray"<< byteArray;
            if(hasSendNetConnect == false )
            {
                hasSendNetConnect = true;
                hasNetConnects(true);
            }
            if(brokenNetTimes == 1)
            {
                emit readMessage("0#{null:1540127389}#{\"domain\":\"server\",\"command\":\"reLogin\"}");
                //0#{null:1540127389}#{\"domain\":\"server\",\"command\":\"reLogin\"}
            }
            brokenNetTimes = 0;
            return byteArray;
        }
        else
        {
            //消息错误处理
            return "";
        }
    }
    else
    {
        //请求超时处理
        ++brokenNetTimes;
        hasSendNetConnect = false;
        //断网时如果http正在请求 返回会很慢 30S左右 所以如果按照十秒 没有数据 就 退出 会造成第一次无法正常切换到 http
        //处理为：如果是第一次断网 第一次断网的请求不计入  第二次从新请求 如果还是断网 请求不到 就退出 用时最多（20 S）；
        if(statusCode == 0 && brokenNetTimes > 1 )
        {
            return "TimeoutYxt";
        }
        return "";
    }
    reply->deleteLater();
    httpAccessmanger->deleteLater();
    return byteArray;
}

void HttpProtocol::heartBeat()
{
    getServerData(QString("0#SYSTEM{\"domain\":\"server\",\"command\":\"heartBeat\"}"));
}

void HttpProtocol::sendMessage(QString message)
{
    if(message == "")
    {
        return;
    }
    allBufferMessageList.append(message);
    if(getMessageTimer->isActive() == false)
    {
        getMessageTimer->start(100);
    }

}
