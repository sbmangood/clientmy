#include <QTime>
#include <QDateTime>
#include <QMessageBox>
#include "channel_wangyi.h"
#include <sys/timeb.h>
#include "nim_cpp_client.h"
#include "libyuv.h"
#include "Processing_C_Channel.h"


#if 0

API 文档 :
    http ://dev.netease.im/docs/interface/%E5%8D%B3%E6%97%B6%E9%80%9A%E8%AE%AFWindows%E7%AB%AF/NIMSDKAPI_CPP/html/index.html
    http://dev.netease.im/docs/product/%E9%80%9A%E7%94%A8/Demo%E6%BA%90%E7%A0%81%E5%AF%BC%E8%AF%BB/PC%E9%80%9A%E7%94%A8/C++%E5%B0%81%E8%A3%85%E5%B1%82

    网易C通道, 执行流程:
    1. 初始化
    2. log in 登录
    3. 建房间 create room(学生端, 没有这一步, 直接步骤4)
  4. 加入房间join room (并设置为: 互动者模式)  nim::VChat::SetViewerMode(false);
5. start device 本地麦克风 + 摄像头

切出C通道的时候, 需要的步骤:
    1. nim::VChat::EndDevice 麦克风 + 摄像头
       2. nim::VChat::End(json_value);
退出视频聊天

再切入C通道的时候
1. 建房间 create room(学生端, 没有这一步, 直接步骤2)
2. 加入房间(并设置为: 互动者模式)  nim::VChat::SetViewerMode(false);
3. start device 本地麦克风 + 摄像头

说明:
    1. audioName, 是上传给服务器的, 录播的时候, 需要使用到
       audioName 以下面的格式, 命名
       "audioName": "0-6272475694203263.aac;;0-6272475694203263.mp4"
       2. 其中: 6272475694203263  为:
       channel id, 可以从回调函数:
       chanel_wangyi::OnJoinChannelCallback 的参数获得
       切换通道的时候, channel id需要发生变更, 因为服务器那端, 需要生成新的aac, mp4文件
       channel id 只有在房间里面, 所有的人, nim::VChat::End(json_value);
以后, 老师再create room, join room的时候, 会发生变化
channel id 只需要老师端, 考虑就可以了

#endif

PicRegion       chanel_wangyi::capture_video_pic_;
std::map<std::string, PicRegion*> chanel_wangyi::recv_video_pic_list_;

std::string     chanel_wangyi::m_account;
std::string     chanel_wangyi::m_password;
std::string     chanel_wangyi::m_push_url;
__int64         chanel_wangyi::m_room_id;

bool chanel_wangyi::bHasFinished_JoinChannel = false;
bool chanel_wangyi::bstop_video_status = false;
bool chanel_wangyi::bHasJoinRoom = false;

static bool g_bOnlyOnce = false;

//记录摄像头的设备信息
static QString g_strCamera = "";

//记录麦克风的设备信息
static QString g_strMicPhone = "";

//记录扬声器的设备信息
static QString g_strSpeaker = "";

static ROLE_TYPE g_role;

// 记录token号
static QString g_token = "";

static QString g_strDllFile = "";

static QString g_strAppName = "";

#define DEMO_GLOBAL_APP_KEY         "cdb20dfadf3f40c5e8e6ab2ea22a6218"

void ARGBToYUV420(char* src, char* dst, int width, int height)
{
    int byte_width = width * 4;
    width -= width % 2;
    height -= height % 2;
    int wxh = width * height;
    uint8_t* des_y = (uint8_t*)dst;
    uint8_t* des_u = des_y + wxh;
    uint8_t* des_v = des_u + wxh / 4;
    libyuv::ARGBToI420((const uint8_t*)src, byte_width,
                       des_y, width,
                       des_u, width / 2,
                       des_v, width / 2,
                       width, height);
}

void OnOptCallback(bool ret, int code, const std::string& json_extension)
{
    qDebug() << ("chanel_wangyi OnOptCallback") << ret << code;
}

static void StartDeviceCb(nim::NIMDeviceType type, bool ret, const char* json, const void*)
{
    qDebug() << ("chanel_wangyi StartDeviceCb") << type << ret;
}

// 设备状态改变的回调
void OnDeviceStatus(nim::NIMDeviceType type, UINT status, std::string path)
{
    qDebug() << ("chanel_wangyi OnDeviceStatus");
}

