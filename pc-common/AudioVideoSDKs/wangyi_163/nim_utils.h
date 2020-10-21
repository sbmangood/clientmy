#ifndef NIM_UTILS_H
#define NIM_UTILS_H


enum FrameType
{
    Ft_I420 = 0,
    Ft_ARGB,
    Ft_ARGB_r,
};

// 自定义消息的类型
enum CustomMsgType
{
    CustomMsgType_Jsb = 1,  // 石头剪子布
    CustomMsgType_SnapChat, // 阅后即焚
    CustomMsgType_Sticker,  // 贴图
    CustomMsgType_Rts,      // 白板的发起结束消息
    CustomMsgType_Meeting = 10,     // 多人会议控制协议
};

enum MeetingOptType//command
{
    Mot_AllStatus           = 1,    // 主持人通知有权限的成员列表                    《1》《2》  {"type":10,"data":{"room_id":"123","command":1,"uids":["a","b"]}}
    Mot_GetStatus           = 2,    // 成员向所有人请求有权限的成员                  《1》       {"type":10,"data":{"room_id":"123","command":2}}
    Mot_StatusResponse      = 3,    // 有权限的成员向请求者返回自己有权限的通知      《2》       {"type":10,"data":{"room_id":"123","command":3,"uids":["myid"]}}
    Mot_SpeekRequest        = 10,   // 向主持人请求连麦权限                          《2》       {"type":10,"data":{"room_id":"123","command":10}}
    Mot_SpeekAccept         = 11,   // 主持人同意连麦请求,主持人同时发送群发1消息    《2》       {"type":10,"data":{"room_id":"123","command":11}}
    Mot_SpeekReject         = 12,   // 主持人拒绝或关闭连麦,主持人同时发送群发1消息  《2》       {"type":10,"data":{"room_id":"123","command":12}}
    Mot_SpeekRequestCancel  = 13,   // 取消向主持人请求连麦权限                      《2》       {"type":10,"data":{"room_id":"123","command":13}}
};

enum DeviceSessionType
{
    kDeviceSessionTypeNone      = 0x0,
    kDeviceSessionTypeChat      = 0x1,
    kDeviceSessionTypeSetting   = 0x2,
    kDeviceSessionTypeRts       = 0x4,
    kDeviceSessionTypeChatRoom  = 0x8,
};

struct PicRegion
{
    PicRegion()
    {
        pdata_ = NULL;
        //subtype_ = nim::kNIMVideoSubTypeARGB;
        size_max_ = 0;
        size_ = 0;
    }

    ~PicRegion()
    {
        Clear();
    }

    /**
    * 清理保存的颜色数据
    * @return void  无返回值
    */
    void Clear()
    {
        if (pdata_)
        {
            delete[] pdata_;
            pdata_ = NULL;
        }
        size_max_ = 0;
        size_ = 0;
    }

    /**
    * 重置颜色数据
    * @param[in] time 时间戳
    * @param[in] data 帧数据
    * @param[in] size 帧数据大小
    * @param[in] width 视频宽度
    * @param[in] height 视频高度
    * @return int 返回传入的size值
    */
    int ResetData(uint64_t time, const char* data, int size, unsigned int width, unsigned int height/*, nim::NIMVideoSubType subtype*/)
    {
        if (size > size_max_)
        {
            if (pdata_)
            {
                delete[] pdata_;
                pdata_ = NULL;
            }
            pdata_ = new char[size];
            size_max_ = size;
        }
        width_ = width;
        height_ = height;
        timestamp_ = time;
        //subtype_ = subtype;
        size_ = size;
        memcpy(pdata_, data, size);
        return size;
    }

    //nim::NIMVideoSubType subtype_;
    char*       pdata_;         //颜色数据首地址
    int         size_max_;
    int         size_;
    long        width_;         //像素宽度
    long        height_;        //像素高度
    uint64_t    timestamp_;     //时间戳（毫秒）
};

#endif // NIM_UTILS_H
