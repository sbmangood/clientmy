#include "YMAccountManagerAdapter.h"
#include "YMUserBaseInformation.h"
#include "debuglog.h"

YMAccountManagerAdapter::YMAccountManagerAdapter(QObject *parent)
    : QObject(parent)
{
    m_accountMgr = YMAccountManager::getInstance();
    connect(m_accountMgr, SIGNAL(teacherInfoChanged(QJsonObject)), this, SIGNAL(teacherInfoChanged(QJsonObject)));
    connect(m_accountMgr, SIGNAL(loginFailed(QString)), this, SIGNAL(loginFailed(QString)));
    connect(m_accountMgr, SIGNAL(loginSucceed(QString)), this, SLOT(onLoginSucceed(QString)));
    //connect(m_accountMgr,SIGNAL(userInfoChanged(QJsonArray)),this,SIGNAL(userInfoChanged(QJsonArray)));
    connect(m_accountMgr, SIGNAL(loginStateChanged(bool)), this, SIGNAL(loginStateChanged(bool)));
    //connect(m_accountMgr,SIGNAL(updateSoftWareChanged(int)),this,SIGNAL(updateSoftWareChanged(int)));

    connect(m_accountMgr, SIGNAL(sigTokenFail()), this, SLOT(findToken())); //SIGNAL(sigTokenFail()));
    m_timer = new QTimer();
    m_timer->setInterval(60000);
    connect(m_timer, SIGNAL(timeout()), this, SLOT(getUserLoginStatus()));
}
void YMAccountManagerAdapter::findToken()
{
    m_timer->stop();
    emit sigTokenFail();
}
void YMAccountManagerAdapter::onLoginSucceed(QString message)
{
    m_timer->start();
    emit loginSucceed(message);
}
void YMAccountManagerAdapter::getUserLoginStatus()
{
    m_accountMgr->findLogin(m_UserId, m_Password);
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

    //qDebug() << "YMAccountManagerAdapter::login" << m_UserId << m_Password;
    m_accountMgr->login(m_UserId, m_Password);
    //m_timer->start();
    // m_accountMgr->login(username,password);
}

void YMAccountManagerAdapter::saveUserInfo(QString userName, QString password, int RememberPwd, int autoLogin)
{
    m_accountMgr->saveUserInfo(userName, password, RememberPwd, autoLogin);
}

void YMAccountManagerAdapter::getUserLoginInfo()
{
    m_accountMgr->getUserLoginInfo();
}

void YMAccountManagerAdapter::getLatestVersion()
{
    m_accountMgr->getLatestVersion();
}

bool YMAccountManagerAdapter::getUpdateFirmware()
{
    return m_updateStatus;
}

void YMAccountManagerAdapter::setUpdateFirmware(bool firmwareStatus)
{
    m_updateStatus = firmwareStatus;
    //m_accountMgr->setUpdateFirmware(m_updateStatus);

    if(firmwareStatus)
    {
        downLoadUpdateExe(m_accountMgr->getDownLoadUrl());
    }

}

YMAccountManagerAdapter::~YMAccountManagerAdapter()
{
    disconnect(m_accountMgr, 0, 0, 0);
}

void YMAccountManagerAdapter::updateLatLng(QString lat, QString lng)
{
    YMUserBaseInformation::latitude = lat;
    YMUserBaseInformation::longitude = lng;
    //qDebug() << "YMAccountManagerAdapter::updateLatLng" <<lat << lng;
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
    //qDebug()<<QStringLiteral("下载结束");
    // QFile::rename(QCoreApplication::applicationDirPath() + "/update.zip",QCoreApplication::applicationDirPath() + "/update.exe");
    if(QProcess::startDetached(QCoreApplication::applicationDirPath() + "/update.exe", QStringList()))
    {
        exit(0);
    }
    else
    {
        qDebug() << "YMAccountManagerAdapter::onhttpFinished fail ";
    }
}

void YMAccountManagerAdapter::onUpdateDataReadProgress(qint64 bytesRead, qint64 totalBytes)
{
    setDownValue(bytesRead, totalBytes);
    //  qDebug()<<QStringLiteral("进度更新")<<bytesRead<<totalBytes;
}