void OnDeviceStatusCb(nim::NIMDeviceType type, UINT status, const std::string& path)
{
    OnDeviceStatus(type, status, path);
}

// "拔除设备"的时候的回调函数
void DeviceStatusCb(nim::NIMDeviceType type, UINT status, const char* path, const char *json, const void *)
{
    qDebug() << ("chanel_wangyi DeviceStatusCb") << type << status << path << json;
    if(type == nim::kNIMDeviceTypeAudioIn)
    {
        // 使用系统默认的设备
        nim::VChat::StartDevice(nim::kNIMDeviceTypeAudioIn, "", 50, 0, 0, StartDeviceCb);
    }
    else if(type == nim::kNIMDeviceTypeAudioOutChat)
    {
        // 使用系统默认的设备
        nim::VChat::StartDevice(nim::kNIMDeviceTypeAudioOutChat, "", 50, 0, 0, StartDeviceCb);
    }
    else if(type == nim::kNIMDeviceTypeVideo)
    {
        // 使用系统默认的设备
        nim::VChat::StartDevice(nim::kNIMDeviceTypeVideo, "", 400, 352, 288, StartDeviceCb);
    }
}

// 回调函数, 得到"麦克风，扬声器, 摄像头"的设备列表
void chanel_wangyi::EnumDevCb(bool ret, nim::NIMDeviceType type, const char* json, const void*)
{
    // 得到当前的设备信息
    // deviceInfo.dll 中, 指定的设备, 在使用的时候, 可能已经被拔出掉了
    QString strJson(json);
    if(type == nim::kNIMDeviceTypeAudioIn) // 麦克风
    {
        // 网易, 获取麦克风设备信息的时候, 有一个bug
        // 应该是:
        // 耳机式麦克风 (Jabra UC VOICE 150 MS duo)
        // 可是我这边拿到的json数据是
        // 耳机式麦克风 (Jabra UC VOICE 150 MS d)
        // 得到配置文件: deviceInfo.dll 中的设备信息
        qDebug() << "chanel_wangyi::EnumDevCb" << json << endl << g_strMicPhone << __LINE__;

        // 第一次启动程序的时候, deviceInfo.dll文件, 还不存在的时候， 不需要下面的判断
        if(g_strMicPhone.trimmed().length() > 0)
        {
            QString strMicPhone = g_strMicPhone.mid(0, g_strMicPhone.length() - 10);
            // 确认: deviceInfo.dll 中, 指定的设备, 是否被拔出了
            QByteArray byteArray = QString(json).toUtf8();
            QJsonArray dataObject = QJsonDocument::fromJson(byteArray).array();
            int i = 0;
            for(i = 0; i < dataObject.count(); i++)
            {
                QJsonObject jsnObject = dataObject.at(i).toObject();
                QString strPath = jsnObject.value("path").toString();
                qDebug() << "chanel_wangyi::EnumDevCb" << strPath << strMicPhone << __LINE__;
                if(strPath.contains(strMicPhone))
                {
                    // 使用指定的设备
                    g_strMicPhone = strPath;
                    break;
                }
            }
        }
        // 开启音频输入, 麦克风, 第二个参数: g_strMicPhone.toStdString().c_str(), 说明使用哪一个麦克风
        nim::VChat::StartDevice(nim::kNIMDeviceTypeAudioIn, g_strMicPhone.toStdString().c_str(), 50, 0, 0, StartDeviceCb);
        //nim::VChat::AddDeviceStatusCb(nim::kNIMDeviceTypeAudioIn, DeviceStatusCb); //对设备进行监听, 比如: 拔除设备的时候, 回调函数, 会被调用
        qDebug() << "chanel_wangyi::EnumDevCb" << g_strMicPhone << __LINE__; //g_strMicPhone为空的时候, 由网易SDK, 自己选择, 使用哪一个设备
    }
    else if(type == nim::kNIMDeviceTypeAudioOutChat) // 扬声器
    {
        // 得到配置文件: deviceInfo.dll 中的设备信息
        qDebug() << "chanel_wangyi::EnumDevCb" << json << endl << g_strSpeaker << __LINE__;

        // 确认: deviceInfo.dll 中, 指定的设备, 是否被拔出了
        if(g_strSpeaker.trimmed().length() > 0 && !strJson.contains(g_strSpeaker))
        {
            g_strSpeaker = ""; //设备, 被拔出了, 使用系统默认设备
        }

        // 开启音频输出, 扬声器, 第二个参数: g_strSpeaker.toStdString().c_str(), 说明使用哪一个扬声器
        nim::VChat::StartDevice(nim::kNIMDeviceTypeAudioOutChat, g_strSpeaker.toStdString().c_str(), 50, 0, 0, StartDeviceCb);
        //        nim::VChat::AddDeviceStatusCb(nim::kNIMDeviceTypeAudioOutChat, DeviceStatusCb); //对设备进行监听, 比如: 拔除设备的时候, 回调函数, 会被调用
        qDebug() << "chanel_wangyi::EnumDevCb" << g_strSpeaker << __LINE__;  //g_strSpeaker为空的时候, 由网易SDK, 自己选择, 使用哪一个设备
    }
    else if(type == nim::kNIMDeviceTypeVideo) //摄像头
    {
        // 得到配置文件: deviceInfo.dll 中的设备信息
        qDebug() << "chanel_wangyi::EnumDevCb" << json << endl << g_strCamera << __LINE__;
        // 确认: deviceInfo.dll 中, 指定的设备, 是否被拔出了
        QByteArray byteArray = QString(json).toUtf8();
        QJsonArray dataObject = QJsonDocument::fromJson(byteArray).array();
        bool bFind = false;
        int i = 0;
        for(i = 0; i < dataObject.count() && g_strCamera.trimmed().length() > 0; i++)
        {
            QJsonObject jsnObject = dataObject.at(i).toObject();
            QString strPath = jsnObject.value("path").toString();
            if(strPath == g_strCamera)
            {
                bFind = true;
                break;
            }
        }

        if(!bFind)
        {
            // 设备, 被拔出了, 使用系统默认设备
            g_strCamera = "";
        }

        nim::VChat::StartDevice(nim::kNIMDeviceTypeVideo, g_strCamera.toStdString().c_str(), 400, 352, 288, StartDeviceCb);
        //nim::VChat::AddDeviceStatusCb(nim::kNIMDeviceTypeVideo, DeviceStatusCb); //对设备进行监听, 比如: 拔除设备的时候, 回调函数, 会被调用
        qDebug() << "chanel_wangyi::EnumDevCb" << json << endl << g_strCamera << __LINE__;
    }
}

