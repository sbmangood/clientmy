#include "getsysdevinfos.h"

#include <QDebug>

#include <Windows.h>
#include <setupapi.h>
#include <QRegExp>
#include <QStringList>
#include <Cfgmgr32.h>

//获取USB设备的信息, 主要是为了获取磐度手写板的硬件ID, VID号, 从而判断, 目前是否需要定时的load磐度的驱动
#pragma comment(lib, "Setupapi.lib")
#define INTERFACE_DETAIL_SIZE   (1024)

GetSysDevInfos::GetSysDevInfos(QObject *parent) :
    QObject(parent)
{
}

int GetSysDevInfos::GetPCIDeviceInfos(QList<PCI_INFO> &infos)
{
    infos.clear();

    bool ok;
    QString str;
    PCI_INFO info;
    HDEVINFO hDevInfo;
    SP_DEVINFO_DATA DeviceInfoData;
    WCHAR buffer[INTERFACE_DETAIL_SIZE] = { 0 };

    SP_DEVICE_INTERFACE_DATA DeviceInterfaceData;
    DeviceInterfaceData.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

    if ((hDevInfo = SetupDiGetClassDevs(NULL, L"PCI", 0, DIGCF_PRESENT | DIGCF_ALLCLASSES)) == INVALID_HANDLE_VALUE){
        // Insert error handling here.
        return 0;
    }

    DeviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

    // 设备序号=0,1,2... 逐一测试设备接口，到失败为止
    for (int i = 0; SetupDiEnumDeviceInfo(hDevInfo, i,
                                          &DeviceInfoData); i++)
    {
        DWORD DataT;
        DWORD buffersize = 0;


        if(!SetupDiGetDeviceRegistryProperty(
                    hDevInfo,
                    &DeviceInfoData,
                    SPDRP_HARDWAREID,
                    &DataT,
                    (PBYTE)buffer,
                    INTERFACE_DETAIL_SIZE,
                    &buffersize))
        {
            continue;
        }

        str = QString::fromWCharArray(buffer, wcslen(buffer));
        info.vid = str.mid(str.indexOf("VEN") + 4, 4).toULong(&ok, 16);
        info.pid = str.mid(str.indexOf("DEV") + 4, 4).toULong(&ok, 16);


        memset(buffer, 0, INTERFACE_DETAIL_SIZE);
        if (!SetupDiGetDeviceRegistryProperty(
                    hDevInfo,
                    &DeviceInfoData,
                    SPDRP_LOCATION_INFORMATION,
                    &DataT,
                    (PBYTE)buffer,
                    INTERFACE_DETAIL_SIZE,
                    &buffersize))
        {
            continue;
        }
        QStringList list;
        str = QString::fromWCharArray(buffer);
        QRegExp rx("(\\d+)");
        int pos = 0;

        while ((pos = rx.indexIn(str, pos)) != -1) {
            list << rx.cap(1);
            pos += rx.matchedLength();
        }
        info.busNum = list.at(0).toULong(&ok, 10);
        info.devNum = list.at(1).toULong(&ok, 10);
        info.funcNum = list.at(2).toULong(&ok, 10);

        memset(buffer, 0, INTERFACE_DETAIL_SIZE);
        if (!SetupDiGetDeviceRegistryProperty(
                    hDevInfo,
                    &DeviceInfoData,
                    SPDRP_DEVICEDESC,
                    &DataT,
                    (PBYTE)buffer,
                    INTERFACE_DETAIL_SIZE,
                    &buffersize))
        {
            continue;
        }
        info.desc = QString::fromWCharArray(buffer);

        ULONG pulStatus;
        ULONG pulProblemNumber;
        CM_Get_DevNode_Status(&pulStatus, &pulProblemNumber, DeviceInfoData.DevInst, 0);

        if((pulStatus & DN_HAS_PROBLEM) && !(pulStatus & DN_DRIVER_LOADED))
        {
            info.enable = false;
        }else
        {
            info.enable = true;
        }

        infos.append(info);
    }

    //  Cleanup
    SetupDiDestroyDeviceInfoList(hDevInfo);

    return 0;
}

int GetSysDevInfos::GetUSBDeviceInfos(QList<USB_INFO> &infos, int iVid)
{
    infos.clear();

    //函数返回结果
    int iResult = 0;

    bool ok;
    QString str;
    USB_INFO info;
    HDEVINFO hDevInfo;
    SP_DEVINFO_DATA DeviceInfoData;
    WCHAR buffer[INTERFACE_DETAIL_SIZE] = { 0 };

    if ((hDevInfo = SetupDiGetClassDevs(NULL, L"USB", 0, DIGCF_PRESENT | DIGCF_ALLCLASSES)) == INVALID_HANDLE_VALUE){
        // Insert error handling here.
        return iResult;
    }

    DeviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

    // 设备序号=0,1,2... 逐一测试设备接口，到失败为止
    for (int i = 0; SetupDiEnumDeviceInfo(hDevInfo, i,
                                          &DeviceInfoData); i++)
    {
        DWORD DataT;
        DWORD buffersize = 0;
        if(!SetupDiGetDeviceRegistryProperty(
                    hDevInfo,
                    &DeviceInfoData,
                    SPDRP_HARDWAREID,
                    &DataT,
                    (PBYTE)buffer,
                    INTERFACE_DETAIL_SIZE,
                    &buffersize))
        {
            continue;
        }

        str = QString::fromWCharArray(buffer, wcslen(buffer));
        info.vid = str.mid(str.indexOf("VID") + 4, 4).toULong(&ok, 16);
        if(info.vid == iVid)
        {
            iResult = 1;
        }

//        qDebug("GetSysDevInfos::GetUSBDeviceInfos: %04X", info.vid);
        info.pid = str.mid(str.indexOf("PID") + 4, 4).toULong(&ok, 16);

        memset(buffer, 0, INTERFACE_DETAIL_SIZE);
        if (!SetupDiGetDeviceRegistryProperty(
                    hDevInfo,
                    &DeviceInfoData,
                    SPDRP_DEVICEDESC,           // 设备描述信息
                    &DataT,
                    (PBYTE)buffer,
                    INTERFACE_DETAIL_SIZE,
                    &buffersize))
        {
            continue;
        }
        info.desc = QString::fromWCharArray(buffer);

        memset(buffer, 0, INTERFACE_DETAIL_SIZE);
        if (!SetupDiGetDeviceRegistryProperty(
                    hDevInfo,
                    &DeviceInfoData,
                    SPDRP_MFG,          // 制造商
                    &DataT,
                    (PBYTE)buffer,
                    INTERFACE_DETAIL_SIZE,
                    &buffersize))
        {
            continue;
        }
        info.manufacturer = QString::fromWCharArray(buffer);

        ULONG pulStatus;
        ULONG pulProblemNumber;
        CM_Get_DevNode_Status(&pulStatus, &pulProblemNumber, DeviceInfoData.DevInst, 0);

        if((pulStatus & DN_HAS_PROBLEM) && !(pulStatus & DN_DRIVER_LOADED))
        {
            info.enable = false;
        }else
        {
            info.enable = true;
        }

        infos.append(info);
    }

    //  Cleanup
    SetupDiDestroyDeviceInfoList(hDevInfo);

    return iResult;
}
