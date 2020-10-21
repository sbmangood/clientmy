#ifndef YMVIDEOPLAYER_H
#define YMVIDEOPLAYER_H

#include <QWidget>
#include <QQuickPaintedItem>

#include "ymplayer.h"

class YMVideoPlayer : public QQuickPaintedItem
{
        Q_OBJECT

        //  Q_PROPERTY(int bePlayedFileTotalTime READ bePlayedFileTotalTime)
    public:
        explicit YMVideoPlayer(QQuickPaintedItem *parent = 0);

        // int bePlayedFileTotalTime();

    protected:
        void paint(QPainter *painter);

    signals:
        void sigControl(int type, int data);
        void totalTimes(int time);

        void playFinished();

        void currentTime(int time);
    public slots:
        void onRenderImg(QImage image);

        bool  setBePlayedFileUrl(QString url, bool playstate);
        //stateType  1 暂停 2 快进 快退  data为正 为进  负为退
        void  setCurrentPlayedItemState(int stateType, int data, bool isPlay);

        void play();

        //  void currentBePlayedPosition(int position);
        // void setTotalTime(int totalTime);

        QString getCurrentBePlayedFileUrl();

        void checkPlayIsFinished();
    private:
        QImage image;
        YMPlayer *videoPlayer;
        int totalTime;
        QString currentBePlayedFileUrl;
};

#endif // YMVIDEOPLAYER_H
