#include <QPluginLoader>
#include "answercenter.h"
#include "messagepack.h"
#include "datacenter.h"

AnswerCenter::AnswerCenter(ControlCenter* controlCenter)
    :m_controlCenter(controlCenter)
    ,m_answerCtrl(nullptr)
    ,m_instance(nullptr)
{

}

AnswerCenter::~AnswerCenter()
{
    uninit();
}

void AnswerCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("answer.dll", Qt::CaseInsensitive))
    {
        m_instance = loadPlugin(pluginPathName);
        if(m_instance)
        {
            m_answerCtrl  = qobject_cast<IAnswerCtrl *>(m_instance);
            if(nullptr == m_answerCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(m_instance);
                return;
            }
            m_answerCtrl->setAnswerCallBack(this);
            m_answerCtrl->init();
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

void AnswerCenter::uninit()
{
    if(m_answerCtrl)
    {
        m_answerCtrl->uninit();
        m_answerCtrl = nullptr;
    }
    if(m_instance)
    {
        unloadPlugin(m_instance);
        m_instance = nullptr;
    }
    m_controlCenter = nullptr;
}

void AnswerCenter::drawAnswer(const QJsonObject &answerDataObj)
{
    if(nullptr != m_answerCtrl)
    {
        m_answerCtrl->drawAnswer(answerDataObj);
    }
    else
    {
        qWarning()<< "draw answer is failed, m_answerCtrl is null";
    }
}

void AnswerCenter::answerStatistics(const QJsonObject &answerDataObj)
{
    if(nullptr != m_answerCtrl)
    {
        m_answerCtrl->answerStatistics(answerDataObj);
    }
    else
    {
        qWarning()<< "answer statistics is failed, m_answerCtrl is null";
    }
}

void AnswerCenter::answerCancel()
{
    if(nullptr != m_answerCtrl)
    {
        m_answerCtrl->answerCancel();
    }
    else
    {
        qWarning()<< "answer cancel is failed, m_answerCtrl is null";
    }
}

void AnswerCenter::answerForceFin()
{
    if(nullptr != m_answerCtrl)
    {
        m_answerCtrl->answerForceFin();
    }
    else
    {
        qWarning()<< "answer force fin is failed, m_answerCtrl is null";
    }
}

bool AnswerCenter::onSendAnswer(int itemId, const QJsonArray &item, const QString &itemAnswer, int countDownTime)
{
    if(m_controlCenter != nullptr)
    {
        QJsonObject obj;
        obj.insert("type", "start");
        obj.insert("itemId", itemId);
        obj.insert("item", item);
        obj.insert("itemAnswer", itemAnswer);
        obj.insert("countDownTime", countDownTime);

        QString message = MessagePack::getInstance()->questionMsg(obj);
        m_controlCenter->asynSendMessage(message);
    }
    else
    {
        qWarning() << "send answer is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

bool AnswerCenter::onCancelAnswer(int itemId)
{
    if(m_controlCenter != nullptr)
    {
        QJsonObject obj;
        obj.insert("type", "cancel");
        obj.insert("itemId", DataCenter::getInstance()->m_itemId);

        QString message = MessagePack::getInstance()->questionMsg(obj);
        m_controlCenter->asynSendMessage(message);
    }
    else
    {
        qWarning() << "send answer is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

bool AnswerCenter::onForceFinAnswer(int itemId)
{
    if(m_controlCenter != nullptr)
    {
        QJsonObject obj;
        obj.insert("type", "forceFin");
        obj.insert("itemId", DataCenter::getInstance()->m_itemId);

        QString message = MessagePack::getInstance()->questionMsg(obj);
        m_controlCenter->asynSendMessage(message);
    }
    else
    {
        qWarning() << "send answer is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

bool AnswerCenter::onQueryStatistics()
{
    if(m_controlCenter != nullptr)
    {
        QJsonObject obj;
        obj.insert("type", "statistics");
        obj.insert("itemId", DataCenter::getInstance()->m_itemId);

        QString message = MessagePack::getInstance()->questionMsg(obj);
        m_controlCenter->asynSendMessage(message);
    }
    else
    {
        qWarning() << "query statistics is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

QObject* AnswerCenter::loadPlugin(const QString &pluginPath)
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

void AnswerCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}

