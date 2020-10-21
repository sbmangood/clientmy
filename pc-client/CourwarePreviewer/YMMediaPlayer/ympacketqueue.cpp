#include "ympacketqueue.h"

YMPacketQueue::YMPacketQueue(QObject *parent) : QObject(parent)
{

}

void YMPacketQueue::packetQueueInit(PacketQueue *queue)
{
    queue->first_pkt    = NULL;
    queue->last_pkt     = NULL;
    queue->nb_packets   = 0;
    queue->mutex        = SDL_CreateMutex();
    queue->cond         = SDL_CreateCond();
}

int YMPacketQueue::packetQueuePut(PacketQueue *queue, AVPacket *packet)
{
    AVPacketList   *pkt_list;
    if (av_dup_packet(packet) < 0)
    {
        return -1;
    }
    pkt_list = (AVPacketList *)av_malloc(sizeof(AVPacketList));
    if (pkt_list == NULL)
    {
        return -1;
    }
    pkt_list->pkt   = *packet;
    pkt_list->next  = NULL;
    //上锁
    SDL_LockMutex(queue->mutex);
    if (queue->last_pkt == NULL)
    {
        queue->first_pkt = pkt_list;
    }
    else
    {
        queue->last_pkt->next = pkt_list;
    }
    queue->last_pkt = pkt_list;  //这里queue->last_pkt = queue->last_pkt->next 的意思，但是，处理了更多的情况。
    queue->nb_packets++;
    queue->size += packet->size;
    SDL_CondSignal(queue->cond);
    SDL_UnlockMutex(queue->mutex);
    return 0;
}

int YMPacketQueue::packetQueueGet(PacketQueue *queue, AVPacket *pkt, int block)
{
    AVPacketList   *pkt_list = NULL;
    int            ret = -1;
    SDL_LockMutex(queue->mutex);
    while(1)
    {
        pkt_list = queue->first_pkt;
        if (pkt_list != NULL)         //队不空，还有数据
        {
            queue->first_pkt = queue->first_pkt->next;    //pkt_list->next
            if (queue->first_pkt == NULL)
            {
                queue->last_pkt = NULL;
            }
            queue->nb_packets--;
            queue->size -= pkt_list->pkt.size;
            *pkt = pkt_list->pkt;          // 复制给packet。
            av_free(pkt_list);
            ret = 0;
            break;
        }
        else if (block == 0)
        {
            ret = 0;
            break;
        }
        else
        {
            SDL_CondWaitTimeout(queue->cond, queue->mutex, 100);
            ret = -1;
            break;
        }
    }
    SDL_UnlockMutex(queue->mutex);
    return ret;
}

void YMPacketQueue::packetQueueFlush(PacketQueue *queue)
{
    AVPacketList    *pkt = NULL;
    AVPacketList    *pkt1 = NULL;
    SDL_LockMutex(queue->mutex);
    for(pkt = queue->first_pkt; pkt != NULL; pkt = pkt1)
    {
        pkt1 = pkt->next;
        av_free_packet(&pkt->pkt);
        av_freep(&pkt);
    }
    //packet_queue_init(queue);
    queue->first_pkt = NULL;
    queue->last_pkt = NULL;
    queue->nb_packets = 0;
    queue->size = 0;
    SDL_UnlockMutex(queue->mutex);
}
