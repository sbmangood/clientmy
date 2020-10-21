#include "getoffsetimage.h"

GetOffsetImage::GetOffsetImage(QObject *parent) : QObject(parent)
{
    currrentImageHeight = StudentData::gestance()->midHeight;
    imageProvider = new ImageProvider();
    //初始化保存当前画板高度 为了全屏时 重新获取图片偏移过后的图片
    currentTrailBoardHeight = StudentData::gestance()->midHeight;
    qDebug() << "***********currentTrailBoardHeight***************" << currentTrailBoardHeight;
}

GetOffsetImage::~GetOffsetImage()
{
    delete imageProvider;
}


QImage GetOffsetImage::downLoadImage(QString imageUrl)
{
    emit sigDownLoadSuccess(true);
    QString imageName = "temp.jpg";
    if(imageUrl.split("/").size() > 0)
    {
        imageName = imageUrl.split("/").takeLast();

#ifdef USE_OSS_AUTHENTICATION
        int indexOf = imageName.indexOf("?");
        imageName = imageName.mid(0, indexOf);
#endif
        if(StudentData::gestance()->isNewPlay){
            int lastIndex = imageName.lastIndexOf(".");
            if(lastIndex <= 0){
                imageName = imageName +  ".png";
                int suffixIndex = imageName.lastIndexOf("=");
                imageName = imageName.mid(suffixIndex + 1,imageName.length() - suffixIndex);
                //qDebug() << "=======#########=========="<< imageName;
            }
        }
    }

    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    if (docPath == "")
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    if(StudentData::gestance()->isNewPlay)
    {
        systemPublicFilePath += "YiMi/PlayerNewImage/" + StudentData::gestance()->m_lessonId + "/";
    }
    else
    {
        systemPublicFilePath += "YiMi/PlayerImage/" + StudentData::gestance()->m_lessonId + "/";
    }
    QDir isDir;
    if (!isDir.exists(systemPublicFilePath))
    {
        isDir.mkpath(systemPublicFilePath);
    }

    imageName = systemPublicFilePath + imageName;
    if(QFile::exists(imageName))
    {
        currentBeBufferedImage.load(imageName);
        currrentImageHeight = currentBeBufferedImage.height();
        emit sigDownLoadSuccess(false);
        return currentBeBufferedImage;
    }
    else
    {
        //不存在就下载然后返回 缩放后的图片 以及高度
        QNetworkAccessManager *networkMgr = new QNetworkAccessManager();
        QNetworkRequest httpRequest;

#ifdef USE_OSS_AUTHENTICATION
        httpRequest.setUrl(QUrl(imageUrl));
#else
        QSslConfiguration conf = httpRequest.sslConfiguration();
        conf.setPeerVerifyMode(QSslSocket::VerifyNone);
        conf.setProtocol(QSsl::TlsV1SslV3);
        httpRequest.setSslConfiguration(conf);
        httpRequest.setUrl(QUrl(imageUrl));
        httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
#endif // #ifdef USE_OSS_AUTHENTICATION

        httpRequest.setUrl(QUrl(imageUrl));
        QEventLoop httploop;
        connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));

        QNetworkReply *httpReply = networkMgr->get(httpRequest);

        httploop.exec();
        QByteArray readData = httpReply->readAll();
        QImage tempImage = QImage::fromData(readData);

        qDebug() << "GetOffsetImage::downLoadImage" << currentBeBufferedImage.width() << currentBeBufferedImage.height();
        //计算缩放后的比列
        double rate = 0.618;
        double imgheight = tempImage.height();
        double imgwidth = tempImage.width();
        double multiple = imgheight / imgwidth / rate;

        double transImageHeight  = StudentData::gestance()->midHeight * multiple  ;
        if(StudentData::gestance()->isNewPlay)
        {
            transImageHeight = StudentData::gestance()->midWidth / tempImage.width()   * tempImage.height();
        }
        //平滑缩放
        currentBeBufferedImage = tempImage.scaled(StudentData::gestance()->midWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        currentBeBufferedImage.save(imageName);

        qDebug() << "GetOffsetImage::downLoadImage:: transImageHeight" << transImageHeight << tempImage.width() << tempImage.height();

        httploop.deleteLater();
        httpReply->deleteLater();
        networkMgr->deleteLater();
        currrentImageHeight = currentBeBufferedImage.height();
        emit sigDownLoadSuccess(false);
        return currentBeBufferedImage;
    }
}

