#include "getoffsetimage.h"

GetOffsetImage::GetOffsetImage(QObject *parent) : QObject(parent)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    //  qDebug()<<"docPath =="<<docPath;


    if (docPath == "")
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    systemPublicFilePath += "YiMi/Image/" + StudentData::gestance()->m_lessonId + "/";

    QDir isDir;
    if (!isDir.exists(systemPublicFilePath))
    {
        isDir.mkpath(systemPublicFilePath);
    }
    imageProvider = new ImageProvider();
    //初始化保存当前画板高度 为了全屏时 重新获取图片偏移过后的图片
    currentTrailBoardHeight = StudentData::gestance()->midHeight;
}

GetOffsetImage::~GetOffsetImage()
{
    delete imageProvider;
}

QImage GetOffsetImage::downLoadImage(QString imageUrl)
{
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
        httpRequest.setUrl(QUrl(imageUrl));
        httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
#endif// #ifdef USE_OSS_AUTHENTICATION

        QEventLoop httploop;
        connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));

        QNetworkReply *httpReply = networkMgr->get(httpRequest);

        httploop.exec();
        QByteArray readData = httpReply->readAll();
        QImage tempImage = QImage::fromData(readData);

        qDebug() << "GetOffsetImage::downLoadImage" << currentBeBufferedImage.width() << currentBeBufferedImage.height() << __LINE__;
        qDebug() << "GetOffsetImage::downLoadImage" << StudentData::gestance()->midHeight << StudentData::gestance()->midWidth << __LINE__;
        //计算缩放后的比列
        double rate = 0.618;
        double imgheight = tempImage.height();
        double imgwidth = tempImage.width();
        double multiple = imgheight / imgwidth / rate;
        double transImageHeight  = StudentData::gestance()->midHeight * multiple  ;

        if(StudentData::gestance()->isCouldUseNewBoard())
        {
            //等比缩放图片的高 (录播做区别的时候只有 新版本用这个比例 老版本不用这行代码)
            transImageHeight = StudentData::gestance()->midWidth / tempImage.width() * tempImage.height();
        }

        //平滑缩放
        //currentBeBufferedImage = tempImage.scaled(StudentData::gestance()->midWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        //直接存储原图
        currentBeBufferedImage = tempImage;
        currentBeBufferedImage.save(imageName);

        //        QImage tempImageTwo = currentBeBufferedImage.copy(0,10,tempImage.width(),StudentData::gestance()->midHeight);

        //        tempImageTwo.save("1111000.jpg");

        qDebug() << "GetOffsetImage::downLoadImage " << imageName << transImageHeight << tempImage.width() << tempImage.height() << currrentImageHeight << __LINE__;

        //  currentBeBufferedImage.save(saveName);
        httploop.deleteLater();
        httpReply->deleteLater();
        networkMgr->deleteLater();
        //currrentImageHeight = currentBeBufferedImage.height();

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

    double zoomRate = StudentData::gestance()->midWidth / tempImage.width();

    //计算缩放后当前图片的高度
    currrentImageHeight = zoomRate * tempImage.height();

    //获取未缩放时对应的区域图片
    double tempHeightToGet = tempImage.height() < StudentData::gestance()->midHeight / zoomRate ? tempImage.height() : StudentData::gestance()->midHeight / zoomRate;
    QImage tempImageTwo = tempImage.copy(0, qAbs(offSetY) * StudentData::gestance()->midHeight / zoomRate, tempImage.width(), tempHeightToGet );
    tempImageTwo = tempImageTwo.scaled(StudentData::gestance()->midWidth, tempHeightToGet * zoomRate, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    if(currentTrailBoardHeight >  StudentData::gestance()->midHeight)
    {
        //重新绘制 缩放后的图片
        //计算缩放后的比列
        double transImageHeight = StudentData::gestance()->fullHeight * currrentImageHeight / StudentData::gestance()->midHeight;
        QImage tempImageThree = currentBeBufferedImage.scaled(StudentData::gestance()->fullWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        double tempHeightToGet = tempImageThree.height() < StudentData::gestance()->fullHeight ? tempImageThree.height() : StudentData::gestance()->fullHeight;

        tempImageTwo = tempImageThree.copy(0, qAbs(offSetY) * StudentData::gestance()->fullHeight, tempImageThree.width(), tempHeightToGet);
        currrentImageHeight = tempImageThree.height();
    }

    qDebug () << "tempHeightToGet" << currentTrailBoardHeight << StudentData::gestance()->midHeight;
    imageProvider->image = tempImageTwo; //这个QImage对象, 就显示在画布中
    //    imageProvider->image = QImage("D:/bbb.png");
    emit reShowOffsetImage();
    emit sigCurrentImageHeight(currrentImageHeight);
}

void GetOffsetImage::getOffSetImage(double offSetY)
{
    qDebug() << qAbs(offSetY) << "GetOffsetImage::getOffS111111etImage(" << currrentImageHeight<< currrentImageHeight / StudentData::gestance()->midHeight - 1.0;
    //根据偏移量算出 要发送出去的 图片的大小
    //判断offsety的值有没有取过界
    if( (currrentImageHeight / StudentData::gestance()->midHeight - 1.0) <  qAbs(offSetY) )
    {
        offSetY =  (currrentImageHeight / StudentData::gestance()->midHeight) - 1.0;
    }

    if(offSetY == 0 || (currrentImageHeight < StudentData::gestance()->midHeight))
    {
        offSetY = 0;
    }
    double zoomRate = StudentData::gestance()->midWidth / currentBeBufferedImage.width();
    double tempHeightToGet = currentBeBufferedImage.height() < StudentData::gestance()->midHeight / zoomRate ? currentBeBufferedImage.height() : StudentData::gestance()->midHeight / zoomRate;
    QImage tempImageTwo = currentBeBufferedImage.copy(0, qAbs(offSetY) * StudentData::gestance()->midHeight / zoomRate, currentBeBufferedImage.width(), tempHeightToGet );
    tempImageTwo = tempImageTwo.scaled(StudentData::gestance()->midWidth, tempHeightToGet * zoomRate, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    if(currentTrailBoardHeight >  StudentData::gestance()->midHeight)
    {
        //判断offsety的值有没有取过界
        if( (currrentImageHeight / StudentData::gestance()->fullHeight - 1.0) < qAbs(offSetY) )
        {
            offSetY =  (currrentImageHeight / StudentData::gestance()->fullHeight) - 1.0;
        }

        //重新绘制 缩放后的图片
        //计算缩放后的比列
        double transImageHeight = StudentData::gestance()->fullHeight * currrentImageHeight / StudentData::gestance()->midHeight;
        QImage tempImageThree = currentBeBufferedImage.scaled(StudentData::gestance()->fullWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        double tempHeightToGet = tempImageThree.height() < StudentData::gestance()->fullHeight ? tempImageThree.height() : StudentData::gestance()->fullHeight;
        tempImageTwo = tempImageThree.copy(0, qAbs(offSetY) * StudentData::gestance()->fullHeight, tempImageThree.width(), tempHeightToGet);
        //currrentImageHeight = tempImageThree.height();
    }

    imageProvider->image = tempImageTwo;
    emit reShowOffsetImage();
}

double GetOffsetImage::resetOffsetY(double offsetY, double zoomRate)
{

    if(zoomRate == 1.0)
    {
        return qAbs(offsetY);
    }

    if(offsetY == 0 || (currrentImageHeight < StudentData::gestance()->midHeight))
    {
        offsetY = 0;
        return offsetY;
    }

    //判断offsety的值有没有取过界
    if( (currrentImageHeight / StudentData::gestance()->midHeight - 1.0) <  qAbs(offsetY) )
    {
        offsetY =  (currrentImageHeight / StudentData::gestance()->midHeight) - 1.0;
    }
    if(currentTrailBoardHeight >  StudentData::gestance()->midHeight)
    {
        if( (currrentImageHeight / StudentData::gestance()->fullHeight - 1.0) <  qAbs(offsetY) )
        {
            offsetY =  (currrentImageHeight / StudentData::gestance()->fullHeight) - 1.0;
        }
    }
    return offsetY;
}