// 参考链接: https://dev.yunxin.163.com/docs/product/%E9%9F%B3%E8%A7%86%E9%A2%91%E9%80%9A%E8%AF%9D/SDK%E5%BC%80%E5%8F%91%E9%9B%86%E6%88%90/Windows%E5%BC%80%E5%8F%91%E9%9B%86%E6%88%90/%E8%AE%BE%E5%A4%87
// 得到"麦克风，扬声器, 摄像头"的设备列表
void GetDeviceInfo()
{
    nim::VChat::EnumDeviceDevpath(nim::kNIMDeviceTypeAudioIn, &chanel_wangyi::EnumDevCb);
    nim::VChat::EnumDeviceDevpath(nim::kNIMDeviceTypeAudioOutChat, &chanel_wangyi::EnumDevCb);
    nim::VChat::EnumDeviceDevpath(nim::kNIMDeviceTypeVideo, &chanel_wangyi::EnumDevCb);
}

// 得到视频帧数据
void chanel_wangyi::AddVideoFrame(bool capture, int64_t time, const char* data, int size, int width, int height, const std::string& json, FrameType frame_type)
{
    if(!g_bOnlyOnce) // 确保这个函数, 每次加入房间, 只会被调用一次
    {
        nim::VChat::SelectVideoAdaptiveStrategy(kNIMVChatVEModeFramerate, "", OnOptCallback); //动态切换视频自适应策略, 流畅优先
        g_bOnlyOnce = true;
    }
    QString qstr;
    qstr = QString::fromStdString(json);
    Json::Value valus;
    Json::Reader reader;
    std::string account;
    if (!capture && reader.parse(json, valus))
    {
        account = valus[nim::kNIMDeviceDataAccount].asString();
    }

    timeb time_now;
    ftime(&time_now);
    int64_t cur_timestamp = time_now.time * 1000 + time_now.millitm;
    const char* src_buffer = data;

    if (capture)
    {
        capture_video_pic_.ResetData(cur_timestamp, src_buffer, size, width, height);
    }
    else
    {
        auto it = recv_video_pic_list_.find(account);
        if (it != recv_video_pic_list_.end())
        {
            it->second->ResetData(cur_timestamp, src_buffer, size, width, height/*, subtype*/);
        }
        else
        {
            PicRegion* pic_info = new PicRegion;
            pic_info->ResetData(cur_timestamp, src_buffer, size, width, height/*, subtype*/);
            recv_video_pic_list_[account] = pic_info;
        }
    }

    int item_w = width;
    int item_h = height;
    std::string data_;
    data_.resize(item_w * item_h * 4);
    bool mirror = false;
    int64_t timestamp_;
    GetVideoFrame((capture ? "" : account), timestamp_, (char*)data_.c_str(), item_w, item_h, mirror);

    QImage grayImg((const uchar *)data_.c_str(), item_w, item_h, QImage::Format_ARGB32);
    QImage image = grayImg.convertToFormat(QImage::Format_RGB888);
    image = image.scaled(512, 288);

#if 0
    static int i = 0;
    QString strName = QString("D:/000/%1.png") .arg(i);
    i++;
    ret = grayImg.save(strName, 0);
    //qDebug() << " grayImg->save" << ret;
#endif

    // 发送图像给上层
    unsigned int uid = 0; // 视频, 默认发送给自己本地的
    int iRotate = 0; // 旋转角度
    if(!capture)
    {
        QString strAccount = QString::fromStdString(account);
        QStringList lstAccount = strAccount.split("_");
        QString strUid = lstAccount[lstAccount.size() - 1];
        uid = strUid.toInt();
        // 和 Android + PC 端
        // 通过宽度, 和高度的比例, 判断图像是否需要旋转
        // 正常情况下, 是宽度大于高度, 如果高度大于宽度的时候, 就旋转
        int iRate = width / height;
        if(iRate >= 1)
        {
            iRotate = 0;
        }
        else
        {
            iRotate = 90;
        }
#if 0
        static int i = 0;
        QString strName = QString("D:/000/%1.png") .arg(i);i++;
        grayImg.save(strName, 0);
#endif
    }
    else
    {
#if 0
        static int i = 0;
        QString strName = QString("D:/111/%1.png") .arg(i);
        i++;
        ret = grayImg.save(strName, 0);
#endif
        if(g_role == TEACHER)
        {
            // for beautyImage
            image.save("0","jpg");
            // 判断是否发送美颜图片
            if(BeautyList::getInstance()->beautyIsOn)
            {
                nim::VChat::SetCustomData(false, true);
                int tSize = BeautyList::getInstance()->hasBeautyImageList.size();
                if(tSize > 0)
                {
                    QImage tImg;
                    tImg =  BeautyList::getInstance()->hasBeautyImageList.at(tSize - 1).scaled(512,288);
                    tImg = tImg.convertToFormat(QImage::Format_ARGB32);

                    int32_t my_width = tImg.width();
                    int32_t my_height = tImg.height();
                    int32_t wxh = my_width * my_height;
                    int32_t data_size = wxh * 3 / 2;

                    std::string beauty_src_data;
                    beauty_src_data.resize(wxh * 4);
                    memcpy((void *)beauty_src_data.c_str(), tImg.bits(), data_size);

                    std::string strDestData2;
                    strDestData2.resize(wxh * 4);
                    ARGBToYUV420((char*)tImg.bits(), (char*)strDestData2.c_str(), my_width, my_height);

                    bool bFlag = nim::VChat::CustomVideoData(0, (const char *)strDestData2.c_str(), data_size, tImg.width(), tImg.height(), nullptr);


                    if(tSize > 200 )
                    {
                        BeautyList::getInstance()->hasBeautyImageList.clear();
                        BeautyList::getInstance()->hasBeautyImageList.append(tImg);
                    }
                }
            }
            else
            {
                nim::VChat::SetCustomData(false, false);
            }
        }
    }
    emit Processing_C_Channel::getInstance()->renderVideoFrameImage(uid, image, iRotate);
}

