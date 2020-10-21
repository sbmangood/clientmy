#include "loadinformation.h"


LoadInforMation::LoadInforMation(QObject *parent) : QObject(parent)
    , m_uploadFileIamge(NULL)
    , m_imageFiles(NULL)
    , m_multiPart(NULL)
{


}

LoadInforMation::~LoadInforMation()
{

}
//上传图片
void LoadInforMation::uploadFileIamge(QString paths)
{
    // qDebug()<<"LoadInforMation::uploadFileIamge =="<<paths;
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
    maps.insert("type", "STU");
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
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(jpegs.toLower()));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"image\"; filename=\"" + paths + "\""));
    imagePart.setBodyDevice(m_imageFiles);
    m_imageFiles->setParent(m_multiPart);
    m_multiPart->append(imagePart);
    QString httpsd = QString(UPLOADHTTP) + QString("%1").arg(urls);
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
        QJsonObject dataObj = QJsonDocument::fromJson(bytes).object();
        if(dataObj.value("result").toString().toLower() == "fail")
        {
            emit sigUploadFileIamge(false);
            emit sigSendUrlHttp("");
            return;
        }
        qDebug() << "onUploadReadyRead" << result;
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
        emit sigSendUrlHttp(strs);
    }
    else
    {
        emit sigSendUrlHttp( QString("") );
    }
}

//下载音视频课件
QString LoadInforMation::downLoadMedia(QString mediaUrl)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    docPath += "/YIMI/Media/";
    QDir dir;
    if(!dir.exists(docPath))
    {
        dir.mkdir(docPath);
    }
    int indexOf = mediaUrl.indexOf("?");
    QString fileUrl = mediaUrl.mid(0,indexOf);
    int lastIndexOf = fileUrl.lastIndexOf("/");
    QString fileName = fileUrl.mid(lastIndexOf + 1,fileUrl.length() - 1);
    QString fileNames = docPath.append(fileName);

    QFile file(fileNames);
    if(file.exists())
    {
        return fileNames;
    }
    emit sigLoadingMedia();
    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    httpRequest.setUrl(QUrl(mediaUrl));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader,"application/x-www-form-urlencoded");
    QEventLoop httploop;
    QNetworkAccessManager *m_networkMgr = new QNetworkAccessManager(this);
    connect(m_networkMgr,SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    QNetworkReply *httpReply;
    httpReply = m_networkMgr->get(httpRequest);
    httploop.exec();

    QByteArray readData = httpReply->readAll();

    file.open(QIODevice::WriteOnly);
    file.write(readData);
    file.flush();
    file.close();
    return fileNames;
}
