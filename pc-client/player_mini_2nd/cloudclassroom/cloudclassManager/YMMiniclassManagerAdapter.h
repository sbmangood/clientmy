#ifndef YMMINICLASSMANAGERADAPTER_H
#define YMMINICLASSMANAGERADAPTER_H

#include <QObject>
#include <QJsonObject>
#include <QDateTime>
#include <QJsonDocument>
#include "YMHttpClient.h"
#include "YMUserBaseInformation.h"
#include "YMEncryption.h"

class YMMiniclassManagerAdapter : public QObject
{
    Q_OBJECT
public:
    explicit YMMiniclassManagerAdapter(QObject *parent = 0);

private:
    YMHttpClient * m_httpClient;

public:
    QJsonObject getCloudDiskFileInfo(QString docId);
};

#endif // YMMINICLASSMANAGERADAPTER_H
