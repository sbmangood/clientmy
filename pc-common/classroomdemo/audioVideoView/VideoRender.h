﻿#ifndef VIDEORENDER_H
#define VIDEORENDER_H

#include <QQuickPaintedItem>
#include <QMouseEvent>
#include <QImage>
#include <QMutex>
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

signals:
    void hideBeautyButton();

public slots:
    //处理视频图片
    void onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation);

    void changeRenderWays(bool isBeauty);

     bool getBeautyIsOn();
protected:
    //画图
    void paint(QPainter *painter);

public:
    void setImageId(QString&imageId );


private:
    QString imageId();

private:
    int m_imageId;
    QImage m_imge;
    int m_rotation;
};

#endif // VIDEORENDER_H