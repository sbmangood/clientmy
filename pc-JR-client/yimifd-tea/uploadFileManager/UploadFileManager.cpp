#include <QDebug>
#include <QEventLoop>
#include <iostream>
#include "UploadFileManager.h"

UploadFileManager::UploadFileManager()
{

}

YMUpLoadFileManager::YMUpLoadFileManager()
{
    addUploadCallBack(this);
}

void YMUpLoadFileManager::ProgressCallback(size_t increment, int64_t transfered, int64_t total, UpLoadFileInfo* fileInfoData)
{
    //qDebug() << "ProgressCallback =>" << (float) transfered / total * 100 << "%" << QString::fromLocal8Bit(fileInfoData->fileurl) << fileInfoData->fileMark;
    float percent = (float) transfered / total * 100;
    QString transferedPercent = QString::number(percent);
    sigUploadProgress(QString::fromLocal8Bit(fileInfoData->fileurl), fileInfoData->fileMark, transferedPercent);
}

void YMUpLoadFileManager::upLoadSuccess(std::string fileUrl, long fileSize, std::string upFileMark)
{
    qDebug() << QString(QString::fromLocal8Bit(fileUrl.c_str())) << " " << fileSize << " " << QString::fromStdString(upFileMark) << "\n\n";
    emit sigUploadSuccess(QString(QString::fromLocal8Bit(fileUrl.c_str())), fileSize, QString::fromStdString(upFileMark));
}

void YMUpLoadFileManager::upLoadFailed(std::string errCode, std::string upFileMark)
{
    std::cout << "\n\n" << errCode << " " << upFileMark << "\n\n";
    emit sigUploadFailed(QString::fromStdString(errCode), QString::fromStdString(upFileMark));
}

void YMUpLoadFileManager::setBasicParams(QJsonObject basicParamsObj)
{
    m_mutex.lock();
    m_basicParamsObj = basicParamsObj;
    m_mutex.unlock();
}

QJsonObject YMUpLoadFileManager::getBasicParams()
{
    QJsonObject basicParamsObj;
    m_mutex.lock();
    basicParamsObj = m_basicParamsObj;
    m_mutex.unlock();
    return basicParamsObj;
}

void YMUpLoadFileManager::run()
{
    if (is_runnable)
    {
        QJsonObject paramsObj = getBasicParams();
        QString filePath, userId, envType, upFileMark;

        if(paramsObj.contains("filePath"))
        {
            filePath = paramsObj.take("filePath").toString();
        }
        if(paramsObj.contains("userId"))
        {
            userId = paramsObj.take("userId").toString();
        }
        if(paramsObj.contains("enType"))
        {
            envType = paramsObj.take("enType").toString();
        }
        if(paramsObj.contains("upFileMark"))
        {
            upFileMark = paramsObj.take("upFileMark").toString();
        }
        upLoadFileToOss(userId.toStdString(), envType.toStdString(), string((const char*)filePath.toLocal8Bit()), upFileMark.toStdString());
    }
}

UploadFileManager::~UploadFileManager()
{

}

int UploadFileManager::upLoadFileToServer(QString upFileMark, QString filePath, QString lessonId, QString userId, QString token, QString enType, int time_out, QString httpUrl, QString appVersion, QString apiVersion)
{
    YMUpLoadFileToOss(userId, enType, filePath, upFileMark);// 兼容老版本接口
    return 0;
}

int UploadFileManager::YMUpLoadFileToOss(const QString& userId, const QString& envType, const QString& filePath, const QString& upFileMark)
{
    QJsonObject basicParamsObj;
    basicParamsObj.insert("filePath", filePath);
    basicParamsObj.insert("userId", userId);
    basicParamsObj.insert("enType", envType);
    basicParamsObj.insert("upFileMark", upFileMark);

    YMUpLoadFileManager* ymUpLoadFileManager = new YMUpLoadFileManager();
    connect(ymUpLoadFileManager, SIGNAL(sigUploadSuccess(QString,long,QString)), this, SIGNAL(sigUploadSuccess(QString,long,QString)));
    connect(ymUpLoadFileManager, SIGNAL(sigUploadFailed(QString,QString)), this, SIGNAL(sigUploadFailed(QString,QString)));
    connect(ymUpLoadFileManager, SIGNAL(sigUploadProgress(QString,QString,QString)), this, SIGNAL(sigUploadProgress(QString,QString,QString)));

    QEventLoop eventLoop;
    connect(ymUpLoadFileManager, SIGNAL(finished()), &eventLoop, SLOT(quit())); // 线程执行完成以后, 退出loop
    if(NULL != ymUpLoadFileManager)
    {
        ymUpLoadFileManager->setBasicParams(basicParamsObj);
        ymUpLoadFileManager->start();
    }
    eventLoop.exec();

    if(NULL != ymUpLoadFileManager)
    {
        ymUpLoadFileManager->stop();
        ymUpLoadFileManager->wait();
        disconnect(ymUpLoadFileManager, SIGNAL(sigUploadSuccess(QString,long,QString)), this, SIGNAL(sigUploadSuccess(QString,long,QString)));
        disconnect(ymUpLoadFileManager, SIGNAL(sigUploadFailed(QString,QString)), this, SIGNAL(sigUploadFailed(QString,QString)));
        disconnect(ymUpLoadFileManager, SIGNAL(sigUploadProgress(QString,QString,QString)), this, SIGNAL(sigUploadProgress(QString,QString,QString)));
        delete ymUpLoadFileManager;
        ymUpLoadFileManager = NULL;
    }

    return 0;
}

