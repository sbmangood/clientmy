#include "loadinformation.h"
#include <QEventLoop>
#include <QTimer>


LoadInforMation::LoadInforMation(QObject *parent) : QObject(parent)
    , m_uploadFileIamge(NULL)
    , m_imageFiles(NULL)
    , m_multiPart(NULL)
{
    m_httpAccessmanger = new QNetworkAccessManager(this);
    m_httpClient = YMHttpClient::defaultInstance();
    m_httpIP = m_httpClient->getRunUrl(1);
    downHttp = "http://" + m_httpIP + "/lesson/viewStuLessonDoc?";
    uploadHttp =  "http://" + m_httpIP + "/file/uploadLessonImg?";
    questionHttp = m_httpClient->getRunUrl(0);
}

LoadInforMation::~LoadInforMation()
{

}

//上传图片
void LoadInforMation::uploadFileIamge(QString paths)
{
    //qDebug()<<"LoadInforMation::uploadFileIamge =="<<paths;
    paths = QUrl::fromPercentEncoding(paths.toUtf8());
    if(m_uploadFileIamge != NULL)
    {
        delete m_uploadFileIamge;
        m_uploadFileIamge = new QNetworkAccessManager(this);
        connect(m_uploadFileIamge, SIGNAL(finished(QNetworkReply*)), this, SLOT( onUploadReadyRead(QNetworkReply* ) ));

    }
    else
    {
        m_uploadFileIamge = new QNetworkAccessManager(this);
        connect(m_uploadFileIamge, SIGNAL(finished(QNetworkReply*)), this, SLOT( onUploadReadyRead(QNetworkReply* ) ));

    }
    if(m_imageFiles != NULL)
    {
        delete m_imageFiles;
        m_imageFiles = NULL;
    }
    m_imageFiles = new QFile(paths);
    //    QFile file(paths);
    if( !m_imageFiles->open(QIODevice::ReadOnly) )
    {
        emit sigUploadFileIamge(false);
        //qDebug() << "================";
        return ;
    }
    QString jpegs = QString("image/jpeg");

    QStringList pathlist = paths.split(".");
    if(pathlist.count() >= 2)
    {
        if(pathlist[1] == "jpg")
        {
            jpegs = QString("image/jpeg");;
        }
        else
        {
            jpegs = QString("image/%1").arg( pathlist[1]);
        }

    }

    if(m_multiPart != NULL)
    {
        delete m_multiPart;
        m_multiPart = NULL;
    }
    QDateTime times = QDateTime::currentDateTime();

    QMap<QString, QString> maps;
    maps.insert("teacherId", StudentData::gestance()->m_teacher.m_teacherId );
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("type", "TEA");
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token); //"6d499b20858b00790af7b7dd0a3a5fd7"
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
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(jpegs));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"image\"; filename=\"" + paths + "\""));
    imagePart.setBodyDevice(m_imageFiles);
    m_imageFiles->setParent(m_multiPart);
    m_multiPart->append(imagePart);
    QString httpsd = QString(uploadHttp) + QString("%1").arg(urls);
    QUrl url(httpsd);
    QNetworkRequest request(url);
    m_replyFileIamge = m_uploadFileIamge->post(request, m_multiPart);

    connect(m_replyFileIamge, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(upLoadError(QNetworkReply::NetworkError)));
    connect(m_replyFileIamge, SIGNAL(uploadProgress ( qint64, qint64 )), this, SLOT( onUploadProgress(qint64, qint64 )));
    // connect(m_replyFileIamge,SIGNAL(finished() ),this,SLOT(httpUploadReadyRead() ));
}


void LoadInforMation::onUploadReadyRead(QNetworkReply *)
{
    // qDebug()<<"m_replyFileIamge->error()  =="<<m_replyFileIamge->error() ;
    if(m_replyFileIamge->error() == QNetworkReply::NetworkError::NoError)
    {
        QByteArray bytes = m_replyFileIamge->readAll();
        QString result(bytes);  //转化为字符串
        //qDebug()<<"onUploadReadyRead"<<result;
        emit sigUploadFileIamge(true);
        emit sigSendUrlHttp(result);
    }
    else
    {
        //处理错误
        // download_Btn->setText("failed");
        emit sigUploadFileIamge(false);
        emit sigSendUrlHttp("");
    }

    m_replyFileIamge->deleteLater();//要删除reply，但是不能在repyfinished里直接delete，要调用deletelater;


}

void LoadInforMation::upLoadError(QNetworkReply::NetworkError erros)
{
    //qDebug() << "LoadInforMation::upLoadError" << erros;
    if(erros == QNetworkReply::NetworkError::ContentNotFoundError)
    {
        // emit sigUploadFileIamge(true);
    }
    else
    {
        emit sigUploadFileIamge(false);
    }
}

void LoadInforMation::onUploadProgress(qint64 lens, qint64 totals)
{
    if(lens >= totals)
    {
        emit sigUploadFileIamge(true);
    }
}

