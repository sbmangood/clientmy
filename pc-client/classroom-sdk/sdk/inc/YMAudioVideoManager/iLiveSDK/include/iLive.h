#ifndef iLive_h_
#define iLive_h_

#include <iLiveCommon.h>
#include <iLiveString.h>
#include <iLiveVector.h>
#include <iLivePair.h>


namespace ilive
{
    /**
    @brief iLiveSDK�����뼯��
    */
    enum E_iLiveError
    {
        INVALID_INTETER_VALUE   = -1,   ///< ��Ч�����ͷ���ֵ(ͨ��)
        NO_ERR                  = 0,    ///< �ɹ�
        ERR_IM_NOT_READY        = 8001, ///< IMģ��δ������δ����
        ERR_AV_NOT_READY        = 8002, ///< AVģ��δ������δ����
        ERR_NO_ROOM             = 8003, ///< ����Ч�ķ���
        ERR_ALREADY_EXIST       = 8004, ///< Ŀ���Ѵ���
        ERR_NULL_POINTER        = 8005, ///< ��ָ�����
        ERR_ENTER_AV_ROOM_FAIL  = 8006, ///< ����AV����ʧ��
        ERR_USER_CANCEL         = 8007, ///< �û�ȡ��
        ERR_WRONG_STATE         = 8008, ///< ״̬�쳣
        ERR_NOT_LOGIN           = 8009, ///< δ��¼
        ERR_ALREADY_IN_ROOM     = 8010, ///< ���ڷ�����
        ERR_BUSY_HERE           = 8011, ///< �ڲ�æ(��һ����δ���)
        ERR_NET_UNDEFINE        = 8012, ///< ����δʶ������粻�ɴ�
        ERR_SDK_FAILED          = 8020, ///< iLiveSDK����ʧ��(ͨ��)
        ERR_INVALID_PARAM       = 8021, ///< ��Ч�Ĳ���
        ERR_NOT_FOUND           = 8022, ///< �޷��ҵ�Ŀ��
        ERR_NOT_SUPPORT         = 8023, ///< ����֧��
        ERR_ALREADY_STATE       = 8024, ///< ״̬�ѵ�λ(һ��Ϊ�ظ���������)
        ERR_KICK_OUT            = 8050, ///< ��������
        ERR_EXPIRE              = 8051, ///< Ʊ�ݹ���(�����Ʊ��userSig)
    };

    /**
    @brief �����¼�
    */
    enum E_EndpointEventId
    {
        EVENT_ID_NONE = 0,                      ///< ��
        EVENT_ID_ENDPOINT_ENTER = 1,            ///< ���뷿���¼�
        EVENT_ID_ENDPOINT_EXIT = 2,             ///< �˳������¼�
        EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO = 3, ///< �з�����ͷ��Ƶ�¼�
        EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO = 4,  ///< �޷�����ͷ��Ƶ�¼�
        EVENT_ID_ENDPOINT_HAS_AUDIO = 5,        ///< �з���Ƶ�¼�
        EVENT_ID_ENDPOINT_NO_AUDIO = 6,         ///< �޷���Ƶ�¼�
        EVENT_ID_ENDPOINT_HAS_SCREEN_VIDEO = 7, ///< �з���Ļ��Ƶ�¼�
        EVENT_ID_ENDPOINT_NO_SCREEN_VIDEO = 8,  ///< �޷���Ļ��Ƶ�¼�
        EVENT_ID_ENDPOINT_HAS_MEDIA_VIDEO = 9,  ///< �в�����Ƶ�¼�
        EVENT_ID_ENDPOINT_NO_MEDIA_VIDEO = 10,  ///< �޲�����Ƶ�¼�
    };

    /**
    @brief ��Ƶ��������
    */
    enum E_AudioCategory
    {
        AUDIO_CATEGORY_VOICECHAT = 0,               ///< VoIPģʽ���ʺ���ʵʱ��Ƶͨ�ų�������ʵʱ����ͨ��
        AUDIO_CATEGORY_MEDIA_PLAY_AND_RECORD = 1,   ///< ý��ɼ��벥��ģʽ���ʺ�����Щ������Ҫ��Ƚϸߵ�ֱ�������������������е�������Ա
        AUDIO_CATEGORY_MEDIA_PLAYBACK = 2,          ///< ý�岥��ģʽ���ʺ�����Щ������Ҫ��Ƚϸߵ�ֱ�������������������е�����
    };

    /**
    @brief ��Ϣ���͡�
    */
    enum E_MessageElemType
    {
        TEXT,
        CUSTOM,
        IMAGE,
        FACE,
    };

    /**
    @brief ͼƬ���͡�ԭͼ��ָ�û����͵�ԭʼͼƬ���ߴ�ʹ�С�����ֲ��䣻����ͼ�ǽ�ԭͼ�ȱ�ѹ����ѹ��������н�С��һ������198���أ���ͼҲ�ǽ�ԭͼ�ȱ�ѹ����ѹ��������н�С��һ������720����
    */
    enum E_ImageType
    {
        THUMB,
        LARGE,
        ORIGINAL,
    };

    /**
    @brief ��Ƶ�����ʽ
    */
    enum E_iLiveStreamEncode
    {
        HLS = 0x01,         ///< ����FLV�������Ƶ��URL
        FLV = 0x02,         ///< ����HLS�������Ƶ��URL
        RAW = 0X04,         ///< RAW����
        RTMP = 0X05,        ///< RTMP
        HLS_AND_RTMP = 0X06,///< HLS AND RTMP
    };

    /**
    @brief ¼����������
    */
    enum E_RecordDataType
    {
        E_RecordCamera = 0, ///< ¼������ͷ
        E_RecordScreen,     ///< ¼�Ƹ���(��Ļ����/�ļ�����)
    };

    /**
    @brief ¼���ļ�����(RecordFile_NONE��¼��)
    */
    enum E_RecordFileType
    {
        RecordFile_NONE = 0x00,
        RecordFile_HLS = 0x01,
        RecordFile_FLV = 0x02,
        RecordFile_HLS_FLV = 0x03,
        RecordFile_MP4 = 0x04,
        RecordFile_HLS_MP4 = 0x05,
        RecordFile_FLV_MP4 = 0x06,
        RecordFile_HLS_FLV_MP4 = 0x07,
        RecordFile_MP3 = 0x10,
    };

    /**
    @brief ������������
    */
    enum E_PushDataType
    {
        E_PushCamera = 0,///< ����ͷ
        E_PushScreen,    ///< ����(��Ļ����/�ļ�����)
    };

    /**
    @brief ���ʵ�λ
    */
    enum E_RateType
    {
        RATE_TYPE_ORIGINAL = 0, ///< ԭʼ����
        RATE_TYPE_550 = 10,     ///< ��������550K
        RATE_TYPE_900 = 20,     ///< ��������900K
    };

    /**
    @brief ɫ�ʸ�ʽ��
    */
    enum E_ColorFormat
    {
        COLOR_FORMAT_NONE = -1,     ///< ������
        COLOR_FORMAT_I420 = 0,      ///< i420��ʽ
        COLOR_FORMAT_NV21 = 1,
        COLOR_FORMAT_NV12 = 3,
        COLOR_FORMAT_RGB16 = 7,
        COLOR_FORMAT_RGB24 = 8,     ///< rgb24��ʽ(ʵ���ڴ��д�ŷ�ʽ��BGR888)
        COLOR_FORMAT_RGB32 = 9,
        COLOR_FORMAT_RGBA  = 10,
        COLOR_FORMAT_ABGR  = 11,
        COLOR_FORMAT_YUVA8888  = 21,
    };

    /**
    @brief ��Ļ����״̬��
    @details ��Ļ����״̬��
    */
    enum E_ScreenShareState
    {
        E_ScreenShareNone,  ///< δ������Ļ����
        E_ScreenShareWnd,   ///< ������ָ�����ڵĹ���
        E_ScreenShareArea,  ///< ������ָ������Ĺ���
    };

    /**
    @brief ��Ƭ״̬��
    */
    enum E_PlayMediaFileState
    {
        E_PlayMediaFileStop,    ///< ֹͣ����
        E_PlayMediaFilePlaying, ///< ������
        E_PlayMediaFilePause,   ///< ��ͣ��
    };

    /**
    @brief ��Ƶ�������͡�
    @details ��Ƶ�������͡�
    */
    enum E_VideoSrc
    {
        VIDEO_SRC_TYPE_NONE = 0,    ///< Ĭ��ֵ��������
        VIDEO_SRC_TYPE_CAMERA = 1,  ///< ����ͷ
        VIDEO_SRC_TYPE_SCREEN = 2,  ///< ��Ļ
        VIDEO_SRC_TYPE_MEDIA = 3,   ///< ��Ƭ
    };

    /**
    @brief �豸��������
    */
    enum E_DeviceOperationType
    {
        E_DeviceOperationNone,      ///< Ĭ��ֵ��������
        E_OpenCamera,               ///< ������ͷ
        E_CloseCamera,              ///< �ر�����ͷ
        E_OpenExternalCapture,      ///< ���Զ���ɼ�
        E_CloseExternalCapture,     ///< �ر��Զ���ɼ�
        E_OpenMic,                  ///< ����˷�
        E_CloseMic,                 ///< �ر���˷�
        E_OpenPlayer,               ///< ��������
        E_ClosePlayer,              ///< �ر�������
        E_OpenScreenShare,          ///< ����Ļ����
        E_CloseScreenShare,         ///< �ر���Ļ����
        E_OpenSystemVoiceInput,     ///< ��ϵͳ�����ɼ�
        E_CloseSystemVoiceInput,    ///< �ر�ϵͳ�����ɼ�
        E_OpenPlayMediaFile,        ///< ���ļ�����
        E_ClosePlayMediaFile,       ///< �ر��ļ�����
    };

    /**
    @brief ˮӡ���͡�
    @details ˮӡ����,����������ֱ���ֱ��ʵ���Ƶ����ˮӡ��
    */
    enum E_WaterMarkType
    {
        WATER_MARK_TYPE_NONE        = 0,
        WATER_MARK_TYPE_320_240     = 1, ///< ��Ա���ֱ���Ϊ320*240����Ƶ����ˮӡ��
        WATER_MARK_TYPE_480_360     = 2, ///< ��Ա���ֱ���Ϊ480*360����Ƶ����ˮӡ��
        WATER_MARK_TYPE_640_480     = 3, ///< ��Ա���ֱ���Ϊ640*480����Ƶ����ˮӡ��
        WATER_MARK_TYPE_640_368     = 4, ///< ��Ա���ֱ���Ϊ640*368����Ƶ����ˮӡ��
        WATER_MARK_TYPE_960_540     = 5, ///< ��Ա���ֱ���Ϊ960*540����Ƶ����ˮӡ��
        WATER_MARK_TYPE_1280_720    = 6, ///< ��Ա���ֱ���Ϊ1280*720����Ƶ����ˮӡ��
        WATER_MARK_TYPE_192_144     = 7, ///< ��Ա���ֱ���Ϊ192*144����Ƶ����ˮӡ��
        WATER_MARK_TYPE_320_180     = 8, ///< ��Ա���ֱ���Ϊ192*144����Ƶ����ˮӡ��
        WATER_MARK_TYPE_MAX,
    };

    /**
    @brief ����ͨ�����͡�
    */
    enum E_SPTCallType
    {
        SpeedTestCallType_Audio,        ///< ����Ƶ
        SpeedTestCallType_AudioVideo,   ///< ����Ƶ
    };

    /**
    @brief ����Ŀ�ġ�
    */
    enum E_SPTPurpose
    {
        SPTPurpose_EntTest,     ///< ����ͨ���ϱ��������ݻ�����һ��ר�����������;
        SPTPurpose_UserTest,    ///< �û�����������٣�Ŀ���ǲ��Ե�ǰ����״��;
    };

    /**
    @brief ��Ƶ���������������͡�
    */
    enum E_AudioDataSourceType
    {
        AUDIO_DATA_SOURCE_MIC           = 0, ///< ��ȡ������˷�ɼ�����Ƶ����(ע��: ע������ͻص��󣬼�ʹû�д���˷磬Ҳ�Ὺʼ�ص���˷���Ƶ����)��
        AUDIO_DATA_SOURCE_MIXTOSEND     = 1, ///< ����������Ƶ���ݣ��뱾�ط��͵���Ƶ���ݻ������ͳ�ȥ��
        AUDIO_DATA_SOURCE_SEND          = 2, ///< ��ȡ���ͷ����շ��ͳ�ȥ����Ƶ���ݡ�
        AUDIO_DATA_SOURCE_MIXTOPLAY     = 3, ///< ����������Ƶ���ݣ��뱾�ز��ŵ���Ƶ���ݻ���������������ų�����
        AUDIO_DATA_SOURCE_PLAY          = 4, ///< ��ȡ����������������Ƶ���ݡ�
        AUDIO_DATA_SOURCE_NETSTREM      = 5, ///< ��ȡ���շ��յ�����Ƶ���ݡ�
        AUDIO_DATA_SOURCE_VOICEDISPOSE  = 6, ///< ��˷���Ƶ����Ԥ����
        AUDIO_DATA_SOURCE_SYNCMIXTOSEND = 7, ///< ���ͻ������룬ʵʱ�Ը��ߡ�
        AUDIO_DATA_SOURCE_AACRAWSTREAM  = 8, ///< ����AAC���ݻ�ȡ���ڲ�ʹ�����ͣ��ݲ����⿪��
        AUDIO_DATA_SOURCE_END           = 9, ///< ������־��
    };

    /**
    @brief ��ƵԴ����(����Ч��Ԥ��)��
    */
    enum E_AudioSrcType
    {
        AUDIO_SRC_TYPE_NONE         = 0,    ///< Ĭ��ֵ�������塣
        AUDIO_SRC_TYPE_MIC          = 1,    ///< ��˷硣
        AUDIO_SRC_TYPE_ACCOMPANY    = 2,    ///< ���ࡣ
        AUDIO_SRC_TYPE_MIX_INPUT    = 3,    ///< �������롣
        AUDIO_SRC_TYPE_MIX_OUTPUT   = 4,    ///< ���������
    };

    /**
    @brief ��Ƶ��Ⱦ��ʽ
    */
    enum E_RootViewType
    {
        ROOT_VIEW_TYPE_NONE = 0,    ///< Ĭ��ֵ�������塣
        ROOT_VIEW_TYPE_D3D  = 1,    ///< Direct3DӲ������
        ROOT_VIEW_TYPE_GDI  = 2,    ///< GDI
    };

