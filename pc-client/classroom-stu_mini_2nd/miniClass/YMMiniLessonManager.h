#ifndef YMMINILESSONMANAGER_H
#define YMMINILESSONMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"
#include <QDataStream>
#include <QTextStream>
#include <QProcess>
#include<QFile>
#include<QDir>
#include<QMessageBox>
#include<QStandardPaths>
#include<QCoreApplication>
#include<QSettings>
#include<QTimer>
#include "./dataconfig/datahandl/datamodel.h"

class YMMiniLessonManager
        : public QObject
{
    Q_OBJECT
public:
    YMMiniLessonManager(QObject *parent = 0);
    ~YMMiniLessonManager();

    Q_INVOKABLE void getEnterRoomData();

    //获取云盘首页的文件信息 stu暂时用不到
    Q_INVOKABLE QJsonArray  getCloudDiskInitFileInfo();

    //根据文件id获取文件夹中的文件 stu暂时用不到
    Q_INVOKABLE QJsonArray  getCloudDiskFolderInfo(QString folderId);

    //根据文件id获取文件详情 获取课件的时候用
    Q_INVOKABLE QJsonObject  getCloudDiskFileInfo(QString fileId);

    //获取ip列表
    QJsonObject getIpListInfo();

private:
    YMHttpClient * m_httpClint;


signals:

};

#endif // YMMINILESSONMANAGER_H
