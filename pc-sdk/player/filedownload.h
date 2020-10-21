#ifndef FILEDOWNLOAD_H
#define FILEDOWNLOAD_H

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "YMHttpClient.h"


class FileDownload : public QObject
{
    Q_OBJECT
public:
    explicit FileDownload(QObject *parent = 0);
    ~FileDownload();

    //小班课查看录播
    Q_INVOKABLE void getPlayback(QString appUrl, QString lessonId, QString appId);

signals:
    void sigDownLoadFailed();
    void setDownValue(int min, int max);
    void downloadChanged(int currentValue);
    void downloadFinished(const QString& lessonId,const QString& date, const QString& filePath, const QString& trailName);

private:
    void downloadMiniPlayFile(const QString &roomId, QJsonArray dataArray);
    void writeFile(QString liveroomId,QString path,int fileNumber,QString suffix);

private:
    YMHttpClient * m_httpClient;

};

#endif // FILEDOWNLOAD_H