// 对图像格式, 进行转换
bool chanel_wangyi::GetVideoFrame(std::string account, int64_t& time, char* out_data, int& width, int& height, bool mirror, bool argb_or_yuv)
{
    timeb time_now;
    ftime(&time_now);
    int64_t cur_timestamp = time_now.time * 1000 + time_now.millitm;
    PicRegion* pic_info = nullptr;
    if (account.empty())
    {
        pic_info = &capture_video_pic_;
    }
    else
    {
        auto it = recv_video_pic_list_.find(account);
        if (it != recv_video_pic_list_.end())
        {
            pic_info = it->second;
        }
    }

    if (pic_info && pic_info->pdata_  && cur_timestamp - 1000 < pic_info->timestamp_)
    {
        time = pic_info->timestamp_;
        int src_w = pic_info->width_;
        int src_h = pic_info->height_;

        if (width <= 0 || height <= 0)
        {
            width = src_w;
            height = src_h;
        }
        else if (src_h * width > src_w * height)
        {
            width = src_w * height / src_h;
        }
        else
        {
            height = src_h * width / src_w;
        }
        width -= width % 2;
        height -= height % 2;

        std::string ret_data;
        if (width != src_w || height != src_h)
        {
            ret_data.append(width * height * 3 / 2, (char)0);
            uint8_t* src_y = (uint8_t*)pic_info->pdata_;
            uint8_t* src_u = src_y + src_w * src_h;
            uint8_t* src_v = src_u + src_w * src_h / 4;
            uint8_t* des_y = (uint8_t*)ret_data.c_str();
            uint8_t* des_u = des_y + width * height;
            uint8_t* des_v = des_u + width * height / 4;
            libyuv::FilterMode filter_mode = libyuv::kFilterBox; //枚举
            libyuv::I420Scale(src_y, src_w,
                              src_u, src_w / 2,
                              src_v, src_w / 2,
                              src_w, src_h,
                              des_y, width,
                              des_u, width / 2,
                              des_v, width / 2,
                              width, height,
                              filter_mode);
        }
        else
        {
            ret_data.append(pic_info->pdata_, pic_info->size_);
        }

        if (argb_or_yuv)
        {
            uint8_t* des_y = (uint8_t*)ret_data.c_str();
            uint8_t* des_u = des_y + width * height;
            uint8_t* des_v = des_u + width * height / 4;

            libyuv::I420ToARGB(
                        des_y, width,
                        des_u, width / 2,
                        des_v, width / 2,
                        (uint8_t*)out_data, width * 4,
                        width, height);
        }
        else
        {
            memcpy(out_data, ret_data.c_str(), ret_data.size());
        }

        return true;
    }
    return false;
}

