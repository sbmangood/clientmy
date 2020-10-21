#include "YMRemoteManager.h"

class RemoteMgrFactory
{
    public:
        RemoteMgrFactory()
        {
            m_remoteMgr = NULL;
        }

        ~RemoteMgrFactory()
        {

        }

        YMRemoteManager * getManager()
        {
            if (m_remoteMgr == NULL)
            {
                m_remoteMgr = new YMRemoteManager();
            }
            return m_remoteMgr;
        }

        YMRemoteManager * m_remoteMgr;
};

RemoteMgrFactory g_remoteMgrFactory;

YMRemoteManager::YMRemoteManager(QObject *parent) : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    m_updateTimer = new QTimer();
    m_updateTimer->setInterval(60 * 1000);
    connect(m_updateTimer, SIGNAL(timeout()), this, SLOT(onUpdateTimerTimeout()));
    m_updateTimer->start();
}

YMRemoteManager * YMRemoteManager::instance()
{
    return g_remoteMgrFactory.getManager();
}

