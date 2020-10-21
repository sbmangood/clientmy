#include "getoffsetimage.h"

GetOffsetImage::GetOffsetImage(QObject *parent) : QObject(parent)
{
    QString docPath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    //  qDebug()<<"docPath =="<<docPath;


    if (docPath == "")
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    systemPublicFilePath += "YiMi/Image/" + lessonId + "/";

    QDir isDir;
    if (!isDir.exists(systemPublicFilePath))
    {
        isDir.mkpath(systemPublicFilePath);
    }
    imageProvider = new ImageProvider();
}

GetOffsetImage::~GetOffsetImage()
{
    delete imageProvider;
}


QImage GetOffsetImage::downLoadImage(QString imageUrl)
{
    emit sigDownLoadSuccess(true);
    QString imageName = "temp.jpg";
    if(imageUrl.split("/").size() >= 2)
    {
        QStringList lstPath = imageUrl.split("/");
        imageName = lstPath.at(lstPath.size() - 2) + imageUrl.split("/").takeLast(); //为了避免本地图片的文件名重复, 所以文件名选用: lstPath.at(lstPath.size() - 2) + imageUrl.split("/").takeLast()

#ifdef USE_OSS_AUTHENTICATION
        int indexOf = imageName.indexOf("?");
        imageName = imageName.mid(0, indexOf);
#endif
    }
    imageName = systemPublicFilePath + imageName;

    if(QFile::exists(imageName))
    {
        currentBeBufferedImage.load(imageName);
        //currrentImageHeight = currentBeBufferedImage.height();
        emit sigDownLoadSuccess(false);
        return currentBeBufferedImage;
    }
    else
    {
        qint64 startDownLoadTime = QDateTime::currentMSecsSinceEpoch();
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
        httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
        httpRequest.setUrl(QUrl(imageUrl));
#endif

        QEventLoop httploop;
        QTimer::singleShot(10000,&httploop,SLOT(quit()));
        connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));

        QNetworkReply *httpReply = networkMgr->get(httpRequest);

        httploop.exec();
        QByteArray readData = httpReply->readAll();
        QImage tempImage = QImage::fromData(readData);

        qDebug() << "GetOffsetImage::downLoadImage" << currentBeBufferedImage.width() << currentBeBufferedImage.height();
        qDebug() << "GetOffsetImage::downLoadImage" << midHeight << midWidth;
        //计算缩放后的比列
        double rate = 0.618;
        double imgheight = tempImage.height();
        double imgwidth = tempImage.width();
        double multiple = imgheight / imgwidth / rate;
        double transImageHeight  = midHeight * multiple  ;
        qDebug()<<midHeight<<midWidth<<tempImage.height()<<tempImage.width()<<"midWidth";

        if(isCouldUseNewBoard)
        {
            //等比缩放图片的高 (录播做区别的时候只有 新版本用这个比例 老版本不用这行代码)
            transImageHeight = midWidth / tempImage.width()   * tempImage.height();
        }

        qDebug()<<"midWidth"<<transImageHeight;
        //平滑缩放
        //currentBeBufferedImage = tempImage.scaled(midWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        //直接存储原图
        currentBeBufferedImage = tempImage;
        currentBeBufferedImage.save(imageName);

        //        QImage tempImageTwo = currentBeBufferedImage.copy(0,10,tempImage.width(),midHeight);

        //        tempImageTwo.save("1111000.jpg");

        qDebug() << "GetOffsetImage::downLoad2333Image " << transImageHeight << tempImage.width() << tempImage.height();

        //  currentBeBufferedImage.save(saveName);
        httploop.deleteLater();
        httpReply->deleteLater();
        networkMgr->deleteLater();
        //currrentImageHeight = transImageHeight;//currentBeBufferedImage.height();
        emit sigDownLoadSuccess(false);

        //信息上报
        QJsonObject obj;
        obj.insert("downLoadResult",readData.size() > 0 ? "success" : "failed");
        obj.insert("coursewareUrl",imageUrl);
        obj.insert("startDownLoadTime",startDownLoadTime);
        obj.insert("endDownLoadTime",QDateTime::currentMSecsSinceEpoch());
        YMQosManager::gestance()->addBePushedMsg("courseware",obj);

        return currentBeBufferedImage;
    }
}

