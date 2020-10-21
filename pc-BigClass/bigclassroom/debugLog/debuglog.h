#ifndef DEBUGLOG_H
#define DEBUGLOG_H

#include <QObject>
#include <QMutex>
#include <QMutexLocker>
#include <QString>
#include <QFile>
#include <QTextStream>
#include <QThread>
#include "YMHttpClientUtils.h"

#include "../../classroom-sdk/sdk/inc/controlcenter/datamodel.h"

class UploadLogThread : public QThread
{
private:
    QString m_strFileFulPath;
    QString m_strHttpUrl;

public:
    void setLogFileName(QString strFileName);
    QString getLogFileName();

    void setHttpUrl(QString strHttpUrl);
    QString getHttpUrl();


protected:
    void run();
};

//功能: 给项目写日志文件, 记录当前qt项目, 执行的过程, 问题发生的点
class DebugLog : public QThread
{
    Q_OBJECT

private:
    explicit DebugLog(QObject *parent = 0);
    UploadLogThread *pClsUploadLogThread;

public:
    static DebugLog* GetInstance();

    std::string UrlCode(std::string &SRC);

    //兼容旧版本
    static DebugLog* gestance();

    ~DebugLog();

    //设置SQLite文件所在目录，注意字母的大小写
    void init_log(QString strAppFileName = "");

    void doCloseLog();
    void AddLog(QString strLog);
    void log(QString message); //兼容旧版本

    //不打印到qt控制台, 比如: 包含字符串"heartBeat"的行, 区分大小写
    static bool doNotPrintOnQtConsole(const QString &msg);

    //不输出到日志文件, 比如: 包含字符串"trail"的行, 区分大小写
    static bool doNotPrintInLogFile(const QString &msg);

    static void LogMsgOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg);

    bool doUpgrade_LocalLogInfo_To_Server_Once(); //将本地日志文件, 上传到服务器, 仅上传一次日志文件, 到服务器, 如果上传失败了, 再上传一次
    bool doUpgrade_LocalLogInfo_To_Server(); //控制: 如果第一次上传失败, 那就再上传一次日志，到服务器

    //得到当前操作系统的目录文件夹
    static QString getDocumentDir();

private:
    static DebugLog * _instance;
    QFile *m_pFile; //写本地日志文件的对象

    static QTextStream *m_pStream;

    static QMutex mutex_log;
    YMHttpClientUtils * m_httpClient; //日志上传的时候, 需要动态指定接口的域名
    QString m_httpUrl;
    QString m_strFileFulPath;
};

#endif // DEBUGLOG_H
