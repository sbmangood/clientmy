#ifndef YMACCOUNTMANAGER_H
#define YMACCOUNTMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QIODevice>
#include "YMHttpClient.h"

#include<QFile>
#include<QDir>
#include<QStandardPaths>
#include<QCoreApplication>
#include <QProcess>

class YMAccountManager
    : public QObject
    , public YMHttpResponseHandler
{
        Q_OBJECT
    public:
        explicit YMAccountManager(QObject * parent = 0);
        ~YMAccountManager();

        static YMAccountManager * getInstance();

        void login(QString username, QString password);
        void saveUserInfo(QString userName, QString password, int RememberPwd, int autoLogin, int stu, int parentRenindHasBeShowed, int isFirstAskForLeave);
        void updatePassword(QString oldPwd, QString newPwd);
        void updateFirmware(bool status);
        void getLatestVersion();
        void getLocation();
        void findLogin(QString username, QString password);
        //申请请假函数 课程 id 原因  默认来源为PC 请假成功返回 1  失败返回 0
        QVariant insertLeave(QString lessonId, QString reason);
        //查询剩余请假次数 返回剩余请假次数
        QJsonObject getLeaveLastCount();

        QJsonArray getUserLoginInfo();

        QVariant getValuationResult();//QS测评

        QString getDownLoadUrl();//获取更新包下载地址
    protected:
        virtual void onResponse(int reqCode, const QString &data);

    private:
        void getLinkMan();
        QProcess *process;

    signals:
        void loginStateChanged(bool loginState);
        void loginSucceed(QString message);
        void loginFailed(QString message);
        void teacherInfoChanged(QJsonObject teacherInfo);
        void linkManInfo(QJsonObject linkManData);
        void updatePasswordChanged();
        void sigTokenFail();//登录失败信号

    private:
        YMHttpClient * m_httpClient;
        static YMAccountManager * m_instance;
        QString m_username;
        QString m_phone;
        QString m_token;

    public:
        QJsonObject m_version;
        QJsonObject m_firmware;

        typedef void (YMAccountManager::* HttpRespHandler)(const QString& data);
        QMap<int, HttpRespHandler> m_respHandlers;
};

#endif // YMACCOUNTMANAGER_H
