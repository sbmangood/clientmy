#include "ymplayer.h"
#include "./ymaudiodecoder.h"
#include "./ymvideodecoder.h"
#include "./ympacketqueue.h"
#include "./ymseek.h"
#include <QDebug>
bool YMPlayer::playFinishedFlag = false;
YMPlayer::YMPlayer(QObject *parent) : QThread(parent)
{
    m_currentTime = -1;
    seekPosition = 0;
    filename = "";
}

void YMPlayer::playerStateInit(PlayerState *ps)
{
    ps->pformat_ctx             = NULL;
    ps->quit                    = 0;
    ps->player_state            = 0;

    ps->audio_stream_index      = -1;
    ps->paudio_stream           = NULL;

    ps->paudio_codec_ctx        = NULL;
    ps->paudio_codec            = NULL;
    ps->audio_buf_size          = 0;
    ps->audio_buf_index         = 0;
    ps->audio_quit              = 0;
    //视频
    ps->video_stream_index      = -1;
    ps->pvideo_stream           = NULL;
    ps->pvideo_codec_ctx        = NULL;
    ps->pvideo_codec            = NULL;
    ps->video_buf               = NULL;
    ps->video_buf_size          = 0;
    ps->video_buf_index         = 0;
    ps->psws_ctx                = NULL;
    ps->video_quit              = 0;
    ps->zero_packet_count       = 0;

    ps->pixel_w                 = 0;
    ps->pixel_h                 = 0;
    ps->window_w                = 0;
    ps->window_h                = 0;

    ps->pwindow                 = NULL;
    ps->prenderer               = NULL;
    ps->ptexture                = NULL;
    ps->pixfmt                  = AV_PIX_FMT_YUV420P;

    ps->audio_clock                 = 0.0;
    ps->video_clock                 = 0.0;
    ps->pre_frame_pts               = 0.0;      //前一帧显示时间
    //   ps->cur_frame_pkt_pts          = 0.0;      //当前帧在packet中标记的pts
    ps->pre_cur_frame_delay         = 40e-3;    //当前帧和前一帧的延时，前面两个相减的结果
    ps->cur_frame_pts               = 0.0;      //packet.pts
    ps->delay                       = 40;

}

void YMPlayer::setFileName(QString filename)
{
    this->filename = filename;
}

void YMPlayer::run()
{
    SDL_Event      event;
    //PlayerState    *ps = NULL;
    //   uint8_t        *state = NULL;

    ps = (PlayerState *)av_malloc(sizeof(PlayerState));
    if (ps == NULL)
    {
        qDebug() << "malloc ps error";
    }

    playerStateInit(ps);

    memcpy(ps->filename, filename.toStdString().c_str(), strlen(filename.toStdString().c_str()));

    if (prepareCommon(ps) != 0)
    {
        qDebug() << "prepare common error";
        return ;
    }

    //av_dump_format(ps->pformat_ctx, 0, ps->filename, 0);
    //至少有一种流，读流，解码。

    SDL_CreateThread(decodeThread, "decode_thread", ps);

    int64_t duration = 0;
    if (ps->audio_stream_index != -1)
    {
        //packet_queue_init(&ps->audio_packet_queue);
        YMAudioDecoder::prepareAudio(ps);
        YMAudioDecoder::playAudio(ps);
        duration = ps->pformat_ctx->streams[ps->audio_stream_index]->duration;
    }
    if ( ps->video_stream_index != -1)
    {
        //      packet_queue_init(&ps->video_packet_queue);
        YMVideoDecoder::gestance()->prepareVideo(ps);
        YMVideoDecoder::gestance()->playVideo(ps);
        duration = ps->pformat_ctx->streams[ps->video_stream_index]->duration;
    }
    qDebug() << QStringLiteral("总时长：") << ps->pformat_ctx->duration / 1000000 << ps->pformat_ctx->duration;
    totalTimes = ps->pformat_ctx->duration / 1000000;
    emit totalTime(totalTimes);
    playFinishedFlag = false;
    ps->player_state = 0;
    while(1)
    {
        if (ps->player_state == -1)
        {
            break;
        }

        SDL_WaitEvent(&event);
        switch(event.type)
        {
            case ISSHE_REFRESH_EVENT:   //自定义的事件
            {
                YMVideoDecoder::gestance()->decodeAndShow(ps, onRenderCallBack, this);
                break;
            }
            case SDL_WINDOWEVENT:       //窗口事件
            {
                SDL_GetWindowSize(ps->pwindow, &ps->window_w, &ps->window_h);
                break;
            }
            case PAUSE_EVENT:       //按键事件
            {
                if (ps->player_state == 1)
                {
                    ps->player_state = 0;
                    SDL_PauseAudio(0);

                }
                else if (ps->player_state == 0)
                {
                    ps->player_state = 1;
                    SDL_PauseAudio(1);
                }
                break;
            }
            case SEEK_EVENT:
            {
                //            increase = -10.0;
                YMSeek::doSeek(ps, seekPosition);
                break;
            }
            case STOP_EVENT:            //退出
            {
                qDebug() << "SDL_QUIT！";
                ps->player_state = -1;
                m_currentTime = -1;
                SDL_CloseAudio();
                SDL_Quit();
                break;
            }
            default:
            {
                break;
            }
        }

    }
    playFinishedFlag = true;
    emit playFinished();
    // avformat_close_input(&ps->pformat_ctx);
    return ;
}

