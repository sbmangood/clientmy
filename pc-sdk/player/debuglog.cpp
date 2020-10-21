#include "debuglog.h"

#include <QDateTime>
#include <qdebug>
#include <iostream>
#include <QTextCodec>
#include <QEventLoop>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QHttpMultiPart>
#include <QNetworkReply>
#include "imageprovider.h"
#include "YMUserBaseInformation.h"
#include <QJsonObject>
#include <QJsonDocument>

using namespace  std;

//功能: 给项目写日志文件, 记录当前qt项目, 执行的过程, 问题发生的点
DebugLog * DebugLog::_instance = NULL;
QTextStream * DebugLog::m_pStream = NULL;
QMutex DebugLog::mutex_log;

DebugLog::DebugLog(QObject *parent) :
    QObject(parent)
{
    m_pStream = NULL;
    m_pFile = NULL;
    m_httpClient = YMHttpClient::defaultInstance();
}

DebugLog::~DebugLog()
{
    doCloseLog();
}

//上传文件前, 先关闭文件, 文件流的句柄
//尤其是在退出程序的时候, 句柄一直都在开的状态, 所以, 在上传文件之前, 先关闭
void DebugLog::doCloseLog()
{
    if(m_pStream != NULL)
    {
        m_pStream->flush();
        delete m_pStream;
        m_pStream = NULL;
    }


    if(m_pFile != NULL)
    {
        m_pFile->close();

        delete m_pFile;
        m_pFile = NULL;
    }
}

void DebugLog::init_log(QString strAppFileName)
{
    QDateTime *datetime = new QDateTime(QDateTime::currentDateTime());
    QString strCurrentTime = datetime->toString("yyyy-MM-dd");
    delete datetime;
    datetime = NULL;

    int i = strAppFileName.indexOf(".");
    QString strAppName = strAppFileName.mid(0, i);

    QString strLogFile = QString("%1_%2.log") .arg(strAppName) .arg(strCurrentTime);

    //得到log文件的绝对路径
    QString strAppFullPath = StudentData::gestance()->strAppFullPath;
    strLogFile = strAppFullPath.replace(StudentData::gestance()->strAppName, strLogFile); //得到log文件的绝对路径
    StudentData::gestance()->strAppFullPath_LogFile = strLogFile;

    //===================================
    //进入教室, 先第一次上传日志文件
    doUpgrade_LocalLogInfo_To_Server();

    //===================================
    //log文件大于50M的话, 就删除
#if 0
    //这个功能, 暂时不需要了
    int iFileSize = 0;
    if (!file.open(QIODevice::ReadOnly)) //文件存在的时候, 才去获取文件大小
    {
        cout << "DebugLog::init_log failed.";
        return;
    }

    iFileSize = file.size();
    cout << "logfile  size: " << iFileSize;
    file.close();

    if(iFileSize > 50 * 1024 * 1024) //大于50M的时候, 删除文件
    {
        QFile::remove(strLogFile);
    }
#endif

    //===================================
    //方式：Append为追加，WriterOnly，ReadOnly
    m_pFile = new QFile(strLogFile);
    if(!m_pFile->open(QIODevice::Append))
    {
        m_pFile = NULL;
        return;
    }

    m_pStream = new QTextStream(m_pFile);
    m_pStream->setCodec(QTextCodec::codecForName("utf-8"));
}

//兼容旧版本
void DebugLog::log(QString strLog)
{
    AddLog(strLog);
}

void DebugLog::AddLog(QString strLog)
{
    return; //因为使用qDebug的内容, 写入到日志里面, 所以这个函数, 就不需要了

    QMutexLocker locker(&mutex_log);

    if(strLog.trimmed().isEmpty())
    {
        return;
    }

    QDateTime *datetime = new QDateTime(QDateTime::currentDateTime());
    QString strCurrentTime = datetime->toString("yyyy-MM-dd hh:mm:ss");
    delete datetime;
    datetime = NULL;

    //(*m_pStream)<<strCurrentTime<<"\t"<<strLog<<"("<<__FILE__<<","<<__LINE__<<")"<<endl;
    //以下写文件, 最好将: strCurrentTime  strLog  转成char *, 写入到: (*m_pStream)中, 如下:
    (*m_pStream) << strCurrentTime.toStdString().c_str() << "\t" << strLog.toStdString().c_str() << endl;
    m_pStream->flush();
}

