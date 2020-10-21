#ifndef YMMASSGEREMINDMANAGER_H
#define YMMASSGEREMINDMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QTimer>
#include "YMHttpClient.h"

class YMMassgeRemindManager : public QObject, public YMHttpResponseHandler
{
        Q_OBJECT
    public:
        explicit YMMassgeRemindManager(QObject *parent = 0);
        ~YMMassgeRemindManager();

        Q_INVOKABLE void getRemind(int type, int page);
        Q_INVOKABLE void getNewRemind(int type, int page);
        Q_INVOKABLE void getRemindTag(QJsonArray idList);
        Q_INVOKABLE void getCurrentStage();
        Q_INVOKABLE void updateStage(int netType,QString stageInfo);

    protected:
        virtual void onResponse(int reqCode, const QString &data);

    private:
        YMHttpClient * m_httpClient;
        QTimer * m_timer;
        QTimer * m_timerOut;

        typedef void (YMMassgeRemindManager::* HttpRespHandler)(const QString& data);
        QMap<int, HttpRespHandler> m_respHandlers;

    signals:
        void requestTimerOut();
        void sigStageInfo(int netType,QString stageInfo);

    public slots:
        void onSearchRmind();

    signals:
        void remindChange(QJsonObject remindData);
        void remindTagChange(QJsonObject remindTag);
        void remindNewChange(QJsonObject remindNew);
};

#endif // YMMASSGEREMINDMANAGER_H
