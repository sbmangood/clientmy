#ifndef PICTURECAPTURE_H
#define PICTURECAPTURE_H

#include <QObject>
#include <QThread>
#include <QVector>
#include <QImage>

class PictureCapture : public QThread
{
        Q_OBJECT
    public:
        explicit PictureCapture(QObject *parent = 0);
        ~PictureCapture();
        void changeRunning(bool b);

    protected:
        void run();
    signals:
        void sendFpsPicture(QImage image);

    public slots:

    private:
        bool running;
        QVector<uchar> arr;
};

#endif // PICTURECAPTURE_H
