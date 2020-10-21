#include <QJsonDocument>
#include <QDir>
#include <QTextStream>
#include <QDesktopServices>
#include <QProcess>
#include <QSettings>
#include <QCoreApplication>
#include "YMUserBaseInformation.h"
#include "YMAccountManager.h"
#include "YMEncryption.h"

YMAccountManager * YMAccountManager::m_instance = nullptr;

YMAccountManager::YMAccountManager(QObject * parent) : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    m_updateStatus = false;
    m_versinon = YMUserBaseInformation::appVersion;
    QSettings reg("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\",QSettings::NativeFormat);
    reg.beginGroup("BIOS");
    QString deviceInfo = reg.value("SystemManufacturer").toString().remove("#").append("|").append(reg.value("SystemSKU").toString().remove("#"));
    deviceInfo.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
    YMUserBaseInformation::deviceInfo =QString::fromUtf8(deviceInfo.toUtf8());
}

YMAccountManager *YMAccountManager::getInstance()
{
    if(m_instance == nullptr){
        m_instance = new YMAccountManager();
    }
    return m_instance;
}

YMAccountManager::~YMAccountManager()
{
    disconnect(m_httpClient,0,0,0);
}

void YMAccountManager::getLatLng()
{
    QVariantMap reqParam;
    QString key = "dff3ddc8832cc8d802ef019276f5de01";
    reqParam.insert("key",key);

    QString sign = YMEncryption::signMapSort(reqParam);
    QString md5 =  YMEncryption::md5(sign + "000a7e3483677c2209f900fbfdb1694d");
    reqParam.insert("sig",md5);
    QString url = "http://restapi.amap.com/v3/ip?" + sign +"&sig=" + md5;

    QByteArray dataArray = m_httpClient->httpGetIp(url);
    if(dataArray.length() == 0)
    {
        return;
    }

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(dataArray,&error);
    if(error.error != QJsonParseError::NoError){
        return;
    }
    QJsonObject obj = doc.object();
    QString rectangle= obj.value("rectangle").toString();
    if(rectangle == ""){
        return;
    }

    QStringList listLocation = rectangle.split(';');
    if(listLocation.size() == 0){
        return;
    }
    QString  location1= listLocation.at(0);
    QString  location2= listLocation.at(1);

    QStringList locationSplit1 = location1.split(",");
    QStringList locationSplit2 = location2.split(",");
    QString location_lng1 = locationSplit1.at(0);
    QString location_lng2 = locationSplit2.at(0);
    double lng = location_lng2.toDouble() - location_lng1.toDouble();

    QString location_lat1 = locationSplit1.at(1);
    QString location_lat2 = locationSplit2.at(1);
    double lat = location_lat2.toDouble() - location_lat1.toDouble();
    YMUserBaseInformation::longitude = QString::number(location_lng2.toDouble() - lng * 0.5,10,4);
    YMUserBaseInformation::latitude = QString::number( location_lat2.toDouble() - lat * 0.5,10,4);
}

