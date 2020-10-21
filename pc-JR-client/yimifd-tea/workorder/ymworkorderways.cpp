#include "ymworkorderways.h"

YMWorkOrderways::YMWorkOrderways(QObject *parent) :
    QObject(parent),m_imageFiles(NULL),m_multiPart(NULL)
{
    m_httpAccessmanger = new QNetworkAccessManager(this);
    m_httpClient = YMHttpClient::defaultInstance();
}

YMWorkOrderways::~YMWorkOrderways()
{

}

QString YMWorkOrderways::getWorkOrderList(QString type, int page)
{

    QEventLoop loop;
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    QNetworkRequest httpRequest;

    QUrl url( YMUserBaseInformation::url + "/tea/workorder/getWorkOrderList");

    // QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("loginUserId", YMUserBaseInformation::id);
    maps.insert("type", type);
    maps.insert("page", QString::number(page));
    maps.insert("rows", "10");
    maps.insert("appVersion", YMUserBaseInformation::appVersion);
    maps.insert("token", YMUserBaseInformation::token);

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
    QNetworkReply *reply =  m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    loop.exec();
    QString data = reply->readAll();
    qDebug() << data;
    return  data;
}

QString YMWorkOrderways::getWorkOrderListDetails(QString orderId)
{
    QEventLoop loop;
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    QNetworkRequest httpRequest;

    QUrl url( YMUserBaseInformation::url + "/tea/workorder/getWorkOrderDetail");

    QMap<QString, QString> maps;
    maps.insert("orderId", orderId);
    maps.insert("apiVersion", YMUserBaseInformation::apiVersion);
    maps.insert("token", YMUserBaseInformation::token);

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
    QNetworkReply *reply =  m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    loop.exec();
    QByteArray dataArray = reply->readAll();
    QString data;
    data.prepend(dataArray);
#ifdef USE_OSS_AUTHENTICATION
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    QJsonObject dataImgObj = dataObj.value("data").toObject();
    QJsonArray imgsArray = dataImgObj.value("imgs").toArray();

    QJsonObject bufferObj;
    bufferObj.insert("code", dataObj.value("code").toString());
    bufferObj.insert("success", dataObj.value("success").toBool());

    QJsonObject bufferData;
    bufferData.insert("orderNo", dataImgObj.value("code").toString());
    bufferData.insert("sponsorType", dataImgObj.value("sponsorType").toString());
    bufferData.insert("orderId", dataImgObj.value("orderId").toInt());
    bufferData.insert("lessonFid", dataImgObj.value("lessonFid").toInt());
    bufferData.insert("sponsorName", dataImgObj.value("sponsorName").toString());
    bufferData.insert("comment", dataImgObj.value("comment").toArray());
    bufferData.insert("sponsorFid", dataImgObj.value("sponsorFid").toString());
    bufferData.insert("createdOn", dataImgObj.value("createdOn").toString());
    bufferData.insert("content", dataImgObj.value("content").toString());

    QJsonArray buuferImgsArray;
    for(int i = 0; i < imgsArray.size(); i++)
    {
        QString imgUrl = imgsArray.at(i).toString();
        QString ossSignUrl = this->getOssSignUrl(imgUrl);
        buuferImgsArray.insert(i, ossSignUrl);
    }
    bufferData.insert("imgs", buuferImgsArray);
    bufferObj.insert("data", bufferData);
    data = QString(QJsonDocument(bufferObj).toJson());
#endif

    qDebug() << data;
    return  data;
}
QString YMWorkOrderways ::closeWorkOrder(QString orderId, QString comment, QString likeType)
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    QNetworkRequest httpRequest;

    QUrl url( YMUserBaseInformation::url + "/tea/workorder/closeWorkOrder");

    QMap<QString, QString> maps;
    maps.insert("orderId", orderId);
    maps.insert("apiVersion", YMUserBaseInformation::apiVersion);
    maps.insert("token", YMUserBaseInformation::token);
    maps.insert("comment", comment);
    maps.insert("commentType", likeType);

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
    QNetworkReply *reply =  m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    loop.exec();
    QString data = reply->readAll();
    qDebug() << data;
    return  data;
}

QString YMWorkOrderways ::getWOrkOrderAllTypes()
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    QNetworkRequest httpRequest;

    QUrl url( YMUserBaseInformation::url + "/tea/workorder/getSelectMenu");

    QMap<QString, QString> maps;
    maps.insert("token", YMUserBaseInformation::token);

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
    QNetworkReply *reply =  m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    loop.exec();
    QString data = reply->readAll();
    qDebug() << "work order types " << data;
    return  data;
}

