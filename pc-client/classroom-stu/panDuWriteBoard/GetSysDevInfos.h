#ifndef GETSYSDEVINFOS_H
#define GETSYSDEVINFOS_H

#include <QObject>
#include <QList>

typedef struct _pci_info{
    bool enable;		// 设备启用标志
    ulong busNum;		// 总线号
    ulong devNum;		// 设备号
    ulong funcNum;		// 功能号
    ulong vid;			// 产品ID
    ulong pid;			// 厂商ID
    QString desc;		// 设备描述信息

}PCI_INFO;

typedef struct _usb_info{
    bool enable;		// 设备启用标志	
    ulong vid;			// 产品ID
    ulong pid;			// 厂商ID

    QString desc;           // 设备描述信息
    QString manufacturer;   // 制造商信息

}USB_INFO;

class GetSysDevInfos : public QObject
{
    Q_OBJECT
public:
    explicit GetSysDevInfos(QObject *parent = 0);

    static int GetPCIDeviceInfos(QList<PCI_INFO> &infos);
    static int GetUSBDeviceInfos(QList<USB_INFO> &infos, int iVid);
    
};

#endif // GETSYSDEVINFOS_H
