#ifndef DEBUGLOG_H
#define DEBUGLOG_H

#include <QObject>
#include <QMutex>
#include <QMutexLocker>
#include <QString>
#include <QFile>
#include <QTextStream>
#include "YMHttpClient.h"
#include "ymcrypt.h"

//功能: 给项目写日志文件, 记录当前qt项目, 执行的过程, 问题发生的点
class DebugLog : public QObject
{
        Q_OBJECT
    private:
        explicit DebugLog(QObject *parent = 0);

    public:
        static DebugLog* GetInstance()
        {
            if(NULL == _instance)
            {
                QMutexLocker locker(&mutex_log);
                if (NULL == _instance)
                {
                    _instance = new DebugLog;
                }
            }

            return _instance;
        }

        //兼容旧版本
        static DebugLog* gestance()
        {
            return GetInstance();
        }

        ~DebugLog();

        //设置SQLite文件所在目录，注意字母的大小写
        void init_log(QString strAppFileName = "");

        void doCloseLog();
        void AddLog(QString strLog);
        void log(QString message); //兼容旧版本
        static void LogMsgOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg);

        bool doUpgrade_LocalLogInfo_To_Server_Once(QString strFileFulPath); //将本地日志文件, 上传到服务器, 仅上传一次日志文件, 到服务器, 如果上传失败了, 再上传一次
        bool doUpgrade_LocalLogInfo_To_Server(); //控制: 如果第一次上传失败, 那就再上传一次日志，到服务器
#ifdef USE_OSS_UPLOAD_LOG
        QString uploadLog_To_OSS(QString logPath);//将日志上传至OSS
        bool saveLogUrl(QString logUrl);//上传日志路径
#endif
    signals:

    public slots:

    private:
        static DebugLog * _instance;
        QFile *m_pFile; //写本地日志文件的对象
        QFile *m_pFile_upLoad; //日志上传到服务器上的对象
        static QTextStream *m_pStream;

        static QMutex mutex_log;
        YMHttpClient * m_httpClient; //日志上传的时候, 需要动态指定接口的域名
};

#endif // LOGWRITER_H
