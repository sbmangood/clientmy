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
#include "../YMCommon/qosManager/YMQosManager.h"

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

    //下载MP3
    Q_INVOKABLE QString downLoadMp3(QString mp3Url);

    //获取长图
    Q_INVOKABLE QJsonObject getQuestionAnswer(long planId,long itemId,QString questionId);

    //    //资源类讲义底图
    //    Q_INVOKABLE QString uploadResourceImgOSS(QString lessonId,QString planId,QString itemId,QString orderNumber);

    //    //学生作业手写图片路径
    //    Q_INVOKABLE QString uploadImgOSS(QString lessonId,QString planId,QString itemId,QString orderNumber);

    //    //学生作业上传照片路径
    //    Q_INVOKABLE QString uploadPhotoImgOSS(QString lessonId,QString planId,QString itemId,QString orderNumber);

    //获取试听课报告h5的Url
    Q_INVOKABLE  QString getAuditionReportView( QString type );

    //获取试听课报告是否已经发布
    Q_INVOKABLE  bool getLessonReportStatus();

    Q_INVOKABLE QString getEndLessonH5Url();

signals:
    void sigUploadFileIamge(bool arrys );//上传是否成功
    void sigSendUrlHttp(QString urls);//上传成功后返回的url
    void sigLoadingMp3();//下载Mp3提醒信号

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

private:
    //判断图片是否需要旋转, 然后再上传(因为ipad上, 拍摄的图片, 在WIN7打开的时候, 是逆时针旋转了90度的, 造成了bug: ONLINEBUG-94)
    bool doRotateImage(QString &paths);
};

#endif // LOADINFORMATION_H
