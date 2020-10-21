#include <QDateTime>
#include <qdebug>
#include <iostream>
#include <QTextCodec>
#include <QEventLoop>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QHttpMultiPart>
#include <QNetworkReply>
#include <QSettings>
#include "debuglog.h"

using namespace  std;

DebugLog * DebugLog::_instance = NULL;
QTextStream * DebugLog::m_pStream = NULL;
QMutex DebugLog::mutex_log;

DebugLog::DebugLog(QObject *parent)
{
    m_pStream = NULL;
    m_pFile = NULL;
    pClsUploadLogThread = new UploadLogThread();
    m_httpClient = YMHttpClientUtils::getInstance();
    m_httpUrl = m_httpClient->getRunUrl(1);
}

DebugLog::~DebugLog()
{
    doCloseLog();
}

DebugLog* DebugLog::GetInstance()
{
    if(NULL == _instance)
    {
        QMutexLocker locker(&mutex_log);
        if (NULL == _instance)
        {
            _instance = new DebugLog();
        }
    }
    return _instance;
}

//兼容旧版本
DebugLog* DebugLog::gestance()
{
    return GetInstance();
}

std::string DebugLog::UrlCode(std::string &SRC)
{
        std::string ret;
        char ch;
        int ii;
        for (size_t i=0; i<SRC.length(); i++) {
            if (int(SRC[i])==37) {
                sscanf(SRC.substr(i+1,2).c_str(), "%x", &ii);
                ch=static_cast<char>(ii);
                ret+=ch;
                i=i+2;
            } else {
                ret+=SRC[i];
            }
        }
        return (ret);
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
    //qDebug() << "33333333333" << qPrintable(strAppFileName);
    QString strAppName = strAppFileName.mid(0, i);

    QString strLogFile = QString("%1_%2.log") .arg(strAppName) .arg(strCurrentTime);

    //得到dll文件的绝对路径
    QString strAppFullPath = StudentData::gestance()->strAppFullPath;
    strLogFile = strAppFullPath.replace(StudentData::gestance()->strAppName, strLogFile); //得到日志文件的绝对路径
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

// 兼容旧版本
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

    (*m_pStream) << strCurrentTime.toStdString().c_str() << "\t" << strLog.toStdString().c_str() << endl;
    m_pStream->flush();
}

//不打印到qt控制台, 比如: 包含字符串"heartBeat"的行, 区分大小写
bool DebugLog::doNotPrintOnQtConsole(const QString &msg)
{
    if(msg.contains("heartBeat", Qt::CaseSensitive)) //区分大小写
    {
        return true;
    }

    return false;
}

//不输出到日志文件, 比如: 包含字符串"trail"的行, 区分大小写
bool DebugLog::doNotPrintInLogFile(const QString &msg)
{
    if(msg.contains("trail", Qt::CaseSensitive)) //区分大小写
    {
        return true;
    }

    return false;
}


//将qDebug显示的日志, 写入到日志文件中
void DebugLog::LogMsgOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    if(msg.trimmed().isEmpty())
    {
        return;
    }

    //不需要打印到控制台的行
    if(doNotPrintOnQtConsole(msg))
    {
        return;
    }

    QMutexLocker locker(&mutex_log);
    cout << msg.toLocal8Bit().data() << endl;

    //不需要写入到日志文件中
    if(doNotPrintInLogFile(msg))
    {
        return;
    }

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
        //log.append(QString("Warning: %1  %2  %3  %4").arg(localMsg.constData()).arg(context.file).arg(context.line).arg(context.function));
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
        (*m_pStream) << strCurrentTime.toStdString().c_str() << " " << log << endl;
        m_pStream->flush();
    }
}

bool DebugLog::doUpgrade_LocalLogInfo_To_Server()
{
    //宏开关, 没有开启
#ifndef USE_LOG_UPLOAD
    return true;
#endif
    //上传当前工程的日志文件
    m_strFileFulPath = StudentData::gestance()->strAppFullPath_LogFile;

    //上传B通道, 声网的日志文件
    m_strFileFulPath = StudentData::gestance()->strAgoraFullPath_LogFile;

    if(!doUpgrade_LocalLogInfo_To_Server_Once())
    {
        //如果上传一次失败了, 那就再上传一次
        doUpgrade_LocalLogInfo_To_Server_Once();
    }

    return true;
}

QString DebugLog::getDocumentDir()
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString systemPublicFilePath;
    QDir dir;
    if (docPath == "" || !dir.exists(docPath)) //docPath是空, 或者不存在
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }

    return systemPublicFilePath;
}

