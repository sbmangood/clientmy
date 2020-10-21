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
#include"../YMCommon/qosManager/YMQosManager.h"

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

    public:
        ImageProvider *imageProvider;

        double currentTrailBoardHeight;

    signals:
        void reShowOffsetImage();

        //new 发送当前图 转化后的长度
        void sigCurrentImageHeight(double imageHeight);

    public slots:
        //根据偏移量获取 应该被显示的图片的截取区域
        void getOffSetImage(QString imageUrl, double offSetY);

        //重新给offsetY赋值 避免取过界 黑屏
        double resetOffsetY(double offsetY, double zoomRate);
    public:
        QImage currentBeBufferedImage;
        double currrentImageHeight = StudentData::gestance()->midHeight;

        QString systemPublicFilePath;//图片缓存的目录

};

#endif // GETOFFSETIMAGE_H
