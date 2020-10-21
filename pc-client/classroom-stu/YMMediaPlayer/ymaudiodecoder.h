#ifndef YMAUDIODECODER_H
#define YMAUDIODECODER_H

#include <QObject>
extern "C" {
#include <libswscale/swscale.h>
#include <libavutil/time.h>
}
#include "./ymplayer.h"
class YMAudioDecoder : public QObject
{
        Q_OBJECT
    public:
        explicit YMAudioDecoder(QObject *parent = 0);
        static int prepareAudio(PlayerState *ps);
        static int playAudio(PlayerState *ps);
        static void audioCallback(void *userdata, uint8_t *stream, int len);
        static int audioDecodeFrame(PlayerState *ps);
        static double getAudioClock(PlayerState *ps);

    signals:

    public slots:
};
#endif // YMAUDIODECODER_H
