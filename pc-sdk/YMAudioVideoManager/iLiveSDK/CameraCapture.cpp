#include "CameraCapture.h"

CameraCapture::CameraCapture(QObject *parent) : QAbstractVideoSurface(parent){}

QList<QVideoFrame::PixelFormat> CameraCapture::supportedPixelFormats(QAbstractVideoBuffer::HandleType handleType) const
{
    QList<QVideoFrame::PixelFormat> list;
    list << QVideoFrame::Format_RGB32;
    return list;
}

void CameraCapture::setVideoFrame(const QVideoFrame &frame)
{
    switch (frame.pixelFormat())
    {
        case  QVideoFrame::Format_Invalid:
            break;
        case  QVideoFrame::Format_ARGB32:
            break;
        default:
            break;
    }
    // 这里可以做人脸识别一类的其他工作。
}

bool CameraCapture::present(const QVideoFrame &frame)
{
    QVideoFrame m_frame(frame);
    // 处理捕获的帧
    if(!frame.isMapped())
    {
        m_frame.map(QAbstractVideoBuffer::ReadOnly);
    }
    QImage::Format format = QVideoFrame::imageFormatFromPixelFormat(m_frame.pixelFormat());
    QImage image(m_frame.bits(), m_frame.width(), m_frame.height(), format);
    image = image.scaled(640, 480, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    image = image.convertToFormat(QImage::Format_RGB888);
    // 转换为BGR888
    int length = image.width() * image.height();
    const uchar *bitss = image.bits();
    arr.clear();
    for (int i = length - 1; i >= 0; i--)
    {
        int index = i * 3;
        arr.append(bitss[index + 2]);
        arr.append(bitss[index + 1]);
        arr.append(bitss[index]);
    }

    m_image = QImage(arr.data(), 640, 480, QImage::Format_RGB888);
    emit sendData(m_image);
    return true;
}
