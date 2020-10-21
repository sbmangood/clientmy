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
    if(imageUrl.split("/").size() > 2)
    {
        imageName = imageUrl.split("/").at(imageUrl.split("/").size() - 2);
        imageName.append(imageUrl.split("/").takeLast());

#ifdef USE_OSS_AUTHENTICATION
        int indexOf = imageName.indexOf("?");
        imageName = imageName.mid(0, indexOf);
#endif

    }
    imageName = systemPublicFilePath + imageName;

    if(QFile::exists(imageName))
    {
        currentBeBufferedImage.load(imageName);
        currrentImageHeight = currentBeBufferedImage.height();
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
#endif// #ifdef USE_OSS_AUTHENTICATION

        QEventLoop httploop;
        connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));

        QNetworkReply *httpReply = networkMgr->get(httpRequest);

        httploop.exec();
        QByteArray readData = httpReply->readAll();
        QImage tempImage = QImage::fromData(readData);

        qDebug() << "GetOffsetImage::downLoadImage" << currentBeBufferedImage.width() << currentBeBufferedImage.height();
        qDebug() << "GetOffsetImage::downLoadImage" << StudentData::gestance()->midHeight << StudentData::gestance()->midWidth;
        //计算缩放后的比列
        double rate = 0.618;
        double imgheight = tempImage.height();
        double imgwidth = tempImage.width();
        double multiple = imgheight / imgwidth / rate;
        double transImageHeight  = StudentData::gestance()->midHeight * multiple  ;
        //等比缩放图片的高 (录播做区别的时候只有 新版本用这个比例 老版本不用这行代码)
        transImageHeight = StudentData::gestance()->midWidth / tempImage.width() * tempImage.height();

        //平滑缩放
        currentBeBufferedImage = tempImage.scaled(StudentData::gestance()->midWidth, transImageHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

        currentBeBufferedImage.save(imageName);

        //        QImage tempImageTwo = currentBeBufferedImage.copy(0,10,tempImage.width(),StudentData::gestance()->midHeight);

        //        tempImageTwo.save("1111000.jpg");

        qDebug() << "GetOffsetImage::downLoad2333Image " << transImageHeight << tempImage.width() << tempImage.height();

        //  currentBeBufferedImage.save(saveName);
        httploop.deleteLater();
        httpReply->deleteLater();
        networkMgr->deleteLater();
        currrentImageHeight = currentBeBufferedImage.height();
        return currentBeBufferedImage;
    }
}

void GetOffsetImage::getOffSetImage(QString imageUrl, double offSetY)
{
    qDebug() << qAbs(offSetY) << "GetOffsetImage::getOffSetImage(";
    //获取图片
    QImage tempImage = downLoadImage(imageUrl);
    //根据偏移量算出 要发送出去的 图片的大小
    //QImage tempImageTwo = tempImage.copy(0, qAbs(offSetY) * StudentData::gestance()->midHeight ,tempImage.width(),StudentData::gestance()->midHeight);

    double tempHeightToGet = tempImage.height() < StudentData::gestance()->midHeight ? tempImage.height() : StudentData::gestance()->midHeight;
    QImage tempImageTwo = tempImage.copy(0, qAbs(offSetY) * StudentData::gestance()->midHeight, tempImage.width(), tempHeightToGet );
    qDebug() << currentTrailBoardHeight << StudentData::gestance()->midHeight << "StudentData::gestance()->midHeight";
    currrentImageHeight = tempImage.height();
    if(currentTrailBoardHeight > StudentData::gestance()->midHeight)
    {
        //重新绘制 缩放后的图片
        //计算缩放后的比列
        double transImageHeight = StudentData::gestance()->fullHeight * currentBeBufferedImage.height() / StudentData::gestance()->midHeight;
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
    qDebug() << qAbs(offSetY) << "GetOffsetImage::getOffS111111etImage(" << currentBeBufferedImage.height()<< currentBeBufferedImage.height() / StudentData::gestance()->midHeight - 1.0;
    //根据偏移量算出 要发送出去的 图片的大小

    double tempHeightToGet = currentBeBufferedImage.height() < StudentData::gestance()->midHeight ? currentBeBufferedImage.height() : StudentData::gestance()->midHeight;

    //判断offsety的值有没有取过界


    if( (currentBeBufferedImage.height() / StudentData::gestance()->midHeight - 1.0) <  qAbs(offSetY) )
    {
        offSetY =  (currentBeBufferedImage.height() / StudentData::gestance()->midHeight) - 1.0;
    }

    if(offSetY == 0 || (currentBeBufferedImage.height() < StudentData::gestance()->midHeight))
    {
        offSetY = 0;
    }
    QImage tempImageTwo = currentBeBufferedImage.copy(0, qAbs(offSetY) * StudentData::gestance()->midHeight, currentBeBufferedImage.width(), tempHeightToGet);
    // currrentImageHeight = tempImageTwo.height();
    if(currentTrailBoardHeight >  StudentData::gestance()->midHeight)
    {
        //判断offsety的值有没有取过界
        if( (currrentImageHeight / StudentData::gestance()->fullHeight - 1.0) < qAbs(offSetY) )
        {
            offSetY =  (currrentImageHeight / StudentData::gestance()->fullHeight) - 1.0;
        }

        //重新绘制 缩放后的图片
        //计算缩放后的比列
        double transImageHeight = StudentData::gestance()->fullHeight * currentBeBufferedImage.height() / StudentData::gestance()->midHeight;
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

    if(offsetY == 0 || (currentBeBufferedImage.height() < StudentData::gestance()->midHeight))
    {
        offsetY = 0;
        return offsetY;
    }

    //判断offsety的值有没有取过界
    if( (currentBeBufferedImage.height() / StudentData::gestance()->midHeight - 1.0) <  qAbs(offsetY) )
    {
        offsetY =  (currentBeBufferedImage.height() / StudentData::gestance()->midHeight) - 1.0;
    }
    if(currentTrailBoardHeight >  StudentData::gestance()->midHeight)
    {
        if( (currentBeBufferedImage.height() / StudentData::gestance()->fullHeight - 1.0) <  qAbs(offsetY) )
        {
            offsetY =  (currentBeBufferedImage.height() / StudentData::gestance()->fullHeight) - 1.0;
        }
    }
    return offsetY;
}
