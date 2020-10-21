#include "lessonevalution.h"
#include <QDir>
#include <QStandardPaths>
#include <QEventLoop>
#include <QCryptographicHash>
#include <QCoreApplication>
#include "../YMUserBaseInformation.h"


#define APIVERSION "4.0"

LessonEvalution::LessonEvalution(QObject *parent)
    : QObject(parent)
{
    m_httpClient = new HttpClient();
}

LessonEvalution::~LessonEvalution()
{
    if(m_httpClient)
    {
        delete m_httpClient;
        m_httpClient = nullptr;
    }
}

//获取课程结束时评价的配置
int LessonEvalution::getLessonEvalutionConfig(const QString &apiUrl, const QString &apiToken, const QString & curUserRole, const QString &appVersion)
{
    QString appVersion0 = YMUserBaseInformation::appVersion;
    QString apiUrl0 = "http://liveroom.yimifudao.com.cn/v1.0.0/openapi";
    if( YMUserBaseInformation::envType != "api")
    {
        apiUrl0 = apiUrl0.replace("liveroom",YMUserBaseInformation::envType + "-liveroom");
    }

    QString url = apiUrl0 + "/app/comment/getConfig";
    QDateTime currentTime = QDateTime::currentDateTime();

    QJsonObject obj;
    obj.insert("type", curUserRole);
    obj.insert("appVersion", appVersion0);
    obj.insert("apiVersion", APIVERSION);
//    obj.insert("token", apiToken);
    obj.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));


    QJsonDocument docparam(obj);
    QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));
    QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, parammsg, apiToken, 15000);

    if(!jsonObj.empty() && jsonObj.value("message").toString().toLower() == "success")
    {
        qDebug() << "getLessonEvalutionConfig revc "<< jsonObj;

        if(jsonObj.contains("data"))
        {
            m_lessonCommentConfigInfo = jsonObj.value("data").toArray();
            emit sigLessonEvalutionConfig(m_lessonCommentConfigInfo);
        }
    }
    else
    {
        qWarning()<< "get api msg is empty, url is " << url;
        return -1;
    }
    return 0;

}

int LessonEvalution::submitTeaLessonEvalution(const QString &apiUrl, const QString &apiToken, QString param1, QString param2, QString param3, QString param4, QString param5, const QString &userId, const QString &roomId,const QString &appVersion)
{
    QString appVersion0 = YMUserBaseInformation::appVersion;
    QString apiUrl0 = "http://liveroom.yimifudao.com.cn/v1.0.0/openapi";
    if( YMUserBaseInformation::envType != "api")
    {
        apiUrl0 = apiUrl0.replace("liveroom",YMUserBaseInformation::envType + "-liveroom");
    }

    QString url = apiUrl0 + "/app/comment/submit";
    QString paramId1 = "param1";
    QString paramId2 = "param2";
    QString paramId3 = "param3";
    QString paramId4 = "param4";
    QString paramId5 = "param5";

    QString paramTitle1 = "知识掌握情况";
    QString paramTitle2 = "课堂表现";
    QString paramTitle3 = "老师评价";
    QString paramTitle4 = "";
    QString paramTitle5 = "";

    for(int i = 0; i < m_lessonCommentConfigInfo.size(); i++)
    {
        QJsonObject lessonObj = m_lessonCommentConfigInfo.at(i).toObject();
        QString paramId = lessonObj.value("paramId").toString();
        QString paramTitle = lessonObj.value("paramTitle").toString();
        if(i == 0)
        {
            paramId1 = paramId;
            paramTitle1 = paramTitle;
        }
        if(i == 1)
        {
            paramId2 = paramId;
            paramTitle2 = paramTitle;
        }
        if(i == 2)
        {
            paramId3 = paramId;
            paramTitle3 = paramTitle;
        }
        if(i == 3)
        {
            paramId4 = paramId;
            paramTitle4 = paramTitle;
        }
        if(i == 4)
        {
            paramId5 = paramId;
            paramTitle5 = paramTitle;
        }
    }

    QJsonObject obj;
    obj.insert("userId", userId);
    obj.insert("roomId", roomId);
    obj.insert("type", "TEA");
    obj.insert("apiVersion", APIVERSION);
    obj.insert("appVersion", appVersion0);
    obj.insert(paramId1, param1);
    obj.insert(paramId2, param2);
    obj.insert(paramId3, param3);
    obj.insert(paramId4, param4);
    obj.insert(paramId5, param5);

    QDateTime times = QDateTime::currentDateTime();
    obj.insert("timestamp", times.toString("yyyyMMddhhmmss"));

    QString s_param;
    s_param.append(paramTitle1).append("#").append(paramTitle2).append("#").append(paramTitle3).append("#").append(paramTitle4).append("#").append(paramTitle5);
    obj.insert("titles", s_param);

    QJsonDocument doc(obj);
    QString msg = QString(doc.toJson(QJsonDocument::Compact));

    QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, msg, apiToken, 15000);
    if(!jsonObj.empty() && jsonObj.value("message").toString().toLower() == "success")
    {
        qDebug() << "submitTeaLessonEvalution  sucsesss "<< jsonObj;
    }
    else
    {
        qWarning()<< "get api msg is empty, url is " << url;
        return -1;
    }

    return 0;
}

