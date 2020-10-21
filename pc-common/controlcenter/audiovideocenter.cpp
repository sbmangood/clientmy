/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  audio video center.cpp
 *  Description: audio video center class
 *
 *  Author: ccb
 *  Date: 2019/07/31 13:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/07/31    V4.5.1       创建文件
*******************************************************************************/

#include <QPluginLoader>
#include "audiovideocenter.h"
#include "./curriculumdata.h"
#include "getoffsetimage.h"
#include "messagepack.h"
#include "messagetype.h"
#include "datamodel.h"

AudioVideoCenter::AudioVideoCenter(QObject *parent)
    :QObject(parent)
    ,m_IAudioVideoCtrl(nullptr)
{

}

AudioVideoCenter::~AudioVideoCenter()
{
    uninit();
}

void AudioVideoCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("YMAudioVideoManager.dll", Qt::CaseInsensitive))
    {
        QObject* instance = loadPlugin(pluginPathName);
        if(instance)
        {
            m_IAudioVideoCtrl = qobject_cast<IAudioVideoCtrl *>(instance);
            if(nullptr == m_IAudioVideoCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(instance);
                return;
            }
            connect(m_IAudioVideoCtrl,SIGNAL(renderVideoFrameImage(uint,QImage,int)), this,SIGNAL(renderVideoFrameImage(uint,QImage,int)));
            connect(m_IAudioVideoCtrl, SIGNAL(sigJoinOrLeaveRoom(uint,int)),this,SLOT(slotJoinroom(uint,int)));
            qDebug()<< "qobject_cast is success, pluginPathName is" << pluginPathName;
        }
        else
        {
            qCritical()<< "load plugin is failed, pluginPathName is" << pluginPathName;
        }
    }
    else
    {
        qWarning()<< "plugin is invalid, pluginPathName is" << pluginPathName;
    }

}

void AudioVideoCenter::uninit()
{
    if(m_IAudioVideoCtrl)
    {
//        unloadPlugin((QObject*)m_IAudioVideoCtrl);
//        m_IAudioVideoCtrl = nullptr;
    }
}

void AudioVideoCenter::initVideoChancel()// 初始化频道
{
    changeChanncel();
}

void AudioVideoCenter::changeChanncel()// 切换频道
{
    DataCenter::getInstance()->m_supplier = TemporaryParameter::gestance()->m_supplier;
    CHANNEL_TYPE currentChannel;
    if(DataCenter::getInstance()->m_supplier == "1")
    {
        currentChannel = CHANNEL_A;
    }
    else if(DataCenter::getInstance()->m_supplier == "2")
    {
        currentChannel = CHANNEL_B;
    }
    else if(DataCenter::getInstance()->m_supplier == "3")
    {
        currentChannel = CHANNEL_C;
    }
    DataCenter::getInstance()->m_videoType =  TemporaryParameter::gestance()->m_videoType;
    DataCenter::getInstance()->m_microphoneState =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId);
    DataCenter::getInstance()->m_cameraState = StudentData::gestance()->m_camera;
    DataCenter::getInstance()->m_role = TEACHER;
    DataCenter::getInstance()->m_userId = StudentData::gestance()->m_agoraUid;
    DataCenter::getInstance()->m_lessonId = StudentData::gestance()->m_lessonId;
    DataCenter::getInstance()->m_apiVersion = StudentData::gestance()->m_apiVersion;
    DataCenter::getInstance()->m_appVersion = StudentData::gestance()->m_appVersion;
    DataCenter::getInstance()->m_token = StudentData::gestance()->m_token;
    DataCenter::getInstance()->m_strSpeaker = getDefaultDevicesId("player_device_name");
    DataCenter::getInstance()->m_strMicPhone = getDefaultDevicesId("recorder_device_name");;
    DataCenter::getInstance()->m_strCamera = getDefaultDevicesId("carmer");
    DataCenter::getInstance()->m_strDllFile = StudentData::gestance()->strAppFullPath;
    DataCenter::getInstance()->m_strAppName = StudentData::gestance()->strAppName;
    DataCenter::getInstance()->m_channelKey = StudentData::gestance()->m_agoraChannelKey;
    DataCenter::getInstance()->m_channelName = StudentData::gestance()->m_agoraChannelName;
    int videoSpan = 0;

