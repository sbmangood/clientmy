#include "ipcclient.h"
#include <QDataStream>

IpcClient::IpcClient(QObject *parent) : QObject(parent)
{

}

int IpcClient::ClientSend(const QString &serverName, const QString &text)
{
    m_client = new QLocalSocket;
    m_text = text;
    connect(m_client,SIGNAL(connected()),this,SLOT(clientConnected()));
    connect(m_client,SIGNAL(error(QLocalSocket::LocalSocketError)),this,SLOT(clientErro(QLocalSocket::LocalSocketError)));
    m_client->connectToServer(serverName);
    return 0;
}

int IpcClient::ClientSendBlock(const QString &serverName, const QString &text)
{
    QLocalSocket *client=new QLocalSocket;
    client->connectToServer(serverName);
    if(client->waitForConnected(1000)){
        QByteArray block;
        QDataStream out(&block, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_4_0);
        out << (quint16)0;
        out << text;
        out.device()->seek(0);
        out << (quint16)(block.size() - sizeof(quint16));
        connect(client, SIGNAL(disconnected()),client, SLOT(deleteLater()));
        client->write(block);
        if(!client->waitForBytesWritten(1000)){
        }
        client->disconnectFromServer();
        return 0;
    } else {
        client->deleteLater();
        return -1;
    }
}

void IpcClient::clientConnected()
{
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_0);
    out << (quint16)0;
    out << m_text;
    out.device()->seek(0);
    out << (quint16)(block.size() - sizeof(quint16));
    connect(m_client, SIGNAL(disconnected()),m_client, SLOT(deleteLater()));
    m_client->write(block);
    m_client->flush();
    m_client->disconnectFromServer();
}

void IpcClient::clientErro(QLocalSocket::LocalSocketError erro)
{

}
