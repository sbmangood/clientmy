#ifndef PANDUWRITEBOARD_H
#define PANDUWRITEBOARD_H

#include <QObject>
#include <QLibrary>

#include <QTime>
#include <Qtimer>
#include <QDebug>
#include <QThread>
#include "getsysdevinfos.h"

/*
磐度手写板 显示调用dll
进教室会主动连接手写板 如果断开链接 会主动重连 处理了按钮事件（进行翻页转换）
*/

class ClickClass: public QObject
{
    Q_OBJECT
public:
    virtual ~ClickClass()
    {

    }

    static ClickClass  * gestance()
    {
        static ClickClass * clickClass = new ClickClass();

        return clickClass;
    }

signals:
    void clickSignal();
    void breakConnect();
};

class PanDuConnectThead: public QThread
{
    Q_OBJECT

protected:
    void run();
};

class PanDuWriteBoard : public QObject
{
    Q_OBJECT
public:
    explicit PanDuWriteBoard(QObject *parent = 0);
    ~PanDuWriteBoard();

    static PanDuWriteBoard  * gestance()
    {
        static PanDuWriteBoard * writeBoard = new PanDuWriteBoard();
        return writeBoard;
    }

private:
    PanDuConnectThead *pObjThreadReconnect;
    QLibrary *panDuLib;
    QTime tempTime;
    QTimer *clickTimer;
    QTimer *reconnectTimer;
    bool isDoubleClick = false;
    bool canClick = true;
    bool hasClick = false;
signals:
    //链接手写板成功信号
    void connectWriteBoardStatus(int codes); // status = 0 为链接成功 -1 为链接失败  1 为主动断开链接成功 2为主动断开链接失败 3非主动断开链接

    //单击信号
    void writeBoardClick();
    //双击信号
    void writeBoardDoubleClick();

public slots:
    //处理点击事件
    void dealClickEvent();

    //  链接板子
    int connectWriteBoard();
    //  断开连接
    int disconectWriteBoard();

    //单击事件
    void onWriteBoardClick();

    //断开事件
    void onBreakConnect();

    //主动重连事件
    void reconnectSlots();

private:
    //判断当前PC是否连接磐度手写板了,
    //磐度手写板的VID号(十六进制), 是: 2D80, 是经过usb协会认证的
    bool doCheckPanDu_USB_Device();
    GetSysDevInfos m_objGetUSBDeviceInfo;
};

#endif // PANDUWRITEBOARD_H