//将qDebug显示的日志, 写入到日志文件中
void DebugLog::LogMsgOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    if(msg.trimmed().isEmpty())
    {
        return;
    }

    QMutexLocker locker(&mutex_log);

    cout << msg.toLocal8Bit().data() << endl;
    //Critical Resource of Code
    QByteArray localMsg = msg.toLocal8Bit();
    QString log;

    switch (type)
    {
        case QtDebugMsg:
            log.append(QString("%1, %2, Line: %3, Content: %4").arg(context.file).arg(context.function).arg(context.line).arg(msg));
            break;
        case QtInfoMsg:
            log.append(QString("Info: %1  %2  %3  %4").arg(localMsg.constData()).arg(context.file).arg(context.line).arg(context.function));
            break;
        case QtWarningMsg:
//             log.append(QString("Warning: %1  %2  %3  %4").arg(localMsg.constData()).arg(context.file).arg(context.line).arg(context.function));
            return;
        //break;
        case QtCriticalMsg:
            log.append(QString("Critical: %1  %2  %3  %4").arg(localMsg.constData()).arg(context.file).arg(context.line).arg(context.function));
            break;
        case QtFatalMsg:
            log.append(QString("Fatal: %1  %2  %3  %4").arg(localMsg.constData()).arg(context.file).arg(context.line).arg(context.function));
            abort();
    }

    QDateTime *datetime = new QDateTime(QDateTime::currentDateTime());
    QString strCurrentTime = datetime->toString("yyyy-MM-dd hh:mm:ss");
    delete datetime;
    datetime = NULL;

    if(m_pStream != NULL)
    {
        //(*m_pStream)<<strCurrentTime<<"\t"<<strLog<<"("<<__FILE__<<","<<__LINE__<<")"<<endl;
        //以下写文件, 最好将: strCurrentTime  strLog  转成char *, 写入到: (*m_pStream)中, 如下:
        (*m_pStream) << strCurrentTime.toStdString().c_str() << " " << log << endl;
        m_pStream->flush();
    }
}

bool DebugLog::doUpgrade_LocalLogInfo_To_Server()
{
    //宏开关, 没有开启的话, return true
#ifndef USE_LOG_UPLOAD
    return true;
#endif

    //====================================
    //上传当前工程的日志文件
    QString strFileFulPath = StudentData::gestance()->strAppFullPath_LogFile;
#ifdef USE_STATIC_UPLOAD_LOG
    if(!doUpgrade_LocalLogInfo_To_Server_Once(strFileFulPath))
    {
        //如果上传一次失败了, 那就再上传一次
        doUpgrade_LocalLogInfo_To_Server_Once(strFileFulPath);
    }
#endif

#ifdef USE_OSS_UPLOAD_LOG
    QString savePath = uploadLog_To_OSS(strFileFulPath);
    if(savePath == "")
    {
        return false;
    }
    else
    {
        bool isSuccess = saveLogUrl(savePath);
        return isSuccess;
    }
#endif
    //====================================
    //上传B通道, 声网的日志文件
#if 0
    strFileFulPath = StudentData::gestance()->strAgoraFullPath_LogFile;

    if(!doUpgrade_LocalLogInfo_To_Server_Once(strFileFulPath))
    {
        //如果上传一次失败了, 那就再上传一次
        doUpgrade_LocalLogInfo_To_Server_Once(strFileFulPath);
    }
#endif

    return true;
}