void YMAccountManager::login(QString username, QString password)
{
    QVariantMap reqParam;
    reqParam.insert("loginName",username);
    reqParam.insert("md5Pwd",YMEncryption::md5(password));
    reqParam.insert("appVersion",YMUserBaseInformation::appVersion);//获取程序版本号
    reqParam.insert("sysInfo","WIN");
    reqParam.insert("deviceInfo","1");
    reqParam.insert("umengAppKey","1");
    reqParam.insert("appSource","YIMI");
    reqParam.insert("type","tea");
    QByteArray byteArray = m_httpClient->httpPostForm(m_httpClient->httpUrl + "/tea/user/login",reqParam);
    QJsonObject dataObject = QJsonDocument::fromJson(byteArray).object();
    if(dataObject.contains("result")
            && dataObject.value("result").toString() == "success"){
        YMUserBaseInformation::token = dataObject.value("token").toString();
        QJsonObject teacherObj = dataObject.value("data").toObject();
        YMUserBaseInformation::realName = teacherObj.value("realName").toString();
        YMUserBaseInformation::nickName = teacherObj.value("nickName").toString();
        YMUserBaseInformation::headPicture = teacherObj.value("headPicture").toString();
        YMUserBaseInformation::MD5Pwd = teacherObj.value("password").toString();
        YMUserBaseInformation::mobileNo = teacherObj.value("mobileNo").toString();
        YMUserBaseInformation::userName = username;
        YMUserBaseInformation::logTime = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
        int id = teacherObj.value("id").toInt();
        YMUserBaseInformation::id = QString::number(id);
        QJsonObject teacherObject;
        teacherObject.insert("userId",YMUserBaseInformation::id);
        teacherObject.insert("realName",YMUserBaseInformation::realName == "" ? YMUserBaseInformation::nickName : YMUserBaseInformation::realName);
        teacherObject.insert("headPicture",YMUserBaseInformation::headPicture);
        teacherObject.insert("appVersion",YMUserBaseInformation::appVersion);
        emit teacherInfoChanged(teacherObject);
        emit loginSucceed("登录成功!");

    }else{
        QString message = "用户名或者密码错误";
        if(dataObject.contains("message")){
            message = dataObject.value("message").toString();
        }
        emit loginFailed(message);
    }
}

void YMAccountManager::onRespLogin(const QString & data)
{

}

void YMAccountManager::onResponse(int reqCode, const QString &data)
{
    if (m_respHandlers.contains(reqCode)){
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        m_respHandlers.remove(reqCode);
    }
}

QJsonArray YMAccountManager::getUserLoginInfo()
{
    QString bufferFilePath = QCoreApplication::applicationDirPath();
    QString readFilePath  = bufferFilePath + "/teaInfo.dll";
    QFile file(readFilePath);
    QJsonArray userArray;
    if(file.open(QIODevice::ReadOnly | QIODevice::Text)){
        QTextStream read(&file);
        QString lineStr;

        while (!read.atEnd()) {
            lineStr = read.readLine();
            userArray.append(lineStr);
        }
    }
    file.close();
    return userArray;
}

void YMAccountManager::saveUserInfo(QString userName, QString password, int RememberPwd, int autoLogin)
{
    QString bufferFilePath = QCoreApplication::applicationDirPath();
    QDir dir(bufferFilePath);
    if(!dir.exists()){
        dir.mkdir(bufferFilePath);
    }
    QString saveFilePath = bufferFilePath + "/teaInfo.dll";
    QFile file(saveFilePath);
    file.close();
    if(file.open(QFile::ReadWrite)){
        QTextStream textOut(&file);
        textOut << userName + "\r\n"  << password + "\r\n"
                << QString::number(RememberPwd) + "\r\n" << QString::number(autoLogin) + "\r\n";
        textOut.flush();
    }
    file.close();
}

void YMAccountManager::getLatestVersion()
{
    QVariantMap reqParam;
    reqParam.insert("appName","tea_pc");
    reqParam.insert("versionName",YMUserBaseInformation::appVersion);
    reqParam.insert("versionCode",YMUserBaseInformation::versionCode);
    reqParam.insert("apiVersion",YMUserBaseInformation::apiVersion);
    QString url = m_httpClient->httpUrl + "/version/getLatestVersion";

    QByteArray byteArray = m_httpClient->httpPostForm(url,reqParam);
    QJsonObject dataObject = QJsonDocument::fromJson(byteArray).object();

    qDebug() << "getLatestVersion:" << dataObject;

    if(dataObject.value("message").toString() == "SUCCESS"
            && dataObject.value("result").toString() == "success"){
        m_updateStatus = true;
        m_firmwareData = dataObject.value("data").toObject();
        int versionCode = m_firmwareData.value("versionCode").toInt();
        if(versionCode > YMUserBaseInformation::versionCode.toInt()){
            int isForce = m_firmwareData.value("isForce").toInt();
            m_updateValue = isForce;
            return;
        }
    }
    m_updateStatus = false;
    m_updateValue= -1;
    //updateSoftWareChanged(-1);
}

