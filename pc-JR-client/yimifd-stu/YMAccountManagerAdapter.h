#ifndef YMACCOUNTMANAGERADAPTER_H
#define YMACCOUNTMANAGERADAPTER_H

#include <QObject>
#include "YMHttpClient.h"
#include "YMAccountManager.h"
#include<QNetworkReply>
#include<QNetworkAccessManager>
#include<QProcess>
#include<QCoreApplication>
#include <QTimer>
#include "../../pc-common/qosV2Manager/YMQosManager.h"

class YMAccountManagerAdapter : public QObject
{
        Q_OBJECT
    public:
        YMAccountManagerAdapter(QObject *parent = 0);
        ~YMAccountManagerAdapter();

        Q_INVOKABLE void login(QString username, QString password);
        Q_INVOKABLE void saveUserInfo(QString userName, QString password, int RememberPwd, int autoLogin, int stu, int parentRenindHasBeShowed, int isFirstAskForLeave);
        Q_INVOKABLE void updatePassword(QString oldPwd, QString newPwd);
        Q_INVOKABLE void updateFirmware(bool status);
        Q_INVOKABLE void updateLatLng(QString lng, QString lat); //修改经纬度
        Q_INVOKABLE QJsonArray getUserLoginInfo();//获取当前被保存的user设置信息 用于在切换用户时 获取已经被保存的信息

        //申请请假函数 课程 id 原因  默认来源为PC
        Q_INVOKABLE int insertLeave(QString lessonId, QString reason);
        //获取请假次数
        Q_INVOKABLE QJsonObject getLeaveLastCount();
        //获取userId
        Q_INVOKABLE QString getUserId();

        Q_INVOKABLE int getValuationResult();

        //更新程序下载
        Q_INVOKABLE void downLoadUpdateExe(QString url);

        Q_INVOKABLE void doUplaodLogFile(); //上传本地日志, 到服务器

        //上报切换用户类型事件
        Q_INVOKABLE void upLoadChangeRoleEvent(QString roleText);

        Q_INVOKABLE QString getCurrentStage();

    private:
        YMAccountManager * m_accountMgr;

        //更新
        QNetworkAccessManager  * m_networkAccessManager;
        QNetworkReply *m_reply;
        QString m_UserId;
        QString m_Password;
        //QTimer *m_timer;

    signals:
        void loginStateChanged(bool loginState);
        void loginSucceed(QString message);
        void loginFailed(QString message);
        void teacherInfoChanged(QJsonObject teacherInfo);
        void linkManInfo(QJsonObject linkManData);
        void updatePasswordChanged();
        void setDownValue(int min, int max); //更新 下载进度
        void sigTokenFail();
    public slots:
        void onhttpReadyRead();
        void onhttpFinished();
        void onUpdateDataReadProgress(qint64 bytesRead, qint64 totalBytes) ;
        //检测账号密码是否改过
        void getUserLoginStatus();
        void findToken();//失效token操作

        void onLoginSucceed(QString message);

};

#endif // YMACCOUNTMANAGERADAPTER_H
