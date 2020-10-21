#ifndef CHANEL_WANGYI_H
#define CHANEL_WANGYI_H

#include <QMutex>
#include <QDebug>
#include "../AudioVideoBase.h"
#include "nim_cpp_api.h"
#include "nim_device_def.h"
#include "nim_utils.h"
#include "../AudioVideoUtils.h"

using namespace nim;

namespace YMAVEncryption
{
    static inline QString md5(const QString& data)
    {
        QCryptographicHash hash(QCryptographicHash::Md5);
        hash.addData(data.toUtf8());
        return QString(hash.result().toHex());
    }

    static inline QString signSort(const QMap<QString, QString> &dataMap)
    {
        QString sign = "";
        for(auto it = dataMap.begin(); it != dataMap.end(); ++it)
        {
            sign.append(it.key()).append("=").append(it.value());
            if(it != dataMap.end() - 1)
            {
                sign.append("&");
            }
        }
        return sign;
    }

    static inline QString signMapSort(const QVariantMap &dataMap)
    {
        QString sign = "";
        for(auto it = dataMap.begin(); it != dataMap.end(); ++it)
        {
            sign.append(it.key()).append("=").append(QString::fromUtf8( it.value().toByteArray()));
            if(it != dataMap.end() - 1)
            {
                sign.append("&");
            }
        }
        return sign;
    }
}

class chanel_wangyi : public QObject
{
    Q_OBJECT

public:
    explicit chanel_wangyi(QWidget *parent = 0);
    ~chanel_wangyi();

public:
    static  chanel_wangyi *getInstance()
    {
        static chanel_wangyi *m_chanel_wangyi = new chanel_wangyi();
        return m_chanel_wangyi;
    }

public:
    void leaveRoom();
    void InitUiKit();
    void UnloadSdk();

    static void OnCreateChannelCallback(int code, __int64 channel_id, const std::string& json_extension);
    static void do_saveRoomInfo(); //保存房间的信息, 用于数据统计

    /**
    * 退出登录结果回调
    * @param[in] res_code 错误码
    * @return void  无返回值
    */
    static void OnLogoutCallback(nim::NIMResCode res_code);

    /**
    * 被其他端踢下线的回调，要在程序开始运行时就注册好
    * @param[in] res 被踢的信息
    * @return void  无返回值
    */
    static void OnKickoutCallback(const nim::KickoutRes& res);

    /**
    * 掉线的回调，要在程序开始运行时就注册好。
    * @return void  无返回值
    */
    static void OnDisconnectCallback();

    /**
    * 自动重连的回调，要在程序开始运行时就注册好。
    * @param[in] login_res 重连结果
    * @return void  无返回值
    */
    static void OnReLoginCallback(const nim::LoginRes& login_res);

    /**
    * 移动端登录时的回调，要在程序开始运行时就注册好。
    * @param[in] res 多端登录回调信息
    * @return void  无返回值
    */
    static void OnMultispotLoginCallback(const nim::MultiSpotLoginRes& res);

    /**
    * 移动端登录发生变化时的回调，要在程序开始运行时就注册好。
    * @param[in] online 是否在线
    * @param[in] clients 其他客户端信息
    * @return void  无返回值
    */
    static void OnMultispotChange(bool online, const std::list<nim::OtherClientPres>& clients);

    /**
    * 把移动端踢下线的结果回调，要在程序开始运行时就注册好。
    * @param[in] res 踢人结果信息
    * @return void  无返回值
    */
    static void OnKickoutOtherClientCallback(const nim::KickOtherRes& res);

    void EndChat();

    /**
    * 加入一个多人房间
    * @param[in] mode 音视频通话类型
    * @param[in] room_name 房间名
    * @param[in] session_id 会话id
    * @param[in] rtmp_url 主播推流地址
    * @param[in] live_link 是否是观众连麦
    * @param[in] cb 操作结果回调函数
    * @return bool true 调用成功，false 调用失败可能有正在进行的通话
    */
    static bool JoinRoom(nim::NIMVideoChatMode mode, const std::string& room_name, const std::string& rtmp_url, bool live_link, const std::string& session_id);

    static void OnMultiportPushConfigChange(int rescode, bool switch_on);
    static void CallbackLogin(const nim::LoginRes& login_res, const void* user_data);
    static void InitChatroomCallback();

    static void VideoCaptureData(unsigned __int64 time, const char* data, unsigned int size, unsigned int width, unsigned int height, const char *json, const void *user_data);
    static void VideoRecData(unsigned __int64 time, const char* data, unsigned int size, unsigned int width, unsigned int height, const char* json, const void *user_data);

public:
    static bool bHasFinished_JoinChannel; // 添加一个状态, 记录当前C通道, 是否完成加入通道了, 目的是为了拿到正确的channel id

private:
    static bool bstop_video_status; // 是否看对方视频
    static bool bHasJoinRoom; // 记录当前是否join room了, 用来控制是否需要EndChat, 如果没有join room, 就EndChat, 程序会发生崩溃
    static PicRegion capture_video_pic_;
    static std::map<std::string, PicRegion*> recv_video_pic_list_;

    static bool doCreateRoom();
    static void AddVideoFrame(bool capture, int64_t time, const char* data, int size, int width, int height, const std::string& json, FrameType frame_type);
    static bool GetVideoFrame(std::string account, int64_t& time, char* out_data, int& width, int& height, bool mirror = false, bool argb_or_yuv = true);
    static void OnJoinChannelCallback(int code, __int64 channel_id, const std::string& json_extension);

public:
    static std::string m_account;
    static std::string m_password;
    static std::string m_push_url; // 录播推流地址
    static __int64     m_room_id;

    static void EnumDevCb(bool ret, nim::NIMDeviceType type, const char* json, const void*);
    static void Start_Device_Audio();
    static void  Stop_Device_Audio();

    static void Start_Device_Video();
    static void  Stop_Device_Video();

public:
    void slotInit(ROLE_TYPE role, QString strSpeaker, QString strMicPhone, QString strCamera, QString token, QString strDllFile, QString strAppName);
    void slotLogin();
    void slotCreateRoom();
    static void slotJoinRoom();
    void slotExitRoom();

    void slotStart_Device_Audio();
    void slotStop_Device_Audio();
    void slotStart_Device_Video();
    void slotStop_Device_Video();

signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);
    void sigAudioName(QString audioName);
    void sigCreateClassroom();
};
#endif // CHANEL_WANGYI_H