//设发送评价
int LessonEvalution::submitStuLessonEvalution(const QString &apiUrl, const QString &apiToken, int status1, int status2, int status3, QString tags, const QString &userId, const QString &roomId,const QString &appVersion)
{
    QString url = apiUrl + "/app/comment/submit";

    QString paramId1 = "param1";
    QString paramId2 = "param2";
    QString paramId3 = "param3";

    QString paramTitle1 = "知识掌握情况";
    QString paramTitle2 = "课堂表现";
    QString paramTitle3 = "老师评价";

    for(int i = 0; i < m_lessonCommentConfigInfo.size(); i++)
    {
        QJsonObject lessonObj = m_lessonCommentConfigInfo.at(i).toObject();
        QString paramId = lessonObj.value("paramId").toString();
        QString paramTitle = lessonObj.value("paramTitle").toString();
        if(i == 0)
        {
            paramId1 = paramId;
            paramTitle1 = paramTitle;
        }
        if(i == 1)
        {
            paramId2 = paramId;
            paramTitle2 = paramTitle;
        }
        if(i == 2)
        {
            paramId3 = paramId;
            paramTitle3 = paramTitle;
        }
    }

    QString param1 = status1 == 1 ? QStringLiteral("是") : QStringLiteral("否");
    QString param2 = status2 == 1 ? QStringLiteral("是") : QStringLiteral("否");
    QString param3 = status3 == 1 ? QStringLiteral("是") : QStringLiteral("否");


    QDateTime times = QDateTime::currentDateTime();
    QJsonObject obj;
    obj.insert("userId", userId);
    obj.insert("roomId", roomId);
    obj.insert("type", "STU");
    obj.insert("apiVersion", APIVERSION);
    obj.insert("appVersion", appVersion);
    obj.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    obj.insert(paramId1, param1);
    obj.insert(paramId2, param2);
    obj.insert(paramId3, param3);
    obj.insert("param4", tags);

    QJsonDocument doc(obj);
    QString msg = QString(doc.toJson(QJsonDocument::Compact));

    QJsonObject jsonObj = m_httpClient->syncRequestMsg(url, msg, apiToken, 15000);
    if(!jsonObj.empty() && jsonObj.value("message").toString().toLower() == "success")
    {
        qDebug() << "submitStuLessonEvalution  sucsesss "<< jsonObj;

    }
    else
    {
        qWarning()<< "get api msg is empty, url is " << url;
        return -1;
    }

return 0;
}

QString LessonEvalution::md5Encryption(QVariantMap dataMap)
{
    QString sign = "";
    for(auto it = dataMap.begin(); it != dataMap.end(); ++it)
    {
        sign.append(it.key()).append("=").append(QString::fromUtf8( it.value().toByteArray()));
        if(it != dataMap.end() - 1)
        {
            sign.append("&");
        }
    }

    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(sign.toUtf8());
    return QString(hash.result().toHex());
}