// 得到本地摄像头的图像信息
void chanel_wangyi::VideoCaptureData(unsigned __int64 time, const char* data, unsigned int size, unsigned int width, unsigned int height, const char *json, const void *user_data)
{
#if 0
    static unsigned int i = 0;
    i++;
    if((i % 100) == 1)
    {
        qDebug() << ("chanel_wangyi VideoCaptureData  size:") << size << ", width:" << width << ", height:" << height;
    }
#endif

    std::string json_temp(json);
    AddVideoFrame(true, time, data, size, width, height, json_temp, Ft_I420);
    return;
}

// 得到远端摄像头, 发送过来的图像信息
void chanel_wangyi::VideoRecData(unsigned __int64 time, const char* data, unsigned int size, unsigned int width, unsigned int height, const char* json, const void *user_data)
{
    if(bstop_video_status)
    {
        return;
    }
    std::string json_temp(json);
    AddVideoFrame(false, time, data, size, width, height, json_temp, Ft_I420);

    return;
}

void OnVChatCb(nim::NIMVideoChatSessionType type, uint64_t channel_id, int code, const std::string& json)
{

}

static void VChatCb(nim::NIMVideoChatSessionType type, __int64 channel_id, int code, const char *json, const void*)
{

}

// login 回调函数返回成功以后, 才可以进行下一步的create room, join room, 不然会出错
void chanel_wangyi::CallbackLogin(const nim::LoginRes& login_res, const void* user_data)
{
    qDebug() << ("chanel_wangyi CallbackLogin") << login_res.res_code_ << login_res.login_step_;

    if (login_res.login_step_ == nim::kNIMLoginStepLogin && login_res.res_code_ == nim::kNIMResSuccess)
    {
        QString strAccount = QString::fromStdString(m_account);
        if(strAccount.contains("tea"))
        {
            qDebug("chanel_wangyi CallbackLogin success");
            doCreateRoom(); // 老师才需要create room, 学生只需要join room
        }
        else
        {
            //slotJoinRoom();
        }
        qDebug() << ("chanel_wangyi CallbackLogin login_step_") << login_res.login_step_;
    }
    else
    {

    }
}

