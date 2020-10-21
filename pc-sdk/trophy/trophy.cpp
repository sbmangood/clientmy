#include <qDebug>
#include "trophy.h"

QMutex Trophy::m_instanceMutex;
Trophy* Trophy::m_trophy = nullptr;
Trophy::Trophy(QObject *parent)
    :QObject(parent)
    ,m_trophyCallBack(nullptr)
{
    m_trophy = this;
}

Trophy::~Trophy()
{

}

void Trophy::init()
{

}

void Trophy::uninit()
{

}

Trophy* Trophy::getInstance()
{
    if(nullptr == m_trophy)
    {
        m_instanceMutex.lock();
        if(nullptr == m_trophy)
        {
            qWarning()<< "Trophy::get qml instance is null";
            m_trophy = new Trophy();
        }
        m_instanceMutex.unlock();
    }
    return m_trophy;
}

void Trophy::drawTrophy()
{
    sigDrawTrophy();
}


void Trophy::sendTrophy(const QString &userId, const QString &userName)
{
    if(nullptr != m_trophyCallBack)
    {
        m_trophyCallBack->onSendTrophy(userId, userName);
    }
    else
    {
        qWarning()<< "send trophy is failed, m_trophyCallBack is null";
    }
}

void Trophy::setTrophyCallBack(ITrophyCallBack* trophyCallBack)
{
    m_trophyCallBack = trophyCallBack;
}
