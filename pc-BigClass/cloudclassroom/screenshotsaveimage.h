#ifndef SCREENSHOTSAVEIMAGE_H
#define SCREENSHOTSAVEIMAGE_H

#include <QObject>
#include <QJsonDocument>
#include <qDebug>
#include <QJsonObject>
#include <QByteArray>
#include <QJsonArray>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QString>
#include <QDir>
#include <QStandardPaths>
#include <QDateTime>
#include <Qfile>
#include <QDirIterator>

class ScreenshotSaveImage : public QObject
{
        Q_OBJECT
    public:
        explicit ScreenshotSaveImage(QObject *parent = 0);
        virtual ~ScreenshotSaveImage();
        // 保存图片
        Q_INVOKABLE void saveBoard(bool bSaveCurPage, const QString &fileName, int curPage);
        //删除缓冲图片
        Q_INVOKABLE void deleteTempImage();

        Q_PROPERTY(QString tempGrabPicture READ tempGrabPicture)

    signals:
        void sigSendScreenshotName(bool bSaveCurPage, QString fileName, int curPage);
        void sigSaveImage(bool bSaveCurPage, QString fileName, int curPage);

    public slots:
        void saveimage(bool bSaveCurPage, QString fileName, int curPage);

    private:
        QString tempGrabPicture();
        //清除缓存
        void clearFile();

    private:
        QQuickItem      *m_grabItem;
        QSharedPointer<QQuickItemGrabResult> m_grabResult;
        QString m_docParh;
        QString m_docParhUploadName;
        QString m_docParhTempName;
};

#endif // SCREENSHOTSAVEIMAGE_H