void LoadInforMation::httpUploadReadyRead()
{
    if(m_replyFileIamge->error() == QNetworkReply::NoError)
    {
        QString strs(m_replyFileIamge->readAll());
        //qDebug() << "LoadInforMation::httpUploadReadyRead" << strs;
        emit sigSendUrlHttp(strs);
    }
    else
    {
        emit sigSendUrlHttp( QString("") );
    }
}

//上传图片返回服务器图片路径
QString LoadInforMation::uploadImage(QString paths)
{
    paths = QUrl::fromPercentEncoding(paths.toUtf8());

    QEventLoop loop;
    QTimer::singleShot(15000, &loop, SLOT(quit()));
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    m_imageFiles = new QFile(paths);
    if( !m_imageFiles->open(QIODevice::ReadOnly) )
    {
        //qDebug()<<"upload image open fail ";
        return "" ;
    }
    QString jpegs = QString("image/jpeg");
    QStringList pathlist = paths.split(".");

    if(pathlist.count() >= 2)
    {
        if(pathlist[1] == "jpg")
        {
            jpegs = QString("image/jpeg");;
        }
        else
        {
            jpegs = QString("image/%1").arg( pathlist[1]);
        }
    }
    QDateTime times = QDateTime::currentDateTime();

    QMap<QString, QString> maps;
    maps.insert("teacherId", StudentData::gestance()->m_teacher.m_teacherId);
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("type", "TEA");
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token); //"6d499b20858b00790af7b7dd0a3a5fd7"
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
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(jpegs));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"image\"; filename=\"" + paths + "\""));
    imagePart.setBodyDevice(m_imageFiles);
    m_imageFiles->setParent(m_multiPart);
    m_multiPart->append(imagePart);

    QString httpsd = QString(uploadHttp) + QString("%1").arg(urls);
    QUrl url(httpsd);
    QNetworkRequest request(url);
    QNetworkReply *imageReply = m_httpAccessmanger->post(request, m_multiPart);

    loop.exec();
    QByteArray replyData = imageReply->readAll();

    if(replyData.contains("\"result\":\"success\""))
    {
        QJsonDocument jsonDocument = QJsonDocument::fromJson(replyData);
        QString s_url =  jsonDocument.toVariant().toMap()["data"].toMap()["url"].toString();
        emit sigUploadFileIamge(true);
        emit sigSendUrlHttp(s_url);
        return s_url;
    }
    else
    {
        qDebug() << "LoadInforMation::uploadImage" << QString::fromUtf8(replyData);
    }

    emit sigUploadFileIamge(false);
    return "";
}

//题目类讲义底图
QString LoadInforMation::uploadQuestionImgOSS(QString planId, QString itemId, QString orderNumber, QString ImgName, QString filePath)
{
    QString key = QString("lessonPlan/baseImage/%1/%2/%3/question/%4/%5").arg(StudentData::gestance()->m_lessonId).arg(planId).arg(itemId).arg(orderNumber).arg(ImgName);
    //qDebug() << "LoadInforMation::uploadQuestionImgOSS" << key << filePath;

    QString paths = QUrl::fromPercentEncoding(filePath.toUtf8());
    QEventLoop loop;
    QTimer::singleShot(10000, &loop, SLOT(quit()));
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager(this);
    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    m_imageFiles = new QFile(paths);
    if( !m_imageFiles->open(QIODevice::ReadOnly) )
    {
        return "" ;
    }
    QString jpegs = QString("image/jpeg");
    QStringList pathlist = paths.split(".");

    if(pathlist.count() >= 2)
    {
        if(pathlist[1] == "jpg")
        {
            jpegs = QString("image/jpeg");;
        }
        else
        {
            jpegs = QString("image/%1").arg( pathlist[1]);
        }
    }

    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("key", key);
    maps.insert("token", StudentData::gestance()->m_token); //"6d499b20858b00790af7b7dd0a3a5fd7"
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

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart imagePart;
    //qDebug() << "===jpegs===" << jpegs;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(jpegs));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"file\""));

    imagePart.setBodyDevice(m_imageFiles);
    m_imageFiles->setParent(multiPart);
    multiPart->append(imagePart);

    QString httpsd = "http://" + questionHttp + "/api/lesson/upload/image?" + QString("%1").arg(urls);
    QUrl url(httpsd);
    QNetworkRequest request(url);
    //qDebug() << "===========loadinformation::url============" << url;
    QNetworkReply *imageReply = httpAccessmanger->post(request, multiPart);

    loop.exec();
    QByteArray replyData = imageReply->readAll();
    QJsonObject dataObject = QJsonDocument::fromJson(replyData).object();
    //qDebug() << "=======loadinFormation===========" << replyData.length() <<imageReply->errorString();

    if(dataObject.value("result").toString().toLower() == "success")
    {
        QString s_url =  dataObject.value("data").toString();
        return s_url;
    }
    else
    {
        qDebug() << "LoadInforMation::uploadQuestionImgOSS" << dataObject;
    }

    return "str_Null";
}

