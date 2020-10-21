#include "YMAccountManager.h"
#include "YMEncryption.h"
#include <QJsonDocument>
#include "QDir"
#include <QTextStream>
#include <QDesktopServices>
#include "QProcess"
#include "QSettings"
#include "QCoreApplication"
#include "YMUserBaseInformation.h"
#include "debuglog.h"

YMAccountManager * YMAccountManager::m_instance = nullptr;

YMAccountManager::YMAccountManager(QObject * parent)
    : QObject(parent),m_updateValue(-1)
{
    m_httpClient = YMHttpClient::defaultInstance();
    m_updateStatus = false;
    m_versinon = YMUserBaseInformation::appVersion;

    QSettings reg("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\",QSettings::NativeFormat);
    reg.beginGroup("BIOS");
    QString deviceInfo = reg.value("SystemManufacturer").toString().remove("#").append("|").append(reg.value("SystemSKU").toString().remove("#"));

    deviceInfo.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
    YMUserBaseInformation::deviceInfo =QString::fromUtf8(deviceInfo.toUtf8());
    qDebug()<<"YMUserBaseInformation::deviceInfo"<<YMUserBaseInformation::deviceInfo<<QString("\u0002");

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
    //qDebug() <<rectangle << "lat:::" << YMUserBaseInformation::longitude << YMUserBaseInformation::latitude;
}

void YMAccountManager::login(QString username, QString password)
{
    //qDebug() << "YMAccountManager::login" << username << password;
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

    //qDebug() << "YMAccountManager::login" << username << YMEncryption::md5(password) << YMUserBaseInformation::appVersion;
    qDebug() << "YMAccountManager::login" << m_httpClient->httpUrl << dataObject;

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

        emit loginSucceed(YMUserBaseInformation::token);
//        this->errorLog("YMAccountManager::login");

    }else
    {
        QString message = QStringLiteral("用户名或者密码错误");
        if(dataObject.contains("message"))
        {
            message = dataObject.value("message").toString();
            //qDebug() << "login::error" << message;
        }
        emit loginFailed(message);
    }
}

void YMAccountManager::onRespLogin(const QString & data)
{
    //qDebug() << "YMAccountManager::onRespLogin" << data;

}

void YMAccountManager::onResponse(int reqCode, const QString &data)
{
    //qDebug() << "YMAccountManager::onResponse" << data;
    if (m_respHandlers.contains(reqCode)){
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        m_respHandlers.remove(reqCode);
    }
}

void YMAccountManager::errorLog(QString message)
{
    QString docPath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    QString filePath = docPath + "/YiMi/";
    //qDebug() << "********YMAccountManager::errorLog**********" << filePath;
    QDir dir(filePath);
    if(!dir.exists())
    {
        dir.mkdir(filePath);
    }

    QFile file(filePath + "teacherlog.txt");

    if(file.open(QFile::WriteOnly | QFile::Append))
    {
        QTextStream textOut(&file);
        textOut << message + "\r\n";
        textOut.flush();
    }
    file.close();
}

QJsonArray YMAccountManager::getUserLoginInfo()
{
    QString bufferFilePath = QCoreApplication::applicationDirPath();//QStandardPaths::writableLocation(QStandardPaths::DataLocation);
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
    QString bufferFilePath = QCoreApplication::applicationDirPath();//QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QDir dir(bufferFilePath);
    if(!dir.exists()){
        dir.mkdir(bufferFilePath);
    }
    QString saveFilePath = bufferFilePath + "/teaInfo.dll";
    //qDebug() << "saveUserInfo:" << saveFilePath;
    QFile file(saveFilePath);
    file.close();
    if(file.open(QFile::ReadWrite)){
        QTextStream textOut(&file);
        textOut << userName.trimmed() + "\r\n"  << password.trimmed() + "\r\n"
                << QString::number(RememberPwd) + "\r\n" << QString::number(autoLogin) + "\r\n";
        textOut.flush();
    }
    file.close();
}


void YMAccountManager::getLatestVersion()
{
    QVariantMap reqParam;

    if(!YMUserBaseInformation::m_bIsPublicTest)
    {
        qDebug() << "YMAccountManager::getLatestVersion" << QStringLiteral("生产版本") << __LINE__;
        reqParam.insert("appName", "tea_pc"); //生产版本
    }
    else
    {
        reqParam.insert("appName","tea_pc_beta"); //公测的版本
        qDebug() << "YMAccountManager::getLatestVersion" << QStringLiteral("公测版本") << __LINE__;
    }

    reqParam.insert("versionName", YMUserBaseInformation::appVersion);
    reqParam.insert("versionCode", YMUserBaseInformation::versionCode);
    reqParam.insert("apiVersion", YMUserBaseInformation::apiVersion);

    QString url = m_httpClient->httpUrl + "/version/getLatestVersion";

    QByteArray byteArray = m_httpClient->httpPostForm(url,reqParam);
    QJsonObject dataObject = QJsonDocument::fromJson(byteArray).object();

    qDebug() << "getLatestVersion:" << url<< dataObject;


    if(dataObject.value("message").toString() == "SUCCESS"
            && dataObject.value("result").toString() == "success"){
        m_updateStatus = true;
        m_firmwareData = dataObject.value("data").toObject();
        int versionCode = m_firmwareData.value("versionCode").toInt();
        if(versionCode > YMUserBaseInformation::versionCode.toInt()){
            int isForce = m_firmwareData.value("isForce").toInt();
            //            qDebug()<<"isforce"<<isForce;
            m_updateValue = isForce;
            //updateSoftWareChanged(isForce);
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
        //qDebug() << "updateFirmware" << m_firmwareData.value("updateUrl").toString();

        //下载更新程序
        //
        QProcess process;

        if(process.startDetached("update/update.exe",urlList))
        {
            exit(0);
        }else {
            //qDebug()<<QStringLiteral("启动更新程序失败");
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
    reqParam.insert("md5Pwd",YMEncryption::md5(password));
    reqParam.insert("appVersion",YMUserBaseInformation::appVersion);//获取程序版本号
    reqParam.insert("sysInfo","WIN");
    reqParam.insert("deviceInfo","1");
    reqParam.insert("umengAppKey","1");
    reqParam.insert("appSource","YIMI");
    reqParam.insert("type","tea");

    QString signStr = YMEncryption::signMapSort(reqParam);
    QString sign = YMEncryption::md5(signStr);

    reqParam.insert("sign", sign);
    QByteArray dataArray = m_httpClient->httpPostForm(m_httpClient->httpUrl + "/tea/user/login", reqParam);
    //解析登录数据并且传值
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "YMAccountManager::findLogin";
    if(dataObject.contains("result") && dataObject.value("result").toString().toLower() != "success"){
        emit sigTokenFail();
    }
}
