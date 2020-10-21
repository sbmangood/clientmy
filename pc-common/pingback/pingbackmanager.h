#ifndef PINGBACKMANAGER_H
#define PINGBACKMANAGER_H
#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QMap>
#include <QQueue>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "commdef.h"
namespace yimipingback {

class PingbackManager : public QObject
{
  Q_OBJECT
protected:
    explicit PingbackManager(QObject *parent = 0);
signals:
public:
    static PingbackManager * gestance()
     {
          static PingbackManager *pingback = new PingbackManager();
          return pingback;
     }
   //传入company字段公司名和业务字端business，做业务区分
    void    InitSDK(const QString &company, const QString &business,const QString  &appversion);
   //在登录或注册成功后调用，传入用户ID和用户类型，并进行缓存
    void    SetUserInfo(const QString &uid, const QString &user_type);
   //在退出登录成功后调用，清除用户信息缓存
    void    ClearUserInfo();
   //注册所有教室事件，便于后续在所有教室内时间中添加教室基础字端，eventList为教室内时间的msgType
    void    RegisterRoomEventList(const QList<QString> &eventid_list);
   //在进入教室时调用，注入教室内课程信息
    void    RegisterRoomEventParams(const QJsonObject &liveinfo);
   //在退出教室时调用，清除教室内课程信息
    void    UnregisterRoomEventParams();
   //发送事件，msgType事件ID， extraInfos
    void    SendEvent(const QString &eventId, YimiLogType logtype, const QMap<QString,QString> &extrainfos);
signals:
    void    sinalFail();
public slots:
    void replyFinished(QNetworkReply *reply);
    void onAgainPostData();
private:
    //http请求方法
    void UrlRequestPost(const QString &url,const QByteArray &data);
private:
     QString GetPushUrl();
     QString GetCurrentNetWorkType();
     QString GetOsVersion();
     QString GetOperatorType();
     QString GetDeviceInfo();
     QString GetSessionId();
     QString GetUuid();
     bool JudgeEventId(const QString &cureventid);
   //静态成员变量
   QString  pushurl_;
   QString  company_;
   QString  business_;
   QString  appversion_;
   QString  uid_;
   QString  user_type_;
   QString  net_type_;
   QString  operator_type_;
   QString  os_version_;
   QString  device_info_;
   QString  session_id_;
   QString  uuid_;
   QList<QString> eventid_list_;
   QJsonObject liveinfo_;
   QByteArray  cur_bytearray_;
private:
QNetworkAccessManager  *m_accessManager;

};
}

#endif // PINGBACKMANAGER_H
