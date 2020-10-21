#include "YMLessonManagerAdapter.h"
#include "YMUserBaseInformation.h"
#include "YMEncryption.h"
#include <QJsonDocument>
#include "QProcess"
#include "QFile"
#include "QDir"
#include <QStandardPaths>
#include <QCoreApplication>

std::string key = "Q-RRt2H2";

YMLessonManagerAdapter::YMLessonManagerAdapter(QObject * parent) : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    connect(m_httpClient, SIGNAL(onRequstTimerOut()), this, SIGNAL(requstTimeOuted()));
    m_timer = new QTimer();
    m_timer->setInterval(15000);
}

void YMLessonManagerAdapter::errorLog(QString message)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    QString filePath = docPath + "/YiMi/";
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


void YMLessonManagerAdapter::getEnterClassresult(QNetworkReply *reply)
{
    QByteArray dataArray = reply->readAll();

    if(dataArray.length() == 0)
    {
        lessonlistRenewSignal();
        return;
    }
    if(m_timer->isActive())
    {
        m_timer->stop();
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    
    if(dataObject.contains("result") && dataObject.contains("message")
            && dataObject.value("result").toString().toLower() == "success"
            && dataObject.value("message").toString().toUpper() == "SUCCESS")
    {
        m_classData = dataObject;
        
        getCloudServer();
    }
}

YMLessonManagerAdapter::~YMLessonManagerAdapter()
{
    this->disconnect(m_httpClient, 0, 0, 0);
}

void YMLessonManagerAdapter::onResponse(int reqCode, const QString &data)
{
    if (m_respHandlers.contains(reqCode))
    {
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        requestData = data;
        m_respHandlers.remove(reqCode);
    }
}

QString YMLessonManagerAdapter::des_decrypt(const std::string &cipherText)
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

    //    if (cipherText.length() % 8 != 0)
    //    {
    //        int tmp1 = cipherText.length() / 8 * 8;
    //        int tmp2 = cipherText.length() - tmp1;
    //        memset(inputText, 0, 8);
    //        memcpy(inputText, cipherText.c_str() + tmp1, tmp2);
    //        // 解密函数
    //        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_DECRYPT);
    //        memcpy(tmp, outputText, 8);
    //        for (int j = 0; j < 8; j++)
    //            vecCleartext.push_back(tmp[j]);
    //    }
    clearText.clear();
    clearText.assign(vecCleartext.begin(), vecCleartext.end());
    return QString::fromStdString(clearText);
}

QString YMLessonManagerAdapter::des_encrypt(const QString &clearText)
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

