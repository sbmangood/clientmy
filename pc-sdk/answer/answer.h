#ifndef ANSWER_H
#define ANSWER_H

#include <QMutex>
#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include "ianswercallback.h"

class Answer : public QObject
{
    Q_OBJECT
public:
    Answer(QObject *parent = 0);
    ~Answer();

    static Answer* getInstance();
    void init();
    void uninit();

    void drawAnswer(const QJsonObject &answerDataObj);
    void answerStatistics(const QJsonObject &answerDataObj);
    void answerCancel();
    void answerForceFin();
    //设置答题器回调
    void setAnswerCallBack(IAnswerCallBack* answerCallBack = 0);

    //发送答题器
    Q_INVOKABLE void sendAnswer(int itemId, const QJsonArray &item, const QString &itemAnswer, int countDownTime);
    //取消答题
    Q_INVOKABLE void cancelAnswer(int itemId);
    //强制收回答题
    Q_INVOKABLE void forceFinAnswer(int itemId);
    //查询答题统计
    Q_INVOKABLE void queryStatistics();

signals:
    //答题器数据统计
    void sigAnswerStatistics(const QJsonArray &itemData, const QString &itemAnswer, int submitNum, int accuracy);
    void sigDrawAnswer(int itemId, const QJsonObject &item, const QString &itemAnswer, int countDownTime);
    void sigAnswerCancel();
    void sigAnswerForceFin();

private:
    static QMutex m_instanceMutex;
    static Answer* m_answer;
    IAnswerCallBack* m_answerCallBack;
    QString m_itemAnswer;
};

#endif // ANSWER_H
