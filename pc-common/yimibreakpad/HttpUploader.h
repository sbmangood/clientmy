
 
#ifndef QBREAKPAD_HTTP_SENDER_H
#define QBREAKPAD_HTTP_SENDER_H

#include <QObject>
#include <QPointer>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class QString;
class QUrl;
class QFile;

class HttpUploader : public QObject
{
	Q_OBJECT
public:
    HttpUploader(QObject *parent=0);
    HttpUploader(const QUrl& url, QObject *parent=0);
    ~HttpUploader();

    //TODO: proxy, ssl
    QString remoteUrl() const;
    void setUrl(const QUrl& url);

signals:
    void finished(QString answer);

public slots:
    void uploadDump(const QString& abs_file_path);

private slots:
    void onUploadProgress(qint64 sent, qint64 total);
    void onError(QNetworkReply::NetworkError err);
    void onUploadFinished();

private:
    QNetworkAccessManager m_manager;
    QNetworkRequest m_request;
    QPointer<QNetworkReply> m_reply;
    QFile* m_file;
};

#endif	// QBREAKPAD_HTTP_SENDER_H