QString YMWorkOrderways::uploadImage(QString paths, QString lessonId)
{
    paths = QUrl::fromPercentEncoding(paths.toUtf8());
    QEventLoop loop;
    QTimer::singleShot(15000, &loop, SLOT(quit()));
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    m_imageFiles = new QFile(paths.remove("file:///"));
    if( !m_imageFiles->open(QIODevice::ReadOnly) )
    {
        qDebug() << "upload image open fail ";
        return "" ;
    }

    int lastIndexOf = paths.lastIndexOf(".");
    QString suffix =  paths.mid(lastIndexOf + 1, paths.length() - 1).toLower();
    QString jpegs = "image/jpeg";//上传图片的格式只能是（image/jpeg）或者(image/png)
    if(suffix.contains("jpg"))
    {
        jpegs = QString("image/jpeg");
    }
    if(suffix.contains("png"))
    {
        jpegs = QString("image/png");
    }

    QDateTime times = QDateTime::currentDateTime();

    QMap<QString, QString> maps;
    maps.insert("teacherId", YMUserBaseInformation::id );
    maps.insert("lessonId", lessonId);
    maps.insert("type", "TEA");
    maps.insert("apiVersion", YMUserBaseInformation::apiVersion);
    maps.insert("appVersion", YMUserBaseInformation::appVersion);
    maps.insert("token", YMUserBaseInformation::token); //"6d499b20858b00790af7b7dd0a3a5fd7"
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

    m_multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(jpegs.toLower()));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"image\"; filename=\"" + paths + "\""));
    imagePart.setBodyDevice(m_imageFiles);
    m_imageFiles->setParent(m_multiPart);
    m_multiPart->append(imagePart);
    QString httpsd = QString(YMUserBaseInformation::url) + QString("/file/uploadLessonImg?%1").arg(urls);
    QUrl url(httpsd);
    QNetworkRequest request(url);
    QNetworkReply *imageReply = m_httpAccessmanger->post(request, m_multiPart);

    loop.exec();
    m_imageFiles->close();
    QByteArray replyData = imageReply->readAll();

    if(replyData.contains("\"result\":\"success\""))
    {
        QJsonDocument jsonDocument = QJsonDocument::fromJson(replyData);
        return jsonDocument.toVariant().toMap()["data"].toMap()["url"].toString();
    }
    else
    {
        qDebug() << "YMWorkOrderways::uploadImage::data" << jpegs << httpsd << QString::fromUtf8(replyData);
    }

    return "";
}

void YMWorkOrderways::creatWorkOrderSheet(QString lessonId, QString urgentType, QString content, QString questionType, QString imgUrl)
{
    QVariantMap maps;
    QDateTime times = QDateTime::currentDateTime();
    maps.insert("apiVersion", YMUserBaseInformation::apiVersion);
    maps.insert("loginUserId", YMUserBaseInformation::id);
    maps.insert("questionType", questionType);
    maps.insert("lessonFid", lessonId);
    maps.insert("appVersion", YMUserBaseInformation::appVersion);
    maps.insert("appSysInfo", "WIN"); //系统信息
    maps.insert("appDeviceInfo", YMUserBaseInformation::deviceInfo); //设备信息
    maps.insert("appSource", "YIMI");
    maps.insert("appNetwork", getLocalHostIp(2));
    maps.insert("appIp", getLocalHostIp(1));
    maps.insert("token", YMUserBaseInformation::token);
    maps.insert("urgentType", urgentType);
    maps.insert("content", content);
    maps.insert("imgUrl", imgUrl);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));

    QString url = (YMUserBaseInformation::url + "/tea/workorder/addWorkOrder?");
    QString sortStr = YMEncryption::signMapSort(maps);
    QString sign = YMEncryption::md5(sortStr).toUpper();
    maps.insert("sign", sign);
    QByteArray dataArray = m_httpClient->httpPostForm(url, maps);

    QJsonObject jsonObj = QJsonDocument::fromJson(dataArray).object();
    if(jsonObj.value("result").toString().toLower() == "success" && jsonObj.value("message").toString().toUpper() == "SUCCESS")
    {
        emit creatWorkOrderSuccessOrFail(true);
        return;
    }

    qDebug() << "YMWorkOrderways::creatWorkOrderSheet" << jsonObj << dataArray;
    emit creatWorkOrderSuccessOrFail(false);
}