    /**
    @brief ��Ⱦ����ģʽ
    */
    enum E_ViewMode
    {
        VIEW_MODE_NONE  = 0,        ///< Ĭ��ֵ�������塣
        VIEW_MODE_FIT       = 1,    ///< ������ʾ����ı����������ź���������
        VIEW_MODE_HIDDEN    = 2,    ///< ����ͼ���ߵı����������ź�����������
    };

    /**
    @brief ����������������
    */
    enum E_PushSvrType
    {
        E_CustomSupport,    ///< 0: ����
        E_CloudSupport,     ///< 1: ��֧��
    };

    /// ����Ƶͨ����ͨ������Ȩ��λ��
    const uint64 AUTH_BITS_DEFAULT              = -1;           ///< ����Ȩ�ޡ�
    const uint64 AUTH_BITS_CREATE_ROOM          = 0x00000001;   ///< ��������Ȩ�ޡ�
    const uint64 AUTH_BITS_JOIN_ROOM            = 0x00000002;   ///< ���뷿���Ȩ�ޡ�
    const uint64 AUTH_BITS_SEND_AUDIO           = 0x00000004;   ///< ������Ƶ��Ȩ�ޡ�
    const uint64 AUTH_BITS_RECV_AUDIO           = 0x00000008;   ///< ������Ƶ��Ȩ�ޡ�
    const uint64 AUTH_BITS_SEND_CAMERA_VIDEO    = 0x00000010;   ///< ��������ͷ��Ƶ��Ȩ�ޡ�
    const uint64 AUTH_BITS_RECV_CAMERA_VIDEO    = 0x00000020;   ///< ��������ͷ��Ƶ��Ȩ�ޡ�
    const uint64 AUTH_BITS_SEND_SCREEN_VIDEO    = 0x00000040;   ///< ������Ļ��Ƶ��Ȩ�ޡ�
    const uint64 AUTH_BITS_RECV_SCREEN_VIDEO    = 0x00000080;   ///< ������Ļ��Ƶ��Ȩ�ޡ�

    /**
    @brief �������߻ص�����ָ������;
    */
    typedef void (*ForceOfflineCallback)();

    /**
    @brief ��������ɹ�����ָ������;
    */
    typedef void (*onNetworkCallback)();

    /**
    @brief ������ɻص�����ָ������;
    @param [in] result �������,NO_ERR��ʾ�ɹ�
    @param [in] errInfo ��������
    @param [in] data �Զ���ָ��
    */
    typedef void (*iLiveCompleteCallback)(int result, const char *errInfo, void* data);

    /**
    @brief �ɹ���ֵ�ص�����ָ�����͵ķ�װ
    */
    template <typename T>
    struct Type
    {
        /**
        @brief ͨ�õĳɹ���ֵ�ص�����ָ������;
        @param [in] value �����ɹ���SDK���ظ�ҵ�����Ӧ���͵�ֵ;
        @param [in] data SDK����ҵ����Զ��������ָ��;
        */
        typedef void (*iLiveValueSuccCallback)(T value, void* data);
    };

    /**
    @brief �յ���Ϣ�Ļص�����ָ�����͡�
    @param [in] msg �յ���Ⱥ��Ϣ
    */
    typedef void (*iLiveMessageCallback)( const struct Message &msg, void* data );

    /**
    @brief ��Ƶ֡Ԥ����ص�
    @param video_frame ��Ƶ֡����
    @param data �Զ���ָ��
    */
    typedef void (*iLivePreTreatmentCallback)( struct LiveVideoFrame* video_frame, void* data );
    /**
    @brief ��Ƶ֡�ص�
    @param video_frame ��Ƶ֡����
    @param data �Զ���ָ��
    */
    typedef void (*iLivePreviewCallback)( const struct LiveVideoFrame* video_frame, void* data );

    /**
    @brief �豸�����ص�
    @param [in] oper �豸��������;
    @param [in] retCode �����룬NO_ERR��ʾ�ɹ�;
    @param [in] data �Զ���ָ��;
    */
    typedef void (*iLiveDeviceOperationCallback)(E_DeviceOperationType oper, int retCode, void* data);

    /**
    @brief ͨ��ʧ�ܻص�
    @param [in] code ������
    @param [in] desc ��������
    @param [in] data �Զ���ָ��
    */
    typedef void (*iLiveErrCallback)(const int code, const char *desc, void* data);
    /**
    @brief ͨ�óɹ��ص�
    @param [in] data �Զ���ָ��
    */
    typedef void (*iLiveSucCallback)(void* data);

    /**
    @brief SDK�����˳������������ָ��
    @details SDK�ڲ�����Ϊ30s��������ʱ��ԭ�������˳����䣬APP��Ҫ�������˳������¼����Ը��¼�������Ӧ����
    @param [in] reason �˳�ԭ�������
    @param [in] errorinfo �˳�ԭ������
    @param [in] data �û��Զ�����ָ�룬�ص�������ԭ�ⲻ�����ظ�ҵ���
    */
    typedef void (*iLiveRoomDisconnectListener)(int reason, const char *errorInfo, void* data);
    /**
    @brief �����ڳ�Ա�仯��������ָ��
    @details �������Ա����״̬�仯(���Ƿ���Ƶ���Ƿ���Ƶ��)ʱ����ͨ���ú���ָ��֪ͨҵ���
    @param [in] event_id ״̬�仯id�����EndpointEventId�Ķ���
    @param [in] identifier_list ����״̬�仯�ĳ�Աid�б�
    @param [in] data �û��Զ��������ͣ��ص�������ԭ�ⲻ�����ظ�ҵ���
    */
    typedef void (*iLiveMemStatusListener)(E_EndpointEventId eventId, const Vector<String> &ids, void* data);
    /**
    @brief �豸��μ�������ָ��
    @param [in] data �û��Զ��������ͣ��ص�������ԭ�ⲻ�����ظ�ҵ���
    */
    typedef void (*iLiveDeviceDetectListener)(void* data);
    /**
    @brief ��������������Ļص�����ָ������
    @details ��iLiveRoomOption�еĲ���
    @param [in] param ��������������.
    @param [in] data �û��Զ��������ͣ��ص�������ԭ�ⲻ�����ظ�ҵ���
    */
    typedef void (*iLiveQualityParamCallback)(const struct iLiveRoomStatParam& param, void* data);

    /**
    @brief ��Ƶ���ݻص��������塣
    @param [in] audioFrame ��Ƶ���ݡ�
    @param [in] srcType ��Ƶ�������͡�
    @param [in] data �û��Զ��������ͣ��ص�������ԭ�ⲻ�����ظ�ҵ��ࡣ
    @details �ص�����Ҫ���Ƿ������ģ�SDK�ص�ʱ�����ȶ���20ms����, �ڻص�����������ʱ��ᵼ�������쳣�����⡣
    @remark �ص������趨Ϊר�Ŵ��������á������ص��ڷ����̣߳���ȷ���̰߳�ȫ���ر��ǲ�Ҫ�ڻص�������ֱ�ӵ���SDK�ӿڡ�
    */
    typedef void (*iLiveAudioDataCallback)(struct iLiveAudioFrame* audioFrame, E_AudioDataSourceType srcType, void* data);

    /**
    @brief ��Ϣ�е�ͼƬ
    */
    struct Image
    {
        /**
        @brief ͼƬ���췽��
        @param [in] _type ͼƬ����
        @param [in] _size ͼƬ�ļ���С
        @param [in] _width ͼƬ���
        @param [in] _height ͼƬ�߶�
        @param [in] _url ͼƬ���ص�ַ
        */
        Image(E_ImageType _type, unsigned _size, unsigned _width, unsigned _height, String _url) : type(_type), size(_size), width(_width), height(_height), url(_url)
        {

        }
        E_ImageType type;
        unsigned size;
        unsigned height;
        unsigned width;
        String url;
    };

    /**
    @brief ��ϢԪ�ػ���
    */
    struct MessageElem
    {
        E_MessageElemType type;
        MessageElem() {}
        MessageElem(const MessageElem& oth): type(oth.type) {}
        virtual ~MessageElem() {}
    };

    /**
    @brief �ı���ϢԪ��
    */
    struct MessageTextElem : public MessageElem
    {
        MessageTextElem(const String& _content)
            : content(_content)
        {
            type = TEXT;
        }
        String content;
    };

    /**
    @brief �Զ�����ϢԪ��
    */
    struct MessageCustomElem : public MessageElem
    {
        MessageCustomElem(const String& _data, const String& _ext) : data(_data), ext(_ext)
        {
            type = CUSTOM;
        }
        String data;
        String ext;
    };

    /**
    @brief ������ϢԪ��
    */
    struct MessageFaceElem : public MessageElem
    {
        MessageFaceElem(int _index, const String &_data) : data(_data), index(_index)
        {
            type = FACE;
        }
        int index;
        String data;
    };

    /**
    @brief ͼƬ��ϢԪ��
    */
    struct MessageImageElem : public MessageElem
    {
        MessageImageElem(const String& _path) : path(_path)
        {
            type = IMAGE;
        }
        MessageImageElem(const MessageImageElem& other)
            : MessageElem(other)
        {
            path = other.path;
            for (int i = 0; i < other.images.size(); ++i)
            {
                Image *otherImg = other.images[i];
                Image *img = new Image(otherImg->type, otherImg->size, otherImg->width, otherImg->height, otherImg->url);
                images.push_back(img);
            }
        }
        ~MessageImageElem()
        {
            while(images.size() > 0)
            {
                delete images.back();
                images.pop_back();
            }
        }

        String path;///< ����ͼƬ�ı��ص�ַ����������Ч
        Vector<Image*> images;///< ���յ�ͼƬ����������Ч

    };

    /**
    @brief ��Ϣ
    @details һ����Ϣ�ڿ��԰��������ϢԪ�أ�����˳������vector��
    */
    struct Message
    {
        String sender;
        uint32 time;
        Vector<MessageElem*> elems;

        Message()
        {
        }

        Message(const Message& other)
        {
            sender = other.sender;
            time = other.time;
            for (int i = 0; i < other.elems.size(); ++i)
            {
                const MessageElem* elem = other.elems[i];
                switch(elem->type)
                {
                    case TEXT:
                    {
                        const MessageTextElem *otherElem = static_cast<const MessageTextElem*>(other.elems[i]);
                        MessageTextElem *e = new MessageTextElem(otherElem->content);
                        elems.push_back(e);
                        break;
                    }
                    case CUSTOM:
                    {
                        const MessageCustomElem *otherElem = static_cast<const MessageCustomElem*>(other.elems[i]);
                        MessageCustomElem *e = new MessageCustomElem(otherElem->data, otherElem->ext);
                        elems.push_back(e);
                        break;
                    }
                    case IMAGE:
                    {
                        const MessageImageElem *otherElem = static_cast<const MessageImageElem*>(other.elems[i]);
                        MessageImageElem *e = new MessageImageElem(*otherElem);
                        elems.push_back(e);
                        break;
                    }
                    case FACE:
                    {
                        const MessageFaceElem *otherElem = static_cast<const MessageFaceElem*>(other.elems[i]);
                        MessageFaceElem *e = new MessageFaceElem(otherElem->index, otherElem->data);
                        elems.push_back(e);
                        break;
                    }
                }

            }
        }

        Message& Message::operator=(const Message& other)
        {
            if (&other == this) return *this;
            sender = other.sender;
            time = other.time;
            for (int i = 0; i < other.elems.size(); ++i)
            {
                const MessageElem* elem = other.elems[i];
                switch(elem->type)
                {
                    case TEXT:
                    {
                        const MessageTextElem *otherElem = static_cast<const MessageTextElem*>(other.elems[i]);
                        MessageTextElem *e = new MessageTextElem(otherElem->content);
                        elems.push_back(e);
                        break;
                    }
                    case CUSTOM:
                    {
                        const MessageCustomElem *otherElem = static_cast<const MessageCustomElem*>(other.elems[i]);
                        MessageCustomElem *e = new MessageCustomElem(otherElem->data, otherElem->ext);
                        elems.push_back(e);
                        break;
                    }
                    case IMAGE:
                    {
                        const MessageImageElem *otherElem = static_cast<const MessageImageElem*>(other.elems[i]);
                        MessageImageElem *e = new MessageImageElem(*otherElem);
                        elems.push_back(e);
                        break;
                    }
                    case FACE:
                    {
                        const MessageFaceElem *otherElem = static_cast<const MessageFaceElem*>(other.elems[i]);
                        MessageFaceElem *e = new MessageFaceElem(otherElem->index, otherElem->data);
                        elems.push_back(e);
                        break;
                    }
                }
            }
            return *this;
        }

        ~Message()
        {
            while(elems.size() > 0)
            {
                delete elems.back();
                elems.pop_back();
            }
        }
    };

    /**
    @brief iLiveRoom�����
    @details �ڴ������߼��뷿��ʱ����Ҫ����д�˽ṹ��Ϊ��������;
    */
    struct iLiveRoomOption
    {
        /**
        @brief ���캯������ʼ����Ա����ֵ��
        */
        iLiveRoomOption()
            : audioCategory(AUDIO_CATEGORY_MEDIA_PLAY_AND_RECORD) //����ֱ������
            , roomId(0)
            , joinImGroup(true)
            , authBits(AUTH_BITS_DEFAULT)
            , autoRequestCamera(true)
            , autoRequestScreen(true)
            , autoRequestMediaFile(true)
            , timeElapse(1000)
            , enableHwEnc(true)
            , enableHwDec(true)
            , enableHwScreenEnc(true)
            , enableHwScreenDec(true)
            , roomDisconnectListener(NULL)
            , memberStatusListener(NULL)
            , deviceDetectListener(NULL)
            , qualityParamCallback(NULL)
            , data(NULL)
        {
        }

