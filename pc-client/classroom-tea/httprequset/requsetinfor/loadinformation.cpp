#include "loadinformation.h"
#include <QEventLoop>
#include <QTimer>
#include <QImageReader>

LoadInforMation::LoadInforMation(QObject *parent) : QObject(parent)
  , m_uploadFileIamge(NULL)
  , m_imageFiles(NULL)
  , m_multiPart(NULL)
  , m_replyFileIamge(NULL)
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

//判断图片是否需要旋转, 然后再上传(因为ipad上, 拍摄的图片, 在WIN7打开的时候, 是逆时针旋转了90度的, 造成了bug: ONLINEBUG-94)
bool LoadInforMation::doRotateImage(QString &filePath)
{
    //记录是否生成了临时的图片文件, 默认没有(有的话, 需要删除该临时文件的)
    bool bFlag = false;

    //判断图片, 是否已旋转了
    QImageReader reader(filePath);
    QImageIOHandler::Transformations transformation = reader.transformation(); //得到图片的旋转角度
    qDebug() << "LoadInforMation::doRotateImage" << int(transformation) << __LINE__;

    if(transformation != QImageIOHandler::Transformation::TransformationNone)
    {
        //设置临时图片文件的保存路径
        QString strImagePath = QCoreApplication::applicationDirPath();
        if(strImagePath.right(1) != "/")
        {
            strImagePath += "/";
        }
        strImagePath += "temp.jpg";

        //设置旋转的角度
        double dRotateAngle = 0.0;
        if(QImageIOHandler::Transformation::TransformationRotate90 == transformation)
        {
            dRotateAngle = 90.0;
        }
        else if(QImageIOHandler::Transformation::TransformationRotate180 == transformation)
        {
            dRotateAngle = 180.0;
        }
        else if(QImageIOHandler::Transformation::TransformationRotate270 == transformation)
        {
            dRotateAngle = 270.0;
        }

        QImage tempImage(filePath);
        QMatrix matrix;
        matrix.rotate(dRotateAngle); //顺时针旋转90度
        tempImage = tempImage.transformed(matrix, Qt::FastTransformation);
        tempImage.save(strImagePath);

        filePath = strImagePath;
        bFlag = true; //生成了临时的图片文件
    }

    return bFlag; //没有生成临时图片文件
}

//上传图片
void LoadInforMation::uploadFileIamge(QString paths)
{
    qDebug() << "LoadInforMation::uploadFileIamge ==" << paths;
    paths = QUrl::fromPercentEncoding(paths.toUtf8());

    bool bCreateTempFile = doRotateImage(paths);
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
        qDebug() << "LoadInforMation::uploadFileIamge failed." << __LINE__;

        if(bCreateTempFile)
        {
            QFile::remove(paths);
        }
        return;
    }

    int iPos = paths.lastIndexOf(".");
    QString strFileExetenion = paths.mid(iPos + 1).toLower();
    QString jpegs = QString("image/jpeg");
    if(strFileExetenion == "jpg")
    {
        jpegs = QString("image/jpeg");
    }
    else
    {
        jpegs = QString("image/%1").arg( strFileExetenion);
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

    qDebug() << "======fileUrls====" << sign;
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

    if(bCreateTempFile)
    {
        QFile::remove(paths);
    }
}

void LoadInforMation::onUploadReadyRead(QNetworkReply *)
{
    if(m_replyFileIamge->error() == QNetworkReply::NetworkError::NoError)
    {
        QByteArray bytes = m_replyFileIamge->readAll();
        QString result(bytes);  //转化为字符串
        QJsonObject dataObj = QJsonDocument::fromJson(bytes).object();
        if(dataObj.value("result").toString().toLower() == "fail")
        {
            qDebug()<<"LoadInforMation::onUploadReadyRead"<< dataObj << m_replyFileIamge->error() << __LINE__;
            emit sigUploadFileIamge(false);
            emit sigSendUrlHttp("");
            return;
        }

        emit sigUploadFileIamge(true);
        emit sigSendUrlHttp(result);
    }
    else
    {
        //处理错误
        // download_Btn->setText("failed");
        qDebug() << "LoadInforMation::onUploadReadyRead failed." << __LINE__;
        emit sigUploadFileIamge(false);
        emit sigSendUrlHttp("");
    }

    m_replyFileIamge->deleteLater();//要删除reply，但是不能在repyfinished里直接delete，要调用deletelater;


}

