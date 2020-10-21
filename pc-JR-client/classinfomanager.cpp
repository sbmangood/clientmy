#include "classinfomanager.h"
enum DOMAIN_ENUM
{
    IP_TYPE,
    DOMAIN_TYPE,
};

enum API_USER_TYPE
{
    STUDENT = 1,//学生
    AUDIT =2,//旁听
    ASSIST = 3,//助教
    TEACHER=4 //老师
};
std::string key = "Q-RRt2H2";

QString ClassInfoManager::m_apiToken = "";
QString ClassInfoManager::m_appKey = "";
ClassInfoManager* ClassInfoManager::m_classInfoManager = NULL;

ClassInfoManager::ClassInfoManager()
{
//    m_classInfoManager = this;
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

void ClassInfoManager::init(const QString &appId, const QString &appKey, const QString &apiUrl, const QString &classId, const QString &userId, int userType, const QString &apiToken)
{
    m_appId = appId;
    m_appKey = appKey;
    m_classId = classId;
    m_userId = userId;
    m_userType = userType;
    m_apiUrl = apiUrl;
    m_apiToken = apiToken;
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
        if(!m_apiToken.isEmpty())
            url = m_apiUrl + "/token/app/getIpList";
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, "", m_apiToken, 15000);
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
         if(!m_apiToken.isEmpty())
             url = m_apiUrl + "/token/app/agora/domain";
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, "", m_apiToken, 15000);
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

int ClassInfoManager::getEnterRoomInfo(QString &channelKey,QString &channelName,QString &token, QString &uid, QString &chatRoomId, QString &title, int &statusCode, int &classType,QString &agoraAppid, QString& roomName)
{
    if(m_httpClient)
    {
        QString url = m_apiUrl + "/app/enter/room";
        if (!m_apiToken.isEmpty())
             url =  m_apiUrl + "/token/app/enter/room";

        int apiUserRole =  API_USER_TYPE::STUDENT ;
        if(0 == m_userType)
        {
            apiUserRole =API_USER_TYPE::TEACHER;
        }else if(1 == m_userType ){

            apiUserRole =API_USER_TYPE::STUDENT;
        }else if(2 == m_userType){

            apiUserRole =API_USER_TYPE::ASSIST;
        } else {

            apiUserRole = API_USER_TYPE::AUDIT;
        }


        QJsonObject obj;
        obj.insert("liveRoomId", m_classId);
        obj.insert("userId", m_userId);
        obj.insert("userTypeEnum", apiUserRole);
        QDateTime times = QDateTime::currentDateTime();
        qint64 curTime = times.currentMSecsSinceEpoch();
        obj.insert("ts", curTime);
        QJsonDocument doc(obj);
        QString msg = QString(doc.toJson(QJsonDocument::Compact));

        AESCryptManager aESCryptManager(m_appKey.toStdString());// AES加密
        QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));
        qDebug() << "=======url=" << url <<",msg=" << msg << ",msgen=" << msgen;

        QJsonObject paramObj;
        paramObj.insert("appid", m_appId);
        paramObj.insert("encyptyData", msgen);
        QJsonDocument docparam(paramObj);
        QString parammsg = "";
        if(!m_apiToken.isEmpty()){
             obj.insert("appid", m_appId);
             QJsonDocument doc1(obj);
             parammsg = QString(doc1.toJson(QJsonDocument::Compact));

        } else {

             parammsg = QString(docparam.toJson(QJsonDocument::Compact));
        }

        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, m_apiToken, 15000);
        if(!jsonObj.empty())
        {
            qDebug() << "getEnterRoomInfo--  "<< jsonObj;
            if(jsonObj.contains("code"))
                statusCode = jsonObj["code"].toInt();
            if(jsonObj.contains("data"))
            {
                QJsonObject dataObj = jsonObj["data"].toObject();
                QJsonObject agoraAuthObj = dataObj["agoraAuth"].toObject();
                agoraAppid = agoraAuthObj["agoraAppid"].toString();
                channelKey = agoraAuthObj["channelKey"].toString();
                channelName = agoraAuthObj["channelName"].toString();
                token = agoraAuthObj["token"].toString();
                uid = agoraAuthObj["uid"].toString();
                chatRoomId = dataObj.value("chatRoomId").toString();
                roomName = dataObj.value("title").toString();
                title = dataObj["title"].toString();
                classType = dataObj["type"].toInt();
                qDebug()<< "getEnterRoomInfo revc --"<< agoraAppid << channelKey << channelName<< token<< uid << chatRoomId<< title<< statusCode<< classType;
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


int ClassInfoManager::getCloudDiskList(QString roomId, QString apiUrl, QString appId, bool isRefreshCloudDisk)
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
        AESCryptManager aESCryptManager(m_appKey.toStdString());// AES加密
        QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));
        qDebug() << "=======url=" << url <<",msg=" << msg << ",msgen=" << msgen;
        QJsonObject paramObj;
        paramObj.insert("appid", appId);
        paramObj.insert("encyptyData", msgen);
        QJsonDocument docparam(paramObj);
        QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, m_apiToken, 5000);
        if(!jsonObj.empty())
        {
            //qDebug() << "getCloudDiskList--  "<< jsonObj;
            if(jsonObj.contains("data"))
            {
                QJsonArray dataArray = jsonObj["data"].toArray();
                //qDebug() << "\n=====clouddisk::data="<<dataArray << "\n";
                if(isRefreshCloudDisk)
                {
                    emit sigCloudDiskInfo(dataArray);
                }
                m_mutex.lock();
                m_coursewareListInfo = dataArray;
                m_mutex.unlock();
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

int ClassInfoManager::upLoadCourseware(QString upFileMark, QString roomId, QString userId, QString fileUrl, long fileSize, QString apiUrl, QString appId)
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

        AESCryptManager aESCryptManager(m_appKey.toStdString());// AES加密
        QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));

        QJsonObject paramObj;
        paramObj.insert("appid", appId);
        paramObj.insert("encyptyData", msgen);
        QJsonDocument docparam(paramObj);
        QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));

        QString url = apiUrl + "/resource/app/save";
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, m_apiToken, 5000);
        qDebug() << "======result=" << jsonObj;
        if(!jsonObj.empty())
        {
            if(jsonObj.contains("code"))
            {
                int code = jsonObj["code"].toInt();
                if(code == 2000)
                {
                    if(jsonObj.contains("data"))
                    {
                        QString coursewareId = jsonObj["data"].toString();
                        emit sigSaveResourceSuccess(coursewareId, originFilename, suffix, upFileMark);
                    }
                }
                else
                {
                    emit sigSaveResourceFailed(originFilename, suffix, upFileMark);
                    return -1;
                }
            }
        }
        else
        {
            qWarning()<< "upLoadCourseware msg is empty, url is " << url;
            emit sigSaveResourceFailed(originFilename, suffix, upFileMark);
            return -1;
        }
    }
    return 0;
}

