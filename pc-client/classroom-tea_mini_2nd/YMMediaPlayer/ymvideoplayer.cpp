﻿#include "ymvideoplayer.h"
#include <QImage>
#include <QPainter>
#include <QDebug>
#include <QPushButton>
#include <QLabel>

YMVideoPlayer::YMVideoPlayer(QQuickPaintedItem *parent): QQuickPaintedItem(parent)
{
    videoPlayer = new YMPlayer(this);
    connect(videoPlayer, &YMPlayer::sigOnRender, this, &YMVideoPlayer::onRenderImg);
    connect(videoPlayer, SIGNAL(totalTime(int)), this, SIGNAL( totalTimes(int)));
    connect(videoPlayer, SIGNAL(sigCurrentTime(int)), this, SIGNAL(sigCurrentTime(int)));
    currentBePlayedFileUrl = "";

    //    QTimer *timer = new QTimer(this);
    //    connect(timer, SIGNAL(timeout()), this, SLOT(checkPlayIsFinished()));
    //    timer->start(1000);

    connect(videoPlayer, SIGNAL(playFinished()), this, SIGNAL( playFinished()));
}
void YMVideoPlayer::checkPlayIsFinished()
{
    if(videoPlayer->playFinishedFlag == true)
    {
        emit playFinished();
    }

}
void YMVideoPlayer::closeVideoOutput()
{

}

void YMVideoPlayer::paint(QPainter *painter)
{
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawImage(0, 0, image);
}

void YMVideoPlayer::onRenderImg(QImage image)
{
    this->image = image.scaled(this->width(), this->height(), Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation);
    update();
}

void YMVideoPlayer::setFormSize(int width, int height)
{
    this->image = image.scaled(width, height, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation);
}

bool YMVideoPlayer::setBePlayedFileUrl(QString url, bool playstate)
{
    if(currentBePlayedFileUrl != url )
    {
        if(videoPlayer->isRunning() == true )
        {
            videoPlayer->onEvent(3, 0);
            QEventLoop loop;
            connect(videoPlayer, SIGNAL(playFinished()), &loop, SLOT(quit()));
            loop.exec();
            //emit playFinished();
            playstate = false;
        }
//        if(currentBePlayedFileUrl != "")
//        {
//            videoPlayer->setFileName(url);
//            videoPlayer->start();
//           // videoPlayer->onEvent(2,playPosition);
//            currentBePlayedFileUrl = url;
//            return true;
//        }
        videoPlayer->setFileName(url);
    }

    currentBePlayedFileUrl = url;
    return playstate;
}

//播放
void YMVideoPlayer::play()
{
    if(videoPlayer->isRunning() == false)
    {
        videoPlayer->start();
    }
    qDebug() << "YMvideo isrunning" << videoPlayer->isRunning();
}

bool YMVideoPlayer::getPlayerStatus()
{
    return videoPlayer->isRunning();
}

void YMVideoPlayer::setCurrentPlayedItemState(int stateType, int data, bool isPlay)
{
    if(videoPlayer->isRunning() == false )
    {
        if(stateType == 3)
        {
            return;
        }
        videoPlayer->start();
        qDebug() << "YMVideoPlayer::setCurrentPlayedItemState: " << videoPlayer->isRunning() << stateType << isPlay;
        if(isPlay && stateType == 1)
        {
            return;
        }
    }

    qDebug() << "YMvideo isrunning 3 here  data" << stateType << data;
    videoPlayer->onEvent(stateType, data);
}

QString YMVideoPlayer::getCurrentBePlayedFileUrl()
{
    return this->currentBePlayedFileUrl;
}

//int YMVideoPlayer::bePlayedFileTotalTime()
//{
//    return totalTime;
//}

//void YMVideoPlayer::setTotalTime(int totalTime)
//{
//    qDebug()<<"set totalTime Success !";
//    this->totalTime = totalTime;
//}
