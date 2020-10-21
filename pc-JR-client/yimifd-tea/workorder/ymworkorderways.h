#ifndef YMWORKORDERWAYS_H
#define YMWORKORDERWAYS_H

#include <QObject>
#include<QSettings>
#include<QNetworkAccessManager>
#include<QNetworkReply>
#include<QNetworkRequest>
#include<QFile>
#include<QEventLoop>
#include<QJsonDocument>
#include<QJsonObject>
#include<QJsonParseError>
#include<QSettings>
#include<QJsonArray>
#include<QJsonValue>
#include<QStandardPaths>
#include<QDir>
#include"YMUserBaseInformation.h"
#include<QTimer>
#include<QHttpPart>
#include<QNetworkInterface>
#include "YMHttpClient.h"
#include "YMEncryption.h"
#include "YMUserBaseInformation.h"

class YMWorkOrderways : public QObject
{
        Q_OBJECT
    public:
        explicit YMWorkOrderways(QObject *parent = 0);
        ~YMWorkOrderways();
    signals:
        void creatWorkOrderSuccessOrFail(bool successs);
    public slots:
        QString getWorkOrderList(QString type, int page);
        QString getWorkOrderListDetails(QString orderId);
        QString closeWorkOrder(QString orderId, QString comment, QString likeType);
        QString getWOrkOrderAllTypes();
        QString uploadImage(QString paths, QString lessonId);
        void creatWorkOrderSheet(QString lessonId, QString urgentType, QString content, QString questionType, QString imgUrl );
        bool reCommitWorkOrder(QString orderId, QString content, QString imgUrl);
#ifdef USE_OSS_AUTHENTICATION
        QString getOssSignUrl(QString ImgUrl);
#endif
    private:
        QNetworkAccessManager *m_httpAccessmanger;
        QFile * m_imageFiles;
        QHttpMultiPart * m_multiPart;
#ifdef USE_OSS_AUTHENTICATION
        QMap<QString, long> m_bufferOssKey;
#endif
        QString getLocalHostIp(int type);
        YMHttpClient *m_httpClient;
};

#endif // YMWORKORDERWAYS_H
