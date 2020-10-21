#ifndef YIMIBREAKPAD_H
#define YIMIBREAKPAD_H
#include <iostream>
#include <map>
#include <QMap>
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>

namespace  yimi_fudao_breakpad {
class HttpClient :public QObject
{
     Q_OBJECT
public:
   explicit HttpClient( QObject *parent=0);
   void requestPost( const QString &url, const QByteArray &data);
signals:
public slots:
   void onFinished(QNetworkReply *reply);
private:
   QNetworkAccessManager  *m_accessManager;


};
class Yimibreakpad : public QObject
{
    Q_OBJECT
public:

   static Yimibreakpad *gestance()
    {
         static Yimibreakpad *yimibreakpad = new Yimibreakpad();
         return yimibreakpad;
    }
    //监控崩溃客户端
    void   monitorProcessClient(const std::map<std::wstring,std::wstring> &base_info);
    //监控崩溃服务端
    void   monitorProcessServer();
    //程序退出释放
    void   cleanUp();

    std::wstring dump_path_;
    QMap<QString, QString> para_map_;
    bool  is_crash_;
    QJsonObject post_data_;

signals:
   void  sigPingback(const QString &url, const QByteArray &data);
   void  sigUploadDump();
public slots:
   void  onSigPingback(const QString &url, const QByteArray &data);
   void  onSigUploadDump();
protected:
   explicit Yimibreakpad(QObject *parent = 0);
private:
    QString GetPushUrl();

    QString  api_url_;


};

}

#endif // YIMIBREAKPAD_H
