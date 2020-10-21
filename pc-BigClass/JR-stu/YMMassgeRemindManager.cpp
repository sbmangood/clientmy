#include "YMMassgeRemindManager.h"
#include "YMUserBaseInformation.h"
#include "YMEncryption.h"

YMMassgeRemindManager::YMMassgeRemindManager(QObject *parent)
    : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    m_timer = new QTimer();
    m_timer->setInterval(1000 * 60 * 5);
    //m_timer->start();

    m_timerOut = new QTimer();
    m_timerOut->setInterval(15000);
    m_timerOut->setSingleShot(true);
    connect(m_httpClient, SIGNAL(onTimerOut()), this, SIGNAL(requestTimerOut())); //请求超时信号
    connect(m_timer, SIGNAL(timeout()), this, SLOT(onSearchRmind()));
    //qDebug() << "YMMassgeRemindManager";
}

void YMMassgeRemindManager::onSearchRmind()
{
    //qDebug() << "YMMassgeRemindManager::onSearchRmind";
    getNewRemind(1, 1);
    m_timer->start();
}

//获取当前网络环境
void YMMassgeRemindManager::getCurrentStage()
{
    int netType = m_httpClient->m_netType;
    QString stageInfo = m_httpClient->m_stage;

//    if(stageInfo.trimmed().length() > 0) //如果不是生产环境
//    {
//        stageInfo += "-";
//    }

    qDebug() << "YMMassgeRemindManager::getCurrentStage" << netType << stageInfo << __LINE__;

    emit sigStageInfo(netType,stageInfo);
}

//修改网络配置文件
void YMMassgeRemindManager::updateStage(int netType, QString stageInfo)
{
    qDebug() << "YMMassgeRemindManager::updateStage" << netType << stageInfo << __LINE__;
    m_httpClient->updateNetType(netType,stageInfo);
}

void YMMassgeRemindManager::getRemind(int type, int page)
{
    QVariantMap reqPram;
    reqPram.insert("type", type);
    reqPram.insert("token", YMUserBaseInformation::token);
    reqPram.insert("userId", (YMUserBaseInformation::id).toInt());
    reqPram.insert("pageIndex", page);

    QString signStr = YMEncryption::signMapSort(reqPram);
    QString sign = YMEncryption::md5(signStr);
    reqPram.insert("sign", sign.toUpper());

    //qDebug() << "sign:" << sign;
    QString url = m_httpClient->httpUrl + "/app/student/remind";
    QByteArray dataArray = m_httpClient->httpPostVariant(url, reqPram);
    if(dataArray.length()  <= 0)
    {
        QJsonObject dataObj;
        remindChange(dataObj);
        return;
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("result")
       && dataObject.value("result").toString().toLower() == "success")
    {
        QJsonObject messageDataObj = dataObject.value("data").toObject();
        emit remindChange(messageDataObj);
    }
    else
    {
        qDebug() << "YMMassgeRemindManager::getRemind" << dataObject;
    }
}
//五分钟更新一次最新消息
void YMMassgeRemindManager::getNewRemind(int type, int page)
{
    QVariantMap reqPram;
    reqPram.insert("type", type);
    reqPram.insert("token", YMUserBaseInformation::token);
    reqPram.insert("userId", (YMUserBaseInformation::id).toInt());
    reqPram.insert("pageIndex", page);

    QString signStr = YMEncryption::signMapSort(reqPram);
    QString sign = YMEncryption::md5(signStr);
    reqPram.insert("sign", sign.toUpper());

    //qDebug() << "sign:" << sign;
    QString url = m_httpClient->httpUrl + "/app/student/remind";
    QByteArray dataArray = m_httpClient->httpPostVariant(url, reqPram);
    if(dataArray.length() == 0)
    {
        QJsonObject dataObj;
        remindChange(dataObj);
        return;
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("result")
       && dataObject.value("result").toString().toLower() == "success")
    {
        QJsonObject messageDataObj = dataObject.value("data").toObject();
        emit remindNewChange(messageDataObj);
    }
    else
    {
        qDebug() << "YMMassgeRemindManager::getNewRemind" << dataObject;
    }
}

void YMMassgeRemindManager::getRemindTag(QJsonArray idList)
{
    QString idListStr;

    for(int i = 0; i < idList.size(); i++)
    {
        if(i == idList.size() - 1 )
        {
            idListStr.append(QString::number(idList.at(i).toInt()));
        }
        else
        {
            idListStr.append(QString::number(idList.at(i).toInt())).append(",");
        }
    }
    //qDebug() << "YMMassgeRemindManager::getRemindTag" << idListStr;
    QVariantMap reqPram;
    reqPram.insert("remindIds", idListStr);
    reqPram.insert("userId", YMUserBaseInformation::id);
    reqPram.insert("token", YMUserBaseInformation::token);

    QString signStr = YMEncryption::signMapSort(reqPram);
    QString sign = YMEncryption::md5(signStr);

    reqPram.insert("sign", sign.toUpper());
    QString url = m_httpClient->httpUrl + "/app/student/remind/tag";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqPram);
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "YMMassgeRemindManager::getRemindTag" << dataObject;
}

void YMMassgeRemindManager::onResponse(int reqCode, const QString &data)
{
    //qDebug() << "YMAccountManager::onResponse" << reqCode;
    if (m_respHandlers.contains(reqCode))
    {
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        m_respHandlers.remove(reqCode);
    }
}

YMMassgeRemindManager::~YMMassgeRemindManager()
{
    this->disconnect(m_httpClient, 0, 0, 0);
}