        E_AudioCategory         audioCategory;          ///< ���ӳ�������,��ϸ��Ϣ��E_AudioCategory�Ķ���.
        uint32                  roomId;                 ///< ����ID,��ҵ��ഴ����ά���ķ���ID
        String                  groupId;                ///< IMȺ��ID;���ֶν���ģʽ��ʹ��;
        bool                    joinImGroup;            ///< �Ƿ����IMȺ��,���ֶν���ģʽ��ʹ��(Ĭ��Ϊtrue���������Ϊfalse����Ҫҵ����̨���û�����IMȺ��);
        uint64                  authBits;               ///< ͨ������Ȩ��λ;����Ӧ������ΪAUTH_BITS_DEFAULT,�����������ΪAUTH_BITS_DEFAULT & (~AUTH_BITS_CREATE_ROOM),��������ΪAUTH_BITS_JOIN_ROOM|AUTH_BITS_RECV_AUDIO|AUTH_BITS_RECV_CAMERA_VIDEO|AUTH_BITS_RECV_SCREEN_VIDEO
        String                  controlRole;            ///< ��ɫ����web������Ƶ�������ù��������õĽ�ɫ��
        String                  authBuffer;             ///< ͨ������Ȩ��λ�ļ��ܴ�
        bool                    autoRequestCamera;      ///< �������г�Ա������ͷʱ���Ƿ��Զ�������;
        bool                    autoRequestScreen;      ///< �������г�Ա����Ļ����ʱ���Ƿ��Զ�������;
        bool                    autoRequestMediaFile;   ///< �������г�Ա�򿪲�Ƭʱ���Ƿ��Զ�������;
        uint32                  timeElapse;             ///< sdkִ��qualityParamCallback�ص���ʱ����,��λ����(SDK�ڲ�1�����һ�Σ�����,timeElapseС��1000���ᱻ������1000)��
        bool                    enableHwEnc;            ///< ����ͷ�Ƿ�ʹ��Ӳ�����롣
        bool                    enableHwDec;            ///< ����ͷ�Ƿ�ʹ��Ӳ�����롣
        bool                    enableHwScreenEnc;      ///< ��Ļ�����Ƿ�ʹ��Ӳ�����롣
        bool                    enableHwScreenDec;      ///< ��Ļ�����Ƿ�ʹ��Ӳ�����롣

        /**
        @brief SDK�����˳�����ص�;
        @details ������Ͽ�30���,���յ��˻ص�,��ʱ�ѱ�sdkǿ���˳�����,����,��Ҫ�����˳�����ӿ�;����������,��Ҫ���´���\���뷿��,�μ�iLiveRoomDisconnectListener���塣
        */
        iLiveRoomDisconnectListener roomDisconnectListener;
        /**
        @brief �����Ա�¼�֪ͨ���μ�iLiveMemStatusListener���塣
        */
        iLiveMemStatusListener      memberStatusListener;
        /**
        @brief �豸��μ����ص�;
        @details ������ͷ����˷硢���������豸�Ľ��뼰�γ�ʱ��sdk��ͨ���˻ص�֪ͨ��ҵ��࣬�յ��˻ص���Ҫ�����豸�б�;�μ�iLiveDeviceDetectListener���塣
        @note ������ͷ����˷硢������������ʹ����ʱ,�յ��˻ص�ǰ�������յ���Ӧ�豸�رյĻص�;
        @todo ���ֶμ������������û�ʹ��iLive::setDeviceDetectCallback()�ӿ����ô˴˻ص�
        */
        Deprecated
        iLiveDeviceDetectListener   deviceDetectListener;
        /**
        @brief ��������Ļص�;
        @details ����û���Ҫ����������ֱ������,�������ô˻ص���������timeElapse��ֵ���μ�iLiveQualityParamCallback���塣
        */
        iLiveQualityParamCallback   qualityParamCallback;
        /**
        @brief �û��Զ����������ͣ���iLiveRoomOption��ָ���ĸ����ص���ԭ�ⲻ�����ء�
        */
        void*                       data;
    };

    /**
    @brief ¼�������
    @details ¼�Ʋ�����Ҫ��������͵Ĳ�����
    */
    struct RecordOption
    {
        /**
        @brief ���캯������ʼ����Ա����ֵ��
        */
        RecordOption()
            : recordDataType(E_RecordCamera)
            , fileName("")
            , classId(0)
        {
        }

        E_RecordDataType    recordDataType; ///< ¼�Ƶ���������,�μ�E_RecordDataType���塣
        String              fileName;       ///< ¼�ƺ���ļ�����
        int                 classId;        ///< ��Ƶ����ID(����Ч)��
    };

    /**
    @brief ���������
    @details ����������Ҫ��������͵Ĳ�����
    */
    struct PushStreamOption
    {
        /**
        @brief ���캯������ʼ����Ա������
        */
        PushStreamOption()
            : pushDataType(E_PushCamera)
            , encode(HLS)
            , recordFileType(RecordFile_NONE)
            , bOnlyPushAudio(false)
            , pushSvrType(E_CloudSupport)
            , recordId(0)
        {
        }

        E_PushDataType              pushDataType;       ///< �����������ͣ��μ�E_PushDataType����.
        E_iLiveStreamEncode         encode;             ///< �������ݱ��뷽ʽ���μ�E_TIMStreamEncode����.
        E_RecordFileType            recordFileType;     ///< ����ʱ�Զ�¼�Ƶ��ļ����ͣ��μ�E_RecordFileType����.
        /**
        @brief �Ƿ���Ƶ����
        @remark
        1��Ҫʹ�ô���Ƶ��������ע��:<br/>
            (1)��Ҫ��ϵ��Ѷ�����������ſ�ʹ�ô˹���;<br/>
            (2)�����ں�̨�����Զ�����������;<br/>
            (3)�ڿ�������ǰ����������Ƶ��(������ͷ����Ļ�����);<br/>
        2�� ʹ�ô���Ƶ����ʱ��������ز���˵��:<br/>
            (1)�����Ҫ����ʱ�Զ�¼���ļ���recordFileType��Ҫ����ΪRecordFile_MP3;<br/>
            (2)ʹ�ô���Ƶ����ʱ��pushDataType����ΪE_PushCamera��E_PushScreen��Ч��һ��������ʹ��Ĭ��ֵE_PushCamera;
        */
        bool                        bOnlyPushAudio;     ///< ����Ƶ����,����Ƶ����ʱ�����Ҫ¼���ļ�����Ҫ��recordFileTypeָ��ΪRecordFile_MP3

        E_PushSvrType               pushSvrType;        ///< ����������������(��ʱ��Ч��ʹ��Ĭ��ֵ����);
        uint32                      recordId;           ///< �û��Զ���RecordId(��Ӧ¼����Ƶ��ҵ���������ص����ֶ�stream_param��cliRecoId);
    };

    /**
    @brief ��������url����
    */
    struct LiveUrl
    {
        E_iLiveStreamEncode         encodeType; ///< ��Ƶ����������
        String                      url;        ///< ��Ƶ������URL
        E_RateType                  rateType;   ///< ���ʵ�λ��Ϣ
    };

    /**
    @brief ����������������
    */
    struct PushStreamRsp
    {
        PushStreamRsp()
            : channelId(0)
        {
        }

        Vector<LiveUrl>     urls;       ///< Url�б�
        uint64              channelId;  ///< Ƶ��ID,ֱ����ģʽ�£�ʼ��Ϊ0;
        uint32              tapeTaskId; ///< ¼�Ʊ��Ϊ¼�Ƶ�ʱ�����¼��task_id��Ч
    };

    /**
    @brief ��Ƶ֡������
    @details ��Ƶ֡������
    */
    struct VideoFrameDesc
    {
        VideoFrameDesc()
            : colorFormat(COLOR_FORMAT_RGB24)
            , width(0)
            , height(0)
            , externalData(false)
            , rotate(0)
            , srcType(VIDEO_SRC_TYPE_CAMERA)
        {
        }

        E_ColorFormat   colorFormat;    ///< ɫ�ʸ�ʽ�������ColorFormat�Ķ��塣
        uint32          width;          ///< ��ȣ���λ�����ء�
        uint32          height;         ///< �߶ȣ���λ�����ء�
        bool            externalData;   ///< �����Ƿ������ⲿ����ͷ��
        E_VideoSrc      srcType;        ///< ��ƵԴ���ͣ������VideoSrcType�Ķ��塣
        uint32          rotate;         ///< ��Ƶ������ת�Ƕȣ�����Ⱦʱ��Ҫ���Ǵ˽Ƕ�ֵ��0��1��2��3�ֱ��ʾ0�㡢90�㡢180�㡢270��
    };

    /**
    @brief ��Ƶ֡��
    */
    struct LiveVideoFrame
    {
        LiveVideoFrame()
            : dataSize(0)
            , data(NULL)
            , timeStamp(0)
        {
        }

        String          identifier; ///< ��Ƶ֡�����ķ����Աid��
        VideoFrameDesc  desc;       ///< ��Ƶ֡������
        uint32          dataSize;   ///< ��Ƶ֡�����ݻ�������С����λ���ֽڡ�
        uint8*          data;       ///< ��Ƶ֡�����ݻ�������SDK�ڲ�����������ķ�����ͷš�
        uint64          timeStamp;  ///< ��Ƶ֡��ʱ�����SDK�ڲ����Զ���д�ã�utcʱ�䣬0Ϊ��Чֵ��
    };

    /**
    @brief ֱ������Ϣ
    */
    struct AVStream
    {
        AVStream(String id, E_VideoSrc type): id(id), srcType(type) {};
        String      id;
        E_VideoSrc  srcType;
    };

    /**
    @brief ��������ʱ����
    */
    struct iLiveNetworkStatParam
    {
        iLiveNetworkStatParam()
            : kbpsSend(0)
            , lossRateSend(0)
            , lossRateSendUdt(0)
            , packetSend(0)
            , lossModelSend(0)

            , kbpsRecv(0)
            , lossRateRecvUdt(0)
            , lossRateRecv(0)
            , packetRecv(0)
            , unsendUdt(0)
            , interfaceIP(0)
            , interfacePort(0)
            , clientIP(0)
            , isTcp(false)
            , lossModelRecv(0)

            , cpuRateApp(0)
            , cpuRateSys(0)
            , rtt(0)

