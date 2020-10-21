#ifndef LessonEvalution_H
#define LessonEvalution_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QString>
#include "httpclient.h"
class LessonEvalution : public QObject
{
        Q_OBJECT
    public:
        explicit LessonEvalution(QObject *parent = 0);
        ~LessonEvalution();

        //获取课程结束时评价的配置
        Q_INVOKABLE int getLessonEvalutionConfig(const QString &apiUrl, const QString &apiToken, const QString & curUserRole, const QString &appVersion);
        //设发送评价
        Q_INVOKABLE int submitTeaLessonEvalution(const QString &apiUrl, const QString &apiToken, QString param1, QString param2, QString param3, QString param4, QString param5, const QString &userId, const QString &roomId,const QString &appVersion);
        Q_INVOKABLE int submitStuLessonEvalution(const QString &apiUrl, const QString &apiToken, int status1, int status2, int status3, QString tags, const QString &userId, const QString &roomId,const QString &appVersion);

private:
        QString md5Encryption(QVariantMap);

    signals:
        void sigLessonEvalutionConfig(QJsonArray dataArray);//课程结束时评价的配置

    private:
        HttpClient* m_httpClient;
        QJsonArray m_lessonCommentConfigInfo;

};

#endif // LessonEvalution_H