void GetOffsetImage::getOffSetImage(QString imageUrl, double offSetY)
{
    //获取图片
    QImage tempImage = downLoadImage(imageUrl);
    //根据偏移量算出 要发送出去的 图片的大小
    //QImage tempImageTwo = tempImage.copy(0, qAbs(offSetY) * StudentData::gestance()->midHeight ,tempImage.width(),StudentData::gestance()->midHeight);

    double tempHeightToGet = tempImage.height() < StudentData::gestance()->midHeight ? tempImage.height() : StudentData::gestance()->midHeight;
    QImage tempImageTwo = tempImage.copy(0, qAbs(offSetY) * StudentData::gestance()->midHeight, tempImage.width(), tempHeightToGet );
    qDebug() << currentTrailBoardHeight << StudentData::gestance()->midHeight << "StudentData::gestance()->midHeight";
    currrentImageHeight = tempImage.height();
    if(currentTrailBoardHeight >  StudentData::gestance()->midHeight)
    {
        //重新绘制 缩放后的图片
        //计算缩放后的比列
        double transImageHeight = StudentData::gestance()->fullHeight * currentBeBufferedImage.height() / StudentData::gestance()->midHeight;
        QImage tempImageThree = currentBeBufferedImage.scaled(StudentData::gestance()->fullWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        double tempHeightToGet = tempImageThree.height() < StudentData::gestance()->fullHeight ? tempImageThree.height() : StudentData::gestance()->fullHeight;

        tempImageTwo = tempImageThree.copy(0, qAbs(offSetY) * StudentData::gestance()->fullHeight, tempImageThree.width(), tempHeightToGet);
        currrentImageHeight = tempImageThree.height();
    }

    //qDebug ()<<"tempHeightToGet"<< currrentImageHeight<<currentTrailBoardHeight<<StudentData::gestance()->midHeight;
    imageProvider->image = tempImageTwo;
    int width = imageProvider->image.width();
    int height = imageProvider->image.height();
    emit reShowOffsetImage(width, height);
    emit sigCurrentImageHeight(currrentImageHeight);
}

void GetOffsetImage::getOffSetImage(double offSetY)
{
    //qDebug()<<qAbs(offSetY)<<"GetOffsetImage::getOffS111111etImage(" ;
    //qDebug() << "###########value################" << StudentData::gestance()->midHeight << currentBeBufferedImage.height();
    //根据偏移量算出 要发送出去的 图片的大小
    double tempHeightToGet = currentBeBufferedImage.height() < StudentData::gestance()->midHeight ? currentBeBufferedImage.height() : StudentData::gestance()->midHeight;

    QImage tempImageTwo = currentBeBufferedImage.copy(0, qAbs(offSetY) * StudentData::gestance()->midHeight, currentBeBufferedImage.width(), tempHeightToGet);
    //currrentImageHeight = tempImageTwo.height();
    if(currentTrailBoardHeight >  StudentData::gestance()->midHeight)
    {
        //重新绘制 缩放后的图片
        //计算缩放后的比列
        double transImageHeight = StudentData::gestance()->fullHeight * currentBeBufferedImage.height() / StudentData::gestance()->midHeight;
        QImage tempImageThree = currentBeBufferedImage.scaled(StudentData::gestance()->fullWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        double tempHeightToGet = tempImageThree.height() < StudentData::gestance()->fullHeight ? tempImageThree.height() : StudentData::gestance()->fullHeight;
        tempImageTwo = tempImageThree.copy(0, qAbs(offSetY) * StudentData::gestance()->fullHeight, tempImageThree.width(), tempHeightToGet);
        //currrentImageHeight = tempImageThree.height();
    }

    imageProvider->image = tempImageTwo;
    int width = imageProvider->image.width();
    int height = imageProvider->image.height();
    emit reShowOffsetImage(width, height);
}
