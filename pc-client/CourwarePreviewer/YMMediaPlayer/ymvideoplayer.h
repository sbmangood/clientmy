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
        Q_INVOKABLE void closeVideoOutput();
        Q_INVOKABLE void setFormSize(int width, int height);
        Q_INVOKABLE bool getPlayerStatus();

        // int bePlayedFileTotalTime();

    protected:
        void paint(QPainter *painter);

    signals:
        void sigControl(int type, int data);
        void totalTimes(int time);
        void playFinished();
        void sigCurrentTime(int currentTime);

    public slots:
        void onRenderImg(QImage image);
        bool  setBePlayedFileUrl(QString url, bool playstate);
        //stateType  1 暂停 2 快进 3退出
        //data 正数为快进  负数为倒退 0为暂停
        //isPlay为播放状态 true 播放，false停止
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
