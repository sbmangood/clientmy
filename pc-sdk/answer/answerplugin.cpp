#include <qqml.h>
#include "answer.h"
#include "answerplugin.h"

Answerplugin::Answerplugin(QObject *parent)
    :QQmlExtensionPlugin(parent)
{

}

Answerplugin::~Answerplugin()
{

}

void Answerplugin::init()
{
    Answer::getInstance()->init();
}

void Answerplugin::uninit()
{
    Answer::getInstance()->uninit();
}

void Answerplugin::drawAnswer(const QJsonObject &answerDataObj)
{
    Answer::getInstance()->drawAnswer(answerDataObj);
}

void Answerplugin::answerStatistics(const QJsonObject &answerDataObj)
{
    Answer::getInstance()->answerStatistics(answerDataObj);
}

void Answerplugin::answerCancel()
{
    Answer::getInstance()->answerCancel();
}

void Answerplugin::answerForceFin()
{
    Answer::getInstance()->answerForceFin();
}

void Answerplugin::setAnswerCallBack(IAnswerCallBack* answerCallBack)
{
    Answer::getInstance()->setAnswerCallBack(answerCallBack);
}

void Answerplugin::registerTypes(const char *uri)
{
    qmlRegisterType<Answer>(uri, 1, 0, "Answer");
}

