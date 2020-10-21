#ifndef ONSIGNALHANDLER_H
#define ONSIGNALHANDLER_H

#include <QObject>

class OnSignalHandler : public QObject
{
    Q_OBJECT
public:
    explicit OnSignalHandler(QObject *parent = 0);

signals:

public slots:
    void onRecieve(QString msg);
};

#endif // ONSIGNALHANDLER_H