//将本地的日志文件, 上传到服务器上去
bool DebugLog::doUpgrade_LocalLogInfo_To_Server_Once()
{
    QEventLoop eventLoop;
    connect(pClsUploadLogThread, SIGNAL(finished()), &eventLoop, SLOT(quit())); //线程执行完成以后, 退出loop
    QTimer::singleShot(5000, &eventLoop, SLOT(quit())); //超时5秒以后, 退出loop

    QTimer *timer = new QTimer();
    timer->setInterval(5000);
    connect(timer, &QTimer::timeout, &eventLoop, &QEventLoop::quit);
    timer->start();

    doCloseLog();
    if(NULL != pClsUploadLogThread)
    {
        pClsUploadLogThread->setLogFileName(m_strFileFulPath);
        pClsUploadLogThread->setHttpUrl(m_httpUrl);
        pClsUploadLogThread->start();
    }

    eventLoop.exec();
    if(NULL != pClsUploadLogThread)
    {
        pClsUploadLogThread->quit(); //如果超时了, 则结束线程
    }
    //pClsUploadLogThread->terminate(); //如果超时了, 则结束线程

    return true; //每次都上传两次, 第二次会因为第一次上传成功以后, 删除了文件, 所以第二次上传的时候, 会直接return
}

void UploadLogThread::setLogFileName(QString strFileName)
{
    m_strFileFulPath = strFileName;
}

QString UploadLogThread::getLogFileName()
{
    return m_strFileFulPath;
}

void UploadLogThread::setHttpUrl(QString strHttpUrl)
{
    m_strHttpUrl = strHttpUrl;
}

QString UploadLogThread::getHttpUrl()
{
    return m_strHttpUrl;
}

void UploadLogThread::run()
{
    QString strFileFulPath = getLogFileName();
    QString paths = QUrl::fromPercentEncoding(strFileFulPath.toUtf8());
    QFile *pFile_upLoad = new QFile(paths);
    if(!QFile::exists(strFileFulPath) || !pFile_upLoad->open(QIODevice::ReadOnly) || pFile_upLoad->size() <= 0 )
    {
        //qDebug() << "DebugLog::doUpgrade_LocalLogInfo_To_Server_Once return: " << qPrintable(strFileFulPath) << QFile::exists(strFileFulPath) << pFile_upLoad->size() << __LINE__;
        delete pFile_upLoad;
        pFile_upLoad = NULL;
        return; //日志上传失败, 文件不存在
    }

    //设置: 完成日志上传以后, 或者超时, 则退出
    QEventLoop loop;
    QTimer *timer = new QTimer();
    timer->setInterval(5000); //超过5秒, 还没有上传完日志, 也退出
    connect(timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager(/*this*/);
    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    maps.insert("lessonId", StudentData::gestance()->m_lessonId + "_" + StudentData::gestance()->m_userName);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);

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
    imagePart.setBodyDevice(pFile_upLoad);
    pFile_upLoad->setParent(multiPart);
    multiPart->append(imagePart);

    QString httpsd = "http://" + getHttpUrl() + "/log/logUpload?" + QString("%1").arg(urls);

    QUrl url(httpsd);
    QNetworkRequest request(url);
    QNetworkReply *imageReply = httpAccessmanger->post(request, multiPart);
    connect(imageReply, SIGNAL(finished()), &loop, SLOT(quit()));
    connect(imageReply, SIGNAL(error(QNetworkReply::NetworkError)), &loop, SLOT(quit()));

    timer->start();
    loop.exec(); //退出程序的时候, 有的时候, 程序卡死, 是卡死在这里

    QByteArray replyData = imageReply->readAll();
    QJsonObject dataObject = QJsonDocument::fromJson(replyData).object();
    //qDebug() << "DebugLog::doUpgrade_LocalLogInfo_To_Server_Once dataObject: " << dataObject << StudentData::gestance()->m_userName << qPrintable(httpsd) << url << replyData.length() << __LINE__;

    if(NULL != imageReply)
    {
        imageReply->deleteLater();
        imageReply->close();
        delete imageReply;
        imageReply = NULL;
    }

    if(NULL != pFile_upLoad)
    {
        pFile_upLoad->close();
    }

    if(NULL != multiPart)
    {
        delete multiPart;
        multiPart = NULL;
    }

    if(NULL != httpAccessmanger)
    {
        delete httpAccessmanger;
        httpAccessmanger = NULL;
    }

    if(NULL != timer)
    {
        timer->stop();
        delete timer; timer = NULL;
    }

    if(dataObject.value("result").toString().toLower() == "success")
    {
        //QFile::remove(strFileFulPath); //上传成功以后, 删除本地文件
        return; //日志上传成功
    }
    else
    {
        qDebug() << "DebugLog::doUpgrade_LocalLogInfo_To_Server_Once dataObject: " << dataObject << __LINE__;
    }
    if(NULL != httpAccessmanger)
    {
        delete httpAccessmanger;
        httpAccessmanger = NULL;
    }

    //日志上传失败
    return;
}
