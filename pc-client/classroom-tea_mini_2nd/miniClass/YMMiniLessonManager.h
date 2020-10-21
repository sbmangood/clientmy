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

    //获取云盘首页的文件信息
    Q_INVOKABLE QJsonArray  getCloudDiskInitFileInfo();

    //根据文件id获取文件夹中的文件
    Q_INVOKABLE QJsonArray  getCloudDiskFolderInfo(QString folderId);

    //根据文件id获取文件详情
    Q_INVOKABLE QJsonObject  getCloudDiskFileInfo(QString fileId);

private:
    YMHttpClient * m_httpClint;


signals:
    void sigCoursewareTotalPage(int pageTotal);
};

#endif // YMMINILESSONMANAGER_H