int ClassInfoManager::findFileStatus(QString coursewareId, QString apiUrl, QString appId)
{
    if(m_httpClient)
    {
        QJsonObject obj;
        obj.insert("id", coursewareId);
        QDateTime times = QDateTime::currentDateTime();
        qint64 curTime = times.currentMSecsSinceEpoch();
        obj.insert("ts", curTime);

        QJsonDocument doc(obj);
        QString msg = QString(doc.toJson(QJsonDocument::Compact));

        AESCryptManager aESCryptManager(m_appKey.toStdString());
        QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));

        QJsonObject paramObj;
        paramObj.insert("appid", appId);
        paramObj.insert("encyptyData", msgen);
        QJsonDocument docparam(paramObj);
        QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));

        QString url = apiUrl + "/resource/find/status";
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, m_apiToken, 5000);
        qDebug() << "======result=" << jsonObj;
        if(!jsonObj.empty())
        {
            if(jsonObj.contains("code"))
            {
                int code = jsonObj["code"].toInt();
                if(code == 2000)
                {
                    int status = jsonObj["data"].toInt();
                    emit sigFindFileStatus(status);
                }
                else
                {
                    return -1;
                }
            }
        }
        else
        {
            qWarning()<< "findFileStatus msg is empty, url is " << url;
            return -1;
        }
    }
    else
    {
        return -1;
    }
}

int ClassInfoManager::deleteCourseware(QString coursewareId, QString roomId, QString apiUrl, QString appId)
{
    if(m_httpClient)
    {
        QJsonObject obj;
        obj.insert("resourceId", coursewareId);
        obj.insert("roomId", roomId);
        QDateTime times = QDateTime::currentDateTime();
        qint64 curTime = times.currentMSecsSinceEpoch();
        obj.insert("ts", curTime);

        QJsonDocument doc(obj);
        QString msg = QString(doc.toJson(QJsonDocument::Compact));

        AESCryptManager aESCryptManager(m_appKey.toStdString());
        QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));

        QJsonObject paramObj;
        paramObj.insert("appid", appId);
        paramObj.insert("encyptyData", msgen);
        QJsonDocument docparam(paramObj);
        QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));

        QString url = apiUrl + "/resource/cancel";
        QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, m_apiToken, 5000);
        qDebug() << "======result=" << jsonObj;
        if(!jsonObj.empty())
        {
            if(jsonObj.contains("code"))
            {
                int code = jsonObj["code"].toInt();
                if(code == 2000)
                {
                    emit sigDeleteResult(coursewareId, true);
                    return 0;
                }
                else
                {
                    emit sigDeleteResult(coursewareId, false);
                    return -1;
                }
            }
        }
        else
        {
            qWarning()<< "findFileStatus msg is empty, url is " << url;
            emit sigDeleteResult(coursewareId, false);
            return -1;
        }
    }
    else
    {
        emit sigDeleteResult(coursewareId, false);
        return -1;
    }
}

QJsonArray ClassInfoManager::getCoursewareListInfo()
{
    QJsonArray coursewareListInfo;
    m_mutex.lock();
    coursewareListInfo = m_coursewareListInfo;
    m_mutex.unlock();
    return coursewareListInfo;
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