//将本地的日志文件, 上传到服务器上去
//参考网页: https://blog.csdn.net/e5Max/article/details/53033971
bool DebugLog::doUpgrade_LocalLogInfo_To_Server_Once(QString strFileFulPath)
{
    doCloseLog();

    QString paths = QUrl::fromPercentEncoding(strFileFulPath.toUtf8());
    m_pFile_upLoad = new QFile(paths);
    if( !QFile::exists(strFileFulPath) || !m_pFile_upLoad->open(QIODevice::ReadOnly) || m_pFile_upLoad->size() <= 0 )
    {
        qDebug() << "DebugLog::doUpgrade_LocalLogInfo_To_Server_Once return: " << qPrintable(strFileFulPath) << QFile::exists(strFileFulPath) << m_pFile_upLoad->size() << __LINE__;
        delete m_pFile_upLoad;
        m_pFile_upLoad = NULL;
        return true; //日志上传失败, 文件不存在
    }

    QEventLoop loop;
    QTimer::singleShot(10000, &loop, SLOT(quit()));
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager(this);
    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("token", StudentData::gestance()->m_token); //"6d499b20858b00790af7b7dd0a3a5fd7"
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("appVersion", YMUserBaseInformation::appVersion);
    maps.insert("apiVersion", YMUserBaseInformation::apiVersion);

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

    //在这里指定: 给服务器的文件流, 以及文件流的参数: "multipartFile"
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(QString("form-data; name=\"%1\"; filename=\"%2\"") .arg("multipartFile") .arg(paths)));

    imagePart.setBodyDevice(m_pFile_upLoad);
    m_pFile_upLoad->setParent(multiPart);
    multiPart->append(imagePart);

//    QString httpsd = "http://api.yimifudao.com/v2.4/log/logUpload?" + QString("%1").arg(urls);
    QString httpsd = "http://" + m_httpClient->httpUrl + "/log/logUpload?" + QString("%1").arg(urls);
//    qDebug() << "=======doUpgrade_LocalLogInfo_To_Server=========== httpsd: " << qPrintable(httpsd);

    QUrl url(httpsd);
    QNetworkRequest request(url);
    QNetworkReply *imageReply = httpAccessmanger->post(request, multiPart);

    loop.exec();
    QByteArray replyData = imageReply->readAll();
    QJsonObject dataObject = QJsonDocument::fromJson(replyData).object();
//    qDebug() << "=======doUpgrade_LocalLogInfo_To_Server=========== replyData" << replyData.length() <<imageReply->errorString();
//    qDebug() << "DebugLog::doUpgrade_LocalLogInfo_To_Server_Once dataObject: " << dataObject << __LINE__;

    m_pFile_upLoad->close();
    delete m_pFile_upLoad;
    m_pFile_upLoad = NULL;
    delete multiPart;
    multiPart = NULL;
    delete httpAccessmanger;
    httpAccessmanger = NULL;

    if(dataObject.value("result").toString().toLower() == "success")
    {
        QFile::remove(strFileFulPath); //上传成功以后, 删除本地文件
        return true; //日志上传成功
    }
    else
    {
        qDebug() << "DebugLog::doUpgrade_LocalLogInfo_To_Server_Once dataObject: " << dataObject << __LINE__;
    }

    //日志上传失败
    return false;
}

#ifdef USE_OSS_UPLOAD_LOG
//上传日志文件的路径信息, 上传到ELK日志分析服务器
bool DebugLog::saveLogUrl(QString logUrl)
{
    QDateTime times = QDateTime::currentDateTime();
    QVariantMap maps;
    maps.insert("deviceType", "PC");
    maps.insert("deviceName", YMUserBaseInformation::deviceInfo);
    maps.insert("appType", QStringLiteral("PC录播"));
    maps.insert("appVersion", YMUserBaseInformation::appVersion);
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("userId", YMUserBaseInformation::id);
    maps.insert("businessModule", QStringLiteral("具体业务模块类名"));
    maps.insert("logUrl", logUrl);
    maps.insert("token", YMUserBaseInformation::token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));

    QString sortStr = YMCrypt::signMapSort(maps);
    QString sign = YMCrypt::md5(sortStr);

    maps.insert("sign", sign);
    QString url = "http://" + m_httpClient->httpUrl + "/log/saveLogUrl";
    QByteArray dataArray =  m_httpClient->httpPostForm(url, maps);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    QString result = dataObj.value("result").toString().toLower();
    qDebug() << "666666666666" << url << dataArray << maps;
    if(result.contains("success"))
    {
        qDebug() << "DebugLog::saveLogUrl::success";
        return true;
    }
    else
    {
        qDebug() << "DebugLog::saveLogUrl" << dataObj;
    }

    return false;
}
#endif

