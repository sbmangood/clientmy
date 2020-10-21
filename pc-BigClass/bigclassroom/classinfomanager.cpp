#include "classinfomanager.h"
#include "httpclient.h"
#include "AESCryptManager/AESCryptManager.h"
enum DOMAIN_ENUM
{
    IP_TYPE,
    DOMAIN_TYPE,
};

enum API_USER_TYPE
{
    STUDENT = 2,
    TEACHER,
    ASSIST = 5,
};

std::string key = "Q-RRt2H2";


ClassInfoManager* ClassInfoManager::m_classInfoManager = NULL;

ClassInfoManager::ClassInfoManager()
{
    m_classInfoManager = this;
    m_httpClient = new HttpClient();
}

ClassInfoManager* ClassInfoManager::getInstance()
{
    if(NULL == m_classInfoManager)
    {
        m_classInfoManager = new ClassInfoManager();
    }
    return m_classInfoManager;
}

void ClassInfoManager::init(const QString &appId, const QString &appKey, const QString &apiUrl, const QString &classId, const QString &userId, int userType)
{
    m_appId = appId;
    m_appKey = appKey;
    m_classId = classId;
    m_userId = userId;
    m_userType = userType;
    m_apiUrl = apiUrl;
}

ClassInfoManager::~ClassInfoManager()
{
    if(nullptr != m_httpClient)
    {
        delete m_httpClient;
        m_httpClient = nullptr;
    }
}

int ClassInfoManager::getSocketIpList(int socketTcpPort, QVariantList &goodIpList)
{
    if(m_httpClient)
    {
        QString url = m_apiUrl + "/app/getIpList";
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, "", "", 5000);
        if(!jsonObj.empty())
        {
            if(jsonObj.contains("data"))
            {
                QJsonObject dataObj = jsonObj["data"].toObject();
                QJsonArray jsonData = dataObj.value("ipList").toArray();
                for(int i = 0; i < jsonData.size();i++)
                {
                    QString ip = jsonData[i].toString();
                    QVariantMap tempMap ;
                    tempMap.insert("port", QString::number(socketTcpPort));
                    tempMap.insert("ip", ip);
                    goodIpList.append(tempMap);
                }
                qDebug() << "getSocketIpList--"<< goodIpList;

            }
        }
        else
        {
            qWarning()<< "get socket iplist is empty, url is " << url;
            return -1;
        }
    }
    else
    {
        qWarning()<< "get socket iplist is failed, m_httpClient is null";
        return -1;
    }
    return 0;
}

int ClassInfoManager::getSocketAddr(QString &socketIp, int &socketTcpPort, int &socketHttpPort)
{
    if(m_httpClient)
    {
        QString url = m_apiUrl + "/app/agora/domain";
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, "", "", 5000);
        if(!jsonObj.empty())
        {
            if(jsonObj.contains("data"))
            {
                QJsonArray jsonData = jsonObj.value("data").toArray();
                for(int i = 0; i < jsonData.size();i++)
                {
                    int domainType;
                    QJsonObject obj = jsonData[i].toObject();
                    socketIp = obj.value("domain").toString();
                    domainType = obj.value("domainType").toInt();
                    if(domainType == DOMAIN_ENUM::DOMAIN_TYPE)
                    {
                        QString domain = socketIp;
                        QString url = "http://119.29.29.29/d?dn=%1&id=191&ttl=1";
                        QByteArray data = m_httpClient->httpGetIp(url.arg(des_encrypt(domain)));
                        socketIp = des_decrypt(QByteArray::fromHex(data).toStdString());//"123.206.203.83,100";//
                        socketIp = socketIp.split(",").at(0);
                        socketIp = socketIp.split(";").at(0);
                    }

                    socketTcpPort = obj["tcpPort"].toInt();
                    socketHttpPort = obj["httpPort"].toInt();
                }
                qDebug() << "getSocketAddr--"<< socketIp <<socketTcpPort << socketHttpPort;

            }
        }
        else
        {
            qWarning()<< "get socket msg is empty, url is " << url;
            return -1;
        }
    }
    else
    {
        qWarning()<< "get socket addr is failed, m_httpClient is null";
        return -1;
    }
    return 0;
}

