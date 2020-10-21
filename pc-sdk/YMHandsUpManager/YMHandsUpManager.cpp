#include "YMHandsUpManager.h"

YMHandsUpManager* YMHandsUpManager::m_YMHandsUpManager = NULL;

YMHandsUpManager::YMHandsUpManager()
{
}

YMHandsUpManager::~YMHandsUpManager()
{

}

YMHandsUpManager* YMHandsUpManager::getInstance()
{
    if(NULL == m_YMHandsUpManager)
    {
        m_YMHandsUpManager = new YMHandsUpManager();
    }
    return m_YMHandsUpManager;
}

int YMHandsUpManager::initHandsUp(QJsonObject json)
{
    return 0;
}

int YMHandsUpManager::raiseHandForUp(QString userId, QString groupId)
{
    QJsonObject content;
    content.insert("groupId", groupId.toInt());
    content.insert("uid", userId);
    content.insert("type", "req");
    emit sigMsgContent(content);
    return 0;
}

int YMHandsUpManager::cancelHandsUp(QString userId, QString groupId)
{
    QJsonObject content;
    content.insert("groupId", groupId.toInt());
    content.insert("uid", userId);
    content.insert("type", "cancel");
    emit sigMsgContent(content);
    return 0;
}

int YMHandsUpManager::processResponse(QString userId, int operation)
{
    emit sigHandsUpEvent(userId, operation);
    return 0;
}

int YMHandsUpManager::processHandsUp(QString userId, uint groupId, TEA_OPERATION operation)
{
    QJsonObject content;
    content.insert("groupId", QString::number(groupId).toInt());
    content.insert("uid", userId);
    QString type;
    if(operation == FORCE_UP)// 强制上台
    {
        type = "forceUp";
    }
    else if(operation == FORCE_DOWN)// 强制下台
    {
        type = "forceDown";
    }
    else if(operation == AGREE)// 同意上台
    {
        type = "agree";
    }
    else if(operation == REFUSE)// 拒绝上台
    {
        type = "refused";
    }
    else// 其他
    {

    }
    content.insert("type", type);
    emit sigMsgContent(content);
    return 0;
}

int YMHandsUpManager::updateAllStudentList(QString userId, uint groupId, int state)
{
    return 0;
}

int YMHandsUpManager::updateUpStudentList(QString userId, uint groupId, int operation)
{
    return 0;
}