void GetOffsetImage::getOffSetImage(QString imageUrl, double offSetY)
{
    //获取图片  存原图
    QImage tempImage = downLoadImage(imageUrl);

    double zoomRate = midWidth / tempImage.width();

    //计算缩放后当前图片的高度
    currrentImageHeight = zoomRate * tempImage.height();

    //获取未缩放时对应的区域图片
    double tempHeightToGet = tempImage.height() < midHeight / zoomRate ? tempImage.height() : midHeight / zoomRate;
    QImage tempImageTwo = tempImage.copy(0, qAbs(offSetY) * midHeight / zoomRate, tempImage.width(), tempHeightToGet );
    tempImageTwo = tempImageTwo.scaled(midWidth, tempHeightToGet * zoomRate, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    if(currentTrailBoardHeight >  midHeight)
    {
        //重新绘制 缩放后的图片
        //计算缩放后的比列
        double transImageHeight = fullHeight * currentBeBufferedImage.height() / midHeight;
        QImage tempImageThree = currentBeBufferedImage.scaled(fullWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        double tempHeightToGet = tempImageThree.height() < fullHeight ? tempImageThree.height() : fullHeight;

        tempImageTwo = tempImageThree.copy(0, qAbs(offSetY) * fullHeight, tempImageThree.width(), tempHeightToGet);
        currrentImageHeight = tempImageThree.height();
    }


    imageProvider->image = tempImageTwo;
    int width = imageProvider->image.width();
    int height = imageProvider->image.height();
    emit reShowOffsetImage(width, height);
    emit sigCurrentImageHeight(currrentImageHeight);
    qDebug () << "tempHeightToGet" << currentTrailBoardHeight << midHeight<<imageProvider->image.height();
}

void GetOffsetImage::getOffSetImage(double offSetY)
{
    qDebug() << qAbs(offSetY) << "GetOffsetImage::getOffS111111etImage("<< imageProvider->image.height()<<midHeight;
    //根据偏移量算出 要发送出去的 图片的大小
    double zoomRate = midWidth / currentBeBufferedImage.width();
    double tempHeightToGet = currentBeBufferedImage.height() < midHeight / zoomRate ? currentBeBufferedImage.height() : midHeight / zoomRate;
    QImage tempImageTwo = currentBeBufferedImage.copy(0, qAbs(offSetY) * midHeight / zoomRate, currentBeBufferedImage.width(), tempHeightToGet );
    tempImageTwo = tempImageTwo.scaled(midWidth, tempHeightToGet * zoomRate, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    //QImage tempImageTwo = currentBeBufferedImage.copy(0, qAbs(offSetY) * midHeight, currentBeBufferedImage.width(), tempHeightToGet);
    //currrentImageHeight = tempImageTwo.height();
    if(currentTrailBoardHeight >  midHeight)
    {
        //重新绘制 缩放后的图片
        //计算缩放后的比列
        double transImageHeight = fullHeight * currentBeBufferedImage.height() / midHeight;
        QImage tempImageThree = currentBeBufferedImage.scaled(fullWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        double tempHeightToGet = tempImageThree.height() < fullHeight ? tempImageThree.height() : fullHeight;
        tempImageTwo = tempImageThree.copy(0, qAbs(offSetY) * fullHeight, tempImageThree.width(), tempHeightToGet);
        //currrentImageHeight = tempImageThree.height();
    }

    imageProvider->image = tempImageTwo;
    int width = imageProvider->image.width();
    int height = imageProvider->image.height();
    emit reShowOffsetImage(width, height);
}

double GetOffsetImage::getMidHeight()
{
    return midHeight;
}

double GetOffsetImage::getMidWidth()
{
    return midWidth;
}

double GetOffsetImage::getFullHeight()
{
    return fullHeight;
}

double GetOffsetImage::getFullWidth()
{
    return fullWidth;
}

void GetOffsetImage::writeMidHeight(double midHeights)
{
    this->midHeight = midHeights;
}

void GetOffsetImage::writeMidWidth(double midWidths)
{
    this->midWidth = midWidths;
}

void GetOffsetImage::writeFullHeight(double fullHeights)
{
    this->fullHeight = fullHeights;
}

void GetOffsetImage::writeFullWidth(double fullWidths)
{
    this->fullWidth = fullWidths;
}

void GetOffsetImage::initGetoffsetImg(double midHeights, double midWidths, double fullHeights, double fullWidths, QString lessonId, bool isCouldUseNewBoards)
{
    this->midHeight = midHeights;
    this->midWidth = midWidths;
    this->fullHeight = fullHeights;
    this->fullWidth = fullWidths;
    this->lessonId = lessonId;
    //初始化保存当前画板高度 为了全屏时 重新获取图片偏移过后的图片
    this->currentTrailBoardHeight = midHeights;
    this->isCouldUseNewBoard = isCouldUseNewBoards;
    qDebug() << "***********currentTrailBoardHeight***************"<<isCouldUseNewBoard<<lessonId << currentTrailBoardHeight;

}
