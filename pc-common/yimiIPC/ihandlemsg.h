#ifndef IHANDLEMSG_H
#define IHANDLEMSG_H
#include <QObject>

class IHandleMsg : public QObject
{
    Q_OBJECT
public:
    explicit IHandleMsg(QObject *parent = 0);
    virtual void handle(const QString &msg)=0;
signals:

public slots:
};

#endif // IHANDLEMSG_H