int ClassInfoManager::getEnterRoomInfo(QString &channelKey,QString &channelName,QString &token, QString &uid, QString &chatRoomId, QString &title, int &statusCode)
{
    if(m_httpClient)
    {
        QString url = m_apiUrl + "/app/enter/room";

        int apiUserRole = m_userType == 0 ? API_USER_TYPE::TEACHER :(m_userType == 2 ? API_USER_TYPE::ASSIST : API_USER_TYPE::STUDENT);
        QJsonObject obj;
        obj.insert("liveRoomId", m_classId);
        obj.insert("userId", m_userId);
        obj.insert("userTypeEnum", apiUserRole);
        QDateTime times = QDateTime::currentDateTime();
        qint64 curTime = times.currentMSecsSinceEpoch();
        obj.insert("ts", curTime);
        QJsonDocument doc(obj);
        QString msg = QString(doc.toJson(QJsonDocument::Compact));

        AESCryptManager aESCryptManager;// AES加密
        QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));
        qDebug() << "=======url=" << url <<",msg=" << msg << ",msgen=" << msgen;

        QJsonObject paramObj;
        paramObj.insert("appid", m_appId);
        paramObj.insert("encyptyData", msgen);
        QJsonDocument docparam(paramObj);
        QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));

        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, "", 5000);
        if(!jsonObj.empty())
        {
            qDebug() << "getEnterRoomInfo--  "<< jsonObj;
            if(jsonObj.contains("code"))
                statusCode = jsonObj["code"].toInt();
            if(jsonObj.contains("data"))
            {
                QJsonObject dataObj = jsonObj["data"].toObject();
                QJsonObject agoraAuthObj = dataObj["agoraAuth"].toObject();
                channelKey = agoraAuthObj["channelKey"].toString();
                channelName = agoraAuthObj["channelName"].toString();
                token = agoraAuthObj["token"].toString();
                uid = agoraAuthObj["uid"].toString();
                chatRoomId = dataObj.value("chatRoomId").toString();
                title = dataObj["title"].toString();
                qDebug()<< "getEnterRoomInfo revc --"<< channelKey << channelName<< token<< uid << chatRoomId<< title<< statusCode;
            }
        }
        else
        {
            qWarning()<< "get socket msg is empty, url is " << url;
            return -1;
        }
    }
    else
    {
        qWarning()<< "get socket addr is failed, m_httpClient is null";
        return -1;
    }
    return 0;
}

int ClassInfoManager::getCloudDiskList(QString roomId, QString apiUrl, QString appId)
{
    if(m_httpClient)
    {
        QString url = apiUrl + "/resource/list";
        QJsonObject obj;
        obj.insert("roomId", roomId);
        QDateTime times = QDateTime::currentDateTime();
        qint64 curTime = times.currentMSecsSinceEpoch();
        obj.insert("ts", curTime);
        QJsonDocument doc(obj);
        QString msg = QString(doc.toJson(QJsonDocument::Compact));
        AESCryptManager aESCryptManager;// AES加密
        QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));
        qDebug() << "=======url=" << url <<",msg=" << msg << ",msgen=" << msgen;
        QJsonObject paramObj;
        paramObj.insert("appid", appId);
        paramObj.insert("encyptyData", msgen);
        QJsonDocument docparam(paramObj);
        QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, "", 5000);
        if(!jsonObj.empty())
        {
            //qDebug() << "getCloudDiskList--  "<< jsonObj;
            if(jsonObj.contains("data"))
            {
                QJsonArray dataArray = jsonObj["data"].toArray();
                qDebug() << "\n=====clouddisk::data="<<dataArray << "\n";
                emit sigCloudDiskInfo(dataArray);
            }
        }
        else
        {
            qWarning()<< "getCloudDiskList msg is empty, url is " << url;
            return -1;
        }
    }
    else
    {
        qWarning()<< "getCloudDiskList failed, m_httpClient is null";
        return -1;
    }
    return 0;
}

