#ifndef CLASSINFOMANAGER_H
#define CLASSINFOMANAGER_H
#include <QJsonObject>
#include <QJsonArray>
#include <openssl/aes.h>
#include <QObject>
#include <QMutex>
#include "ymcrypt.h"
#include "openssl/include/openssl/des.h"
#include"lessonevaluation/httpclient.h"

#include"../../pc-common/AESCryptManager/AESCryptManager.h"
//class HttpClient;
class ClassInfoManager : public QObject
{
    Q_OBJECT
public:
    explicit ClassInfoManager();
    virtual ~ClassInfoManager();

    static ClassInfoManager* getInstance();

    void init(const QString &appId, const QString &appKey, const QString &apiUrl, const QString &classId, const QString &userId, int userType, const QString &apiToken);

    int getSocketIpList(int socketTcpPort, QVariantList &goodIpList);
    int getSocketAddr(QString &socketIp, int &socketTcpPort, int &socketHttpPort);
    int getEnterRoomInfo(QString &channelKey,QString &channelName,QString &token, QString &uid, QString &chatRoomId, QString &title, int &statusCode, int &classType, QString &agoraAppid, QString& roomName);



    Q_INVOKABLE int getCloudDiskList(QString roomId, QString apiUrl, QString appId, bool isRefreshCloudDisk = true);

    Q_INVOKABLE int upLoadCourseware(QString upFileMark, QString roomId, QString userId, QString fileUrl, long fileSize, QString apiUrl, QString appId);

    Q_INVOKABLE int findFileStatus(QString coursewareId, QString apiUrl, QString appId);// 查询文件转换状态，返回值0-转换中 1-成功 2-失败

    Q_INVOKABLE int deleteCourseware(QString coursewareId, QString roomId, QString apiUrl, QString appId);// 删除云盘课件

    Q_INVOKABLE QJsonArray getCoursewareListInfo();


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
    static QString m_appKey;
    static QString m_apiToken;
    HttpClient* m_httpClient;
    static ClassInfoManager* m_classInfoManager;
    QJsonArray m_coursewareListInfo;
    QMutex m_mutex;

signals:
    // @param clouddiskInfo包含信息:"date": "string","docType": "string","id": 0,"jsonData": "string","name": "string","path": "string","type": 0
    void sigCloudDiskInfo(QJsonArray clouddiskInfo);
    void sigSaveResourceSuccess(QString coursewareId, QString originFilename, QString suffix, QString upFileMark);// 保存资源成功信号
    void sigSaveResourceFailed(QString originFilename, QString suffix, QString upFileMark);// 保存资源失败信号
    void sigFindFileStatus(int status);// 查询文件转码状态,status 转换状态 0-转换中 1-成功 2-失败
    void sigDeleteResult(QString coursewareId, bool isSuccess);// 云盘课件删除结果
};

#endif // CLASSINFOMANAGER_H
