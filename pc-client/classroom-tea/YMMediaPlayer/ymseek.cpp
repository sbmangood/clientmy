#include "ymseek.h"

YMSeek::YMSeek()
{

}

void YMSeek::doSeek(PlayerState *ps, double increase)
{
    double  pos = 0.0;

    pos = YMAudioDecoder::getAudioClock(ps);    //这里以什么为基准同步，就用哪个clock。
    pos += increase;
    if (ps->seek_req == 0)
    {
        ps->seek_req = 1;
        ps->seek_pos = (int64_t)(pos * AV_TIME_BASE);       //seek_pos用double会不会更好点？
        //AVSEEK_FLAG_BACKWARD，ffmpeg定义为1
        ps->seek_flags = increase > 0 ? 0 : AVSEEK_FLAG_BACKWARD;
    }
}

void YMSeek::seeking(PlayerState *ps)
{
    int     stream_index = -1;
    int64_t seek_target = ps->seek_pos;

    if (ps->video_stream_index >= 0)
    {
        stream_index = ps->video_stream_index;
    }
    else if (ps->audio_stream_index >= 0)
    {
        stream_index = ps->audio_stream_index;
    }

    if (stream_index >= 0)
    {
        //AV_TIME_BASE_Q是AV_TIME_BASE的倒数，用AVRational结构存储
        AVRational rational;
        rational.den = 1000000;
        rational.num = 1;
        seek_target = av_rescale_q(seek_target, rational,
                                   ps->pformat_ctx->streams[stream_index]->time_base);
    }

    if (av_seek_frame(ps->pformat_ctx, stream_index,
                      seek_target, ps->seek_flags) < 0)
    {
        //error while seeking
    }
    else
    {
        if (ps->video_stream_index >= 0)
        {
            YMPacketQueue::packetQueueFlush(&ps->video_packet_queue);
        }
        if (ps->audio_stream_index >= 0)
        {
            YMPacketQueue::packetQueueFlush(&ps->audio_packet_queue);
        }
    }

    ps->seek_req = 0;
}