int ClassInfoManager::upLoadCourseware(QString roomId, QString userId, QString fileUrl, long fileSize, QString apiUrl, QString appId)
{
    if(m_httpClient)
    {
        int pos1 = fileUrl.lastIndexOf("/");
        int pos2 = fileUrl.lastIndexOf(".");
        QString originFilename = fileUrl.mid(pos1 + 1, pos2 - pos1 - 1);
        QString suffix = fileUrl.mid(pos2 + 1, fileUrl.length() - 1 - pos2);

        QJsonObject obj;
        obj.insert("originFilename", originFilename);
        obj.insert("path", fileUrl);
        obj.insert("roomId", roomId);
        obj.insert("size", fileSize);
        obj.insert("suffix", suffix);
        QDateTime times = QDateTime::currentDateTime();
        qint64 curTime = times.currentMSecsSinceEpoch();
        obj.insert("ts", curTime);
        obj.insert("userNo", userId);
        QJsonDocument doc(obj);
        QString msg = QString(doc.toJson(QJsonDocument::Compact));
        //qDebug() << "==============upLoadCourseware::msg=" << msg;

        AESCryptManager aESCryptManager;// AES加密
        QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));

        QJsonObject paramObj;
        paramObj.insert("appid", appId);
        paramObj.insert("encyptyData", msgen);
        QJsonDocument docparam(paramObj);
        QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));

        QString url = apiUrl + "/resource/save";
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, "", 5000);
        qDebug() << "======result=" << jsonObj;
        if(!jsonObj.empty())
        {
            if(jsonObj.contains("code"))
            {
                int code = jsonObj["code"].toInt();
                if(code == 2000)
                {
                    emit sigSaveResourceSuccess();
                }
                else
                {
                    emit sigSaveResourceFailed();
                    return -1;
                }
            }
        }
        else
        {
            qWarning()<< "upLoadCourseware msg is empty, url is " << url;
            emit sigSaveResourceFailed();
            return -1;
        }
    }
    return 0;
}

QString ClassInfoManager::des_decrypt(const std::string &cipherText)
{
    std::string clearText; // 明文
    DES_cblock keyEncrypt;
    memset(keyEncrypt, 0, 8);
    if (key.length() <= 8)
        memcpy(keyEncrypt, key.c_str(), key.length());
    else
        memcpy(keyEncrypt, key.c_str(), 8);

    DES_key_schedule keySchedule;
    DES_set_key_unchecked(&keyEncrypt, &keySchedule);

    const_DES_cblock inputText;
    DES_cblock outputText;
    std::vector<unsigned char> vecCleartext;
    unsigned char tmp[8];

    for (int i = 0; i < cipherText.length() / 8 ; i++)
    {
        memcpy(inputText, cipherText.c_str() + i * 8, 8);
        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_DECRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCleartext.push_back(tmp[j]);
    }

    clearText.clear();
    clearText.assign(vecCleartext.begin(), vecCleartext.end());
    return QString::fromStdString(clearText);
}

QString ClassInfoManager::des_encrypt(const QString &clearText)
{
    DES_cblock keyEncrypt;
    memset(keyEncrypt, 0, 8);

    if (key.length() <= 8)
        memcpy(keyEncrypt, key.c_str(), key.length());
    else
        memcpy(keyEncrypt, key.c_str(), 8);

    DES_key_schedule keySchedule;
    DES_set_key_unchecked(&keyEncrypt, &keySchedule);

    const_DES_cblock inputText;
    DES_cblock outputText;
    std::vector<unsigned char> vecCiphertext;
    unsigned char tmp[8];
    for (int i = 0; i < clearText.length() / 8; i++)
    {
        memcpy(inputText, clearText.toStdString().c_str() + i * 8, 8);
        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_ENCRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCiphertext.push_back(tmp[j]);
    }

    if (clearText.length() % 8 != 0)
    {
        int tmp1 = clearText.length() / 8 * 8;
        int tmp2 = clearText.length() - tmp1;
        memset(inputText, 8 - clearText.length() % 8, 8);
        memcpy(inputText, clearText.toStdString().c_str() + tmp1, tmp2);

        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_ENCRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCiphertext.push_back(tmp[j]);
    }
    else
    {
        memset(inputText, 8, 8);
        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_ENCRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCiphertext.push_back(tmp[j]);
    }

    QByteArray arr;
    for (int i = 0; i < vecCiphertext.size(); i++)
    {
        arr.append(vecCiphertext.at(i));
    }
    return arr.toHex();
}


void ClassInfoManager::encrypt(QString source, QString target)
{
    QFile file(source);
    if (!file.open(QIODevice::ReadOnly))
    {
        return;
    }
    QFile outFile(target);
    if (!outFile.open(QIODevice::WriteOnly))
    {
        return;
    }

    QDataStream out(&outFile);
    QTextStream in(&file);
    in.setCodec("UTF-8");
    while (! in.atEnd())
    {
        QString line = in.readLine();
        //qDebug() << "asdasdas" << line;
        out << YMCrypt::encrypt(line);
    }
}

QList<QString> ClassInfoManager::decrypt(QString source)
{
    QFile file(source);
    QList<QString> list;
    if (!file.open(QIODevice::ReadOnly))
    {
        return list;
    }
    QDataStream in(&file);
    while (! in.atEnd())
    {
        QString line;
        in >> line;
        list.append(YMCrypt::decrypt(line));
    }
    return list;

}

