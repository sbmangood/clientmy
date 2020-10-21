#include "screenshotsaveimage.h"
#include "debuglog/debuglog.h"


ScreenshotSaveImage::ScreenshotSaveImage(QObject *parent) : QObject(parent)
    , m_docParhUploadName("")
    , m_docParhTempName("")
{
    m_docParh = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

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
    connect(this, SIGNAL(sigSaveImage(bool, QString, int)), this, SIGNAL(sigSendScreenshotName(bool, QString, int)), Qt::QueuedConnection);
}

ScreenshotSaveImage::~ScreenshotSaveImage()
{

}

void ScreenshotSaveImage::saveBoard(bool bSaveCurPage, const QString &fileName, int curPage)
{
    QString names = QString("/%1_%2.png").arg(fileName).arg(curPage);
    QString pathTempName = m_docParh + names;
    emit sigSaveImage(bSaveCurPage, pathTempName, curPage);
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

void ScreenshotSaveImage::saveimage(bool bSaveCurPage, QString fileName, int curPage)
{
//    emit sigSendScreenshotName(bSaveCurPage, fileName, curPage);
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

