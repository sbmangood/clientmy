#include <QPluginLoader>
#include "trophycenter.h"
#include "messagepack.h"

TrophyCenter::TrophyCenter(ControlCenter* controlCenter)
    :m_controlCenter(controlCenter)
    ,m_trophyCtrl(nullptr)
    ,m_instance(nullptr)
{

}

TrophyCenter::~TrophyCenter()
{
    uninit();
}

void TrophyCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("trophy.dll", Qt::CaseInsensitive))
    {
        m_instance = loadPlugin(pluginPathName);
        if(m_instance)
        {
            m_trophyCtrl  = qobject_cast<ITrophyCtrl *>(m_instance);
            if(nullptr == m_trophyCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(m_instance);
                return;
            }
            m_trophyCtrl->setTrophyCallBack(this);
            m_trophyCtrl->init();
            qDebug()<< "qobject_cast is success, pluginPathName is" << pluginPathName;
        }
        else
        {
            qCritical()<< "load plugin is failed, pluginPathName is" << pluginPathName;
        }
    }
    else
    {
        qWarning()<< "plugin is invalid, pluginPathName is" << pluginPathName;
    }

}

void TrophyCenter::uninit()
{
    if(m_trophyCtrl)
    {
        m_trophyCtrl->uninit();
        m_trophyCtrl = nullptr;
    }
    if(m_instance)
    {
        unloadPlugin(m_instance);
        m_instance = nullptr;
    }
    m_controlCenter = nullptr;
}

void TrophyCenter::drawTrophy()
{
    if(nullptr != m_trophyCtrl)
    {
        m_trophyCtrl->drawTrophy();
    }
    else
    {
        qWarning()<< "draw trophy is failed, m_trophyCtrl is null";
    }
}

bool TrophyCenter::onSendTrophy(const QString &userId, const QString &userName)
{
    if(m_controlCenter != nullptr)
    {
        int rewardType = 1;
        int millisecond = 5000;
        QString message = MessagePack::getInstance()->rewardMsg(userId, rewardType, millisecond, userName);
        m_controlCenter->sendLocalMessage(message, true, false);
    }
    else
    {
        qWarning() << "send trophy is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

QObject* TrophyCenter::loadPlugin(const QString &pluginPath)
{
    QObject *plugin = nullptr;
    QFile file(pluginPath);
    if (!file.exists())
    {
        qWarning()<< pluginPath<< "file is not file";
        return plugin;
    }

    QPluginLoader loader(pluginPath);
    plugin = loader.instance();
    if (nullptr == plugin)
    {
        qCritical()<< pluginPath<< "failed to load plugin" << loader.errorString();
    }

    return plugin;
}

void TrophyCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}
