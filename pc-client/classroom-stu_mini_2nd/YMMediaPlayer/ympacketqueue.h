#ifndef YMPACKETQUEUE_H
#define YMPACKETQUEUE_H

#include <QObject>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswresample/swresample.h>
#include <SDL.h>
}

typedef struct PacketQueue
{
    AVPacketList    *first_pkt;     //队头的一个packet, 注意类型不是AVPacket
    AVPacketList    *last_pkt;      //队尾packet
    int             nb_packets;     // paket个数
    int             size;           //
    SDL_mutex       *mutex;         //
    SDL_cond        *cond;          // 条件变量
} PacketQueue;


class YMPacketQueue : public QObject
{
        Q_OBJECT
    public:
        explicit YMPacketQueue(QObject *parent = 0);
        static void packetQueueInit(PacketQueue *queue);
        static int packetQueuePut(PacketQueue *queue, AVPacket *packet);
        static int packetQueueGet(PacketQueue *queue, AVPacket *pakcet, int block);
        static void packetQueueFlush(PacketQueue *queue);

    signals:

    public slots:
};
#endif // YMPACKETQUEUE_H
