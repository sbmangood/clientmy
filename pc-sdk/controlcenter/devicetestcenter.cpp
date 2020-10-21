#include <QPluginLoader>
#include <QDebug>
#include <QJsonArray>
#include <QFile>
#include "devicetestcenter.h"

DeviceTestCenter::DeviceTestCenter(ControlCenter* controlCenter) : m_controlCenter(controlCenter), m_IDeviceTestCtrl(NULL)
{

}

DeviceTestCenter::~DeviceTestCenter()
{
    uninit();
}

void DeviceTestCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("YMDeviceTestManager.dll", Qt::CaseInsensitive))
    {
        QObject* instance = loadPlugin(pluginPathName);
        if(instance)
        {
            m_IDeviceTestCtrl = qobject_cast<IDeviceTestCtrl *>(instance);
            if(nullptr == m_IDeviceTestCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(instance);
                return;
            }
            connect(m_IDeviceTestCtrl, SIGNAL(netQuailty(int)), this, SIGNAL(netQuailty(int)));
            connect(m_IDeviceTestCtrl, SIGNAL(renderVideoImage(QString)), this, SIGNAL(renderVideoImage(QString)));
            connect(m_IDeviceTestCtrl, SIGNAL(carmeraReady()), this, SIGNAL(carmeraReady()));
            connect(m_IDeviceTestCtrl, SIGNAL(noCarmerDevices()), this, SIGNAL(noCarmerDevices()));
            connect(m_IDeviceTestCtrl, SIGNAL(speakerVolume(int,int)), this, SIGNAL(speakerVolume(int,int)));
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

void DeviceTestCenter::uninit()
{
    if(m_IDeviceTestCtrl)
    {
        //unloadPlugin((QObject*)m_IDeviceTestCtrl);
        m_IDeviceTestCtrl = NULL;
    }
    if(m_controlCenter)
    {
        m_controlCenter = NULL;
    }
}

QJsonArray DeviceTestCenter::getUserDeviceList(int type)
{
    QJsonArray arr;
    if(NULL != m_IDeviceTestCtrl)
    {
        arr = m_IDeviceTestCtrl->getUserDeviceList(type);
    }
    return arr;
}

void DeviceTestCenter::setCarmerDevice(QString deviceName)
{
    if(NULL != m_IDeviceTestCtrl)
    {
        m_IDeviceTestCtrl->setCarmerDevice(deviceName);
    }
}

void DeviceTestCenter::setPlayerDevice(QString deviceName)
{
    if(NULL != m_IDeviceTestCtrl)
    {
        m_IDeviceTestCtrl->setPlayerDevice(deviceName);
    }
}

void DeviceTestCenter::setRecorderDevice(QString deviceName)
{
    if(NULL != m_IDeviceTestCtrl)
    {
        m_IDeviceTestCtrl->setRecorderDevice(deviceName);
    }
}

void DeviceTestCenter::startOrStopAudioTest(bool isStart)
{
    if(NULL != m_IDeviceTestCtrl)
    {
        m_IDeviceTestCtrl->startOrStopAudioTest(isStart);
    }
}

void DeviceTestCenter::startOrStopVideoTest(bool isStart)
{
    if(NULL != m_IDeviceTestCtrl)
    {
        m_IDeviceTestCtrl->startOrStopVideoTest(isStart);
    }
}

void DeviceTestCenter::startOrStopNetTest(bool isStart)
{
    if(NULL != m_IDeviceTestCtrl)
    {
        m_IDeviceTestCtrl->startOrStopNetTest(isStart);
    }
}

void DeviceTestCenter::releaseDevice()
{
    if(NULL != m_IDeviceTestCtrl)
    {
        m_IDeviceTestCtrl->releaseDevice();
    }
}

QObject* DeviceTestCenter::loadPlugin(const QString &pluginPath)
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

void DeviceTestCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}