//获取本机IP
QString YMWorkOrderways::getLocalHostIp(int type)
{
    if(type == 1)
    {
        QList<QHostAddress> AddressList = QNetworkInterface::allAddresses();
        foreach(QHostAddress address, AddressList)
        {
            if(address.protocol() == QAbstractSocket::IPv4Protocol &&
               address != QHostAddress::Null &&
               address != QHostAddress::LocalHost)
            {
                if (address.toString().contains("127.0."))
                {
                    continue;
                }
                return address.toString();
            }
        }
        return "";
    }
    else
    {
        int types = 0;
        QString m_netWorkMode;
        QList<QNetworkInterface> list = QNetworkInterface::allInterfaces();
        foreach (QNetworkInterface netInterface, list)
        {
            if (!netInterface.isValid())
                continue;
            QNetworkInterface::InterfaceFlags flags = netInterface.flags();
            if (flags.testFlag(QNetworkInterface::IsRunning)
                && !flags.testFlag(QNetworkInterface::IsLoopBack))    // 网络接口处于活动状态
            {
                if(types == 0) //wireless
                {
                    m_netWorkMode = netInterface.name();
                }
                types++;
            }
        }
        m_netWorkMode.remove("#");
        m_netWorkMode.remove("\n");
        if(m_netWorkMode.contains("wireless"))
        {
            return QStringLiteral("无线");
        }
        return QStringLiteral("网线");
    }
}

bool YMWorkOrderways::reCommitWorkOrder(QString orderId, QString content, QString imgUrl)
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    QNetworkRequest httpRequest;

    QUrl url( YMUserBaseInformation::url + "/tea/workorder/feedBack");

    QMap<QString, QString> maps;
    maps.insert("orderId", orderId);
    maps.insert("apiVersion", YMUserBaseInformation::apiVersion);
    maps.insert("token", YMUserBaseInformation::token);
    maps.insert("content", content);
    maps.insert("imgUrl", imgUrl);
    maps.insert("loginUserId", YMUserBaseInformation::id);

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
    //qDebug()<<urls;
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    httpRequest.setUrl(url);
    QNetworkReply *reply =  m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
    loop.exec();
    QString data = reply->readAll();

    if(data.contains("result\":\"success"))
    {
        return true;
    }
    qDebug() << "YMWorkOrderways::reCommitWorkOrder" << data;
    return  false;
}

#ifdef USE_OSS_AUTHENTICATION
//图片进行验签
QString YMWorkOrderways::getOssSignUrl(QString ImgUrl)
{
    long current_second = QDateTime::currentDateTime().toTime_t();
    int indexOf = ImgUrl.indexOf(".com");
    int midOf = ImgUrl.indexOf("?");
    QString key = ImgUrl.mid(indexOf + 4, midOf - indexOf - 4); //ImgUrl.length() - indexOf - 4);

    bool isKey = m_bufferOssKey.contains(key);
    if(!isKey)//key是否存在,不存在则添加
    {
        m_bufferOssKey.insert(key, 0);
    }

    QMap<QString, long>::iterator key_Map = m_bufferOssKey.find(key);
    long buffer_second = key_Map.value();

    //qDebug() << "==TrailBoard::getOssSignUrl==" << isKey << buffer_second << current_second << key;

    if(current_second - buffer_second >= 1800 || isKey == false)//如果该key存在则判断是否过期
    {
        QVariantMap  reqParm;
        reqParm.insert("key", key);
        reqParm.insert("expiredTime", 1800 * 1000);
        reqParm.insert("token", YMUserBaseInformation::token);

        QString signSort = YMEncryption::signMapSort(reqParm);
        QString sign = YMEncryption::md5(signSort).toUpper();
        reqParm.insert("sign", sign);

        QString httpUrl = m_httpClient->getRunUrl(0);
        QString url = "https://" + httpUrl + "/api/oss/make/sign";
        QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
        QJsonObject allDataObj = QJsonDocument::fromJson(dataArray).object();

//        qDebug() << "======TrailBoard::getOssSignUrl::pram====" << reqParm;
//        qDebug() << "======TrailBoard::getOssSignUrl::key====" << key;
//        qDebug() << "======TrailBoard::getOssSignUrl::url====" << url;
//        qDebug() << "***********allDataObj********" << dataArray.length() << allDataObj;

        if(allDataObj.value("result").toString().toLower() == "success")
        {
            QString url = allDataObj.value("data").toString();
            m_bufferOssKey[key] = current_second;
            qDebug() << "*********url********" << url << current_second;
            return url;
        }
        else
        {
            qDebug() << "YMWorkOrderways::getOssSignUrl" << allDataObj;
        }
    }
    return ImgUrl;
}
#endif
