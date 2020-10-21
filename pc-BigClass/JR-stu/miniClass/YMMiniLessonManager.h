#ifndef YMMINILESSONMANAGER_H
#define YMMINILESSONMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "YMHttpClient.h"
#include <QSsl>
#include <QSslSocket>
#include <openssl/des.h>
#include "ymcrypt.h"
#include <QDataStream>
#include <QTextStream>
#include <QProcess>
#include<QFile>
#include<QDir>
#include<QMessageBox>
#include<QStandardPaths>
#include<QCoreApplication>
#include<QSettings>
#include <QTimer>

class YMMiniLessonManager
        : public QObject
        , public YMHttpResponseHandler
{
    Q_OBJECT
public:
    YMMiniLessonManager(QObject *parent = 0);
    ~YMMiniLessonManager();

    Q_INVOKABLE void getMiniLessonList(QString page,QString pageSize);
    Q_INVOKABLE void getMiniLessonItemInfo(QString lessonId);

    Q_INVOKABLE void getMiniLessonMyLesson(QString page,QString pageSize);
    //type 0 为课表 1为作业
    Q_INVOKABLE QJsonObject getMiniLessonMyLessonItemInfo(QString planId,QString type);//

    Q_INVOKABLE QJsonObject getEnterClass(QString planId, QString handleStatus );//拓课云进入教室
    Q_INVOKABLE QJsonObject getEnterClass(QString executionPlanId);//自研进入教室
    Q_INVOKABLE QJsonObject getTalkEnterClass(QString executionPlanId,QString handelStatus);


    Q_INVOKABLE void getLookCourse(QString executionPlanId);

    Q_INVOKABLE QString getH5Url(QString executionPlanId,QString handleStatus,QString className,QString title);

    Q_INVOKABLE QJsonObject getPlayBack(QString executionPlanId);
    //设置开课时间
    Q_INVOKABLE void setQosStartTime(qlonglong startTime,qlonglong endTime);

public slots:
    void enterClassTimerOut();
    //获取上课通知 type 0教室 1作业  返回"handleStatus": "int,操作状态 1：进入教师 12：去考试 20：开始作答 "
    void getEnterClassTips();

    QJsonObject getDoHomeWorkTips(QString classId);

    //    QString getRunUrl();

private:

    //获取进入教室的ip
    void getCloudServer();

    //拼接进入教室数据
    void enterClass();



    QString des_decrypt(const std::string &cipherText);
    QString des_encrypt(const QString &clearText);
    QList<QString> decrypt(QString source);
    void encrypt(QString source, QString target); //加密函数

public:
    QTimer *m_timer;
    QTimer *tipsTimer;
protected:
    virtual void onResponse(int reqCode, const QString &data);

private:
    YMHttpClient * m_httpClint;
    QJsonObject m_classData;
    QString m_domain;
    QString m_ipAddress;
    QString m_tcpPort, m_udpPort,m_httpPort;
    QString m_startTime,m_endTime;
    QString m_lessonId;

    typedef void (YMMiniLessonManager::* HttpRespHandler)(const QString& data);
    QMap<int, HttpRespHandler> m_respHandlers;
    void downloadMiniPlayFile(QJsonArray dataArray);
    void writeFile(QString liveroomId,QString path,int fileNumber,QString suffix);

signals:
    void studentLessonInfoChanged(QJsonObject lessonInfo);
    void studentLesonListInfoChanged(QJsonObject lessonInfo);

    void myMiniLessonInfoChanged(QJsonObject lessonInfo);
    void myMiniLessonItemInfoChanged(QJsonObject lessonInfo,int type);

    void enterClassTips(QJsonObject tipsData);

    void lessonlistRenewSignal();
    void setDownValue(int min, int max);
    void downloadChanged(int currentValue);
    void downloadFinished();
    void lodingFinished();//加载数据完成
    void requestTimerOut();
    void showEnterRoomStatusTips(QString statusText);
    void sigJoinClassroom(QString status);
    void hideEnterClassRoomItem();
    void sigPlayBackData(QJsonObject playData);
    void sigJoinroomfail();
};

#endif // YMMINILESSONMANAGER_H
