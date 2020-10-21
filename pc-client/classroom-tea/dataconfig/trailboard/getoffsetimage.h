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
    Q_PROPERTY( double midHeight READ getMidHeight  WRITE writeMidHeight)
    Q_PROPERTY( double midWidth READ getMidWidth  WRITE writeMidWidth)
    Q_PROPERTY( double fullHeight READ getFullHeight  WRITE writeFullHeight)
    Q_PROPERTY( double fullWidth READ getFullWidth  WRITE writeFullWidth)

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
    double getMidHeight();
    double getMidWidth();
    double getFullHeight();
    double getFullWidth();

    void writeMidHeight(double midHeights);
    void writeMidWidth(double midWidths);
    void writeFullHeight(double fullHeights);
    void writeFullWidth(double fullWidths);
    void initGetoffsetImg(double midHeights,double midWidths,double fullHeights,double fullWidths,QString lessonId,bool isCouldUseNewBoards);

public:
    ImageProvider *imageProvider;

    double currentTrailBoardHeight;//当前的画板高度

    QImage currentBeBufferedImage;//当前被缓存的图
    double currrentImageHeight;

    QString systemPublicFilePath;//图片缓存的目录

    double midHeight,midWidth,fullHeight,fullWidth;//画板的未放大时和放大时的高度和宽度
    bool isCouldUseNewBoard = false;//是否可以启用新比例画板
    QString lessonId = "0";

signals:
    void reShowOffsetImage(int width, int height);

    //new 发送当前图 转化后的长度
    void sigCurrentImageHeight(double imageHeight);
    void sigDownLoadSuccess(bool downStatus);//下载完成

public slots:
    //根据偏移量获取 应该被显示的图片的截取区域
    void getOffSetImage(QString imageUrl, double offSetY);

};

#endif // GETOFFSETIMAGE_H
