#include "picturecapture.h"
#include <QDebug>

PictureCapture::PictureCapture(QObject *parent) : QThread(parent)
{
    running = false;
}

PictureCapture::~PictureCapture()
{
    this->wait(); //等待线程执行完成, 不然程序有可能会崩溃, 崩溃的问题: QThread: Destroyed while thread is still running
}

void PictureCapture::changeRunning(bool b)
{
    running = b;
}

void PictureCapture::run()
{
    while (running)
    {
        QImage image("D:\\bg_test.jpg");
        image = image.scaled(320, 240, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        image = image.convertToFormat(QImage::Format_RGB888);
        //转换BGR888并旋转180度
        int length = image.width() * image.height() * 3;
        const uchar *bitss = image.bits();
        arr.clear();
        for (int i = length - 1; i >= 0; i--)
        {
            arr.append(bitss[i]);
        }
        QImage image1(arr.data(), image.width(), image.height(), QImage::Format_RGB888);
        emit sendFpsPicture(image1);
        msleep(500);
    }
}

