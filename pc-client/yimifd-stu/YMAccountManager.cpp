#include "YMAccountManager.h"
#include "YMEncryption.h"
#include <QJsonDocument>
#include "QDir"
#include <QTextStream>
#include <QDesktopServices>
#include <QProcess>
#include "QSettings"
#include "YMUserBaseInformation.h"
#include "stdlib.h"

YMAccountManager * YMAccountManager::m_instance = nullptr;

YMAccountManager::YMAccountManager(QObject * parent)
    : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();

}

YMAccountManager *YMAccountManager::getInstance()
{
    if(m_instance == nullptr)
    {
        m_instance = new YMAccountManager();
    }
    return m_instance;
}

void YMAccountManager::getLocation()
{
    QVariantMap reqParam;
    QString key = "dff3ddc8832cc8d802ef019276f5de01";
    reqParam.insert("key", key);

    QString sign = YMEncryption::signMapSort(reqParam);
    QString md5 =  YMEncryption::md5(sign + "000a7e3483677c2209f900fbfdb1694d");
    reqParam.insert("sig", md5);
    QString url = "http://restapi.amap.com/v3/ip?" + sign + "&sig=" + md5;

    QByteArray dataArray = m_httpClient->httpGetIp(url);
    qDebug() << "YMAccountManager::getLocation::data" << dataArray;
    if(dataArray.length() <= 0)
    {
        return;
    }

    QJsonParseError jsonError;
    QJsonDocument doc = QJsonDocument::fromJson(dataArray, &jsonError);

    if(jsonError.error != QJsonParseError::NoError)
    {
        return;
    }
    QJsonObject obj = doc.object();
    if(!obj.contains("rectangle"))
    {
        return;
    }
    QString rectangle = obj.value("rectangle").toString();
    if(rectangle == "")
    {
        return;
    }
    if(dataArray == "")
    {
        return;
    }
    //QJsonObject obj = QJsonDocument::fromJson(dataArray).object();
    //QString rectangle= obj.value("rectangle").toString();
    QStringList listLocation = rectangle.split(';');
    QString  location1 = listLocation.at(0);
    QString  location2 = listLocation.at(1);

    QStringList locationSplit1 = location1.split(",");
    QStringList locationSplit2 = location2.split(",");
    QString location_lng1 = locationSplit1.at(0);
    QString location_lng2 = locationSplit2.at(0);
    double lng = location_lng2.toDouble() - location_lng1.toDouble();

    QString location_lat1 = locationSplit1.at(1);
    QString location_lat2 = locationSplit2.at(1);
    double lat = location_lat2.toDouble() - location_lat1.toDouble();
    YMUserBaseInformation::geolocation = QString::number(location_lng2.toDouble() - lng * 0.5, 10, 4) + "," + QString::number( location_lat2.toDouble() - lat * 0.5, 10, 4);

    //读取电脑信息
    QSettings reg("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\", QSettings::NativeFormat);
    reg.beginGroup("BIOS");
    YMUserBaseInformation::deviceInfo.append(reg.value("SystemManufacturer").toString().remove("#").append("|").append(reg.value("SystemSKU").toString().remove("#")));
    YMUserBaseInformation::deviceInfo.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("\\").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
    //qDebug() <<"get::lng:" <<YMUserBaseInformation::geolocation<<YMUserBaseInformation::deviceInfo;

}

void YMAccountManager::findLogin(QString username, QString password)
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap reqParam;
    reqParam.insert("mobileNo", username);
    reqParam.insert("password", YMEncryption::md5(password));
    reqParam.insert("appVersion", YMUserBaseInformation::appVersion); //获取程序版本号
    reqParam.insert("sysInfo", "WIN");
    reqParam.insert("deviceInfo", "1");
    reqParam.insert("umengAppKey", "1");
    reqParam.insert("appSource", "YIMI");
    reqParam.insert("type", "stu");
    reqParam.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString signStr = YMEncryption::signMapSort(reqParam);
    QString sign = YMEncryption::md5(signStr);
    reqParam.insert("sign", sign);
    QByteArray dataArray = m_httpClient->httpPostForm(m_httpClient->httpUrl + "/user/login", reqParam);

    //解析登录数据并且传值
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("result") && dataObject.value("result").toString().toLower() != "success")
    {
        emit sigTokenFail();
        qDebug() << "YMAccountManager::findLogin::Fail" << dataObject;
    }
}

