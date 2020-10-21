#ifndef IANSWERCALLBACK_H
#define IANSWERCALLBACK_H
#include <QString>
#include <QJsonObject>

class IAnswerCallBack
{
public:
    virtual ~IAnswerCallBack(){}
    virtual bool onSendAnswer(int itemId, const QJsonArray &item, const QString &itemAnswer, int countDownTime) = 0;
    virtual bool onCancelAnswer(int itemId) = 0;
    virtual bool onForceFinAnswer(int itemId) = 0;
    virtual bool onQueryStatistics() = 0;

};

#endif // IANSWERCALLBACK_H