void LoadInforMation::upLoadError(QNetworkReply::NetworkError erros)
{
    qDebug() << "LoadInforMation::upLoadError failed." << erros << __LINE__;
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
        qDebug() << "LoadInforMation::httpUploadReadyRead" << strs;
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
    //qDebug() << "======loading::uploadImage::1111========"<< paths;
    QEventLoop loop;
    QTimer::singleShot(15000, &loop, SLOT(quit()));
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    m_imageFiles = new QFile(paths);
    if( !m_imageFiles->open(QIODevice::ReadOnly) )
    {
        qDebug() << "LoadInforMation::uploadImage failed" << __LINE__;
        return "" ;
    }

    QString jpegs = QString("image/jpeg");
    int lastIndexOf = paths.lastIndexOf(".");
    QString suffix =  paths.mid(lastIndexOf + 1, paths.length() - 1).toLower();
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
    QJsonObject dataObj = QJsonDocument::fromJson(replyData).object();
    //qDebug() << "======loading::uploadImage========" << dataObj << paths;

    if(dataObj.value("result").toString().toLower() == "success")
    {
        QJsonDocument jsonDocument = QJsonDocument::fromJson(replyData);
        QString s_url =  jsonDocument.toVariant().toMap()["data"].toMap()["url"].toString();
        emit sigUploadFileIamge(true);
        emit sigSendUrlHttp(s_url);
        return s_url;
    }
    else
    {
        qDebug() << "LoadInforMation::uploadImage failed" << dataObj << __LINE__;
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
        qDebug() << "LoadInforMation::uploadQuestionImgOSS failed." << __LINE__;
        return "" ;
    }

    int iPos = paths.lastIndexOf(".");
    QString strFileExetenion = paths.mid(iPos + 1).toLower();
    QString jpegs = QString("image/jpeg");
    if(strFileExetenion == "jpg")
    {
        jpegs = QString("image/jpeg");;
    }
    else
    {
        jpegs = QString("image/%1").arg( strFileExetenion);
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
    qDebug() << "===jpegs===" << jpegs;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(jpegs));

    //在这里指定: 给服务器的文件流, 以及文件流的参数: "file"
    //API 接口文档: http://tools.yimigit.com/showdoc/index.php?s=/2&page_id=960
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"file\""));

    imagePart.setBodyDevice(m_imageFiles);
    m_imageFiles->setParent(multiPart);
    multiPart->append(imagePart);

    QString httpsd = "http://" + questionHttp + "/api/lesson/upload/image?" + QString("%1").arg(urls);
    QUrl url(httpsd);
    QNetworkRequest request(url);
    qDebug() << "===========loadinformation::url============" << url;
    QNetworkReply *imageReply = httpAccessmanger->post(request, multiPart);

    loop.exec();
    QByteArray replyData = imageReply->readAll();
    QJsonObject dataObject = QJsonDocument::fromJson(replyData).object();
    qDebug() << "=======loadinFormation===========" << replyData.length() << imageReply->errorString();

    if(dataObject.value("result").toString().toLower() == "success")
    {
        QString s_url =  dataObject.value("data").toString();
        return s_url;
    }
    else
    {
        qDebug() << "LoadInforMation::uploadQuestionImgOSS failed" << dataObject;
    }

    return "str_Null";
}

