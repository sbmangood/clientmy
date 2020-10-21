#ifndef YMREMOTEMANAGER_H
#define YMREMOTEMANAGER_H

#include <QObject>
#include <QTimer>
#include "YMHttpClient.h"

class RemoteMgrFactory;

class YMRemoteManager : public QObject
{
        Q_OBJECT

        friend class RemoteMgrFactory;

    public:
        explicit YMRemoteManager(QObject *parent = 0);

        static YMRemoteManager * instance();

    private:
        YMHttpClient *  m_httpClient;

        QTimer * m_updateTimer;

};

#endif // YMREMOTEMANAGER_H