void chanel_wangyi::do_saveRoomInfo()
{
    QString url = "http://" + YMHttpClientUtils::getInstance()->getRunUrl(1, g_strDllFile, g_strAppName) + "/im/saveRoomInfo";
    QVariantMap  reqParm;
    QDateTime currentTime = QDateTime::currentDateTime();
    reqParm.insert("lessonId", chanel_wangyi::m_room_id);
    reqParm.insert("roomId", QString::number(chanel_wangyi::m_room_id));
    reqParm.insert("token", g_token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMAVEncryption::signMapSort(reqParm);
    QString sign = YMAVEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QByteArray dataArray = YMHttpClientUtils::getInstance()->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();

    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "====== chanel_wangyi::do_saveRoomInfo failed";
    }
}

void chanel_wangyi::OnCreateChannelCallback(int code, __int64 channel_id, const std::string& json_extension)
{
    qDebug() << "chanel_wangyi::OnCreateChannelCallback" << code;

    // 信息上报
    QJsonObject changeChannelObj;
    changeChannelObj.insert("currentChannel","3");
    // 创建房间成功
    if(code == nim::kNIMResSuccess || code == nim::kNIMResExist)
    {
        qDebug() << ("chanel_wangyi OnCreateChannelCallback success.");
        slotJoinRoom();
        do_saveRoomInfo();
        changeChannelObj.insert("result","1");
        changeChannelObj.insert("errMsg","");
        emit Processing_C_Channel::getInstance()->createRoomSucess();
    }
    else
    {
        changeChannelObj.insert("result","0");
        changeChannelObj.insert("errMsg",QString("createChannel fail ").append(QString::fromStdString(json_extension)));
        qDebug() << ("chanel_wangyi OnCreateChannelCallback failed.");
        emit Processing_C_Channel::getInstance()->createRoomFail();
    }
    emit Processing_C_Channel::getInstance()->sigChangeChannel(changeChannelObj);
}

bool chanel_wangyi::doCreateRoom()
{
    std::string json_valueA;
    qDebug() << ("chanel_wangyi::doCreateRoom m_room_id:") << m_room_id;

    QString strRoomId = QString::number(m_room_id, 10);
    nim::VChat::CreateRoom(strRoomId.toStdString(), "custom_info", json_valueA, &chanel_wangyi::OnCreateChannelCallback);

    return true;
}

void chanel_wangyi::OnJoinChannelCallback(int code, __int64 channel_id, const std::string& json_extension)
{
    // 给m_audioName赋值, 上传给服务器, 录播的时候, 需要
    bHasFinished_JoinChannel = true;
    QString audioName = QString("%1;;%1").arg(channel_id);
    emit Processing_C_Channel::getInstance()->sigAudioName(audioName);

    QString qstr;
    qstr = QString::fromStdString(json_extension);
    qDebug("chanel_wangyi::OnJoinChannelCallback = %s, code: %d, channel_id: %llu", qPrintable(qstr), code, channel_id);

    if (code != nim::kNIMResSuccess)
    {
        if (code == nim::kNIMResNotExist)
        {
            qDebug("chanel_wangyi OnJoinChannelCallback failed");
        }
        else
        {
        }
        emit Processing_C_Channel::getInstance()->createRoomFail();
    }
    else
    {
        // 得到"麦克风，扬声器, 摄像头"的设备列表
        GetDeviceInfo();
        bHasJoinRoom = true;
        emit Processing_C_Channel::getInstance()->createRoomSucess();
    }
}

void chanel_wangyi::slotExitRoom()
{
    leaveRoom();
}

void chanel_wangyi::slotJoinRoom()
{
    qDebug() << ("chanel_wangyi slotJoinRoom start");
    g_bOnlyOnce = false;
    nim::VChat::SetViewerMode(false); // 设置为: 互动者
    QString strRoomId = QString::number(m_room_id, 10);
    bool ret = JoinRoom(nim::kNIMVideoChatModeVideo, strRoomId.toStdString(), "", false, "");
    qDebug() << ("chanel_wangyi slotJoinRoom ret: ") << ret;
    nim::VChat::SetViewerMode(false); // 设置为: 互动者
}

void chanel_wangyi::slotStart_Device_Audio()
{
    //Start_Device_Audio();
}

void chanel_wangyi::slotStop_Device_Audio()
{
    //    Stop_Device_Audio();
}

void chanel_wangyi::slotStart_Device_Video()
{
    //开启看对方的视频
    bstop_video_status = false;
    //Start_Device_Video();
}

void chanel_wangyi::slotStop_Device_Video()
{
    //Stop_Device_Video();
    bstop_video_status = true;
    //关闭视频, 即: 不看对方的视频了
}

