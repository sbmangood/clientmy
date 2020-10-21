

 
#include <QCoreApplication>
#include <QString>
#include <QUrl>
#include <QDir>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QHttpMultiPart>

#include "HttpUploader.h"

HttpUploader::HttpUploader(QObject *parent) :
    QObject(parent),
    m_file(0)
{

}

HttpUploader::HttpUploader(const QUrl &url, QObject *parent) :
    QObject(parent),
    m_file(0)
{
    m_request.setUrl(url);
}

HttpUploader::~HttpUploader()
{
	if(m_reply) {
		qWarning("m_reply is not NULL");
		m_reply->deleteLater();
	}

	delete m_file;
}

QString HttpUploader::remoteUrl() const
{
    return m_request.url().toString();
}

void HttpUploader::setUrl(const QUrl &url)
{
    m_request.setUrl(url);
}

void HttpUploader::uploadDump(const QString& abs_file_path)
{
    Q_ASSERT(!m_file);
    Q_ASSERT(!m_reply);
    Q_ASSERT(QDir().exists(abs_file_path));
    QFileInfo fileInfo(abs_file_path);

    qDebug()<<"uploadDump"<<abs_file_path;
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(QString("form-data; name=\"%1\"; filename=\"%2\"") .arg("multipartFile") .arg(abs_file_path)));
    m_file = new QFile(abs_file_path);
    if(!m_file->open(QIODevice::ReadOnly)) return;
    filePart.setBodyDevice(m_file);
    m_file->setParent(multiPart);
    multiPart->append(filePart);

    m_reply = m_manager.post(m_request, multiPart);
    multiPart->setParent(m_reply);

    connect(m_reply, SIGNAL(uploadProgress(qint64, qint64)),
            this,      SLOT(onUploadProgress(qint64,qint64)));

    connect(m_reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this,      SLOT(onError(QNetworkReply::NetworkError)));

    connect(m_reply, SIGNAL(finished()),
            this,      SLOT(onUploadFinished()));
}

void HttpUploader::onUploadProgress(qint64 sent, qint64 total)
{
    qDebug("upload progress: %lld/%lld", sent, total);
}

void HttpUploader::onError(QNetworkReply::NetworkError err)
{
    qDebug() << err;
}

void HttpUploader::onUploadFinished()
{
    QString data = (QString)m_reply->readAll();
    qDebug() << "Upload finished";
    qDebug() << "Answer: " << data;

	if(m_reply->error() != QNetworkReply::NoError) {
        qWarning("Upload error: %d - %s", m_reply->error(), qPrintable(m_reply->errorString()));
	} else {
        qDebug() << "Upload to " << remoteUrl() << " success!";
        m_file->remove();
	}
    emit finished(data);

	m_reply->close();
	m_reply->deleteLater();
	m_reply = 0;

	delete m_file;
	m_file = 0;
}