            , udtSMode(0)
            , udtRMode(0)
            , udtSendq(0)
            , udtRecvq(0)
            , udtEnable(false)
        {
        }

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;

            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(kbpsSend), kbpsSend);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossRateSend), lossRateSend);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossRateSendUdt), lossRateSendUdt);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(packetSend), packetSend);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossModelSend), lossModelSend);

            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(kbpsRecv), kbpsRecv);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossRateRecvUdt), lossRateRecvUdt);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossRateRecv), lossRateRecv);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(packetRecv), packetRecv);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(unsendUdt), unsendUdt);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(interfaceIP), interfaceIP);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(interfacePort), interfacePort);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(clientIP), clientIP);
            szRet += String::Format("%s%s: %d\n", pre.c_str(), NAME(isTcp), isTcp);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossModelRecv), lossModelRecv);

            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(cpuRateApp), cpuRateApp);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(cpuRateSys), cpuRateSys);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(rtt), rtt);

            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(udtSMode), udtSMode);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(udtRMode), udtRMode);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(udtSendq), udtSendq);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(udtRecvq), udtRecvq);
            szRet += String::Format("%s%s: %d\n", pre.c_str(), NAME(udtEnable), udtEnable);

            return szRet;
        }

        uint32  kbpsSend;           ///< ��������,��λkbps
        uint16  lossRateSend;       ///< ���ж����ʣ���Hello�Ļذ��л��
        uint16  lossRateSendUdt;    ///< udt�����ж�����
        uint32  packetSend;         ///< ��������,ÿ�뷢���ĸ���
        uint16  lossModelSend;      ///< ����ƽ������������������Hello�Ļذ��л��

        uint32  kbpsRecv;           ///< �հ�����,��λkbps
        uint16  lossRateRecvUdt;    ///< udt�����ж�����
        uint16  lossRateRecv;       ///< ���ж�����
        uint32  packetRecv;         ///< �հ�����,ÿ���հ��ĸ���
        uint32  unsendUdt;          ///< udtδ���Ͱ���
        uint32  interfaceIP;        ///< �ӿڻ�ip
        uint16  interfacePort;      ///< ��ӿڻ����ӵĶ˿�
        uint32  clientIP;           ///< �ͻ���ip
        bool    isTcp;              ///< �Ƿ�Ϊtcp
        uint16  lossModelRecv;      ///< ����ƽ��������������

        uint16  cpuRateApp;         ///< App���̵�CPUʹ���ʡ�10000(���磺3456��Ӧ��34.56%)
        uint16  cpuRateSys;         ///< ��ǰϵͳ��CPUʹ���ʡ�10000(���磺3456��Ӧ��34.56%)
        uint32  rtt;                ///< ����ʱ�ӣ�Round-Trip Time������λ���룬ͳ�Ʒ�����Hello SendData ��ʱ���һ�� TickCount��Hello Reply ��ʱ���һ�� TickCount�����ߵĲ�ֵΪʱ��

        uint16  udtSMode;           ///< udt���Ͷ�ģʽ
        uint16  udtRMode;           ///< udt���ն�ģʽ
        uint16  udtSendq;           ///< udt���Ͷ˶������ʱ�䳤��
        uint16  udtRecvq;           ///< udt���ն˶������ʱ�䳤��
        bool    udtEnable;          ///< udt switch
    };

    /**
    @brief ��Ƶ�ɼ�����
    */
    struct iLiveVideoCaptureParam
    {
        iLiveVideoCaptureParam(): width(0), height(0), fps(0) {}

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(width), width);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(height), height);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(fps), fps);
            return szRet;
        }

        uint32  width;    ///< ��Ƶ��
        uint32  height;   ///< ��Ƶ��
        uint32  fps;      ///< ֡��
    };

    /**
    @brief GOP��ر��������ò���
    */
    struct iLiveVideoEncNewGOPInterParam
    {
        iLiveVideoEncNewGOPInterParam()
            : reffrmInterval(0)
            , encIFrmNum(0)
            , reqIFrmNum(0)
            , recvNACKNum(0)
            , recvFailedFrmInfNum(0)
            , lossrate2S(0)
            , weigth20SLossRate(0)
        {
        }

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(reffrmInterval), reffrmInterval);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(encIFrmNum), encIFrmNum);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(reqIFrmNum), reqIFrmNum);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(recvNACKNum), recvNACKNum);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(recvFailedFrmInfNum), recvFailedFrmInfNum);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossrate2S), lossrate2S);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(weigth20SLossRate), weigth20SLossRate);
            return szRet;
        }

        uint32  reffrmInterval;     //���������õĲο�֡��֡����
        uint32  encIFrmNum;
        uint32  reqIFrmNum;
        uint32  recvNACKNum;
        uint32  recvFailedFrmInfNum;
        uint32  lossrate2S;
        uint32  weigth20SLossRate;
    };

    /**
    @brief ��Ƶ������ز���
    */
    struct iLiveVideoEncodeParam
    {
        iLiveVideoEncodeParam()
            : viewType(0), width(0), height(0), fps(0)
            , bitrate(0), angle(0), encodeType(0), hw(0)
        {
        }

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(viewType), viewType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(width), width);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(height), height);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(fps), fps);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(bitrate), bitrate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(angle), angle);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(encodeType), encodeType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(hw), hw);

            szRet += pre + "gopparam:\n";
            szRet += gopparam.getInfoString(pre + "   ");

            return szRet;
        }

        uint32 viewType;    ///< �������ͣ���Ϊ������Ϣ������0-��·���� 2-��·
        uint32 width;       ///< ��Ƶ�����
        uint32 height;      ///< ��Ƶ�����
        uint32 fps;         ///< ��Ƶ����ʵʱ֡�ʡ�10
        uint32 bitrate;     ///< ��Ƶ��������(�ް�ͷ)
        uint32 angle;       ///< �Ƕ�
        uint32 encodeType;  ///< ��Ƶ��������
        uint32 hw;          ///< �Ƿ�Ӳ������

        iLiveVideoEncNewGOPInterParam gopparam; //�µ�GOP����
    };

    /**
    @brief ��Ƶ���Ͳ���
    */
    struct iLiveVideoSendParam
    {
        iLiveVideoSendParam()
            : lossRate(0)
            , iFec(0)
            , spFec(0)
            , pkt(0)
            , STnSBGainLoss12s(0)
            , STnSBDecLostMaxConcal12s(0)
            , STnSBBreakSmallBreakContiPlc12s(0)
        {
        }

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossRate), lossRate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(iFec), iFec);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(spFec), spFec);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(pkt), pkt);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(STnSBGainLoss12s), STnSBGainLoss12s);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(STnSBDecLostMaxConcal12s), STnSBDecLostMaxConcal12s);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(STnSBBreakSmallBreakContiPlc12s), STnSBBreakSmallBreakContiPlc12s);
            return szRet;
        }

        uint32 lossRate;                        ///< ��Ƶ���Ͳ���������
        uint32 iFec;                            ///< ��Ƶ���Ͳ���I֡fec
        uint32 spFec;                           ///< ��Ƶ���Ͳ���sp֡
        uint32 pkt;                             ///< ��Ƶ���Ͱ���
        uint32 STnSBGainLoss12s;                ///< ��Ϊ���㡢��Ϊ����
        uint32 STnSBDecLostMaxConcal12s;        ///< �����ͳ�ƵĶ�����jitter��ͳ�Ƶ�EOS������һ����������������
        uint32 STnSBBreakSmallBreakContiPlc12s; ///< ���ٴ��������ܵ�С���ٴ���������plc
    };

    /**
    @brief ��Ƶ������ز���
    */
    struct iLiveVideoDecodeParam
    {
        iLiveVideoDecodeParam()
            : viewType(0)
            , width(0)
            , height(0)
            , fps(0)
            , bitrate(0)
            , hw(0)
            , codecType(0)
            , hwdecDelay(0)
        {
        }

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %s\n", pre.c_str(), NAME(userId), userId.c_str());
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(viewType), viewType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(width), width);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(height), height);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(fps), fps);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(bitrate), bitrate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(hw), hw);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(codecType), codecType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(hwdecDelay), hwdecDelay);
            return szRet;
        }

        String userId;      ///< �����û�
        uint32 viewType;    ///< �������ͣ���Ϊ������Ϣ������0-��·���� 2-��·
        uint32 width;       ///< ��Ƶ�����
        uint32 height;      ///< ��Ƶ�����
        uint32 fps;         ///< ��Ƶ�������֡�ʡ�10
        uint32 bitrate;     ///< ��Ƶ�����������(�ް�ͷ)
        uint32 hw;          ///< �Ƿ���Ӳ���
        uint32 codecType;   ///< ��������
        uint32 hwdecDelay;  ///< �����ӳ�
    };

    /**
    @brief ��Ƶ���ղ���
    */
    struct iLiveVideoRecvParam
    {
        iLiveVideoRecvParam(): lossRate(0.f), dwJitterR(0), dwBRR(0) {}

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %.2f\n", pre.c_str(), NAME(lossRate), lossRate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(dwJitterR), dwJitterR);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(dwBRR), dwBRR);
            return szRet;
        }

        float   lossRate;       ///< ��Ƶ���ն�����
        uint32  dwJitterR;      ///< ��Ƶ���ն���
        uint32  dwBRR;          ///< ��Ƶ��������
    };

    /**
    @brief ��Ƶ�·����ز���,���ں�̨Spear�����õĲ������
    */
    struct iLiveVideoQosParam
    {
        iLiveVideoQosParam()
            : width(0), height(0), fps(0), bitrate(0), encodeType(0), minQp(0), maxQp(0)
            , fectype(0), iFecPrecent(0), spFecPrecent(0), pFecPrecent(0), iMtu(0)
            , spMtu(0), pMtu(0), iFecMinPkg(0), spFecMinPkg(0), pFecMinPkg(0), iFecMinSize(0)
            , spFecMinSize(0), pFecMinSize(0), gopType(0), gop(0), encMode(0), hw(0)
        {
        }

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(width), width);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(height), height);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(fps), fps);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(bitrate), bitrate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(encodeType), encodeType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(minQp), minQp);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(maxQp), maxQp);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(fectype), fectype);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(iFecPrecent), iFecPrecent);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(spFecPrecent), spFecPrecent);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(pFecPrecent), pFecPrecent);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(iMtu), iMtu);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(spMtu), spMtu);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(pMtu), pMtu);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(iFecMinPkg), iFecMinPkg);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(spFecMinPkg), spFecMinPkg);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(pFecMinPkg), pFecMinPkg);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(iFecMinSize), iFecMinSize);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(spFecMinSize), spFecMinSize);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(pFecMinSize), pFecMinSize);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(gopType), gopType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(gop), gop);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(encMode), encMode);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(hw), hw);
            return szRet;
        }

        uint32 width;           ///< ��Ƶ��
        uint32 height;          ///< ��Ƶ��
        uint32 fps;             ///< ֡��
        uint32 bitrate;         ///< ����
        uint32 encodeType;      ///<��Ƶ�����·�������������
        uint32 minQp;           ///<��Ƶ�����·���С����
        uint32 maxQp;           ///<��Ƶ�����·��������
        uint32 fectype;         ///<��Ƶ�����·�����fec����
        uint32 iFecPrecent;     ///<��Ƶ�����·�i֡fec
        uint32 spFecPrecent;    ///<��Ƶ�����·�sp֡fec
        uint32 pFecPrecent;     ///<��Ƶ�����·�p֡fec
        uint32 iMtu;            ///<��Ƶ�����·�����I֡mtu
        uint32 spMtu;           ///<��Ƶ�����·�����sp֡mtu
        uint32 pMtu;            ///<��Ƶ�����·�����p֡mtu
        uint32 iFecMinPkg;      ///<��Ƶ�����·�����i֡��С��
        uint32 spFecMinPkg;     ///<��Ƶ�����·�����sp֡��С��
        uint32 pFecMinPkg;      ///<��Ƶ�����·�����p֡��С��
        uint32 iFecMinSize;     ///<��Ƶ�����·�����i֡��С����С
        uint32 spFecMinSize;    ///<��Ƶ�����·�����sp֡��С����С
        uint32 pFecMinSize;     ///<��Ƶ�����·�����p֡��С����С
        uint32 gopType;         ///<��Ƶ�����·�����gop����
        uint32 gop;             ///<��Ƶ�����·�����gop
        uint32 encMode;         ///<��Ƶ�����·�����ģʽ
        uint32 hw;              ///< 0:������Ӳ�����٣�1:����Ӳ������
    };

    /**
    @brief ��Ƶ�ɼ�����
    */
    struct iLiveAudioCaptureParam
    {
        iLiveAudioCaptureParam(): sampleRate(0), channelCount(0) {}

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(sampleRate), sampleRate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(channelCount), channelCount);
            return szRet;
        }

        uint32 sampleRate;      ///< ������
        uint32 channelCount;    ///< ͨ������1��ʾ������(mono)��2��ʾ������(stereo)
    };

    /**
    @brief ��Ƶ������ز���
    */
    struct iLiveAudioEncodeParam
    {
        iLiveAudioEncodeParam(): encodeType(0), encodeBitrate(0), vad(0) {}

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(encodeType), encodeType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(encodeBitrate), encodeBitrate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(vad), vad);
            return szRet;
        }

        uint32  encodeType;     ///< ��Ƶ��������
        uint32  encodeBitrate;  ///< ��Ƶ��������
        uint32  vad;            ///< ��Ƶ����vad����
    };

    /**
    @brief ��Ƶ���Ͳ���
    */
    struct iLiveAudioSendParam
    {
        iLiveAudioSendParam(): lossRate(0), FEC(0), jitter(0), sendBr(0), sendBrUdt(0) {}

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossRate), lossRate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(FEC), FEC);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(jitter), jitter);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(sendBr), sendBr);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(sendBrUdt), sendBrUdt);
            return szRet;
        }

        uint32  lossRate;       ///< ��Ƶ���Ͷ�����
        uint32  FEC;            ///< ��Ƶ����FEC
        uint32  jitter;         ///< ��Ƶ���Ͷ���
        uint32  sendBr;         ///< ��Ƶ���ͷ�������
        uint32  sendBrUdt;      ///< ��Ƶ���ͷ�������+header
    };

    /**
    @brief ��Ƶ������ز���
    */
    struct iLiveAudioDecodeParam
    {
        iLiveAudioDecodeParam(): decodeType(0), sampleRate(0), channelCount(0) {}

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %s\n", pre.c_str(), NAME(userId), userId.c_str());
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(decodeType), decodeType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(sampleRate), sampleRate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(channelCount), channelCount);
            return szRet;
        }

        String userId;       ///< ��Ƶ�����û�
        uint32 decodeType;   ///< ��Ƶ��������
        uint32 sampleRate;   ///< ��Ƶ���������
        uint32 channelCount; ///< ͨ������1��ʾ������(mono)��2��ʾ������(stereo)
    };

    /**
    @brief ��Ƶ���ղ���
    */
    struct iLiveAudioRecvParam
    {
        iLiveAudioRecvParam(): playDelay(0), lossRate(0), recvBr(0) {}

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(playDelay), playDelay);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(lossRate), lossRate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(recvBr), recvBr);
            return szRet;
        }

        uint32 playDelay;   ///< ��Ƶ���ղ���ʱ��
        uint32 lossRate;    ///< ��Ƶ���ն�����
        uint32 recvBr;      ///< ��ƵReceive����
    };

    /**
    @brief ��Ƶ�·����ز���,���ں�̨Spear�����õĲ������
    */
    struct iLiveAudioQosParam
    {
        iLiveAudioQosParam()
            : sampleRate(0)
            , channelCount(0)
            , codecType(0)
            , bitrate(0)
            , aecEnable(0)
            , agcEnable(0)
            , fec(0)
            , vad(0)
            , packDuration(0)
            , recn(0)
            , recm(0)
            , audioMtu(0)
            , jitterMinDelay(0)
            , jitterMinMaxDelay(0)
            , jitterMaxMaxDelay(0)
            , jitterDropScale(0)
        {
        }

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @param [in] pre ���ÿ�е�ǰ׺;
        @return �����String
        */
        String getInfoString(const String& pre) const
        {
            String szRet;
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(sampleRate), sampleRate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(channelCount), channelCount);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(codecType), codecType);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(bitrate), bitrate);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(aecEnable), aecEnable);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(agcEnable), agcEnable);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(fec), fec);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(vad), vad);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(packDuration), packDuration);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(recn), recn);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(recm), recm);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(audioMtu), audioMtu);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(jitterMinDelay), jitterMinDelay);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(jitterMinMaxDelay), jitterMinMaxDelay);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(jitterMaxMaxDelay), jitterMaxMaxDelay);
            szRet += String::Format("%s%s: %u\n", pre.c_str(), NAME(jitterDropScale), jitterDropScale);
            return szRet;
        }

        uint32 sampleRate;             ///< ������
        uint32 channelCount;           ///< ͨ������1��ʾ������(mono)��2��ʾ������(stereo)
        uint32 codecType;              ///< ��������
        uint32 bitrate;                ///< ����
        uint8  aecEnable;              ///< AEC�����Ƿ���
        uint8  agcEnable;              ///< AGC�����Ƿ���
        uint32 fec;                    ///< ��Ƶ�����·�fec
        uint32 vad;                    ///< ��Ƶ�����·�vad
        uint32 packDuration;          ///< ��Ƶ�����·�pack
        uint32 recn;                   ///< ��Ƶ�����·�recn
        uint32 recm;                   ///< ��Ƶ�����·�recm
        uint32 audioMtu;              ///< ��Ƶ�����·�mtu
        uint32 jitterMinDelay;       ///< Jitter����С��ʱ����λ����
        uint32 jitterMinMaxDelay;   ///< Jitter�����ʱ����С��ֵ
        uint32 jitterMaxMaxDelay;   ///< Jitter�����ʱ�����ֵ
        uint32 jitterDropScale;      ///< Jitter�����ʱ����ʧ�������ٷֱ�eg:10%Ϊ10,50%Ϊ50
    };

    /**
    @brief ����ֱ��������صĲ���
    */
    struct iLiveRoomStatParam
    {
        iLiveRoomStatParam()
            : tickCountBegin(0)
            , tickCountEnd(0)
            , avsdkVersion("")
            , exeCpuRate(0)
            , sysCpuRate(0)
            , isAnchor(false)
            , audioCategory(0)
        {
        }

        /**
        @brief ���˲������ת��ΪString�������ӡ���
        @return �����String
        */
        String getInfoString() const
        {
            String szRet;

            szRet += String::Format("%s: %llu\n", NAME(tickCountBegin), tickCountBegin);
            szRet += String::Format("%s: %llu\n", NAME(tickCountEnd), tickCountEnd);

            szRet += String::Format("%s: %s\n", NAME(avsdkVersion), avsdkVersion.c_str());
            szRet += String::Format("%s: %u\n", NAME(exeCpuRate), exeCpuRate);
            szRet += String::Format("%s: %u\n", NAME(sysCpuRate), sysCpuRate);

            szRet += "networkParams:\n";
            szRet += networkParams.getInfoString("   ");

            szRet += "videoCaptureParam:\n";
            szRet += videoCaptureParam.getInfoString("   ");

            szRet += String::Format( "%s: %d\n", NAME(videoEncodeParams.size), videoEncodeParams.size() );
            for (int i = 0; i < videoEncodeParams.size(); ++i)
            {
                szRet += String::Format("videoEncodeParams[%d]:\n", i);
                szRet += videoEncodeParams[i].getInfoString("   ");
            }

            szRet += "videoSendParam:\n";
            szRet += videoSendParam.getInfoString("   ");

            szRet += String::Format( "%s: %d\n", NAME(videoDecodeParams.size), videoDecodeParams.size() );
            for (int i = 0; i < videoDecodeParams.size(); ++i)
            {
                szRet += String::Format("videoDecodeParams[%d]:\n", i);
                szRet += videoDecodeParams[i].getInfoString("   ");
            }

            szRet += String::Format( "%s: %d\n", NAME(videoRecvParams.size), videoRecvParams.size() );
            for (int i = 0; i < videoRecvParams.size(); ++i)
            {
                szRet += String::Format("videoRecvParams[%d]:\n", i);
                szRet += videoRecvParams[i].getInfoString("   ");
            }

            szRet += String::Format("%s: %d\n", NAME(isAnchor), isAnchor);

            szRet += "videoMainQosParam:\n";
            szRet += videoMainQosParam.getInfoString("   ");

            szRet += "videoAuxQosParam:\n";
            szRet += videoAuxQosParam.getInfoString("   ");

            szRet += "audioCaptureParam:\n";
            szRet += audioCaptureParam.getInfoString("   ");

            szRet += "audioEncodeParams:\n";
            szRet += audioEncodeParams.getInfoString("   ");

            szRet += "audioSendParam:\n";
            szRet += audioSendParam.getInfoString("   ");

            szRet += String::Format( "%s: %d\n", NAME(audioDecodeParams.size), audioDecodeParams.size() );
            for (int i = 0; i < audioDecodeParams.size(); ++i)
            {
                szRet += String::Format("audioDecodeParams[%d]:\n", i);
                szRet += audioDecodeParams[i].getInfoString("   ");
            }

            szRet += "audioRecvParam:\n";
            szRet += audioRecvParam.getInfoString("   ");

            szRet += "audioQosParam:\n";
            szRet += audioQosParam.getInfoString("   ");

            szRet += String::Format("%s: %u\n", NAME(audioCategory), audioCategory);

            return szRet;
        }

        uint64                          tickCountBegin;     ///< ͳ�ƿ�ʼʱʱ��㣬ʹ�ñ���TickCount
        uint64                          tickCountEnd;       ///< ͳ�ƽ�����ʱ��㣬ʹ�ñ���TickCount

        String                          avsdkVersion;       ///< avsdk�汾��
        uint16                          exeCpuRate;         ///< Ӧ��CPUʹ���ʡ�10000(���磺3456��Ӧ��34.56%)
        uint16                          sysCpuRate;         ///< ϵͳCPUʹ���ʡ�10000(���磺3456��Ӧ��34.56%)

        iLiveNetworkStatParam           networkParams;      ///<  �������ص�ͳ�Ʋ���

        iLiveVideoCaptureParam          videoCaptureParam;  ///< ��Ƶ�ɼ�����
        Vector<iLiveVideoEncodeParam>   videoEncodeParams;  ///< ��Ƶ�������
        iLiveVideoSendParam             videoSendParam;     ///< ��Ƶ���Ͳ���

        Vector<iLiveVideoDecodeParam>   videoDecodeParams;  ///< ��Ƶ�������
        Vector<iLiveVideoRecvParam>     videoRecvParams;    ///< ��Ƶ���ղ���
        bool                            isAnchor;           ///< �Ƿ�Ϊ����(ֻҪ����Ƶ���о���Ϊ������)

        iLiveVideoQosParam              videoMainQosParam;  ///< ��·��Ƶ�����·�����
        iLiveVideoQosParam              videoAuxQosParam;   ///< ��·��Ƶ�����·�����

        iLiveAudioCaptureParam          audioCaptureParam;  ///< ��Ƶ�ɼ���Ϣ
        iLiveAudioEncodeParam           audioEncodeParams;  ///< ��Ƶ�������(�˲�����ʱΪ0������������)
        iLiveAudioSendParam             audioSendParam;     ///< ��Ƶ������Ϣ

        Vector<iLiveAudioDecodeParam>   audioDecodeParams;  ///< ��Ƶ�������(�˲�����ʱΪ0������������)
        iLiveAudioRecvParam             audioRecvParam;     ///< ��Ƶ������Ϣ
        iLiveAudioQosParam              audioQosParam;      ///< ��Ƶ�����·�����
        uint32                          audioCategory;      ///< ��Ƶ����
    };

    /**
    @brief ÿ��IP��Ӧ�Ĳ��ٽ��
    */
    struct iLiveSpeedTestResult
    {
        uint32          access_ip;      ///< �ӿڻ�IP
        uint32          access_port;    ///< �ӿڻ��˿�
        uint32          clientip;       ///< �ͻ���IP
        uint32          test_cnt;       ///< �˲��ٰ�����
        uint32          test_pkg_size;  ///< ���ٰ���С
        uint32          avg_rtt;        ///< ƽ������ʱ��
        uint32          max_rtt;        ///< �������ʱ��
        uint32          min_rtt;        ///< ��С����ʱ��
        uint32          rtt0_50;        ///< 0-50ms rtt�������
        uint32          rtt50_100;      ///< 50-100ms rtt�������
        uint32          rtt100_200;     ///< 100-200ms rtt�������
        uint32          rtt200_300;     ///< 200-300ms rtt�������
        uint32          rtt300_700;     ///< 300-700ms rtt�������
        uint32          rtt700_1000;    ///< 700-1000ms rtt�������
        uint32          rtt1000;        ///< 1000ms���� rtt�������
        uint32          jitter0_20;     ///< ���綶��0-20ms�������
        uint32          jitter20_50;    ///< ���綶��20-50ms�������
        uint32          jitter50_100;   ///< ���綶��50-100ms�������
        uint32          jitter100_200;  ///< ���綶��100-200ms�������
        uint32          jitter200_300;  ///< ���綶��200-300ms�������
        uint32          jitter300_500;  ///< ���綶��300-500ms�������
        uint32          jitter500_800;  ///< ���綶��500-800ms�������
        uint32          jitter800;      ///< ���綶������800ms�������
        uint32          t1_uploss;      ///< ���ж����ʡ�10000(���磺1111��Ӧ��11.11%)
        uint32          t1_dwloss;      ///< ���ж����ʡ�10000(���磺1111��Ӧ��11.11%)
        uint32          up_cons_loss0;  ///< ������������Ϊ0�Ĵ���
        uint32          up_cons_loss1;  ///< ������������Ϊ1�Ĵ���
        uint32          up_cons_loss2;  ///< ������������Ϊ2�Ĵ���
        uint32          up_cons_loss3;  ///< ������������Ϊ3�Ĵ���
        uint32          up_cons_lossb3; ///< ����������������3�Ĵ���
        uint32          dw_cons_loss0;  ///< ������������Ϊ0�Ĵ���
        uint32          dw_cons_loss1;  ///< ������������Ϊ1�Ĵ���
        uint32          dw_cons_loss2;  ///< ������������Ϊ2�Ĵ���
        uint32          dw_cons_loss3;  ///< ������������Ϊ3�Ĵ���
        uint32          dw_cons_lossb3; ///< ����������������3�Ĵ���
        uint32          up_disorder;    ///< �����������
        uint32          dw_disorder;    ///< �����������
        Vector<uint32>  up_seq;         ///< ���а�����
        Vector<uint32>  dw_seq;         ///< ���а�����
    };

    /**
    @brief ���ٽӿڻص���������
    */
    struct iLiveSpeedTestResultReport
    {
        uint64          test_id;        ///< ����id
        uint64          test_time;      ///< ����ʱ���(s)
        uint64          roomid;         ///< ���Է����
        uint32          client_type;    ///< �ͻ������� 0:unknown  1:pc  2:android  3:iphone  4:ipad
        uint32          net_type;       ///< ��������(ʼ��Ϊ1): 0:������  1:wifi  2:2G  3:3G  4:4G  10:WAP  255:unknow
        String          net_name;       ///< ��Ӫ�����֣��ܻ�ȡ���ϱ�,utf8(��Ч)
        String          wifi_name;      ///< wifi ssid���ܻ�ȡ���ϱ�,utf8(��Ч)
        double          longitude;      ///< ����(��Ч)
        double          latitude;       ///< γ��(��Ч)
        uint32          client_ip;      ///< �ͻ���IP
        uint32          call_type;      ///< ͨ�����ͣ�0:����Ƶ��1:����Ƶ
        uint32          sdkappid;       ///< sdkappid
        uint32          test_type;      ///< ��������: 0x1:udp  0x2:tcp  0x4:http get  0x8:http post  0x10:trace route
        Vector<iLiveSpeedTestResult>    results;    ///< ���Խ���б�
        uint32          net_changecnt;  ///< ���ٹ���������仯����(��Ч)
        uint32          access_ip;      ///< ����ͨ��ѡ���accessip(��Ч)
        uint32          access_port;    ///< ����ͨ��ѡ���access port(��Ч)
    };

    /**
    @brief ����mp4¼��ί�л��ࡣҵ�����Ҫʵ�ָû���������¼���¼���
    */
    struct iLiveLocalRecordDelegate
    {
        virtual ~iLiveLocalRecordDelegate() {}

        /**
        @brief ¼�ƹ����з�������Ļص�֪ͨ��
        @details ����¼��֮����¼�ƹ����з������󣬼��ص��������, �����Զ�ֹͣ¼�ơ�
        */
        virtual void OnError(int32 result, const String& errInf) = 0;

        /**
        @brief ���浥��¼��MP4�ļ�ʱ�Ļص�֪ͨ, ���Ƿ�ֹͣ¼��MP4�޹ء�
        @param [in] duration mp4�ļ�ʱ������λ�롣����MP4�ļ����ʱ��Ϊ1Сʱ��
        @param [in] width mp4�ļ���Ƶͼ���ȡ�
        @param [in] height mp4�ļ���Ƶͼ��߶ȡ�
        @param [in] filePath mp4�ļ�·����
        @details ����¼��֮��¼�ƹ��������һ��MP4�ļ���¼�ƣ����ص����������
                 ¼�ƹ������п��ܲ������MP4�ļ�, ��¼�ƹ����п��ܻ��ж��OnRecorded�ص���
                 �������MP4�ļ��Ǳ�Ҫ��, ԭ����:<br/>
                 1. SDK�������ܿ��ǣ�û�н��ж��α��룬����ֱ�ӽ�ͨ���е���������dump����ת��MP4��<br/>
                 2. ����ͨ���������н�ɫ, ��Ƶ�����п��ܻ�仯������h264 sps pps�����ı�(��ҪΪ��Ƶ�ֱ��ʸı�)���Ӷ��������±��档<br/>
                 3. �ر�ģ�����ͨ�������У���Ļ��������仯������h264 sps pps�����ı�(��ҪΪ��Ƶ�ֱ��ʸı�)���Ӷ��������±��档<br/>
                 4. ���ǵ�����ת��mp4��ʱ��Ϳռ�Ч�����⣬�����ļ����ʱ��Ϊ1Сʱ�����������±��档<br/>
                 5. ����ͷ����Ļ�����ͬʱ¼�Ʊ��棬Ҳ��ֿ�¼�Ʊ��棬����ͷMP4�ļ�����"main"��ͷ����Ļ����MP4�ļ�����"sub"��ͷ<br/>
                 6. ��Ƶ��̶�ת��Ϊ��׼ACC (sample rate: 48000, channel: 2, bitrate: 64000),���������������MP4�����⡣<br/>
                 ���ԣ�����ҵ��ྡ��ʹ�ù̶��ֱ��ʣ��̶����ʵȲ���������mp4�ļ�����������ࡣ
        */
        virtual void OnRecorded(uint32 duration, uint32 width, uint32 height, const String& filePath) = 0;
    };

    /**
    @brief ��Ƶ����֡��ʽ
    */
    struct iLiveAudioFrameDesc
    {
        iLiveAudioFrameDesc()
            : sampleRate(0)
            , channelNum(0)
            , bits(0)
            , srcType(AUDIO_SRC_TYPE_NONE)
        {
        }

        uint32          sampleRate; ///< �����ʣ���λ������(Hz)
        uint32          channelNum; ///< ͨ������1��ʾ������(mono)��2��ʾ������(stereo)
        uint32          bits;       ///< ��Ƶ����λ��SDK1.6�汾�ݹ̶�Ϊ16��
        E_AudioSrcType  srcType;    ///< ��ƵԴ���͡�
    };

    /**
    @brief ��Ƶ����֡
    */
    struct iLiveAudioFrame
    {
        iLiveAudioFrame()
            : dataSize(0)
            , data(NULL)
            , timeStamp(0)
        {
        }

        String              identifier; ///< ��Ƶ֡�����ķ����Աid��
        iLiveAudioFrameDesc desc;       ///< ��Ƶ֡������
        uint32              dataSize;   ///< ��Ƶ֡�����ݻ�������С����λ���ֽڡ�
        uint8*              data;       ///< ��Ƶ֡�����ݻ�������SDK�ڲ�����������ķ�����ͷš�
        uint64              timeStamp;  ///< ��Ƶ֡��ʱ�����SDK�ڲ����Զ���д�ã�utcʱ�䣬0Ϊ��Чֵ��
    };

    /**
    @brief �ӿڷ�װ����ӿ�
    */
    struct iLive
    {
        /**
        @brief ��ȡ�汾��
        @return �汾��
        */
        virtual const char *getVersion() = 0;
        /**
        @brief ��ʼ��
        @details ʹ��ilive�����ǰ�����ȳ�ʼ��
        @param [in] appId ����Ѷ�������sdkappid
        @param [in] accountType ����Ѷ�������accountType
        @param [in] imSupport �Ƿ���Ҫ����ȼ�ʱͨѶ����
        @return ���ز������,�ɹ��򷵻�NO_ERR
        */
        virtual int init(const int appId, const int accountType, bool imSupport = true) = 0;
        /**
        @brief �ͷ�
        @details ʹ����ilive����Ҫ�ͷ���Դ��
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        @remark �˺���������7��ǰ��������־�ļ�(iLiveSDK��AVSDK��IMSDK)��
        */
        virtual void release(iLiveSucCallback suc = NULL, iLiveErrCallback err = NULL, void* data = NULL) = 0;
        /**
        @brief ���ñ������߼���
        @details ÿ���˺Ų���ͬʱ��¼��̨�豸���������豸��¼��ͬ�˺�ʱ���յ����֪ͨ
        @param [in] cb �ص�����
        */
        virtual void setForceOfflineCallback(ForceOfflineCallback cb) = 0;
        /**
        @brief ������Ϣ����
        @param [in] cb �ص�����
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        @note ��ǰ��������Ⱥ��֮���Ⱥ��Ϣ�ᱻsdk���˵�;
        */
        virtual void setMessageCallBack( iLiveMessageCallback cb, void* data ) = 0;
        /**
        @brief �����������Ӽ���
        @param [in] onConn �����ɹ��ص�
        @param [in] onDisconn �����ص�
        @note ����ɹ������ص����ٽ��е�¼������ҵ���߼�
        */
        virtual void setConnListener( onNetworkCallback onConn, onNetworkCallback onDisconn ) = 0;

        /**
        @brief ����Ԥ������ָ�롣
        @details ����Ƶ�������ȥǰ���û������ڴ˻ص���������Ԥ����;
        @param [in] pPreTreatmentFun Ԥ������ָ�롣
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        @remark Ԥ��������ʱ��Ҫ���ã���ÿ�����10ms��; ͬʱ���ܸı�ͼ���С��ͼ����ɫ��ʽ��
        @note SDK�������߳���ִ�д˻ص�.
        */
        virtual void setPreTreatmentFun( iLivePreTreatmentCallback pPreTreatmentFun, void* data ) = 0;
        /**
        @brief ���ñ�����Ƶ�ص�����ָ�롣
        @param [in] pLocalVideoCB ������Ƶ�ص�����ָ��
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        @remark ҵ���ʵ�ָûص�������SDK��ûص��������뱾����Ƶ������ݣ�ҵ����õ����ݺ������Ⱦ��ʾ
        */
        virtual void setLocalVideoCallBack( iLivePreviewCallback pLocalVideoCB, void* data ) = 0;
        /**
        @brief ����Զ����Ƶ�ص�����ָ�롣
        @param [in] pRemoteVideoCB Զ����Ƶ�ص�����ָ��
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        @remark ҵ���ʵ�ָûص�������SDK��ûص���������Զ����Ƶ������ݣ�ҵ����õ����ݺ������Ⱦ��ʾ
        */
        virtual void setRemoteVideoCallBack( iLivePreviewCallback pRemoteVideoCB, void* data ) = 0;
        /**
        @brief �����豸�����ص�����ָ�롣
        @details ����ͷ���Զ���ɼ�����˷硢����������Ļ����ϵͳ�����ɼ����ļ����ŵ��豸�����������ͨ���˻ص�֪ͨ��ҵ��㡣
        @param [in] cb �豸�����Ļص�����ָ��.
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        */
        virtual void setDeviceOperationCallback( iLiveDeviceOperationCallback cb, void* data ) = 0;
        /**
        @brief �����豸��μ�������;
        @details ������ͷ����˷硢�������豸�Ľ��뼰�γ�ʱ��sdk��ͨ���˻ص�֪ͨ��ҵ��࣬�յ��˻ص���Ҫ�����豸�б�;�μ�iLiveDeviceDetectListener���塣
        @note ������ͷ����˷硢������������ʹ����ʱ,�豸���γ����յ��˻ص�ǰ�������յ���Ӧ�豸�رյĻص�;
        */
        virtual void setDeviceDetectCallback( iLiveDeviceDetectListener cb, void* data ) = 0;
        /**
        @brief ������Ƶ�ص�����ɫ��ʽ;
        @details ������Ƶ�ص�(setLocalVideoCallBack()��setRemoteVideoCallBack()�ӿ����õĻص�)����Ƶ֡��ɫ��ʽ;
        @param [in] fmt ��ɫ��ʽ;
        @return ���������true�ɹ���falseʧ��;
        @note ��Ҫ�ڽ��뷿��\�����豸����֮ǰ����,���򷵻�false;
        */
        virtual bool setVideoColorFormat(E_ColorFormat fmt) = 0;

        /**
        @brief ��¼
        @param [in] userId �û�id
        @param [in] userSig �û�ǩ��
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        */
        virtual void login(const char *userId, const char *userSig, iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;
        /**
        @brief �ǳ�
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        */
        virtual void logout(iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;

        /**
        @brief ��ʼ�豸����
        @details ��ʼ�豸���Ժ󣬿����ڵ�¼֮�󣬽��뷿��֮ǰ���Դ�����ͷ����˷硢�������������豸����;
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        @param [in] preWidth ���ô�����ͷ����ʱ,��Ƶ֡�Ŀ��(�˲����ѷ�����sdkʹ������ͷ֧��Ĭ�Ͽ��);
        @param [in] preHeight ���ô�����ͷ����ʱ,��Ƶ֡�ĸ߶�(�˲����ѷ�����sdkʹ������ͷ֧��Ĭ�ϸ߶�);
        @remark �豸����ʱ�����ա����׹��ܿ���;
        */
        virtual void startDeviceTest(iLiveSucCallback suc, iLiveErrCallback err, void* data, int preWidth = 640, int preHeight = 480) = 0;
        /**
        @brief ֹͣ�豸����
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        @remark �ڿ�ʼ�豸���Ժ���Ҫֹͣ�豸���ԣ����ܽ��뷿�䣬����᷵����Ӧ������;
        */
        virtual void stopDeviceTest(iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;

        /**
        @brief ����ֱ������
        @param [in] roomOption ��������
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        */
        virtual void createRoom(const iLiveRoomOption &roomOption, iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;
        /**
        @brief ����ֱ������
        @param [in] roomOption ��������
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        */
        virtual void joinRoom(const iLiveRoomOption& roomOption, iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;
        /**
        @brief �˳�ֱ������
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        */
        virtual void quitRoom(iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;
        /**
        @brief ����һ��������Ա����Ƶ����
        @param [in] streams �������
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        @note
        1��requestStream��������ȴ��첽�ص�����ִ�н����󣬲��ܽ����µ�requestStream����;<br/>
        2��requestStream��cancelStream��cancelAllStream���ܲ���ִ�У���ͬһʱ��ֻ�ܽ���һ�ֲ���;
        */
        virtual void requestStream(const Vector<AVStream> &streams, iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;
        /**
        @brief  ȡ��ָ���û��Ļ��档
        @param [in] streams ȡ������
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        @note
        1��cancelStream��������ȴ��첽�ص�����ִ�н����󣬲��ܽ����µ�cancelStream����;<br/>
        2��requestStream��cancelStream��cancelAllStream���ܲ���ִ�У���ͬһʱ��ֻ�ܽ���һ�ֲ���;
        */
        virtual void cancelStream(const Vector<AVStream> &streams, iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;
        /**
        @brief ȡ�������������Ƶ���档
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        @note requestStream��cancelStream��cancelAllStream���ܲ���ִ�У���ͬһʱ��ֻ�ܽ���һ�ֲ���;
        */
        virtual void cancelAllStream(iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;
        /**
        @brief ��C2C��Ϣ
        @param [in] dstUser ���շ�id
        @param [in] message Ҫ���͵���Ϣ
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        */
        virtual void sendC2CMessage( const char *dstUser, const Message &message, iLiveSucCallback suc, iLiveErrCallback err, void* data ) = 0;
        /**
        @brief ��Ⱥ��Ϣ
        @param [in] message Ҫ���͵���Ϣ
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        @note �˴�����Ⱥ��Ϣ���������ڵ�ǰֱ�����з���Ⱥ��Ϣ��
        */
        virtual void sendGroupMessage( const Message &message, iLiveSucCallback suc, iLiveErrCallback err, void* data ) = 0;

        /**
        @brief ��ȡ������Ϣ
        @param [in] count Ҫ��ȡ����Ϣ����
        @param [in] user �Ự�Ķ���id
        @param [in] fromStart ��ͷ��ʼ��ȡ
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        */
        virtual void getLocalC2CMessage( int count, const char *user, bool fromStart, Type<Vector<Message>>::iLiveValueSuccCallback suc, iLiveErrCallback err, void* data ) = 0;

        /**
        @brief ��ʼ����
        @param [in] pushOption ��������
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        */
        virtual void startPushStream( const PushStreamOption& pushOption, Type<PushStreamRsp&>::iLiveValueSuccCallback suc, iLiveErrCallback err, void* data ) = 0;
        /**
        @brief ��������
        @param [in] channelId Ƶ��id(�������ɹ��ĵĻص��з��ص�Ƶ��id)
        @param [in] pushDataType Ҫֹͣ��������������
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        */
        virtual void stopPushStream( uint64 channelId, E_PushDataType pushDataType, iLiveSucCallback suc, iLiveErrCallback err, void* data ) = 0;

        /**
        @brief ��ʼ¼�ơ�
        @param [in] recordOption ¼������ѡ�
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        */
        virtual void startRecord(const RecordOption& recordOption, iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;

        /**
        @brief ֹͣ¼�ơ�
        @param [in] recordDataType Ҫֹͣ¼�Ƶ���������
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        @remark ֹͣ¼�Ƴɹ��ص�������¼����Ƶ�ļ���ID�б�; ҵ��࿪���Զ�¼��ʱ�������ؿ��б��û���ֱ�ӵ���̨��ѯ��
        */
        virtual void stopRecord(E_RecordDataType recordDataType, Type<Vector<String>&>::iLiveValueSuccCallback suc, iLiveErrCallback err, void* data) = 0;

        /**
        @brief ��������
        @param [in] role ��ɫ
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        */
        virtual void changeRole( const char *role, iLiveSucCallback suc, iLiveErrCallback err, void* data ) = 0;
        /**
        @brief �������ճ̶�
        @param [in] grade ���ճ̶Ȳ�����gradeȡֵ��Χ��0-9֮�䣬0��ʾ���չر�
        @return ����ֵΪNO_ERRʱ��ʾ�ɹ��������ʾʧ��
        @note ���ա����׹���ֻ�Ա�����������Ч��SDK������Զ���ɼ��������ա����״���;
        */
        virtual int setSkinSmoothGrade(int grade) = 0;
        /**
        @brief �������׳̶�
        @param [in] grade ���׳̶Ȳ�����gradeȡֵ��Χ��0-9֮�䣬0��ʾ���׹ر�
        @return ����ֵΪNO_ERRʱ��ʾ�ɹ��������ʾʧ��
        @note ���ա����׹���ֻ�Ա�����������Ч��SDK������Զ���ɼ��������ա����״���;
        */
        virtual int setSkinWhitenessGrade(int grade) = 0;
        /**
        @brief ����ˮӡ
        @param [in] filePath ˮӡ�ļ�·��;֧�� BMP, GIF, JPEG, PNG, TIFF, Exif, WMF, and EMF ��ʽ;����� NULL�������ȥ��ˮӡ;
        @param [in] xOffset  ���Ͻ�x��ƫ�ƣ�TODO ȡֵ��Χ
        @param [in] yOffset  ���Ͻ�y��ƫ�ƣ�TODO ȡֵ��Χ
        @param [in] fWidthRatio ˮӡռx��ı�����TODO ȡֵ��Χ
        @return ����ֵΪNO_ERRʱ��ʾ�ɹ��������ʾʧ��
        @note �˽ӿ����õ�ˮӡ,ֻ�Ա�������\��Ļ��������Ч��SDK������Զ���ɼ���������ˮӡ;
        */
        virtual int setWaterMark(const String& filePath, float xOffset, float yOffset, float fWidthRatio) = 0;

        /**
        @brief ��ȡ��������ͷ�б�
        @param [out] cameraList ���ػ�ȡ��������ͷ�б�,��һ��(����0)ΪϵͳĬ���豸;
        @return �������,NO_ERR��ʾ�޴���;���û�п�������ͷ,����AV_ERR_DEVICE_NOT_EXIST������(�������github�ϵĴ������);
        */
        virtual int getCameraList( Vector< Pair<String/*id*/, String/*name*/> >& cameraList ) = 0;
        /**
        @brief ��ȡ������˷��б�
        @param [out] micList ���ػ�ȡ������˷��б�,��һ��(����0)ΪϵͳĬ���豸;
        @return �������,NO_ERR��ʾ�޴���;���û�п�����˷�,����AV_ERR_DEVICE_NOT_EXIST������(�������github�ϵĴ������);
        */
        virtual int getMicList( Vector< Pair<String/*id*/, String/*name*/> >& micList ) = 0;
        /**
        @brief ��ȡ���õ��������б�
        @param [out] playerList ���ػ�ȡ�����������б�,��һ��(����0)ΪϵͳĬ���豸;
        @return �������,NO_ERR��ʾ�޴���;���û�п���������,����AV_ERR_DEVICE_NOT_EXIST������(�������github�ϵĴ������);
        */
        virtual int getPlayerList( Vector< Pair<String/*id*/, String/*name*/> >& playerList ) = 0;
        /**
        @brief ��ȡ�������򿪵����������ڡ�
        @param [out] wndList ���ػ�ȡ���Ĵ����б�(����˵����ɼ�����\�ޱ��ⴰ��\��С����״̬�Ĵ���)��
        @return �������,NO_ERR��ʾ�޴���;���û�пɷ�����,����AV_ERR_DEVICE_NOT_EXIST������(�������github�ϵĴ������);
        @remark �û����Ե��ô˽ӿڻ�ȡ���Խ�����Ļ����Ĵ��ھ���б�,Ҳ�����Լ���ȡ;
        */
        virtual int getWndList( Vector< Pair<HWND/*id*/, String/*name*/> >& wndList ) = 0;
        /**
        @brief ������ͷ
        @param [in] szCameraId ͨ��getCameraList()������ȡ������ͷ�б��е�ĳ������ͷid
        @note
        1��������ͷ�ɹ�������û����ϴ���ƵȨ�ޣ�����Զ���ʼ�ϴ�����ͷ��Ƶ;<br/>
        2��������ͷ�����ʹ��Զ���ɼ��ǻ���Ĳ���;���ͬʱ�򿪣��᷵�ش���AV_ERR_EXCLUSIVE_OPERATION(�������github�ϵĴ������)
        */
        virtual void openCamera(const String& szCameraId) = 0;
        /**
        @brief �رյ�ǰ�򿪵�����ͷ
        */
        virtual void closeCamera() = 0;
        /**
        @brief ���Զ���ɼ�
        @note
        1�����Զ���ɼ��ɹ�������û����ϴ���ƵȨ�ޣ��û�ͨ��fillExternalCaptureFrame()�����ÿһ֡���潫��ͨ��sdk�ϴ�;<br/>
        2��������ͷ�����ʹ��Զ���ɼ��ǻ���Ĳ���;���ͬʱ�򿪣��᷵�ش���AV_ERR_EXCLUSIVE_OPERATION(�������github�ϵĴ������);
        */
        virtual void openExternalCapture() = 0;
        /**
        @brief �ر��Զ���ɼ�
        */
        virtual void closeExternalCapture() = 0;
        /**
        @brief �ⲿ������Ƶ���ݽӿڡ�
        @return ���������NO_ERR��ʾ�޴���;
        @note
        1��Ŀǰsdk֧�ֵ�VideoFrame��ʽֻ��COLOR_FORMAT_RGB24��COLOR_FORMAT_I420,����������Ƶ֡���Ǵ����ָ�ʽ��������ERR_NOT_SUPPORT;<br/>
        2����Ƶֻ֡������Щ����(176*144��192*144��320*240��480*360��640*368��640*480��960*540��1280*720��144*176��144*192��240*320��360*480��368*640��480*640��540*960��720*1280),���򷵻�AV_ERR_INVALID_ARGUMENT(�������github�ϵĴ������);<br/>
        3����ð��պ�̨SPEAR���õ���Ƶ֡�ʽ��������Ƶ����;<br/>
        4���������Ƶ֡�ֱ���������ڿ���̨SPEAR�������õ�ֵ����Ƶ���ᱻ�ü���SPEAR���õķֱ���(������Ԥ������͹��ڶ˻����С���᲻һ��);<br/>
           ���С�ڿ���̨���õ�ֵ�����ᰴ�մ������Ƶ֡��С���뵽���ڶ�(�����ᱻ�Ŵ󵽿���̨���õ�ֵ);<br/>
        5�������LiveVideoFrame��Ҫҵ���������������ڣ����û���Ҫע��frame.data�ֶε��ͷ�;
        */
        virtual int fillExternalCaptureFrame( const LiveVideoFrame &frame ) = 0;
        /**
        @brief ����˷硣
        @param [in] szMicId ͨ��getMicList()������ȡ����˷��б��е�ĳ����˷�id��
        @note ����˷�ɹ�������û����ϴ�����Ȩ�ޣ�����Զ���ʼ�ϴ���˷���Ƶ��
        */
        virtual void openMic(const String &szMicId) = 0;
        /**
        @brief ������˷���ǿ��
        @param [in] value ������˷���ǿ,ȡֵ��Χ[0,100].
        @return ���������NO_ERR��ʾ�޴���;
        @note
        1����������˷���ǿ������ָ��˷�����,������Ϊ0�����ǻ�����Ƶ����;
        2��ֻ�д�����˷���ܽ�������,���򷵻�ERR_WRONG_STATE;<br/>
        3�������̨SPEAR�������ô���agc(��˷��Զ�����),����ֵ̫Сʱ���ᱻ�Զ���������;
        */
        virtual int setMicVolume(int value) = 0;
        /**
        @brief ��ȡ��˷���ǿ��
        @return ������˷���ǿ,δ����˷��򷵻�0;
        */
        virtual uint32 getMicVolume() = 0;
        /**
        @brief �رյ�ǰ�򿪵���˷硣
        */
        virtual void closeMic() = 0;
        /**
        @brief ����������
        @param [in] szPlayerId ͨ��getPlayerList()������ȡ���������б��е�ĳ��������id��
        @note ���������ɹ�������û��н�����ƵȨ�ޣ�����Զ���ʼ����Զ����Ƶ��
        */
        virtual void openPlayer(const String& szPlayerId) = 0;
        /**
        @brief ����������������
        @param [in] value ������������Ŀ������,ȡֵ��Χ[0,100].
        @return ���������NO_ERR��ʾ�޴���;
        @note ֻ�д������������ܽ�������,���򷵻�ERR_WRONG_STATE;
        */
        virtual int setPlayerVolume( uint32 value ) = 0;
        /**
        @brief ��ȡ������������
        @return ��������������,δ���������򷵻�0;
        */
        virtual uint32 getPlayerVolume() = 0;
        /**
        @brief �رյ�ǰ�򿪵���������
        */
        virtual void closePlayer() = 0;
        /**
        @brief ����Ļ����(ָ������)��
        @param [in] hWnd ��Ҫ����Ĵ��ھ��(NULL��ʾȫ��)����������hWnd������Ч���ھ��\���ڲ��ɼ�\���ڴ�����С��״̬�����᷵��ERR_INVALID_PARAM;
        @param [in] fps ����֡��,ȡֵ��Χ[1,10]��ע��: �˲����������壬sdk����������������̬����fps;
        @note
        ��Ļ����Ͳ�Ƭ���ܶ���ͨ����·�����䣬������Ļ����Ͳ�Ƭ����ʹ��;
        ��·�����Լ�ռ�ã��豸�����ص��У����ش�����AV_ERR_EXCLUSIVE_OPERATION(�������github�ϵĴ������);
        ��������������Առ�ã��豸�����ص��У����ش�����AV_ERR_RESOURCE_IS_OCCUPIED(�������github�ϵĴ������);
        */
        virtual void openScreenShare( HWND hWnd, uint32& fps ) = 0;
        /**
        @brief ����Ļ����(ָ������)��
        @param [in] left/top/right/bottom ��Ҫ������Ļ�������������Ͻ�����(left, top)�����½�����(right, bottom)������������Ļ�����Ͻ�����Ϊԭ��ġ�
        @param [in] fps ����֡�ʣ�ȡֵ��Χ[1,10];ע��: �˲�����ʱ�����壬sdk����������������̬����fps;
        @note
        ��Ļ����Ͳ�Ƭ���ܶ���ͨ����·�����䣬������Ļ����Ͳ�Ƭ����ʹ��;
        ��·�����Լ�ռ�ã��豸�����ص��У����ش�����AV_ERR_EXCLUSIVE_OPERATION(�������github�ϵĴ������);
        ��������������Առ�ã��豸�����ص��У����ش�����AV_ERR_RESOURCE_IS_OCCUPIED(�������github�ϵĴ������);
        */
        virtual void openScreenShare( int32& left, int32& top, int32& right, int32& bottom, uint32& fps ) = 0;
        /**
        @brief ��Ļ���������,��̬�޸���Ļ���������
        @param [in] left/top/right/bottom ��Ҫ������Ļ�������������Ͻ�����(left, top)�����½�����(right, bottom)����������Ļ�����Ͻ�Ϊԭ�㡣
        @return ���������NO_ERR��ʾ�޴���
        @remark ����Ĳ������ܻᾭ��sdk�ڲ�ϸ΢�ĵ�������ͨ�����÷�ʽ���ظ������ߣ�ʵ�ʵķ��������Դ��ص�ֵΪ׼;
        @note �˽ӿ�ֻ���ڴ���ָ���������Ļ����ʱ����Ч,����״̬�½��᷵��ERR_WRONG_STATE����;
        */
        virtual int changeScreenShareSize( int32& left, int32& top, int32& right, int32& bottom ) = 0;
        /**
        @brief �ر���Ļ����
        @return ���������NO_ERR��ʾ�޴���
        @remark ָ�����ڵ���Ļ�����ָ���������Ļ�������ô˽ӿ����ر�.
        */
        virtual void closeScreenShare() = 0;

        /**
        @brief ��ϵͳ�����ɼ���
        @details �ɼ�ϵͳ������
        @param [in] szPlayerPath ��������ַ;����û��˲�����ջ����ʾ�ɼ�ϵͳ�е���������;�������exe����(��:�ṷ��QQ����)����·��,���������˳��򣬲�ֻ�ɼ��˳��������;
        @remark �ļ����ź�ϵͳ�����ɼ���Ӧ��ͬʱ�򿪣������ļ����ŵ������ֻᱻϵͳ�����ɼ�����������������;
        */
        virtual void openSystemVoiceInput(const String& szPlayerPath = "") = 0;
        /**
        @brief �ر�ϵͳ�����ɼ���
        */
        virtual void closeSystemVoiceInput() = 0;
        /**
        @brief ����ϵͳ�����ɼ���������
        @param [in] value ����Ŀ������,ȡֵ��Χ[0,100].
        @return ���������NO_ERR��ʾ�޴���;
        @note ֻ�д���ϵͳ�����ɼ����ܽ�������,���򷵻�ERR_WRONG_STATE;
        @remark ����ǲɼ�����ϵͳ��������������ʾ���������������ָ������Ĳ��ţ�������Ϊ�������,��10Ϊ1����100Ϊ10����1Ϊԭ����1/10;
        */
        virtual int setSystemVoiceInputVolume( uint32 value ) = 0;
        /**
        @brief ��ȡϵͳ�����ɼ�������
        @return ����ϵͳ�����ɼ�����,δ���򷵻�0;
        @remark ����ǲɼ�����ϵͳ��������������ʾ���������������ָ������Ĳ��ţ�������Ϊ�������,��10Ϊ1����100Ϊ10����1Ϊԭ����1/10;
        */
        virtual uint32 getSystemVoiceInputVolume() = 0;

        /**
        @brief ���ļ����š�
        @details ��ʼ���ű�����Ƶ\��Ƶ�ļ��������ļ�ǰ������ȵ���isValidMediaFile()����ļ��Ŀ����ԡ�
        @param [in] szMediaFile �ļ�·��(�����Ǳ����ļ�·����Ҳ������һ�������ļ���url);
        @remark
        1��֧�ֵ��ļ�����:<br/>
        *.aac,*.ac3,*.amr,*.ape,*.mp3,*.flac,*.midi,*.wav,*.wma,*.ogg,*.amv,
        *.mkv,*.mod,*.mts,*.ogm,*.f4v,*.flv,*.hlv,*.asf,*.avi,*.wm,*.wmp,*.wmv,
        *.ram,*.rm,*.rmvb,*.rpm,*.rt,*.smi,*.dat,*.m1v,*.m2p,*.m2t,*.m2ts,*.m2v,
        *.mp2v, *.tp,*.tpr,*.ts,*.m4b,*.m4p,*.m4v,*.mp4,*.mpeg4,*.3g2,*.3gp,*.3gp2,
        *.3gpp,*.mov,*.pva,*.dat,*.m1v,*.m2p,*.m2t,*.m2ts,*.m2v,*.mp2v,*.pss,*.pva,
        *.ifo,*.vob,*.divx,*.evo,*.ivm,*.mkv,*.mod,*.mts,*.ogm,*.scm,*.tod,*.vp6,*.webm,*.xlmv��<br/>
        2��Ŀǰsdk��Դ���640*480����Ƶ�ü���640*480;<br/>
        3���ļ����ź�ϵͳ�����ɼ���Ӧ��ͬʱ�򿪣������ļ����ŵ������ֻᱻϵͳ�����ɼ�����������������;
        @note
        ��Ļ����Ͳ�Ƭ���ܶ���ͨ����·�����䣬������Ļ����Ͳ�Ƭ����ʹ��;
        ��·�����Լ�ռ�ã��豸�����ص��У����ش�����AV_ERR_EXCLUSIVE_OPERATION(�������github�ϵĴ������);
        ��������������Առ�ã��豸�����ص��У����ش�����AV_ERR_RESOURCE_IS_OCCUPIED(�������github�ϵĴ������);
        */
        virtual void openPlayMediaFile( const String& szMediaFile ) = 0;
        /**
        @brief �ر��ļ����š�
        */
        virtual void closePlayMediaFile() = 0;
        /**
        @brief ��ͷ�����ļ���
        @return ���������NO_ERR��ʾ�޴���
        @note ֻ���ڴ��ڲ���״̬��(E_PlayMediaFilePlaying)���˽ӿڲ���Ч�����򷵻�ERR_WRONG_STATE;
        */
        virtual int restartMediaFile() = 0;
        /**
        @brief ��ͣ�����ļ���
        @return ���������NO_ERR��ʾ�޴���
        */
        virtual int pausePlayMediaFile() = 0;
        /**
        @brief �ָ������ļ���
        @return ���������NO_ERR��ʾ�޴���
        */
        virtual int resumePlayMediaFile() = 0;
        /**
        @brief ���ò����ļ����ȡ�
        @param [in] n64Pos ����λ��(��λ: ��)
        @return ���������NO_ERR��ʾ�޴���
        */
        virtual int setPlayMediaFilePos(const int64& n64Pos) = 0;
        /**
        @brief ��ȡ�����ļ����ȡ�
        @param [out] n64Pos ��ǰ����λ��(��λ: ��)
        @param [out] n64MaxPos ��ǰ�������ļ����ܳ���(��λ: ��)
        @return ���������NO_ERR��ʾ�޴���
        */
        virtual int getPlayMediaFilePos(int64& n64Pos, int64& n64MaxPos) = 0;
        /**
        @brief �ж��ļ��Ƿ�����ڲ��š�
        @param [in] szMediaFile Ҫ������Ƶ�ļ�.
        @return �Ƿ����;����ļ������ڣ�Ҳ�᷵��false;
        */
        virtual bool isValidMediaFile(const String& szMediaFile) = 0;

        /**
        @brief ��������ƵSDK�����ˮӡ.
        @param [in] waterMarkType ˮӡ���ͣ��ο�E_WaterMarkType˵��;
        @param [in] argbData ˮӡ��argb��ʽ����;
        @param [in] width ˮӡ���;
        @param [in] height ˮӡ�߶�;
        @return ���������NO_ERR��ʾ�޴���
        @remark
        1��ֻ���ڵ�¼�ɹ�������·��Ƶ(����ͷ\�Զ���ɼ�)֮ǰ���ô˽ӿڡ�<br/>
        2��Ϊ�����л��涼��ˮӡЧ�����û�Spear�����õĸ����ֱ��ʶ�Ӧ��������Ӧˮӡ;<br/>
        3��Ϊ�����ܿ��ǣ�������ˮӡ�������Լ���Ԥ�����治����ʾˮӡ�����ڶ˲Ż���ʾˮӡ��<br/>
        4��ˮӡ��С���ƹ���Ϊ: ˮӡ��Ȳ����ڻ����ȵ�1/4,�߶Ȳ��ܴ���1/6,��ˮӡ��߶�����Ϊ2�ı���;<br/>
        5��sdk��ʱֻ֧�ֶ���·��Ƶ����ˮӡ,��֧�ֶԸ�·����ˮӡ;
        @todo �˽ӿ����ƽ϶࣬���Ƽ��û�ʹ�ã�����ʹ��setWaterMark�ӿ�;
        */
        Deprecated
        virtual int addWaterMark(E_WaterMarkType waterMarkType, uint8* argbData, uint32 width, uint32 height) = 0;

        /**
        @brief ����sdk����־·��
        @return ���������true�ɹ���falseʧ��
        @remark Ϊ������ô˽ӿ�ǰ����־��ӡ����ͬĿ¼��,����ֻ����sdk�κνӿڵ���֮ǰ���ô˽ӿڣ����򷵻�false;
        */
        virtual bool setLogPath(const String& szLogPath) = 0;

        /**
        @brief ��ʼ����
        @details ��ʼ���ٺ�sdk��Լ����ӿڻ����в��٣��������ٽ���ص���ҵ���
        @param [in] calltype ͨ������
        @param [in] purpose ����Ŀ��
        @param [in] suc �ɹ���ֵ�ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��)
        @remark ��Ҫ�ڵ�¼�󣬲��ܵ��ò��ٽӿ�;
        */
        virtual void startSpeedTest( E_SPTCallType calltype, E_SPTPurpose purpose, Type<iLiveSpeedTestResultReport&>::iLiveValueSuccCallback suc, iLiveErrCallback err, void* data ) = 0;
        /**
        @brief ȡ������;
        @details ��ʼ���ٺ󣬿�����Ҫȡ���������񣬴�ʱ���Ե��ô˽ӿ�
        @param [in] suc �ɹ��ص�
        @param [in] err ʧ�ܻص�
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        */
        virtual void cancelSpeedTest(iLiveSucCallback suc, iLiveErrCallback err, void* data) = 0;

        /**
        @brief ��ʼ������Ƶ¼��;
        @details ��ʼ������Ƶ¼�ƺ�����ͷ����Ļ������Ƶ���ݣ���¼�Ƴ�mp4�ļ���ŵ�����;
        @param [in] szDir ¼���ļ���ŵ�·��,��"D:/";��ȷ������·������Ч�ģ������ص�OnError��ֹͣ¼��;
        @param [in] delegate ¼�ƴ���¼�ƹ����еĻص�����ͨ���˻ص�֪ͨ��ҵ���;
        @remark �ڵ�¼�󣬼��ɵ��ô˽ӿڣ����뷿��󣬴�����ͷ������Ļ����Ļ��涼���Զ�¼�Ƴɱ����ļ�;<br/>
        �Ƽ��ڽ�����ɹ��ص��п�ʼ¼��,���˳�����ص��н���¼�ƣ�ע�⣬����˵���˳��������sdkǿ���˳�����ص�;
        */
        virtual void startLocalRecord(const String& szDir, iLiveLocalRecordDelegate* delegate) = 0;
        /**
        @brief ֹͣ������Ƶ¼��;
        */
        virtual void stopLocalRecord() = 0;

        /**
        @brief ע��ָ�����͵���Ƶ���ݻص�
        @details ע��ָ�����͵���Ƶ���ݻص�����Ƶ���ݽ����Ƭ�ص���ҵ���;
        @param [in] srcType ��Ƶ��������
        @param [in] callback �ص�����
        @param [in] data �û��Զ������ݵ�ָ�룬�ص�������ԭ�ⲻ���ش���(ͨ��Ϊ�������ָ��);
        @return ���������NO_ERR��ʾ�ɹ�;
        @remark �����ڷ����ڲ���ע����Ƶ���ݻص�,���򷵻�ERR_WRONG_STATE������;
        */
        virtual int registAudioDataCallback(E_AudioDataSourceType srcType, iLiveAudioDataCallback callback, void* data) = 0;
        /**
        @brief ��ע������������͵Ļص�����
        @param [in] srcType ��Ƶ��������
        @return ���������NO_ERR��ʾ�ɹ�;
        @remark �����ڷ����ڽ��д˲���,���򷵻�ERR_WRONG_STATE������;
        */
        virtual int unregistAudioDataCallback(E_AudioDataSourceType srcType) = 0;
        /**
        @brief ��ע�������������͵Ļص�����
        @return ���������NO_ERR��ʾ�ɹ�;
        @remark �����ڷ����ڽ��д˲���,���򷵻�ERR_WRONG_STATE������;
        */
        virtual int unregistAllAudioDataCallback() = 0;
        /**
        @brief ����ĳ���͵���Ƶ��ʽ������
        @param [in] srcType ��Ƶ�������͡�
        @param [in] desc ��Ƶ���ݵĸ�ʽ��
        @return ���������NO_ERR��ʾ�ɹ�;
        @remark �����ڷ����ڽ��д˲���,���򷵻�ERR_WRONG_STATE������;
        */
        virtual int setAudioDataFormat(E_AudioDataSourceType srcType, const iLiveAudioFrameDesc& desc) = 0;
        /**
        @brief ��ȡĳ���͵���Ƶ��ʽ������
        @param [in] srcType ��Ƶ�������͡�
        @param [out] desc ��Ƶ���ݵĸ�ʽ��
        @return ���������NO_ERR��ʾ�ɹ�;
        @remark �����ڷ����ڽ��д˲���,���򷵻�ERR_WRONG_STATE������;
        */
        virtual int getAudioDataFormat(E_AudioDataSourceType srcType, iLiveAudioFrameDesc& desc) = 0;

        /**
        @brief �緿����
        @details �����������������˫��������������˶��ܻ�ȡ���������˵���Ƶ����Ƶ���ݡ�
        @param [in] roomId ����ķ����
        @param [in] userId ������û�id
        @param [in] authBuffer �緿�������Ȩ���ܴ�
        @param [in] cb ������ɵĻص�����
        @param [in] data �Զ���ָ��
        @remark �����������������������, ÿ������ֻ������һ���˲���緿������
        */
        virtual void linkRoom(uint32 roomId, const String& userId, const String& authBuffer, iLiveCompleteCallback cb, void* data) = 0;
        /**
        @brief ȡ���緿����
        @details ȡ�����п緿������
        @param [in] cb ������ɵĻص�����
        @param [in] data �Զ���ָ��
        */
        virtual void unlinkRoom(iLiveCompleteCallback cb, void* data) = 0;

        /**
        @brief ���÷�������Ƶ���ݰ�������
        @details ������Ƶ�������󣬽�ֻ���հ������б��г�Ա����Ƶ����;
        @param [in] identifiers ϣ����������Ƶ���ݵĳ�Ա�б�;
        @return ���������NO_ERR��ʾ�ɹ�;����ֵ��ʾʧ�ܣ���������Ϊ���䲻����,�����Ա���ڷ����ڻ���ת��tinyidʧ�ܵ�(������������������г�Աidת���ɹ�����Ȼ�ᱻ����������Ұ�������Ч)��
        @remark ÿ���������6����Աid������6�������vector���6����������������������ʱ����identifiersΪ�գ���Ĭ�϶�����������Ƶ���ݣ�ÿ�ε��ã���������������Ϊ�µĳ�Ա�б��������ۼӡ���Ҫ��������յ���Ƶ���ݲ���Ҫ���ã���������Ĭ�Ͻ��շ�����������Ƶ����;
        */
        virtual int requestAudioList(const Vector<String>& identifiers) = 0;
        /**
        @brief �ر���Ƶ���ݰ�������
        @details �ر���Ƶ���ݰ������󣬽��ָ����շ��������г�Ա����Ƶ����;
        @return ���������NO_ERR��ʾ�ɹ�;
        */
        virtual int cancelAudioList() = 0;

        /**
        @brief ��ȡ��ǰ����ͷ״̬
        @return true:�� false���ر�
        */
        virtual bool getCurCameraState() = 0;
        /**
        @brief ��ȡ�Զ���ɼ�״̬��
        @return true:�� false���ر�
        */
        virtual bool getExternalCaptureState() = 0;
        /**
        @brief ��ȡ��ǰ��˷�״̬
        @return true:�� false���ر�
        */
        virtual bool getCurMicState() = 0;
        /**
        @brief ��ȡ��ǰ������״̬
        @return true:�� false���ر�
        */
        virtual bool getCurPlayerState() = 0;
        /**
        @brief ��ȡ��ǰ��Ļ����״̬
        @return ��ǰ��Ļ����״̬
        */
        virtual E_ScreenShareState getScreenShareState() = 0;
        /**
        @brief ��ȡ��ǰ�ļ�����״̬��
        @return ��ǰ�ļ�����״̬.
        */
        virtual E_PlayMediaFileState getPlayMediaFileState() = 0;
        /**
        @brief ��ȡ��ǰϵͳ�����ɼ�״̬
        @return true:�� false���ر�
        */
        virtual bool getCurSystemVoiceInputState() = 0;
    };

    /**
    @brief ��ȡiLive��ָ��
    @return iLive��ָ��
    */
    extern "C" iLiveAPI iLive* GetILive();

    /**
    @brief ��Ƶ��ʾview��
    @details ���ڱ�ʾһ·��Ƶ����ʾ�������ʾ��ʽ,���һ����APP�Զ�����Ƶͼ��ĽǶ���ת
    */
    struct iLiveView
    {
        iLiveView() : mode(VIEW_MODE_NONE), exclusive(false), x(0), y(0), width(0), height(0), zorder(5) {}

        E_ViewMode  mode;      ///< ��Ⱦ����ģʽ��
        bool        exclusive; ///< �Ƿ��ռ�������ڣ�Ϊtrueʱ, (x, y, width, height) �ȼ��� (0��0�����ڿ�ȣ����ڸ߶�)��
        uint32      x;         ///< ��ʾ�������Ͻ�����x��
        uint32      y;         ///< ��ʾ�������Ͻ�����y��
        uint32      width;     ///< ��ʾ�������ؿ�
        uint32      height;    ///< ��ʾ�������ظߡ�
        uint32      zorder;    ///< zorder, ���ڱ�ʾ��ʾ����㼶��ϵ��
    };

    /**
    @brief ��Ƶ��Ⱦ�ķ�װ��
    @details
        - �ṩ2����Ⱦʵ�֣�D3D��GDI
        - D3D��֧����Ⱦi420��ʽ,��ռ��CPU��Դ��D3Dʹ��������PC֧��DirectXӲ�����١����󲿷�֧�֣�����ģʽ��(���簲ȫģʽ)��֧�֡�
        - GDI��֧����ȾRGB24��ʽ�������Ե�CPU������GDI��ʹ��������
        - SDK�ڲ�Ĭ������ʹ��D3D��Ⱦ�������֧�֣��Զ�ѡ��GDI;
    @remark ��Ⱦģ����̲߳���ȫ�����з���Ӧ�������̵߳��á�
    */
    struct iLiveRootView
    {
        /**
        @brief ��ʼ��
        @details ͨ���û�����Ĵ��ھ�������г�ʼ��
        @param [in] hwnd Ҫ��Ⱦ����Ĵ��ھ��
        @return �������;true�ɹ���falseʧ��;
        */
        virtual bool init(HWND hwnd) = 0;
        /**
        @brief �ͷ�
        @details ������iLiveRootViewǰ����Ҫ���ͷ�;
        */
        virtual void uninit() = 0;
        /**
        @brief ����
        */
        virtual void destroy() = 0;
        /**
        @brief ��ȡ��ǰ��Ⱦ����(D3D��GDI)
        @return ��Ⱦ����
        */
        virtual E_RootViewType getRootViewType() = 0;
        /**
        @brief ������Ⱦ���ڱ���ɫ��
        @param [in] argb ������ɫ
        */
        virtual void setBackgroundColor(uint32 argb) = 0;
        /**
        @brief ��Ⱦ��Ƶ֡
        @details
            - ֱ����SDK��Ƶ�ص��е���doRender�����ɽ�����Ƶ��Ⱦ��
            - ����ݽǶ��Զ�����Ƶͼ�����ת��
        @param [in] frame Ҫ��Ⱦ����Ƶ֡
        @remark û��setView()������Ⱦ��
        */
        virtual void doRender(const LiveVideoFrame* frame) = 0;
        /**
        @brief ��ȡ���õ�iLiveView������
        @return �������õ�iLiveView�ĸ�����
        @remark ���ڱ�����ӹ���iLiveView��
        */
        virtual uint32 getViewCount() = 0;
        /**
        @brief ��ȡָ��������iLiveView
        @param [in] index Ҫ��ȡ��iLiveView����
        @param [out] identifier ��ȡ����iLiveView��Ӧ���û�id
        @param [out] type ��ȡ����iLiveView��Ӧ����Ƶ��������
        @param [out] view ��ȡ����iLiveView
        @return ���ػ�ȡ�Ƿ�ɹ�������±�Խ�磬�򷵻�false��
        */
        virtual bool getView(uint32 index, String& identifier, E_VideoSrc& type, iLiveView& view) = 0;
        /**
        @brief ���iLiveView��
        @param [in] identifier Ҫ���iLiveView��Ӧ���û�id��
        @param [in] type ��ӵ�iLiveView��Ӧ����Ƶ�������͡�
        @param [in] view Ҫ��ӵ�iLiveView��
        @param [in] paint �Ƿ�����ˢ�»��ƴ��ڡ�
        @remark
            - ���֮ǰ��ӹ�����Ϊ����iLiveView״̬��
            - ����paint��Ƶ�����ûᵼ�»��ƴ�����˸�������ڱ�Ҫ��ʱ��ˢ�¡�
        */
        virtual void setView(const String& identifier, E_VideoSrc type, const iLiveView& view, bool paint = true) = 0;
        /**
        @brief �Ƴ���iLiveView��
        @param [in] identifier �Ƴ�iLiveView��Ӧ���û�id��
        @param [in] type �Ƴ�iLiveView��Ӧ����Ƶ�������͡�
        @param [in] paint �Ƿ�����ˢ�»��ƴ��ڡ�
        */
        virtual void removeView(const String& identifier, E_VideoSrc type, bool paint = true) = 0;
        /**
        @brief �Ƴ�����iLiveView��
        @param [in] paint �Ƿ�����ˢ�»��ƴ��ڡ�
        */
        virtual void removeAllView(bool paint = true) = 0;
        /**
        @brief �Ƿ������iLiveView��
        @param [in] identifier ��ƵԴ�û�id
        @param [in] type ��Ƶ��������
        @return �Ƿ������iLiveView;
        */
        virtual bool hasView(const String& identifier, E_VideoSrc type) = 0;
    };

    /**
    @brief ����iLiveRootView����
    @return iLiveRootView����ָ��
    */
    extern "C" iLiveAPI iLiveRootView* iLiveCreateRootView();
}
#endif //iLive_h_