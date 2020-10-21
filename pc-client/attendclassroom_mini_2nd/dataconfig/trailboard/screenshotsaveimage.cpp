#include "screenshotsaveimage.h"

ScreenshotSaveImage::ScreenshotSaveImage(QObject *parent) : QObject(parent)
    , m_docParhUploadName("")
    , m_docParhTempName("")
{
    m_docParh = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    m_docParh += "/";
    QDir wdir(m_docParh);
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_docParh + "YiMi/tempimages"))
    {


        wdir.mkpath("YiMi/tempimages/" );
    }
    m_docParh += "YiMi/tempimages";
    clearFile();

}

ScreenshotSaveImage::~ScreenshotSaveImage()
{

}

void ScreenshotSaveImage::grabImage(QObject *itemObj)
{
    m_grabItem = qobject_cast<QQuickItem*>(itemObj);
    m_grabResult = m_grabItem->grabToImage();
    QQuickItemGrabResult * grabResult = m_grabResult.data();
    connect(grabResult, SIGNAL(ready()), this, SLOT(saveimage() ));
}
//删除缓冲图片
void ScreenshotSaveImage::deleteTempImage()
{
    if(m_docParhUploadName.length() > 0)
    {

        if(QFile::exists(m_docParhUploadName))
        {
            QFile::remove(m_docParhUploadName);
        }

        m_docParhUploadName = "";
    }
    if(m_docParhTempName.length() > 0)
    {

        if(QFile::exists(m_docParhTempName))
        {
            QFile::remove(m_docParhTempName);
        }

        m_docParhTempName = "";
    }


}

void ScreenshotSaveImage::saveimage()
{
    QImage img = m_grabResult->image();
    int currentDateTimes = QDateTime::currentDateTime().toTime_t();
    QString names = QString("/%1.jpg").arg(currentDateTimes);
    int currentDateTimeh = QDateTime::currentDateTime().toMSecsSinceEpoch();
    QString nameh = QString("/%1.jpg").arg(currentDateTimeh);
    m_docParhTempName = m_docParh + nameh;
    if(img.save(m_docParh + names))
    {
        m_docParhUploadName = m_docParh + names;
        emit sigSendScreenshotName(m_docParhUploadName);
    }
}

QString ScreenshotSaveImage::tempGrabPicture()
{

    return m_docParhTempName;
}
//清除缓存
void ScreenshotSaveImage::clearFile()
{
    QStringList nameFilters;
    QStringList fileList;
    nameFilters << "*.png" << "*.jpg" << "*.PNG" << "*.JPG" ;
    QDirIterator dirIterator(m_docParh, nameFilters, QDir::Files | QDir::NoSymLinks | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
    while(dirIterator.hasNext())
    {

        // fileList << dirIterator.fileName();
        fileList << dirIterator.filePath();
        //   qDebug()<<"dirIterator.filePath() =="<<dirIterator.filePath();

        dirIterator.next();
    }

    QString fileallpath;

    QString filetemparay;
    for (int i = 0 ; i < fileList.count() ; i++)
    {
        //qDebug()<<fileList[i];
        fileallpath += fileList[i] + " ;\n ";
        filetemparay = fileList[i];
        QFile::remove(filetemparay);

    }


}

