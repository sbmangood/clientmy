#ifndef YMVIDEODECODER_H
#define YMVIDEODECODER_H

#include <QObject>
extern "C" {
#include <libswscale/swscale.h>
#include <libavutil/time.h>
}
#include "./ymaudiodecoder.h"
class YMVideoDecoder : public QObject
{
        Q_OBJECT
    public:
        explicit YMVideoDecoder(QObject *parent = 0);
        static YMVideoDecoder  * gestance()
        {
            static YMVideoDecoder * videoDecorder = new YMVideoDecoder();

            return videoDecorder;
        }
        static int prepareVideo(PlayerState *ps);
        static int playVideo(PlayerState *ps);
        static int decodeAndShow(void *arg, OnRenderCallBack func, void *data);
        static int refreshFun(void *arg);
        static double getFramePts(PlayerState *ps, AVFrame *pframe);
        static double getDelay(PlayerState *ps);
        static void playFinished();
        void checkPlayIsFinished();
    signals:
        void playFinish();
        void currentTime();
    public slots:
};
#endif // YMVIDEODECODER_H
