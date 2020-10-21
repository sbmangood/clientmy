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


#define DOWNHTTP  "http://"+StudentData::gestance()->apiUrl+"/lesson/viewStuLessonDoc?"
#define UPLOADHTTP  "http://"+StudentData::gestance()->apiUrl+"/file/uploadLessonImg?"

class LoadInforMation : public QObject
{
        Q_OBJECT
    public:
        explicit LoadInforMation(QObject *parent = 0);
        ~LoadInforMation();
        //上传图片
        Q_INVOKABLE  void uploadFileIamge(QString paths ) ;

    signals:
        void sigUploadFileIamge(bool arrys );//上传是否成功
        void sigSendUrlHttp(QString urls);//上传成功后返回的url

    protected slots:
        void onUploadReadyRead(QNetworkReply* );
        void upLoadError(QNetworkReply::NetworkError erros);
        void onUploadProgress(qint64 lens, qint64 totals );
        void httpUploadReadyRead();


    private:
        QNetworkAccessManager * m_uploadFileIamge;
        QNetworkReply * m_replyFileIamge;
        QFile * m_imageFiles;
        QHttpMultiPart * m_multiPart;



};

#endif // LOADINFORMATION_H
