#ifndef ANSWERCENTER_H
#define ANSWERCENTER_H
#include "controlcenter.h"
#include "../answer/ianswerctrl.h"
#include "../answer/ianswercallback.h"

class AnswerCenter : public IAnswerCallBack
{
public:
    AnswerCenter(ControlCenter* controlCenter);
    virtual ~AnswerCenter();

    void init(const QString &pluginPathName);
    void uninit();

    void drawAnswer(const QJsonObject &answerDataObj);
    void answerStatistics(const QJsonObject &answerDataObj);
    void answerCancel();
    void answerForceFin();
    virtual bool onSendAnswer(int itemId, const QJsonArray &item, const QString &itemAnswer, int countDownTime);
    virtual bool onCancelAnswer(int itemId);
    virtual bool onForceFinAnswer(int itemId);
    virtual bool onQueryStatistics();

private:
    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

private:
    QObject* m_instance;
    IAnswerCtrl* m_answerCtrl;
    ControlCenter* m_controlCenter;
};

#endif // ANSWERCENTER_H
