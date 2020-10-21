#ifndef YMACCOUNTMANAGER_H
#define YMACCOUNTMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QIODevice>
#include "YMHttpClient.h"

class YMAccountManager
    : public QObject
    , public YMHttpResponseHandler
{
        Q_OBJECT
    public:
        explicit YMAccountManager(QObject * parent = 0);
        ~YMAccountManager();

        void login(const QString &username, QString &password);
        void saveUserInfo(QString userName, QString password, int RememberPwd, int autoLogin);
        QJsonArray getUserLoginInfo();
        void getLatestVersion();
        void getLatLng();//获取经纬度
        void errorLog(QString messge);

        static YMAccountManager * getInstance();

        //获取更新下载的url
        QString getDownLoadUrl();

    public:
        bool getUpdateFirmware();
        void setUpdateFirmware(bool firmwareStatus);

        void findLogin(QString username, QString password);

    protected:
        virtual void onResponse(int reqCode, const QString &data);
        void onRespLogin(const QString& data);

    signals:
        void loginStateChanged(bool loginState);
        void loginSucceed(QString message);
        void loginFailed(QString message);
        void teacherInfoChanged(QJsonObject teacherInfo);
        void updateSoftWareChanged(int isForce);
        void  sigTokenFail();

    private:
        static YMAccountManager * m_instance;

    private:
        YMHttpClient * m_httpClient;
        QString m_username;
        QString m_phone;
        QString m_token;
        QJsonObject m_firmwareData;
        //  QWebView *m_webView;

    public:
        QString m_versinon;
        bool m_updateStatus;
        int m_updateValue;

        typedef void (YMAccountManager::* HttpRespHandler)(const QString& data);
        QMap<int, HttpRespHandler> m_respHandlers;
};

#endif // YMACCOUNTMANAGER_H