//开启视频
void chanel_wangyi::Start_Device_Video()
{
    qDebug() << "chanel_wangyi::Start_Device_Video" << __LINE__;
    //摄像头, 第二个参数: g_strCamera.toStdString().c_str(), 说明使用哪一个摄像头
    nim::VChat::StartDevice(nim::kNIMDeviceTypeVideo, g_strCamera.toStdString().c_str(), 400, 352, 288, StartDeviceCb);
}

//关闭视频
void chanel_wangyi::Stop_Device_Video()
{
    qDebug() << "chanel_wangyi::Stop_Device_Video" << __LINE__;
    nim::VChat::EndDevice(nim::kNIMDeviceTypeVideo);
}

//打开麦克风
void chanel_wangyi::Start_Device_Audio()
{
    qDebug() << "chanel_wangyi::Start_Device_Audio" << g_strMicPhone << __LINE__;
    //开启音频输出, 扬声器, 第二个参数: g_strSpeaker.toStdString().c_str(), 说明使用哪一个扬声器
    nim::VChat::StartDevice(nim::kNIMDeviceTypeAudioOutChat, g_strSpeaker.toStdString().c_str(), 50, 0, 0, StartDeviceCb);
    //开启音频输入, 麦克风, 第二个参数: g_strMicPhone.toStdString().c_str(), 说明使用哪一个麦克风
    nim::VChat::StartDevice(nim::kNIMDeviceTypeAudioIn, g_strMicPhone.toStdString().c_str(), 50, 0, 0, StartDeviceCb);
}

//关闭音频
void chanel_wangyi::Stop_Device_Audio()
{
    nim::VChat::EndDevice(nim::kNIMDeviceTypeAudioIn);
}

void chanel_wangyi::slotCreateRoom()
{
    qDebug() << ("chanel_wangyi slotCreateRoom start");
    bHasFinished_JoinChannel = false;
    doCreateRoom();
}

void chanel_wangyi::slotLogin()
{
    auto cb = std::bind(&chanel_wangyi::CallbackLogin, std::placeholders::_1, nullptr);
    bool ret = nim::Client::Login(DEMO_GLOBAL_APP_KEY, chanel_wangyi::m_account, chanel_wangyi::m_password, cb);

    qDebug() << ("chanel_wangyi Client::Login") << ret;
}

void chanel_wangyi::slotInit(ROLE_TYPE role, QString strSpeaker, QString strMicPhone, QString strCamera, QString token, QString strDllFile, QString strAppName)
{
    g_role = role;
    g_strSpeaker = strSpeaker;
    g_strMicPhone = strMicPhone;
    g_strCamera = strCamera;
    g_token = token;
    g_strDllFile = strDllFile;
    g_strAppName = strAppName;
    qDebug() << ("chanel_wangyi slotInit");
    bstop_video_status = false;
    // 初始化云信SDK
    nim::SDKConfig config;
    // sdk能力参数（必填）
    config.database_encrypt_key_ = "Netease"; // string（db key必填，目前只支持最多32个字符的加密密钥！建议使用32个字符
    // 初始化IM SDK
    bool ret = nim::Client::Init(DEMO_GLOBAL_APP_KEY, "NIM_EDU_YIMI", "", config); // 载入云信sdk，初始化安装目录和用户目录
    qDebug() << ("chanel_wangyi Client::Init") << ret;
    InitUiKit();
}

bool chanel_wangyi::JoinRoom(nim::NIMVideoChatMode mode, const std::string& room_name, const std::string& rtmp_url, bool live_link, const std::string& session_id)
{
    Json::FastWriter fs;
    Json::Value value;
    value[nim::kNIMVChatSessionId] = "";
    if(g_role == TEACHER)
    {
        value[nim::kNIMVChatRtmpUrl] = chanel_wangyi::m_push_url;
    }
    else
    {
        value[nim::kNIMVChatRtmpUrl] = rtmp_url;
    }
    value[nim::kNIMVChatBypassRtmp] = 1;
    value[nim::kNIMVChatRtmpRecord] = 1;
    value[nim::kNIMVChatAudioHighRate] = 1;
    std::string split_mode;
    if (split_mode.empty())
    {
        value[nim::kNIMVChatSplitMode] = nim::kNIMVChatSplitLatticeTile;
    }
    else
    {
        value[nim::kNIMVChatSplitMode] = atoi(split_mode.c_str());
    }
    std::string json_value = fs.write(value);
    QString readString = room_name.c_str();
    qDebug("chanel_wangyi room_name: %s", qPrintable(readString));
    readString = json_value.c_str();
    qDebug("chanel_wangyi json_value: %s", qPrintable(readString));
    return nim::VChat::JoinRoom(mode, room_name, json_value, &chanel_wangyi::OnJoinChannelCallback);
}

