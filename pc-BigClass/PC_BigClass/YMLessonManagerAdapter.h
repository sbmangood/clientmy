#ifndef YMLESSONMANAGERADAPTER_H
#define YMLESSONMANAGERADAPTER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include "YMHttpClient.h"
#include<QSsl>
#include<QSslSocket>
#include <openssl/des.h>
#include "ymcrypt.h"
#include<QDataStream>
#include<QTextStream>
#include<QSettings>
#include <QMutex>

class YMLessonManagerAdapter : public QObject, public YMHttpResponseHandler
{
    Q_OBJECT
public:
    YMLessonManagerAdapter(QObject *parent = 0);
    ~YMLessonManagerAdapter();

    Q_INVOKABLE void getJoinClassRoomInfo(QString envType, QString executionPlanId, QString uId, QString groupId, const QString &classType);
    Q_INVOKABLE void setUserRole(int role);
    Q_INVOKABLE void startPlayer(QString appId,  QString appKey, QString envType, QString liveroomId);
    Q_INVOKABLE bool isDigitStr(QString src);

public slots:
    void getEnterClassresult(QNetworkReply *reply);

private:
    void getCloudServer();
    void enterClass(QString envType, QString executionPlanId, QString uId, QString groupId, const QString &classType);
    void errorLog(QString message);
    QString des_decrypt(const std::string &cipherText);
    QString des_encrypt(const QString &clearText);
    void encrypt(QString source, QString target);
    QList<QString> decrypt(QString source);
    QString lessonType;
    void resetSelectIp(int type, QString ip);
    virtual void onResponse(int reqCode, const QString &data);
    int getUserRole();

private:
    YMHttpClient * m_httpClient;
    typedef void (YMLessonManagerAdapter::* HttpRespHandler)(const QString& data);
    QMap<int, HttpRespHandler> m_respHandlers;
    QMap<int, HttpRespHandler> m_playbackHandlers;
    QJsonObject m_classData;
    QString m_ipAddress;
    QString m_port;
    QString requestData;
    int m_listen;//旁听状态
    bool m_listenOrClass;//监听或者进入教室状态 true 进入教室， false进入旁听
    QTimer *m_timer;
    bool isStop;
    QString m_tcpPort;
    QString m_httpPort;
    QString execPlanId;
    QString m_startTime,m_endTime;
    QString m_lessonId;
    int m_userRole;
    QMutex m_mutex;

signals:
    void lessonlistRenewSignal();
    void programRuned();
    void requstTimeOuted();//请求超时
    void sigJoinClassroomStaus();//进入教室信号
    void sigJoinClassroomFail();//进入教室失败信号
};

#endif // YMLESSONMANAGERADAPTER_H