//获取更新状态
bool YMAccountManager::getUpdateFirmware()
{
    return m_updateStatus;
}

//设置更新状态
void YMAccountManager::setUpdateFirmware(bool firmwareStatus)
{
    m_updateStatus = firmwareStatus;
    if(m_updateStatus)
    {
        QStringList urlList;
        urlList << m_firmwareData.value("updateUrl").toString();
        urlList << "TEA";
        urlList << YMUserBaseInformation::appVersion;
        QProcess process;

        if(process.startDetached("update/update.exe",urlList))
        {
            exit(0);
        }else {

        }
    }
}

QString YMAccountManager::getDownLoadUrl()
{
    return m_firmwareData.value("updateUrl").toString();
}


void YMAccountManager::findLogin(QString username, QString password)
{
    QVariantMap reqParam;
    reqParam.insert("loginName",username);
    reqParam.insert("userPwd",password);
    reqParam.insert("loginType",1);
    reqParam.insert("systemType",2);
    reqParam.insert("needIdentifyCode",0);
    QString url = YMUserBaseInformation::m_minClassUrl + "/auth/login";
    QByteArray dataArray = m_httpClient->httpPostVariantHanlder(url , reqParam);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("message").toString() != QStringLiteral("成功"))
    {
        qDebug() << "YMAccountManager::findLogin" << dataObj << __LINE__;
        emit sigTokenFail();
    }
}

void YMAccountManager::talkLogin(QString userName, QString passWord)
{
    QVariantMap reqParam;
    reqParam.insert("loginName",userName);
    reqParam.insert("userPwd",passWord);
    reqParam.insert("loginType",1);
    reqParam.insert("systemType",2);
    reqParam.insert("needIdentifyCode",0);
    QString url = YMUserBaseInformation::m_minClassUrl + "/auth/login";
    QByteArray dataArray = m_httpClient->httpPostVariantHanlder(url , reqParam);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("message").toString() == QStringLiteral("成功"))
    {
        QJsonObject dataObject = dataObj.value("data").toObject();
        QString token = dataObject.value("token").toString();
        YMUserBaseInformation::token = token;
        this->talkGetUserInfo();
    }else{
        QString message = "用户名或者密码错误！";
        if(dataObj.contains("message"))
        {
            message = dataObj.value("message").toString();
        }
        emit loginFailed(message);
    }
}

void YMAccountManager::talkGetUserInfo()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);
    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();
    dataMap.insert("sign", sign);
    QString url = QString(YMUserBaseInformation::m_minClassUrl + "/auth/userLogin");
    QByteArray dataArray = m_httpClient->httpGetVariant(url,YMUserBaseInformation::token,dataMap);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("message").toString() == QStringLiteral("成功"))
    {
        QJsonObject dataChildObj = dataObj.value("data").toObject();
        YMUserBaseInformation::realName = dataChildObj.value("realName").toString();
        YMUserBaseInformation::nickName = dataChildObj.value("nickName").toString();
        YMUserBaseInformation::headPicture = dataChildObj.value("profilePhoto").toString();
        YMUserBaseInformation::id =  dataChildObj.value("userId").toString();

        YMUserBaseInformation::userName = dataChildObj.value("userName").toString();;
        YMUserBaseInformation::logTime = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

        QJsonObject teacherObject;
        teacherObject.insert("userId",YMUserBaseInformation::id);
        teacherObject.insert("realName",YMUserBaseInformation::realName == "" ? YMUserBaseInformation::nickName : YMUserBaseInformation::realName);
        teacherObject.insert("headPicture",YMUserBaseInformation::headPicture);
        teacherObject.insert("appVersion",YMUserBaseInformation::appVersion);
        emit teacherInfoChanged(teacherObject);
        emit loginSucceed("登录成功!");
    }
}
