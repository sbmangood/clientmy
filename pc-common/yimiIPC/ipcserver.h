#ifndef IPCSERVER_H
#define IPCSERVER_H

#include <QObject>
#include <QLocalServer>
#include <QLocalSocket>
#include <queue>

#include "ihandlemsg.h"

class IpcServer : public QObject
{
    Q_OBJECT
public:
    explicit IpcServer(const QString &servername, IHandleMsg *ihm,QObject *parent = 0);

private:
    bool isServerRun(const QString &servername);

signals:

private slots:
    void ServerNewConnection();
    void ServerReadyRead();

private:
    QLocalServer *m_server;
    IHandleMsg *m_ihm;
    std::queue<QLocalSocket*> m_lsq;
    quint16 m_blockSize;
};

#endif // IPCSERVER_H
