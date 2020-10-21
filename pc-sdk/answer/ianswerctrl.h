#ifndef IANSWERCTRL_H
#define IANSWERCTRL_H
#include <QString>
#include <QJsonObject>
#include "ianswercallback.h"

class IAnswerCtrl
{
public:
    virtual ~IAnswerCtrl(){}
    virtual void init() = 0;
    virtual void uninit() = 0;
    virtual void drawAnswer(const QJsonObject &answerDataObj) = 0;
    virtual void answerStatistics(const QJsonObject &answerDataObj) = 0;
    virtual void answerCancel() = 0;
    virtual void answerForceFin() = 0;

    //设置答题器回调
    virtual void setAnswerCallBack(IAnswerCallBack* answerCallBack = 0) = 0;

};

Q_DECLARE_INTERFACE(IAnswerCtrl,"org.qt-project.Qt.Plugin.IAnswerCtrl/1.0")
#endif // IANSWERCTRL_H
