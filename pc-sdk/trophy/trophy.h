#ifndef TROPHY_H
#define TROPHY_H

#include <QMutex>
#include <QObject>
#include "itrophycallback.h"

class Trophy : public QObject
{
    Q_OBJECT
public:
    Trophy(QObject *parent = 0);
    ~Trophy();

    static Trophy* getInstance();
    void init();
    void uninit();
    //绘制奖杯
    void drawTrophy();
    //发送奖杯
    Q_INVOKABLE void sendTrophy(const QString &userId, const QString &userName);
    //设置奖杯回调
    void setTrophyCallBack(ITrophyCallBack* trophyCallBack = 0);

signals:
    //绘制奖杯信号
    void sigDrawTrophy();

private:
    static QMutex m_instanceMutex;
    static Trophy* m_trophy;
    ITrophyCallBack* m_trophyCallBack;
};

#endif // TROPHY_H
