#ifndef VIDEORENDER_H
#define VIDEORENDER_H

#include <QQuickPaintedItem>
#include <QMouseEvent>
#include <QImage>
#include <QMutexLocker>
#include <QMatrix>
#include <QPainter>
#include <QDebug>

class VideoRender : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QString imageId READ imageId  WRITE setImageId )

public:
    explicit VideoRender(QQuickPaintedItem *parent = 0);
    virtual ~VideoRender();
    void setImageId(QString&imageId );

signals:
    void hideBeautyButton();

public slots:
    // 处理视频图片
    void onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation);
    void enableBeauty(bool isBeauty);
    bool getBeautyIsOn();

protected:
    // 画图
    void paint(QPainter *painter);

private:
    QString imageId();
    QImage m_imge;
    int m_imageId;
    int m_rotation;
};

#endif // VIDEORENDER_H
