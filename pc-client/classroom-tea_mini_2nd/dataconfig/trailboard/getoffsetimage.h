#ifndef GETOFFSETIMAGE_H
#define GETOFFSETIMAGE_H

#include <QObject>
#include"imageprovider.h"
#include<QNetworkAccessManager>
#include<QNetworkRequest>
#include<QNetworkReply>
#include<QUrl>
#include<QEventLoop>
#include<QSslConfiguration>
#include<QImage>
#include<QFile>
#include<QDir>
#include<QStandardPaths>
#include"./dataconfig/datahandl/datamodel.h"

class GetOffsetImage : public QObject
{
        Q_OBJECT
    public:
        explicit GetOffsetImage(QObject *parent = 0);
        ~GetOffsetImage();
        QImage downLoadImage(QString imageUrl);

        static GetOffsetImage  * instance()
        {
            static GetOffsetImage * getOffsetImage = new GetOffsetImage();

            return getOffsetImage;
        }
    public slots:
        //根据偏移量获取 应该被显示的图片的截取区域
        void getOffSetImage( double offSetY);
        //double resetOffsetY(double offsetY);

    public:
        ImageProvider *imageProvider;

        double currentTrailBoardHeight;

    signals:
        void reShowOffsetImage(int width, int height);

        //new 发送当前图 转化后的长度
        void sigCurrentImageHeight(double imageHeight);
        void sigDownLoadSuccess(bool downStatus);//下载完成

    public slots:
        //根据偏移量获取 应该被显示的图片的截取区域
        void getOffSetImage(QString imageUrl, double offSetY);
    public:
        QImage currentBeBufferedImage;
        double currrentImageHeight = StudentData::gestance()->midHeight;

        QString systemPublicFilePath;//图片缓存的目录

};

#endif // GETOFFSETIMAGE_H
