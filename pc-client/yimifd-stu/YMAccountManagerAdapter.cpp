#include "YMAccountManagerAdapter.h"
#include "YMUserBaseInformation.h"
#include <QDebug>
#include "debuglog.h"

YMAccountManagerAdapter::YMAccountManagerAdapter(QObject *parent)
    : QObject(parent)
{
    m_accountMgr = YMAccountManager::getInstance();
    connect(m_accountMgr, SIGNAL(loginStateChanged(bool)), this, SIGNAL(loginStateChanged(bool)));
    connect(m_accountMgr, SIGNAL(loginSucceed(QString)), this, SLOT(onLoginSucceed(QString)));
    connect(m_accountMgr, SIGNAL(loginFailed(QString)), this, SIGNAL(loginFailed(QString)));
    connect(m_accountMgr, SIGNAL(teacherInfoChanged(QJsonObject)), this, SIGNAL(teacherInfoChanged(QJsonObject)));
    connect(m_accountMgr, SIGNAL(linkManInfo(QJsonObject)), this, SIGNAL(linkManInfo(QJsonObject)));
    connect(m_accountMgr, SIGNAL(updatePasswordChanged()), this, SIGNAL(updatePasswordChanged()));
    connect(m_accountMgr, SIGNAL(sigTokenFail()), this, SLOT(findToken())); //SIGNAL(sigTokenFail()));

    m_timer = new QTimer();
    m_timer->setInterval(60000);
    connect(m_timer, SIGNAL(timeout()), this, SLOT(getUserLoginStatus()));
}
void YMAccountManagerAdapter::onLoginSucceed(QString message)
{
    m_timer->start();
    emit loginSucceed(message);
}
int YMAccountManagerAdapter::getValuationResult()
{
    return m_accountMgr->getValuationResult().toInt();
}

void YMAccountManagerAdapter::findToken()
{
    m_timer->stop();
    emit sigTokenFail();
}

void YMAccountManagerAdapter::getUserLoginStatus()
{
    //qDebug() << "YMAccountManagerAdapter::getUserLoginStatus";
    m_accountMgr->findLogin(m_UserId, m_Password);
}

int YMAccountManagerAdapter::insertLeave(QString lessonId, QString reason)
{
    return m_accountMgr->insertLeave(lessonId, reason).toInt();
}

QJsonObject YMAccountManagerAdapter::getLeaveLastCount()
{
    return m_accountMgr->getLeaveLastCount();
}

QString YMAccountManagerAdapter::getUserId()
{
    //qDebug() <<"YMAccountManagerAdapter::getUserId()" << YMUserBaseInformation::sqId;
    return YMUserBaseInformation::sqId;
}


//上传本地日志, 到服务器
void YMAccountManagerAdapter::doUplaodLogFile()
{
    DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server();
}


void YMAccountManagerAdapter::login(QString username, QString password)
{
    m_UserId = username.trimmed();
    m_Password = password.trimmed();
    m_accountMgr->login(m_UserId, m_Password);
    // m_timer->start();
}

void YMAccountManagerAdapter::saveUserInfo(QString userName, QString password, int RememberPwd, int autoLogin, int stu, int parentRenindHasBeShowed, int isFirstAskForLeave)
{
    m_accountMgr->saveUserInfo(userName, password, RememberPwd, autoLogin, stu, parentRenindHasBeShowed, isFirstAskForLeave);
}

void YMAccountManagerAdapter::updatePassword(QString oldPwd, QString newPwd)
{
    m_accountMgr->updatePassword(oldPwd, newPwd);
}

void YMAccountManagerAdapter::updateFirmware(bool status)
{
    //原逻辑启动更新程序 现逻辑在主程序中下载更新的安装包程序 下载完毕后启动安装包程序 完成更新

    // m_accountMgr->updateFirmware(status);

    if(status)
    {
        downLoadUpdateExe(m_accountMgr->getDownLoadUrl());
    }

}

YMAccountManagerAdapter::~YMAccountManagerAdapter()
{
    disconnect(m_accountMgr, 0, 0, 0);
}

QJsonArray YMAccountManagerAdapter::getUserLoginInfo()
{
    return m_accountMgr->getUserLoginInfo();
}

void YMAccountManagerAdapter::updateLatLng(QString lng, QString lat)
{
    //qDebug() <<"YMAccountManagerAdapter::updateLatLng:"<< lng << lat;
    YMUserBaseInformation::geolocation = lng + "," + lat;
}


void YMAccountManagerAdapter::downLoadUpdateExe(QString url)
{
    QFile::remove(QCoreApplication::applicationDirPath() + "/update.exe");
    m_networkAccessManager = new QNetworkAccessManager(this);
    QUrl urls(url);

    m_reply = m_networkAccessManager->get(QNetworkRequest(urls));

    connect(m_reply, SIGNAL(finished()), this, SLOT( onhttpFinished()));
    connect(m_reply, SIGNAL(readyRead()), this, SLOT( onhttpReadyRead() ));
    connect(m_reply, SIGNAL(downloadProgress(qint64, qint64)),
            this, SLOT(onUpdateDataReadProgress(qint64, qint64)));
}
void YMAccountManagerAdapter::onhttpReadyRead()
{
    QFile file(QCoreApplication::applicationDirPath() + "/update.exe");
    if (file.open(QIODevice::Append ))
    {
        file.write(m_reply->readAll());
    }
    file.close();

}

void YMAccountManagerAdapter::onhttpFinished()
{
    qDebug() << QStringLiteral("下载结束");
    // QFile::rename(QCoreApplication::applicationDirPath() + "/update.zip",QCoreApplication::applicationDirPath() + "/update.exe");
    if(QProcess::startDetached(QCoreApplication::applicationDirPath() + "/update.exe", QStringList()))
    {
        exit(0);
    }
    else
    {
        qDebug() << "start fail ";
    }

}

void YMAccountManagerAdapter::onUpdateDataReadProgress(qint64 bytesRead, qint64 totalBytes)
{
    setDownValue(bytesRead, totalBytes);
    //  qDebug()<<QStringLiteral("进度更新")<<bytesRead<<totalBytes;
}

void YMAccountManagerAdapter::upLoadChangeRoleEvent(QString roleText)
{
    QJsonObject msgData;
    msgData.insert("switchRole",roleText.contains(QStringLiteral("家长")) ? QStringLiteral("切换至家长") : QStringLiteral("切换至学生"));
    YMQosManager::gestance()->addBePushedMsg("switchIdentity",msgData);
}