void YMLessonManagerAdapter::encrypt(QString source, QString target)
{
    QFile file(source);
    if (!file.open(QIODevice::ReadOnly))
    {
        //   //   // qDebug() << "open file error:file path = " << source;
        return;
    }
    QFile outFile(target);
    if (!outFile.open(QIODevice::WriteOnly))
    {
        //   //   // qDebug() << "open file error:file path = " << target;
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

QList<QString> YMLessonManagerAdapter::decrypt(QString source)
{
    QFile file(source);
    QList<QString> list;
    if (!file.open(QIODevice::ReadOnly))
    {
        //   //   // qDebug() << "open file error:file path = " << source;
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

void YMLessonManagerAdapter::resetSelectIp(int type, QString ip)
{
    this->errorLog("YMLessonManagerAdapter::resetSelectIp");
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString systemPublicFilePath;
    if (docPath == "")
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    systemPublicFilePath += "YiMi/temp/";
    QDir dir;
    if( !dir.exists(systemPublicFilePath))
    {
        dir.mkdir(systemPublicFilePath);
    }
    QString fileName = systemPublicFilePath + "/stuconfig.ini";

    QString selectIp;
    QSettings * m_settings = new QSettings (fileName, QSettings ::IniFormat);

    m_settings->beginGroup("SelectItem");
    selectIp = m_settings->value("ipitem").toString();
    if(type == 1)
    {
        m_settings->setValue("ipitem", ip);
    }
    if(type == 2 && selectIp == "")
    {
        m_settings->setValue("ipitem", ip);
    }

    m_settings->endGroup();

}

void YMLessonManagerAdapter::setUserRole(int role)
{
    m_mutex.lock();
    m_userRole = role;
    m_mutex.unlock();
}

void YMLessonManagerAdapter::startPlayer(QString appId,  QString appKey, QString envType, QString liveroomId)
{
    QStringList courseData;

    char url[1024] = {0};
    sprintf(url, "appurl://?appId=%s&appKey=%s&roomId=%s&envType=%s",
            appId.toStdString().c_str(), appKey.toStdString().c_str(), liveroomId.toStdString().c_str(),
            envType.toStdString().c_str());
    courseData << url;

    QString runPath = QCoreApplication::applicationDirPath();
    runPath += "/player.exe";
    qDebug() << "onRespCloudServer::runPath:" << runPath;
    qDebug()<< "------------"<<courseData;
    QProcess *enterPlayerprocess = new QProcess(this);
    enterPlayerprocess->start(runPath, courseData);
}

int YMLessonManagerAdapter::getUserRole()
{
    int role = 0;
    m_mutex.lock();
    role = m_userRole;
    m_mutex.unlock();
    return role;
}

// 1
void YMLessonManagerAdapter::getJoinClassRoomInfo(QString envType, QString executionPlanId, QString uId, QString groupId, const QString &classType)
{
    enterClass(envType, executionPlanId, uId, groupId, classType);
}

// 2
void YMLessonManagerAdapter::getCloudServer()
{

}


bool YMLessonManagerAdapter::isDigitStr(QString src)
{
    QByteArray ba = src.toLatin1();//QString 转换为 char*
    const char *s = ba.data();

    while(*s && *s>='0' && *s<='9') s++;

    if (*s)
    { //不是纯数字
        return false;
    }
    else
    { //纯数字
        return true;
    }
}
// 3
void YMLessonManagerAdapter::enterClass(QString envType, QString executionPlanId, QString uId, QString groupId, const QString &classType)
{

    QStringList courseData;
    QString appId;
    QString appKey;
    if(classType == "roomApp1V1")
    {
        appId = "kiFBIeLYvxOuWFgwWOy1XFFFehdA2ovo";
        appKey = "L6X0TIPFLQGkwEKM";
    }
    else if(classType == "roomApp")
    {
        appId = "7169a6c5ab5b4eeba2ca37b831fb9239";
        appKey = "yimi_324122469776515704_ccb123456_m9if1K_1566806110610";
    }
    QString userRole = QString::number(getUserRole());
    QString nickName = "xiao";
    QString userId = uId;
    QString liveroomId = executionPlanId;

    char url[1024] = {0};
    sprintf(url, "appurl://?appId=%s&appKey=%s&roomId=%s&userId=%s&userRole=%s&nickName=%s&groupId=%s&envType=%s",
            appId.toStdString().c_str(), appKey.toStdString().c_str(), liveroomId.toStdString().c_str(),
            userId.toStdString().c_str(), userRole.toStdString().c_str(), nickName.toStdString().c_str(),
            groupId.toStdString().c_str(), envType.toStdString().c_str());
    courseData << url;

    QString runPath = QCoreApplication::applicationDirPath();
    if(classType == "roomApp1V1")
    {
        runPath += "/cloudclassroom.exe";
    }
    else if(classType == "roomApp")
    {
        runPath += "/bigclassroom.exe";
    }

    qDebug() << "onRespCloudServer::runPath:" << runPath;
    qDebug()<< "------------"<<courseData;
    QProcess *enterRoomprocess = new QProcess(this);
    enterRoomprocess->start(runPath, courseData);
    programRuned();
    connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
}