void YMAccountManager::login(QString username, QString password)
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap reqParam;
    reqParam.insert("mobileNo", username);
    reqParam.insert("password", YMEncryption::md5(password));
    reqParam.insert("appVersion", YMUserBaseInformation::appVersion); //获取程序版本号
    reqParam.insert("sysInfo", "WIN");
    reqParam.insert("deviceInfo", "1");
    reqParam.insert("umengAppKey", "1");
    reqParam.insert("appSource", "YIMI");
    reqParam.insert("type", "stu");
    reqParam.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString signStr = YMEncryption::signMapSort(reqParam);
    QString sign = YMEncryption::md5(signStr);
    reqParam.insert("sign", sign);
    QByteArray dataArray = m_httpClient->httpPostForm(m_httpClient->httpUrl + "/user/login", reqParam);
    //    QFile file("11111out.txt");
    //    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    //        return;
    //    file.write(dataArray);
    //    file.flush();
    //    file.close();
    //解析登录数据并且传值
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();

    qDebug() << "YMAccountManager::login: " << dataObject << dataObject.contains("result");
    if(dataObject.contains("result") && dataObject.value("result").toString().toLower() == "success")
    {
        YMUserBaseInformation::token = dataObject.value("token").toString();
        QJsonObject teacherObj = dataObject.value("data").toObject();
        YMUserBaseInformation::realName = teacherObj.value("userName").toString();
        YMUserBaseInformation::nickName = teacherObj.value("nickName").toString();
        YMUserBaseInformation::headPicture = teacherObj.value("headPicture").toString();
        YMUserBaseInformation::MD5Pwd = teacherObj.value("password").toString();
        YMUserBaseInformation::id = QString::number(teacherObj.value("userId").toInt());
        YMUserBaseInformation::mobileNo = teacherObj.value("mobileNo").toString();
        //qDebug()<<"token: "<<YMUserBaseInformation::token;
        YMUserBaseInformation::userName = username;
        YMUserBaseInformation::logTime = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");

        int id = teacherObj.value("userId").toInt();
        YMUserBaseInformation::id = QString::number(id);
        QJsonObject teacherObject;
        teacherObject.insert("realName", YMUserBaseInformation::realName);
        teacherObject.insert("headPicture", YMUserBaseInformation::headPicture);
        teacherObject.insert("password", YMUserBaseInformation::passWord);
        teacherObject.insert("nickName", YMUserBaseInformation::nickName);
        teacherObject.insert("appVersion", YMUserBaseInformation::appVersion);
        teacherObject.insert("userId", YMUserBaseInformation::id);
        teacherObject.insert("token", YMUserBaseInformation::token);
        teacherObject.insert("mobileNo",YMUserBaseInformation::mobileNo);
        emit teacherInfoChanged(teacherObject);
        emit loginSucceed(QStringLiteral("登录成功"));
        getLinkMan();
    }
    else
    {
        QString message = QStringLiteral("登录失败: 网络异常");
        if(dataObject.contains("message"))
        {
            message = dataObject.value("message").toString();
        }

        emit loginFailed(message);
        qDebug() << "YMAccountManager::login" << dataObject;
    }

    YMUserBaseInformation::passWord = password;

}

QVariant YMAccountManager::insertLeave(QString lessonId, QString reason)
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("studentFid", YMUserBaseInformation::id);
    dataMap.insert("lessonFid", lessonId);
    dataMap.insert("applyFrom", "PC");
    dataMap.insert("applyReason", reason);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    QString signStr = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signStr).toUpper();

    dataMap.insert("sign", sign);

    QString url = m_httpClient->httpUrl + "/app/leave/insertLeave";
    QByteArray dataArray = m_httpClient->httpPostVariant(url, dataMap);

    //qDebug()<<QString::fromUtf8( dataArray).contains(QStringLiteral("新增请假成功"))<<QStringLiteral("新增请假");

    return QString::fromUtf8( dataArray).contains(QStringLiteral("新增请假成功")) ? 1 : 0;
}

