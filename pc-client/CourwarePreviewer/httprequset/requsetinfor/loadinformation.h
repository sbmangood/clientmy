#ifndef LOADINFORMATION_H
#define LOADINFORMATION_H

/*
 * 用于加载文件信息跟查询文件内容
*/

#include <QObject>
#include <QStringList>
#include <QProcess>
#include <QRegExp>
#include <QDir>
#include <QFile>
#include <QIODevice>
#include <QDateTime>
#include <QByteArray>
#include <QDebug>
#include <QFile>
#include <QTextCodec>
#include <QDir>
#include <QFileInfoList>
#include <QFileInfo>
#include <QFile>
#include <QCoreApplication>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QCryptographicHash>
#include <QByteArray>
#include <QPixmap>
#include <QDataStream>
#include <QHttpMultiPart>
#include <QDateTime>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include "./dataconfig/datahandl/datamodel.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"

class LoadInforMation : public QObject
{
        Q_OBJECT
    public:
        explicit LoadInforMation(QObject *parent = 0);
        ~LoadInforMation();
        //上传图片
        Q_INVOKABLE  void uploadFileIamge(QString paths ) ;

        //上传图片返回路径
        Q_INVOKABLE QString uploadImage(QString paths);

        //题目类图OSS上传图片
        Q_INVOKABLE QString uploadQuestionImgOSS(QString planId, QString itemId, QString orderNumber, QString ImgName, QString filePath);

//    //资源类讲义底图
//    Q_INVOKABLE QString uploadResourceImgOSS(QString lessonId,QString planId,QString itemId,QString orderNumber);

//    //学生作业手写图片路径
//    Q_INVOKABLE QString uploadImgOSS(QString lessonId,QString planId,QString itemId,QString orderNumber);

//    //学生作业上传照片路径
//    Q_INVOKABLE QString uploadPhotoImgOSS(QString lessonId,QString planId,QString itemId,QString orderNumber);

    signals:
        void sigUploadFileIamge(bool arrys );//上传是否成功
        void sigSendUrlHttp(QString urls);//上传成功后返回的url

    protected slots:
        void onUploadReadyRead(QNetworkReply* );
        void upLoadError(QNetworkReply::NetworkError erros);
        void onUploadProgress(qint64 lens, qint64 totals );
        void httpUploadReadyRead();

    private:
        YMHttpClient * m_httpClient;
        QNetworkAccessManager * m_httpAccessmanger;
        QNetworkAccessManager * m_uploadFileIamge;
        QNetworkReply * m_replyFileIamge;
        QFile * m_imageFiles;
        QHttpMultiPart * m_multiPart;
        QString m_httpIP;
        QString downHttp;
        QString uploadHttp;
        QString questionHttp;
};

#endif // LOADINFORMATION_H
