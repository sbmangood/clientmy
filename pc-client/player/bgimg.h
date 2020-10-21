#ifndef BGIMG_H
#define BGIMG_H

#include <QObject>
#include "./painterboard.h"
#include <QQuickPaintedItem>

class QNetworkReply;
class QNetworkAccessManager;

class BGImg : public QQuickPaintedItem
{
        Q_OBJECT
    public:
        explicit BGImg(QString lessonId, QString date, QString path, QString trail, QSize size, QQuickPaintedItem *parent = 0);
        ~BGImg();
        void changeBgimg(QPixmap pixmap, double width, double height);
        void resizeUI(QSize size);

    public slots:
        void loadNetImg(QString url, double width, double height);

    signals:
        void update(QString url);
        void displayerBackImage(QString url);
        void imageChanged(QPixmap image);

    public:
        PainterBoard *board;
        QString docPath;
        QString soucePath;//原始路径

    protected:
        void paintEvent(QPaintEvent *event);

    public:
        QNetworkAccessManager *manager;
        QSize boardSize;
        QString lessonId;
        QString date;
        QPixmap currentPixmap;
        double currentWidth, currentHeight;

};

#endif // BGIMG_H
