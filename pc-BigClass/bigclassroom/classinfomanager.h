#ifndef CLASSINFOMANAGER_H
#define CLASSINFOMANAGER_H
#include <QJsonObject>
#include <QJsonArray>
#include <openssl/aes.h>
#include <QObject>
#include "ymcrypt.h"
#include "openssl/include/openssl/des.h"

class HttpClient;
class ClassInfoManager : public QObject
{
    Q_OBJECT
public:
    explicit ClassInfoManager();
    virtual ~ClassInfoManager();

    static ClassInfoManager* getInstance();

    void init(const QString &appId, const QString &appKey, const QString &apiUrl, const QString &classId, const QString &userId, int userType);

    int getSocketIpList(int socketTcpPort, QVariantList &goodIpList);
    int getSocketAddr(QString &socketIp, int &socketTcpPort, int &socketHttpPort);
    int getEnterRoomInfo(QString &channelKey,QString &channelName,QString &token, QString &uid, QString &chatRoomId, QString &title, int &statusCode);

    Q_INVOKABLE int getCloudDiskList(QString roomId, QString apiUrl, QString appId = "7169a6c5ab5b4eeba2ca37b831fb9239");

    Q_INVOKABLE int upLoadCourseware(QString roomId, QString userId, QString fileUrl, long fileSize, QString apiUrl, QString appId = "7169a6c5ab5b4eeba2ca37b831fb9239");

    QString des_decrypt(const std::string &cipherText);
    QString des_encrypt(const QString &clearText);
    void encrypt(QString source, QString target);
    QList<QString> decrypt(QString source);

private:
    QString m_classId;
    QString m_userId;
    int m_userType;
    QString m_apiUrl;
    QString m_appId;
    QString m_appKey;
    HttpClient* m_httpClient;
    static ClassInfoManager* m_classInfoManager;

signals:
    // @param clouddiskInfo包含信息:"date": "string","docType": "string","id": 0,"jsonData": "string","name": "string","path": "string","type": 0
    void sigCloudDiskInfo(QJsonArray clouddiskInfo);
    void sigSaveResourceSuccess();// 保存资源成功信号
    void sigSaveResourceFailed();// 保存资源失败信号
};

#endif // CLASSINFOMANAGER_H
