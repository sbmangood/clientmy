#ifndef RESETIPSETTINGFILE_H
#define RESETIPSETTINGFILE_H

#include <QObject>
#include<QSettings>
#include<QNetworkAccessManager>
#include<QNetworkReply>
#include<QNetworkRequest>
#include<QFile>
#include<QEventLoop>
#include<QJsonDocument>
#include<QJsonObject>
#include<QJsonParseError>
#include<QSettings>
#include<QJsonArray>
#include<QJsonValue>
#include<QStandardPaths>
#include<QDir>
#include<QTimer>
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"
#include "./dataconfig/datahandl/datamodel.h"
/*

重新设置服务器 ip 列表的 配置文件
文件不存在  return
如果不存在用户自定义选择的ip 就删除ip配置文件
如果存在用户自定义选择的ip 且此次请求的 ip列表不包含用户选择的 ip 删除文件  若包含 重新设置ItemLost ItemDelay 项

*/

class ResetIpSettingFile : public QObject
{
        Q_OBJECT
    public:
        explicit ResetIpSettingFile(QObject *parent = 0);
        void resetIpFile(QString backData);
        ~ResetIpSettingFile();

        //获取优化的ip列表
        void getGoodIplist(QString backData);

    private:
        QNetworkAccessManager * m_httpAccessmanger;
        YMHttpClient * m_httpClint;
    signals:

    public slots:
};

#endif // RESETIPSETTINGFILE_H