//下载MP3
QString LoadInforMation::downLoadMp3(QString mp3Url)
{
    QString docPath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    docPath += "/YIMI/Mp3/";
    QDir dir;
    if(!dir.exists(docPath))
    {
        dir.mkdir(docPath);
    }
    int indexOf = mp3Url.indexOf("?");
    QString fileUrl = mp3Url.mid(0,indexOf);
    int lastIndexOf = fileUrl.lastIndexOf("/");
    QString fileName = fileUrl.mid(lastIndexOf + 1,fileUrl.length() - 1);
    QString fileNames = docPath.append(fileName);

    QFile file(fileNames);
    if(file.exists())
    {
        return fileNames;
    }
    emit sigLoadingMp3();
    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    httpRequest.setUrl(QUrl(mp3Url));
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

QString LoadInforMation::getAuditionReportView( QString type )
{
    QString tempUrl = "";
    if(m_httpIP.contains("stage-"))
    {
        tempUrl = "stage-";
    }else if(m_httpIP.contains("dev-"))
    {
        tempUrl = "dev-";
    }
    else if(m_httpIP.contains("pre-"))
    {
        tempUrl = "pre-";
    }
    else if(m_httpIP.contains("test-"))
    {
        tempUrl = "test-";
    }else
    {
        //获取默认的环境前缀
        if(m_httpIP.split("-").size() >= 2)
        {
           tempUrl = m_httpIP.split("-").at(0) + "-";
        }
    }
    QString h5BasicData = YMQosManager::gestance()->getH5NeedBasicData();
    YMUserBaseInformation::endLessonH5Url = QString("http://%5h5.yimifudao.com.cn/hybrid/?studentId=%3&lessonId=%1&classType=%2&token=%4&userId=%6%7#/trial/lessonInfo").arg(StudentData::gestance()->m_lessonId).arg(QString::number(YMUserBaseInformation::lessonType)).arg(StudentData::gestance()->m_selfStudent.m_studentAId).arg(StudentData::gestance()->m_token).arg(tempUrl).arg(StudentData::gestance()->m_teacher.m_teacherId).arg(h5BasicData);

    return QString("http://%5h5.yimifudao.com.cn/freeTrialResult?classId=%1&classType=%2&number=%3&token=%4").arg(StudentData::gestance()->m_lessonId).arg(QString::number(YMUserBaseInformation::lessonType)).arg(type).arg(StudentData::gestance()->m_token).arg(tempUrl);
}

bool LoadInforMation::getLessonReportStatus()
{
    if(YMUserBaseInformation::reportFlag == 0)
    {
        return false;
    }
    if(YMUserBaseInformation::reportFlag == 1)
    {
        return true;
    }
    return false;
}


QString LoadInforMation::getEndLessonH5Url()
{
    //http://xxx-h5.yimifudao.com/freeTrial?studentId=xxx&lessonId=xxx&classType=xxx&token=xxx
    return YMUserBaseInformation::endLessonH5Url;
}

QJsonObject LoadInforMation::getQuestionAnswer(long planId, long itemId, QString questionId)
{
    QJsonObject jsonObj;
    QDateTime currentTime = QDateTime::currentDateTime();
    QString timestamp = currentTime.toString("yyyyMMddhhmmss");
    QVariantMap reqParm;
    reqParm.insert("lessonId", YMUserBaseInformation::lessonId.toLong());
    reqParm.insert("planId", planId);
    reqParm.insert("itemId",itemId);
    reqParm.insert("questionId",questionId);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", timestamp.toLongLong());

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);
    //questionHttp = "111.231.67.238:12121";//调试用，后面要删除

    QString url = QString("http://" + m_httpClient->answerUrl + "/socks/lesson/getQuestionAnswer?apiVersion=%1&appVersion=%2&itemId=%3&lessonId=%4&planId=%5&questionId=%6&sign=%7&timestamp=%8&token=%9")
            .arg(YMUserBaseInformation::apiVersion).arg(YMUserBaseInformation::appVersion).arg(itemId).arg(YMUserBaseInformation::lessonId.toLong())
            .arg(planId).arg(questionId).arg(sign).arg(timestamp).arg(YMUserBaseInformation::token);

    QByteArray byteArray = m_httpClient->httpGetIp(url);//->httpPostForm(url,reqParm);//
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

    qDebug() << "====getQuestionAnswer===" << url << dataObj;

    if(dataObj.value("result").toString().contains("success"))
    {
        jsonObj = dataObj.value("data").toObject();
    }
    return jsonObj;
}
