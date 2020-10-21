#include <qDebug>
#include "answer.h"

QMutex Answer::m_instanceMutex;
Answer* Answer::m_answer = nullptr;
Answer::Answer(QObject *parent) :
    QObject(parent)
  ,m_answerCallBack(nullptr)
{
    m_answer = this;
}

Answer::~Answer()
{

}

void Answer::init()
{

}

void Answer::uninit()
{

}

Answer* Answer::getInstance()
{
    if(nullptr == m_answer)
    {
        m_instanceMutex.lock();
        if(nullptr == m_answer)
        {
            qWarning()<< "Answer::get qml instance is null";
            m_answer = new Answer();
        }
        m_instanceMutex.unlock();
    }
    return m_answer;
}

void Answer::drawAnswer(const QJsonObject &answerDataObj)
{
    if(!answerDataObj.empty())
    {
        int itemId = answerDataObj["itemId"].toInt();
        QJsonObject item = answerDataObj["item"].toObject();
        QString itemAnswer = answerDataObj["itemAnswer"].toString();
        int countDownTime = answerDataObj["countDownTime"].toInt();
        emit sigDrawAnswer(itemId, item, itemAnswer, countDownTime);
    }

}

void Answer::answerStatistics(const QJsonObject &answerDataObj)
{
    if(!answerDataObj.empty())
    {
        QJsonArray itemData;
        QString tempAnswer;
        int submitNum = 0;
        int correctNum = 0;
        int accuracy = 0;

        qDebug() <<"answerStatistics --"<<answerDataObj;
        itemData = answerDataObj.value("itemData").toArray();
        for(int i = 0; i < itemData.size();i++)
        {

            QJsonObject obj = itemData[i].toObject();
            tempAnswer = obj["itemName"].toString();
            int value = obj["value"].toInt();
            submitNum += value;
            qDebug() <<"answerStatistics---"<<obj<< tempAnswer<< value;
            if(m_itemAnswer == tempAnswer)
            {
                correctNum = value;
            }
        }

        if(submitNum > 0)
        {
            accuracy = (correctNum*1.0 / submitNum) * 100;
        }

        emit sigAnswerStatistics(itemData, m_itemAnswer, submitNum, accuracy);
    }

}

void Answer::answerCancel()
{
    emit sigAnswerCancel();
}

void Answer::answerForceFin()
{
    emit sigAnswerForceFin();
}

void Answer::setAnswerCallBack(IAnswerCallBack* answerCallBack)
{
    m_answerCallBack = answerCallBack;
}

void Answer::sendAnswer(int itemId, const QJsonArray &item, const QString &itemAnswer, int countDownTime)
{
    if(nullptr != m_answerCallBack)
    {
        m_itemAnswer = itemAnswer;
        m_answerCallBack->onSendAnswer(itemId, item, itemAnswer, countDownTime);
    }
    else
    {
        qWarning()<< "send answer is failed, m_answerCallBack is null"<< itemId<< itemAnswer;
    }
}

void Answer::cancelAnswer(int itemId)
{
    if(nullptr != m_answerCallBack)
    {
        m_answerCallBack->onCancelAnswer(itemId);
    }
    else
    {
        qWarning()<< "cancel answer is failed, m_answerCallBack is null";
    }
}

void Answer::forceFinAnswer(int itemId)
{
    if(nullptr != m_answerCallBack)
    {
        m_answerCallBack->onForceFinAnswer(itemId);
    }
    else
    {
        qWarning()<< "force fin answer is failed, m_answerCallBack is null";
    }
}

//查询答题统计
void Answer::queryStatistics()
{
    if(nullptr != m_answerCallBack)
    {
        m_answerCallBack->onQueryStatistics();
    }
    else
    {
        qWarning()<< "query statistics is failed, m_answerCallBack is null";
    }
}

