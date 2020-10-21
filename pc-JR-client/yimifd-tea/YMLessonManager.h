#ifndef YMLessonManager_H
#define YMLessonManager_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDataStream>
#include <QTextStream>
#include <QProcess>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QSettings>
#include <QTimer>
#include <QMap>
#include <QStringList>
#include <QCryptographicHash>
#include <QDebug>
#include <QIODevice>

struct UserBaseInfo {
    QString appVersion;
    QString apiVersion;
    QString token;
    QString miniUrl;
    QString miniH5;
    QString liveroomId;
};

namespace YMEncryptions
{
static inline
QString md5(const QString& data)
{
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(data.toUtf8());
    return QString(hash.result().toHex());
}

static inline
QString signSort(const QMap<QString, QString> &dataMap)
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
static inline
QString signMapSort(const QVariantMap &dataMap)
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

class YMLessonManager : public QObject
{
    Q_OBJECT
public:
    YMLessonManager(QObject *parent = 0);
    ~YMLessonManager();

    Q_INVOKABLE void getEnterRoomData();

    //获取云盘首页的文件信息
    Q_INVOKABLE QJsonArray  getCloudDiskInitFileInfo();

    //根据文件id获取文件夹中的文件
    Q_INVOKABLE QJsonArray  getCloudDiskFolderInfo(QString folderId);

    //根据文件id获取文件详情
    Q_INVOKABLE QJsonObject  getCloudDiskFileInfo(QString fileId);

    QByteArray httpGetVariant(QString url,const QVariantMap &formData);

    int readUserBaseInfo();

    QTimer * m_timer;

private:

    UserBaseInfo m_userBaseInfo;

signals:
    void sigCoursewareTotalPage(int pageTotal);
};

#endif // YMLessonManager_H