chanel_wangyi::chanel_wangyi(QWidget *parent)
{

}

void chanel_wangyi::UnloadSdk()
{
    // Cleanup之前, 需要logout
    nim::Client::Logout(nim::kNIMLogoutRelogin, OnLogoutCallback);

    nim::VChat::Cleanup();
    nim::Client::Cleanup();
}

chanel_wangyi::~chanel_wangyi()
{
    qDebug() << "chanel_wangyi::~chanel_wangyi()";
    leaveRoom();
    UnloadSdk();
}

void chanel_wangyi::EndChat()
{
    qDebug() << ("chanel_wangyi EndChat Begin.");
    Json::FastWriter fs;
    Json::Value value;
    value[nim::kNIMVChatSessionId] = "";
    std::string json_value = fs.write(value);
    nim::VChat::End(json_value);
    qDebug() << ("chanel_wangyi EndChat End");
}


void chanel_wangyi::leaveRoom()
{
    if(!bHasJoinRoom) // 如果没有join room, 就不需要EndChat了
    {
        return;
    }

    bHasJoinRoom = false;
    qDebug() << ("chanel_wangyi leaveRoom");
    Stop_Device_Audio();
    Stop_Device_Video();
    EndChat();
}

void chanel_wangyi::InitUiKit()
{
    qDebug() << ("chanel_wangyi InitUiKit");

    // 初始化云信音视频
    bool ret = nim::VChat::Init("");
    qDebug() << "chanel_wangyi VChat::Init" << ret;

    /* 以下注册的回调函数，都是在收到服务器推送的消息或事件时执行的。因此需要在程序开始时就注册好。 */
    // 注册重连、被踢、掉线、多点登录、把移动端踢下线的回调
    nim::Client::RegReloginCb(&chanel_wangyi::OnReLoginCallback);
    nim::Client::RegKickoutCb(&chanel_wangyi::OnKickoutCallback);
    nim::Client::RegDisconnectCb(&chanel_wangyi::OnDisconnectCallback);
    nim::Client::RegMultispotLoginCb(&chanel_wangyi::OnMultispotLoginCallback);
    nim::Client::RegKickOtherClientCb(&chanel_wangyi::OnKickoutOtherClientCallback);
    nim::Client::RegSyncMultiportPushConfigCb(&chanel_wangyi::OnMultiportPushConfigChange);

    // 注册音视频回调
    nim::VChat::SetVideoDataCb(true,  &chanel_wangyi::VideoCaptureData);
    nim::VChat::SetVideoDataCb(false, &chanel_wangyi::VideoRecData);
    nim::VChat::SetCbFunc(VChatCb);
}

void chanel_wangyi::OnMultiportPushConfigChange(int rescode, bool switch_on)
{
    qDebug() << "chanel_wangyi OnMultiportPushConfigChange";
}

void chanel_wangyi::OnLogoutCallback(nim::NIMResCode res_code)
{
    qDebug() << "chanel_wangyi OnLogoutCallback res_code: " << res_code;
}

void chanel_wangyi::OnKickoutCallback(const nim::KickoutRes& res)
{
    qDebug() << "chanel_wangyi OnKickoutCallback";
}

void chanel_wangyi::OnDisconnectCallback()
{
    qDebug() << "chanel_wangyi OnDisconnectCallback";
}

void chanel_wangyi::OnReLoginCallback(const nim::LoginRes& login_res)
{
    qDebug() << "chanel_wangyi OnReLoginCallback";
}

// 多端
void chanel_wangyi::OnMultispotLoginCallback(const nim::MultiSpotLoginRes& res)
{
    qDebug() << "chanel_wangyi OnMultispotLoginCallback";
}

void chanel_wangyi::OnMultispotChange(bool online, const std::list<nim::OtherClientPres>& clients)
{
    qDebug() << "OnMultispotChange";
}

void chanel_wangyi::OnKickoutOtherClientCallback(const nim::KickOtherRes& res)
{
    qDebug() << "chanel_wangyi OnKickoutOtherClientCallback";
}