#ifdef USE_OSS_UPLOAD_LOG
//将日志文件, 上传至OSS服务器
QString DebugLog::uploadLog_To_OSS(QString logPath)
{
    doCloseLog();
    QDateTime times = QDateTime::currentDateTime();
    QString paths = QUrl::fromPercentEncoding(logPath.toUtf8());
    m_pFile_upLoad = new QFile(paths);
    if( !QFile::exists(logPath) || !m_pFile_upLoad->open(QIODevice::ReadOnly) || m_pFile_upLoad->size() <= 0 )
    {
        //qDebug() << "DebugLog::doUpgrade_LocalLogInfo_To_Server_Once return: " << logPath<< QFile::exists(logPath) << m_pFile_upLoad->size() << __LINE__;
        delete m_pFile_upLoad;
        m_pFile_upLoad = NULL;
        return true; //日志上传失败, 文件不存在
    }
    QString filePaht = m_pFile_upLoad->fileName();
    int lastIndexOf = filePaht.lastIndexOf("/");
    QString fileName = filePaht.mid(lastIndexOf + 1, filePaht.length() - lastIndexOf - 1);

    QString key = QString("appLog/%1/${%2}-${%3}_%4").arg(times.toString("yyyy/MM/dd")) .arg(StudentData::gestance()->m_lessonId) .arg("player").arg(fileName);
    //qDebug() << "LoadInforMation::uploadQuestionImgOSS" << key << paths;

    QEventLoop loop;
    QTimer::singleShot(10000, &loop, SLOT(quit()));
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager(this);
    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    QFile *m_imageFiles = new QFile(paths);
    if( !m_imageFiles->open(QIODevice::ReadOnly) )
    {
        return "" ;
    }
    QString text = QString("text/text");
    QStringList pathlist = paths.split(".");

    if(pathlist.count() >= 2)
    {
        if(pathlist[1] == "txt")
        {
            text = QString("text/txt");;
        }
        else
        {
            text = QString("text/%1").arg( pathlist[1]);
        }
    }


    QVariantMap maps;
    maps.insert("key", key);
    maps.insert("token", YMUserBaseInformation::token); //"6d499b20858b00790af7b7dd0a3a5fd7"
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    QString urls =  YMCrypt::signMapSort(maps);

    QString sign = YMCrypt::md5(urls).toUpper();
    urls.append("&sign=").append(sign);//QCryptographicHash::hash(sign.toUtf8() ,QCryptographicHash::Md5).toHex().toUpper());

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart imagePart;
    //qDebug() << "===text===" << text;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(text));

    //在这里指定: 给服务器的文件流, 以及文件流的参数: "file"
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"file\""));

    imagePart.setBodyDevice(m_imageFiles);
    m_imageFiles->setParent(multiPart);
    multiPart->append(imagePart);
    QString http = m_httpClient->getRunUrl(0);
    QString httpsd = "http://" + http + "/api/lesson/upload/image?" + QString("%1").arg(urls);
    QUrl url(httpsd);
    QNetworkRequest request(url);
    //qDebug() << "===========loadinformation::url============" << url;
    QNetworkReply *imageReply = httpAccessmanger->post(request, multiPart);

    loop.exec();
    m_pFile_upLoad->close();
    m_imageFiles->close();
    QByteArray replyData = imageReply->readAll();
    QJsonObject dataObject = QJsonDocument::fromJson(replyData).object();
    qDebug() << "=======loadinFormation===========" << replyData.length() << dataObject;

    if(dataObject.value("result").toString().toLower() == "success")
    {
        QString s_url =  dataObject.value("data").toString();
        QFile::remove(logPath); //上传成功以后, 删除本地文件
        return s_url;
    }
    else
    {
        qDebug() << "LoadInforMation::uploadQuestionImgOSS failed" << dataObject;
        return "";
    }
}
#endif