QJsonObject YMAccountManager::getLeaveLastCount()
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("leaveVersion", "1.0");
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    QString signStr = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signStr).toUpper();

    dataMap.insert("sign", sign);

    QString url = m_httpClient->httpUrl + "/app/leave/leaveLastCount";
    QByteArray dataArray = m_httpClient->httpPostVariant(url, dataMap);
    QJsonObject object = QJsonDocument::fromJson(dataArray).object();

    if(dataArray.contains("result\":\"success"))
    {
        QJsonObject numberObj = object.value("data").toObject();
        //qDebug()<<numberObj<<QStringLiteral("剩余请假次数");
        return numberObj;
    }
    else
    {
        qDebug() << "YMAccountManager::getLeaveLastCount" << object;
        QJsonObject obj;
        return obj;
    }
}

//联系人信息
void YMAccountManager::getLinkMan()
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap reqParam;
    reqParam.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParam.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParam.insert("token", YMUserBaseInformation::token);
    reqParam.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString signStr = YMEncryption::signMapSort(reqParam);
    QString sign = YMEncryption::md5(signStr);
    reqParam.insert("sign", sign);

    QString url = m_httpClient->httpUrl + "/contract/getLinkMan";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParam);
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    emit linkManInfo(dataObject);
}

void YMAccountManager::onResponse(int reqCode, const QString &data)
{
    //qDebug() << "YMAccountManager::onResponse" << data;
    if (m_respHandlers.contains(reqCode))
    {
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        m_respHandlers.remove(reqCode);
    }
}

QJsonArray YMAccountManager::getUserLoginInfo()
{
#if 0
    //保存到AppData目录: C:\Users\admin\AppData\Local\yimifudao\Qutt.dll
    QString bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
#endif

    QString bufferFilePath = QCoreApplication::applicationDirPath();
    QString readFilePath  = bufferFilePath + "/Qutt.dll";

    qDebug() << "getUserLoginInfo::" << readFilePath;
    QFile file(readFilePath);
    QJsonArray userArray;
    if(!file.exists())
    {
        qDebug() << "YMAccountManager::getUserLoginInfo";
        return userArray;
    }
    if(file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream read(&file);
        QString lineStr;

        while (!read.atEnd())
        {
            lineStr = read.readLine().trimmed();
            userArray.append(lineStr);
        }
    }
    file.close();
    return userArray;
}

QVariant YMAccountManager::getValuationResult()
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("status", "2");
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    QString signStr = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signStr).toUpper();

    dataMap.insert("sign", sign);

    QString url = m_httpClient->httpUrl + "/pli/findevaluation";
    QByteArray dataArray = m_httpClient->httpPostVariant(url, dataMap);


    QJsonDocument jsonDocument = QJsonDocument::fromJson(dataArray);

    qDebug() << "allresult " << jsonDocument;
    QVariantMap result = jsonDocument.toVariant().toMap();
    result = result["data"].toMap();
    if(result["leaveList"].toList().size() > 0)
    {
        QVariantMap dataMap;
        for(int a = 0; a < result["leaveList"].toList().size(); a++)
        {
            if(a == 0)
            {
                dataMap = result["leaveList"].toList().at(0).toMap();
            }
            else
            {
                QDateTime dateTime = QDateTime::fromString(dataMap["createdOn"].toString(), "yyyy-MM-dd HH:mm:ss.z");
                QDateTime dateTimeOne = QDateTime::fromString(result["leaveList"].toList().at(a).toMap()["createdOn"].toString(), "yyyy-MM-dd HH:mm:ss.z");;
                if(dateTime < dateTimeOne)
                {
                    dataMap = result["leaveList"].toList().at(a).toMap();
                }
            }
        }
        result = dataMap;
        QString sqId = QString::number(result["id"].toInt());
        YMUserBaseInformation::sqId = sqId;
        //qDebug() << "sqID:" <<YMUserBaseInformation::sqId;
        //qDebug()<<result<<QStringLiteral("测评状态")<<result["status"].toInt();
    }

    return result["status"].toInt();// 空 0 1 2     3   4
}

