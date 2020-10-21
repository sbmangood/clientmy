#ifndef YMACCOUNTMANAGERADAPTER_H
#define YMACCOUNTMANAGERADAPTER_H

#include <QObject>
#include "YMAccountManager.h"
#include<QNetworkReply>
#include<QNetworkAccessManager>
#include<QProcess>
#include<QCoreApplication>
#include<QTimer>
class YMAccountManagerAdapter : public QObject
{
        Q_OBJECT
    public:
        YMAccountManagerAdapter(QObject *parent = 0);
        ~YMAccountManagerAdapter();

        Q_INVOKABLE void login(QString username, QString password);
        Q_INVOKABLE void saveUserInfo(QString userName, QString password, int RememberPwd, int autoLogin);
        Q_INVOKABLE void getUserLoginInfo();
        Q_INVOKABLE void getLatestVersion();
        Q_INVOKABLE void updateLatLng(QString lat, QString lng);
        Q_PROPERTY(bool updateFirmware READ getUpdateFirmware WRITE setUpdateFirmware)

        Q_INVOKABLE void doUplaodLogFile(); //上传本地日志, 到服务器

        //更新程序下载
        Q_INVOKABLE void downLoadUpdateExe(QString url);

        Q_INVOKABLE QString getCurrentStage();

    public:
        bool getUpdateFirmware();
        void setUpdateFirmware(bool firmwareStatus);

    private:
        YMAccountManager * m_accountMgr;
        bool m_updateStatus;//软件更新状态

        //更新
        QNetworkAccessManager  * m_networkAccessManager;
        QNetworkReply *m_reply;

        QString  m_UserId, m_Password;
        //QTimer * m_timer;
    signals:
        void loginStateChanged(bool loginState);
        void loginSucceed(QString message);
        void loginFailed(QString message);
        void teacherInfoChanged(QJsonObject teacherInfo);
        void userInfoChanged(QJsonArray userInfo);
        void updateSoftWareChanged(int isForce);

        void setDownValue(int min, int max); //更新 下载进度


        void  sigTokenFail();
    public slots:
        void onhttpReadyRead();
        void onhttpFinished();
        void onUpdateDataReadProgress(qint64 bytesRead, qint64 totalBytes) ;

        void findToken();
        void getUserLoginStatus();

        void onLoginSucceed(QString message);

};

#endif // YMACCOUNTMANAGERADAPTER_H