//    qDebug()<<"DataCenter::getInstance()->m_videoType="<<m_videoType<<",m_microphoneState"<<m_microphoneState<<",m_cameraState="<<m_cameraState
//            <<",m_userId="<<m_userId<<",m_lessonId="<<m_lessonId<<",m_apiVersion="<<m_apiVersion<<",m_appVersion="<<m_appVersion<<",m_token="<<m_token
//            <<",m_strDllFile="<<m_strDllFile<<",m_strAppName="<<m_strAppName<<",strAgoraFullPath_LogFile="<<StudentData::gestance()->strAgoraFullPath_LogFile
//            <<",m_strSpeaker="<<m_strSpeaker<<",m_strMicPhone="<<m_strMicPhone<<",m_strCamera="<<m_strCamera<<",m_cameraPhone="<<StudentData::gestance()->m_cameraPhone
//            <<",m_channelKey="<<m_channelKey<<",m_channelName="<<m_channelName;

    if(NULL != m_IAudioVideoCtrl)
    {
        m_IAudioVideoCtrl->changeChanncel(currentChannel, DataCenter::getInstance()->m_videoType, DataCenter::getInstance()->m_microphoneState, DataCenter::getInstance()->m_cameraState,
                                          DataCenter::getInstance()->m_role, DataCenter::getInstance()->m_userId, DataCenter::getInstance()->m_lessonId, DataCenter::getInstance()->m_apiVersion, DataCenter::getInstance()->m_appVersion, DataCenter::getInstance()->m_token,
                                          DataCenter::getInstance()->m_strDllFile, DataCenter::getInstance()->m_strAppName, StudentData::gestance()->strAgoraFullPath_LogFile,
                                          DataCenter::getInstance()->m_strSpeaker, DataCenter::getInstance()->m_strMicPhone, DataCenter::getInstance()->m_strCamera, StudentData::gestance()->m_cameraPhone,
                                          videoSpan, DataCenter::getInstance()->m_channelKey, DataCenter::getInstance()->m_channelName, SMALL_GROUP);
    }
}

void AudioVideoCenter::closeAudio(QString status)// 关闭音频
{
    if(NULL != m_IAudioVideoCtrl)
    {
        if(status == "0")
        {
            m_IAudioVideoCtrl->closeLocalAudio();
        }
        else
        {
            m_IAudioVideoCtrl->openLocalAudio();
        }
    }
}

void AudioVideoCenter::closeVideo(QString status)// 关闭视频
{
    if(NULL != m_IAudioVideoCtrl)
    {
        if(status == "0")
        {
            m_IAudioVideoCtrl->closeLocalVideo();
        }
        else
        {
            m_IAudioVideoCtrl->openLocalVideo();
        }
    }
}

void AudioVideoCenter::setStayInclassroom()// 设置留在教室
{
    if(NULL != m_IAudioVideoCtrl)
    {
        m_IAudioVideoCtrl->setStayInclassroom();
    }
}

void AudioVideoCenter::exitChannel()
{
    if(NULL != m_IAudioVideoCtrl)
    {
        m_IAudioVideoCtrl->exitChannel();
    }
}

void AudioVideoCenter::slotJoinroom(unsigned int uid, int status)
{
    qDebug() << "===sloJoinroom==" << uid << status;
    for(int i = 0; i < StudentData::gestance()->m_student.count(); i++)
    {
        if(StudentData::gestance()->m_student.at(i).m_uid == uid)
        {
            StudentData::gestance()->m_student[i].m_isVideo = "1";
            QString userId = StudentData::gestance()->m_student[i].m_studentId;
            StudentData::gestance()->insertIntoOnlineId(userId);
            emit sigJoinroom(uid,userId,status);
            qDebug() << "=====uids=====" << uid << userId << StudentData::gestance()->m_student[i].m_isVideo;
            break;
        }
    }
}

QString AudioVideoCenter::getDefaultDevicesId(QString deviceKey)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString systemPublicFilePath;
    QDir dir;
    if (docPath == "" || !dir.exists(docPath)) //docPath是空, 或者不存在
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    systemPublicFilePath += "/YiMi/temp/";
    QDir isDir;
    // 设置顶端配置路径
    if (!isDir.exists(systemPublicFilePath))
    {
        isDir.mkpath(systemPublicFilePath);
        return "";
    }
    QSettings deviceSetting(systemPublicFilePath + "deviceInfo.dll", QSettings::IniFormat);
    deviceSetting.setIniCodec(QTextCodec::codecForName("UTF-8"));
    deviceSetting.beginGroup("Device");
    return deviceSetting.value(deviceKey).toString();
}


QObject* AudioVideoCenter::loadPlugin(const QString &pluginPath)
{
    QObject *plugin = nullptr;
    QFile file(pluginPath);
    if (!file.exists())
    {
        qWarning()<< pluginPath<< "file is not file";
        return plugin;
    }

    QPluginLoader loader(pluginPath);
    plugin = loader.instance();
    if (nullptr == plugin)
    {
        qCritical()<< pluginPath<< "failed to load plugin" << loader.errorString();
    }

    return plugin;
}

void AudioVideoCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}

