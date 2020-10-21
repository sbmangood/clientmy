#ifndef IPCCLIENT_H
#define IPCCLIENT_H

#include <QObject>
#include <QLocalSocket>

class IpcClient : public QObject
{
    Q_OBJECT
public:
    explicit IpcClient(QObject *parent = 0);
    int ClientSend(const QString &serverName, const QString &text);
    int ClientSendBlock(const QString &serverName, const QString &text);
signals:

public slots:
    void clientConnected();
    void clientErro(QLocalSocket::LocalSocketError erro);

private:
    QLocalSocket *m_client;
    QString m_text;
};

#endif // IPCCLIENT_H