void YMAccountManager::saveUserInfo(QString userName, QString password, int RememberPwd, int autoLogin, int stu, int parentRenindHasBeShowed, int isFirstAskForLeave)
{
#if 0
    //保存到AppData目录: C:\Users\admin\AppData\Local\yimifudao\Qutt.dll
    QString bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
#endif

    QString bufferFilePath = QCoreApplication::applicationDirPath();
    QString filePath  = bufferFilePath + "/Qutt.dll";

    //qDebug() << "YMAccountManager::saveUserInfo" << filePath;
    QFile file(filePath);
    file.close();
    if(file.open(QFile::ReadWrite))
    {
        QTextStream textOut(&file);
        textOut << userName.trimmed() + "\r\n"  << password.trimmed() + "\r\n"
                << QString::number(RememberPwd) + "\r\n"
                << QString::number(autoLogin) + "\r\n"
                << QString::number(stu) + "\r\n"
                << QString::number(parentRenindHasBeShowed) + "\r\n"
                << QString::number(isFirstAskForLeave) + "\r\n";
        textOut.flush();
    }
    file.flush();
    file.close();
    //qDebug() << "YMAccountManager::saveUserInfo::loginPath" << filePath;
    // QFile::remove(saveFilePath);
}

void YMAccountManager::getLatestVersion()
{
    QString url = m_httpClient->httpUrl + "/version/getLatestVersion";
    QVariantMap reqParam;

    if(!YMUserBaseInformation::m_bIsPublicTest)
    {
        qDebug() << "YMAccountManager::getLatestVersion" << QStringLiteral("非公测版本") << __LINE__;
        reqParam.insert("appName", "stu_pc"); //生产版本
    }
    else
    {
        qDebug() << "YMAccountManager::getLatestVersion" << QStringLiteral("公测版本") << __LINE__;
        reqParam.insert("appName", "stu_pc_beta"); //公测的版本
    }

    reqParam.insert("versionName", YMUserBaseInformation::appVersion);
    reqParam.insert("versionCode", YMUserBaseInformation::versionCode);
    reqParam.insert("apiVersion", YMUserBaseInformation::apiVersion);

    m_version = QJsonObject();
    m_version.insert("version", YMUserBaseInformation::appVersion);
    QByteArray byteArray = m_httpClient->httpPostForm(url, reqParam);
    QJsonObject dataObject = QJsonDocument::fromJson(byteArray).object();
    // qDebug() << "dataObjectversion:" << dataObject;

    if(dataObject.value("message").toString().toUpper() == "SUCCESS"
       && dataObject.value("result").toString().toLower() == "success")
    {
        m_version.insert("update", true);
        QJsonObject m_firmwareData = dataObject.value("data").toObject();
        m_firmware = m_firmwareData;
        int versionCode = m_firmwareData.value("versionCode").toInt();

        if(versionCode > YMUserBaseInformation::versionCode.toInt())
        {
            int isForce = m_firmwareData.value("isForce").toInt();
            m_version.insert("status", isForce);
            return;
        }
    }
    else
    {
        qDebug() << "YMAccountManager::getLatestVersion" << dataObject;
    }

    m_version.insert("update", false);
    m_version.insert("status", 0);
    //qDebug() << "getLatestVersion:" << m_version << dataObject;
}

void YMAccountManager::updatePassword(QString oldPwd, QString newPwd)
{
    // qDebug() << "updatePassword::" << newPwd;
    QDateTime timess = QDateTime::currentDateTime();

    QVariantMap dataMap;
    dataMap.insert("oldPassword", YMEncryption::md5(oldPwd));
    dataMap.insert("newPassword", YMEncryption::md5(newPwd));
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    QString signStr = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signStr).toUpper();

    dataMap.insert("sign", sign);
    QString url = m_httpClient->httpUrl + "/person/setting/changePassword";
    QByteArray dataArray = m_httpClient->httpPostVariant(url, dataMap);

    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
//    qDebug() << "YMAccountManager::updatePassword" << dataObject;
    if(dataObject.contains("result")
       && dataObject.value("result").toString().toLower() == "success")
    {
        emit updatePasswordChanged();
    }
    else
    {
        qDebug() << "YMAccountManager::updatePassword" << dataObject;
    }
}

//设置更新状态
void YMAccountManager::updateFirmware(bool status)
{
    if(status)
    {
        // qDebug() << "m_firmware" << m_firmware;
        QStringList urlList;
        urlList << m_firmware.value("updateUrl").toString();
        urlList << "STU";
        urlList << YMUserBaseInformation::appVersion;
        QProcess process;
        // qDebug() << "updateSoftWare:"<< urlList;
        if(process.startDetached("update/update.exe", urlList))
        {
            exit(0);
        }
    }
}

YMAccountManager::~YMAccountManager()
{
    this->disconnect(m_httpClient, 0, 0, 0);
}

QString YMAccountManager::getDownLoadUrl()
{
    return m_firmware.value("updateUrl").toString();
}