void YMPlayer::closeVideoOutput()
{
    avformat_close_input(&ps->pformat_ctx);
}

int YMPlayer::decodeThread(void *arg)
{
    PlayerState *ps = (PlayerState *)arg;
    AVPacket    *packet = av_packet_alloc();
    int         flag = 0;

    //初始化队列
    if (ps->audio_stream_index != -1)
    {
        YMPacketQueue::packetQueueInit(&ps->audio_packet_queue);
    }

    if ( ps->video_stream_index != -1)
    {
        YMPacketQueue::packetQueueInit(&ps->video_packet_queue);
    }

    while(1)
    {
        if (ps->player_state == -1)
        {
            break;
        }
        //如果队列数据过多，就等待以下
        if (ps->seek_req == 1)
        {
            YMSeek::seeking(ps);
        }

        if (ps->audio_packet_queue.nb_packets >= MAX_AUDIO_QUEUE_SIZE ||
            ps->video_packet_queue.nb_packets >= MAX_VIDEO_QUEUE_SIZE)
        {
            //qDebug() << QStringLiteral("过多数据，延时");
            SDL_Delay(100);
            continue;
        }

        //小于0代表读完或者出错，如果连续多次都<0，则认为没数据了
        if (av_read_frame(ps->pformat_ctx, packet) < 0)
        {
            if (flag < READ_FRAME_ERROR_TIMES)
            {
                flag++;
                continue;
            }
            else
            {
                qDebug() << QStringLiteral("退出读pakcet线程!");
                break; //退出读packet线程
            }
        }
        flag = 0;
        //读取到数据了
        if (packet->stream_index == ps->video_stream_index)
        {
            YMPacketQueue::packetQueuePut(&ps->video_packet_queue, packet);
        }

        if (packet->stream_index == ps->audio_stream_index)
        {
            YMPacketQueue::packetQueuePut(&ps->audio_packet_queue, packet);
        }

    }

    av_packet_free(&packet);
    return 0;
}

void YMPlayer::onRenderCallBack(QImage img, int pts, void *data)
{
    YMPlayer *p = (YMPlayer*)data;
    if(pts != p->m_oldTime)
    {

        p->m_currentTime = pts;
        emit p->sigCurrentTime(pts);
        p->m_oldTime = pts;
    }
    if(p->m_currentTime >= p->totalTimes)
    {
        SDL_Event event;
        event.type = STOP_EVENT;
        SDL_PushEvent(&event);
    }
    emit p->sigOnRender(img);
}

int YMPlayer::prepareCommon(PlayerState *ps)
{
    av_register_all();
    avformat_network_init();
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER))
    {
        qDebug() << "init SDL error" << SDL_GetError();
        return -1;
    }

    //打开文件
    //pformat_ctx会有所指向，不用分配内存
    if (avformat_open_input(&ps->pformat_ctx, ps->filename, NULL, NULL) != 0)
    {
        qDebug() << "open input file error";
        return -1;
    }

    if (avformat_find_stream_info(ps->pformat_ctx, NULL) < 0)
    {
        qDebug() << "Couldn't find stream info";
        return -1;
    }

    ps->video_stream_index = -1;
    ps->audio_stream_index = -1;
    for (int i = 0; i < ps->pformat_ctx->nb_streams; i++)
    {
        if(ps->pformat_ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO && ps->video_stream_index < 0)
        {
            ps->video_stream_index = i;
        }
        else if(ps->pformat_ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO && ps->audio_stream_index < 0)
        {
            ps->audio_stream_index = i;
        }
    }
    if (ps->audio_stream_index == -1 && ps->video_stream_index == -1)
    {
        qDebug() << "Couldn't find any stream index";
        return -1;
    }
    return 0;
}

void YMPlayer::onEvent(int type, int data)
{
    SDL_Event event;
    if (type == 1)  //暂停事件
    {
        event.type = PAUSE_EVENT;
    }
    else if (type == 2)    //快进 快退
    {
        int seek = data - m_currentTime;
        seekPosition = seek;
        qDebug() << "seekPosition::data" << totalTimes << data << seekPosition << m_currentTime;
        event.type = SEEK_EVENT;
    }
    else if (type == 3)    //退出
    {
        event.type = STOP_EVENT;
    }
    SDL_PushEvent(&event);
}
