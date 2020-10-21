#include "YMAccountManagerAdapter.h"
#include "YMUserBaseInformation.h"

YMAccountManagerAdapter::YMAccountManagerAdapter(QObject *parent) : QObject(parent)
{
    m_accountMgr = YMAccountManager::getInstance();
    connect(m_accountMgr, SIGNAL(teacherInfoChanged(QJsonObject)), this, SIGNAL(teacherInfoChanged(QJsonObject)));
    connect(m_accountMgr, SIGNAL(loginFailed(QString)), this, SIGNAL(loginFailed(QString)));
    connect(m_accountMgr, SIGNAL(loginSucceed(QString)), this, SLOT(onLoginSucceed(QString)));
    connect(m_accountMgr, SIGNAL(loginStateChanged(bool)), this, SIGNAL(loginStateChanged(bool)));
    connect(m_accountMgr, SIGNAL(sigTokenFail()), this, SLOT(findToken()));
    connect(m_accountMgr,SIGNAL(sigTalkLoginInfo(QJsonObject)),this,SIGNAL(sigTalkLoginInfo(QJsonObject)));
    connect(m_accountMgr,SIGNAL(sigTalkTeacherInfo(QJsonObject)),this,SIGNAL(sigTalkTeacherInfo(QJsonObject)));
}
void YMAccountManagerAdapter::findToken()
{
    emit sigTokenFail();
}
void YMAccountManagerAdapter::onLoginSucceed(QString message)
{
    emit loginSucceed(message);
}
void YMAccountManagerAdapter::getUserLoginStatus()
{
    m_accountMgr->findLogin(m_UserId, m_Password);
}

void YMAccountManagerAdapter::doUplaodLogFile()
{

}

void YMAccountManagerAdapter::login(QString username, QString password)
{
    m_UserId = username;
    m_Password = password;
    m_accountMgr->login(username, password);
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
}

void YMAccountManagerAdapter::downLoadUpdateExe(QString url)
{
    QFile::remove(QCoreApplication::applicationDirPath() + "/update.exe");
    m_networkAccessManager = new QNetworkAccessManager(this);
    QUrl urls(url);
    m_reply = m_networkAccessManager->get(QNetworkRequest(urls));
    connect(m_reply, SIGNAL(finished()), this, SLOT( onhttpFinished()));
    connect(m_reply, SIGNAL(readyRead()), this, SLOT( onhttpReadyRead() ));
    connect(m_reply, SIGNAL(downloadProgress(qint64, qint64)),this, SLOT(onUpdateDataReadProgress(qint64, qint64)));
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
}

void YMAccountManagerAdapter::talkUserLogin(QString userName, QString passWork)
{
    m_UserId = userName;
    m_Password = passWork;
    m_accountMgr->talkLogin(userName,passWork);
}

void YMAccountManagerAdapter::talkGetUserInfo()
{
    m_accountMgr->talkGetUserInfo();
}
