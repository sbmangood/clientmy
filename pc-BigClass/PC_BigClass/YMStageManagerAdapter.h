#ifndef YMSTAGEMANAGERADAPTER_H
#define YMSTAGEMANAGERADAPTER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QSsl>
#include <QSslSocket>
#include <openssl/des.h>
#include <QDataStream>
#include <QTextStream>
#include <QProcess>
#include <QFile>
#include <QDir>
#include <QMessageBox>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QSettings>
#include <QTimer>
#include "ymcrypt.h"
#include "YMHttpClient.h"
#include "YMUserBaseInformation.h"

class YMStageManagerAdapter : public QObject
{
    Q_OBJECT
public:
    explicit YMStageManagerAdapter(QObject *parent = 0);
    Q_INVOKABLE void getCurrentStage();// 获取当前环境配置
    Q_INVOKABLE void updateStage(int netType, QString stageInfo);// 修改配置文件
    Q_INVOKABLE QString getAppVersion();// 获取版本号

private:
    YMHttpClient * m_httpClient;

signals:
    void sigStageInfo(int netType,QString stageInfo);
};

#endif // YMSTAGEMANAGERADAPTER_H
