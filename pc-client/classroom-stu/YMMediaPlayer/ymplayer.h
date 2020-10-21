#ifndef YMPLAYER_H
#define YMPLAYER_H
#include <QObject>
#include <QThread>
extern "C" {
#include <libswscale/swscale.h>
#include <libavutil/time.h>
#include <libavformat/avformat.h>
}
#include "./ympacketqueue.h"
#include <QImage>

#define MAX_AUDIO_FRAME_SIZE    192000  //1 second of 48khz 32bit audio
#define SDL_AUDIO_BUFFER_SIZE   1024    //

#define ERR_STREAM              stderr
#define OUT_SAMPLE_RATE         44100
#define OUT_STREAM              stdout
#define WINDOW_W                640
#define WINDOW_H                320
#define ISSHE_REFRESH_EVENT     (SDL_USEREVENT + 1)
#define BREAK_EVENT             (SDL_USEREVENT + 2)
#define VIDEO_QUIT_EVENT        (SDL_USEREVENT + 3)
#define AUDIO_QUIT_EVENT        (SDL_USEREVENT + 4)
#define SEEK_EVENT      (SDL_USEREVENT + 5)
#define PAUSE_EVENT     (SDL_USEREVENT + 6)
#define STOP_EVENT      (SDL_USEREVENT + 7)
#define MAX_AUDIO_QUEUE_SIZE    128
#define MAX_VIDEO_QUEUE_SIZE    64
#define READ_FRAME_ERROR_TIMES  10      //连续没读到packet10次，认为没有了
#include<QTimer>
typedef  void (*OnRenderCallBack)(QImage, double, void*);

typedef struct PlayerState
{
    //公共
    AVFormatContext    *pformat_ctx;
    char               filename[1024];
    int                quit;
    int                 player_state;
    /*
     SDL_Thread         *audio_decode_tid;
     SDL_Thread         *audio_tid;
     SDL_Thread         *video_decode_tid;
     SDL_Thread         *video_tid;
    */
    //音频
    int                audio_stream_index;
    AVStream           *paudio_stream;
    AVCodecContext     *paudio_codec_ctx;
    AVCodec            *paudio_codec;
    PacketQueue        audio_packet_queue;
    uint8_t            audio_buf[(MAX_AUDIO_FRAME_SIZE * 3) / 2];
    unsigned int       audio_buf_size;
    unsigned int       audio_buf_index;
    int                 audio_quit;

    //视频
    int                video_stream_index;
    AVStream           *pvideo_stream;
    AVCodecContext     *pvideo_codec_ctx;
    AVCodec            *pvideo_codec;
    PacketQueue        video_packet_queue;
    uint8_t            *video_buf;
    unsigned int       video_buf_size;
    unsigned int       video_buf_index;
    struct SwsContext  *psws_ctx;
    int                 video_quit;
    int                 zero_packet_count; //计算获取不到packet的次数，退出的依据

    int                pixel_w;
    int                pixel_h;
    int                window_w;
    int                window_h;

    SDL_Window         *pwindow;
    SDL_Renderer       *prenderer;
    SDL_Texture *ptexture;
    SDL_Rect sdl_rect;
    //     int pixfmt;
    AVPixelFormat pixfmt;
    //     AVFrame            frame;
    AVFrame            out_frame;

    //同步相关
    double             audio_clock;
    double             video_clock;
    double          pre_frame_pts;          //前一帧显示时间
    double          cur_frame_pts;          //packet.pts
    double          pre_cur_frame_delay;    //当前帧和前一帧的延时，前面两个相减的结果
    uint32_t            delay;
    double             frame_timer;

    //快进快退
    int                 seek_req;               //request
    int                 seek_flags;             //向前向后之类的
    int64_t         seek_pos;               //position，用double会不会更好点？
} PlayerState;


class YMPlayer : public QThread
{
        Q_OBJECT
    public:
        explicit YMPlayer(QObject *parent = 0);
        void playerStateInit(PlayerState *ps);


        void run();
        static int decodeThread(void *arg);
        static void onRenderCallBack(QImage img, double pts, void *data);
        int prepareCommon(PlayerState *ps);
        static bool playFinishedFlag ;

    signals:
        void sigOnRender(QImage);

        void totalTime(int totalTime);
        // void changeUrlFinished();
        void playFinished();

        void currentBePlayedTime(int time);

    public slots:
        void setFileName(QString filename);
        void onEvent(int type, int data);
        //void   checkPlayIsFinished();

    private:
        int seekPosition;
        QString filename;
        static int currentTime;
        int totalTimes;
};
#endif // YMPLAYER_H
