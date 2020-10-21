#include "panduwriteboard.h"
#include <QString>
#include <Windows.h>
#include "dataconfig/datahandl/datamodel.h"

typedef int ( WINAPI* PconnectMouse )();
typedef int ( WINAPI* PdisConnectMouse )();

typedef void ( WINAPI* PBreakConnected)();

#define PAN_DU_VID_NUMBER 0x2D80

//HINSTANCE hDll;
PconnectMouse connectMouse;
PdisConnectMouse disconnectMouse;
PBreakConnected breakConnected;

typedef void(WINAPI *PSetCallBackForbreakConnected)(PBreakConnected CallBackfun);
PSetCallBackForbreakConnected setCallBackForbreakConnected;

typedef void(WINAPI *PCallBackForButton)(int iButtonValue);
typedef void(WINAPI *PSetCallBackForButton)(PCallBackForButton CallBackfun);

typedef void(WINAPI *PCallBackForMouseData)(int x, int y, int preasure, int length, int weight);
typedef void(WINAPI *PSetCallBackForMouseData)(PCallBackForMouseData CallBackfun);

PSetCallBackForButton setCallBackForButton;
PSetCallBackForMouseData setCallBackForMouseData;
static int g_iCode = -10; //手写板连接状态的返回值

void WINAPI callBackForButton(int buttonValue)
{
    ClickClass::gestance()->clickSignal();
}

void WINAPI callBackForMouseData(int x, int y, int preasure, int length, int weight)
{
    //qDebug()<<"callBackForMouseData:"<< "x:"<<x<<"y:"<<y;//<<deviceBleMac<<deviceBleName;
}

void WINAPI callBackForbreakConnected()
{
    //    qDebug()<<"callBackForbreakConnected";
    ClickClass::gestance()->breakConnect();
}

PanDuWriteBoard::PanDuWriteBoard(QObject *parent) : QObject(parent)
{
    //得到dll文件的绝对路径
    QString strDllFile = StudentData::gestance()->strAppFullPath;
    strDllFile = strDllFile.replace(StudentData::gestance()->strAppName, "DigitNoteUSBController.dll"); //得到dll文件的绝对路径
    qDebug() << "PanDuWriteBoard::PanDuWriteBoard: " << qPrintable(strDllFile);

    panDuLib = new QLibrary(strDllFile, this);
    tempTime = QTime::currentTime();
    clickTimer = new QTimer(this);
    clickTimer->setInterval(500);
    clickTimer->setSingleShot(true);
    reconnectTimer = new QTimer(this);
    reconnectTimer->setInterval(5000);
    connect(clickTimer, SIGNAL(timeout()), this, SLOT(onWriteBoardClick()));
    connect(ClickClass::gestance(), SIGNAL(clickSignal()), this, SLOT(dealClickEvent()));
    connect(ClickClass::gestance(), SIGNAL(breakConnect()), this, SLOT(onBreakConnect()));
    connect(reconnectTimer, SIGNAL(timeout()), this, SLOT(reconnectSlots()));

    pObjThreadReconnect = new PanDuConnectThead(); //起一个线程, 用于: 在上课过程中, 重连手写板(因为影响到画布上写字了, connectWriteBoard 阻塞了, 引起画布写字卡顿)
    //disconectWriteBoard();
    connectWriteBoard();
}

//检测磐度手写板, 是否连接PC了
bool PanDuWriteBoard::doCheckPanDu_USB_Device()
{
//    qDebug() << "PanDuWriteBoard::doCheckPanDu_USB_Device" << __LINE__;

    //获取USB设备信息
    QList<USB_INFO> infos;
    if(m_objGetUSBDeviceInfo.GetUSBDeviceInfos(infos, PAN_DU_VID_NUMBER) == 1)
    {
        qDebug() << "PanDuWriteBoard::doCheckPanDu_USB_Device true" << __LINE__;
        return true;
    }

    //减少打印信息
    static int i = 0;
    if((i % 20) == 0)
    {
        qDebug() << "PanDuWriteBoard::doCheckPanDu_USB_Device false" << __LINE__;
    }

    i++;

    return false;
}

PanDuWriteBoard::~PanDuWriteBoard()
{
    disconectWriteBoard();
    pObjThreadReconnect->wait();
}

int PanDuWriteBoard::connectWriteBoard()
{
    int code = -10;

    //如果没有检测到磐度手写板
    if(!doCheckPanDu_USB_Device())
    {
        if(!reconnectTimer->isActive())
        {
            reconnectTimer->start(); //启动定时器
        }

        return code;
    }

    if(panDuLib->load())
    {
        //====================================================
        //qDebug() << "PanDuWriteBoard::PanDuWriteBoard panDuLib->load success" << __LINE__;
        setCallBackForMouseData = (PSetCallBackForMouseData)panDuLib->resolve("_SetCallBackForMouseData@4");
        if(setCallBackForMouseData)
        {
            setCallBackForMouseData((PCallBackForMouseData)callBackForMouseData);
        }

        setCallBackForButton = (PSetCallBackForButton)panDuLib->resolve("_SetCallBackForMouseButton@4");
        if(setCallBackForButton)
        {
            setCallBackForButton((PCallBackForButton)callBackForButton);
            //            qDebug()<<"setCallBackForButton ";
        }

        setCallBackForbreakConnected = (PSetCallBackForbreakConnected)panDuLib->resolve("_SetCallBackForBreakConnected@4");
        if(setCallBackForbreakConnected)
        {
            setCallBackForbreakConnected( (PBreakConnected)callBackForbreakConnected );
        }

        //====================================================
        //判断手写板是否连接了
        connectMouse = (PconnectMouse)panDuLib->resolve("_connectMouse@0");
        if(connectMouse)
        {
            code = connectMouse();
            //qDebug()<<"PanDuConnectThead::connectWriteBoard" << __LINE__ << code;
            if(code == 0)
            {
                //连接成功
                emit connectWriteBoardStatus(0);

                if(reconnectTimer->isActive())
                {
                    reconnectTimer->stop();
                    qDebug()<<"PanDuConnectThead::connectWriteBoard reconnectTimer->stop" << __LINE__ << code;
                }
            }
            else
            {
                //没有连接
                emit connectWriteBoardStatus(-1);

                if(!reconnectTimer->isActive())
                {
                    reconnectTimer->start();
                    //qDebug()<<"PanDuConnectThead::connectWriteBoard reconnectTimer->start" << __LINE__ << code;
                }
            }
        }
        else
        {
            emit connectWriteBoardStatus(-1);
        }
    }
    else
    {
        qDebug() << "PanDuWriteBoard::connectWriteBoard panDuLib->load() failed." << __LINE__;
    }

    //    qDebug()<<"PanDuWriteBoard::connectWriteBoard("<<code;

    return code;
}

int PanDuWriteBoard::disconectWriteBoard()
{
    if(panDuLib->load())
    {
        disconnectMouse = (PdisConnectMouse)panDuLib->resolve("_disconnectMouse@0");
        if(disconnectMouse)
        {
            int code =  disconnectMouse();
            if(code == 0)
            {
                emit connectWriteBoardStatus(1);
            }
            else
            {
                emit connectWriteBoardStatus(2);
            }
        }
        else
        {
            emit connectWriteBoardStatus(2);
        }
    }
    else
    {
        qDebug() << "PanDuWriteBoard::disconectWriteBoard panDuLib->load() failed." << __LINE__;
    }

    return -1;
}

void PanDuWriteBoard::dealClickEvent()
{
    //qDebug()<<"callBackForButton";
    int s = tempTime.elapsed();
    if( s < 500 )
    {
        clickTimer->stop();
        if(hasClick)
        {

            isDoubleClick = true;
            writeBoardDoubleClick();
            //            qDebug()<<"click twos";
            hasClick = false;
        }
    }
    else
    {
        hasClick = false;
        clickTimer->start();
        hasClick = !hasClick;
    }
    tempTime.restart();

}

void PanDuWriteBoard::onWriteBoardClick()
{
    //    qDebug()<<" click ones ";
    hasClick = false;
    isDoubleClick = false;
    emit writeBoardClick();
}

//拔除手写板的信号
void PanDuWriteBoard::onBreakConnect()
{
    //拔除手写板以后, 重新开始检测磐度手写板
    reconnectTimer->start();
    g_iCode = -10;

    //非主动断开信号, 提示Tool Tips: "溢米手写板连接断开"
    connectWriteBoardStatus(3);
}

void PanDuWriteBoard::reconnectSlots()
{
//    qDebug() << "PanDuWriteBoard::reconnectSlots" << g_iCode << __LINE__;
    if(g_iCode == 0)
    {
        reconnectTimer->stop();
    }
    else
    {
        pObjThreadReconnect->start();
    }

    //disconectWriteBoard();
#if 0
    if(panDuLib->load())
    {
        //        qDebug()<<"panDuLib->loadssssss";
        setCallBackForMouseData = (PSetCallBackForMouseData)panDuLib->resolve("_SetCallBackForMouseData@4");
        if(setCallBackForMouseData)
        {
            setCallBackForMouseData((PCallBackForMouseData)callBackForMouseData);
        }
        setCallBackForButton = (PSetCallBackForButton)panDuLib->resolve("_SetCallBackForMouseButton@4");
        if(setCallBackForButton)
        {
            setCallBackForButton((PCallBackForButton)callBackForButton);
            //            qDebug()<<"setCallBackForButton ";
        }
        setCallBackForbreakConnected = (PSetCallBackForbreakConnected)panDuLib->resolve("_SetCallBackForBreakConnected@4");
        if(setCallBackForbreakConnected)
        {
            setCallBackForbreakConnected( (PBreakConnected)callBackForbreakConnected );
        }

    }
    else
    {
        qDebug() << "PanDuWriteBoard::reconnectSlots panDuLib->load() failed." << __LINE__;
    }


    if( 0 == connectWriteBoard())
    {
        //        pObjThreadReconnect->terminate();
        qDebug() << "PanDuWriteBoard::reconnectSlots" << __LINE__;
        //        reconnectTimer->stop();
    }
#endif
}


//    hDll = LoadLibrary(("DigitNoteUSBController.dll"));
//if (hDll != NULL)
//{
//    setCallBackForMouseData = (PSetCallBackForMouseData)GetProcAddress(hDll, "_SetCallBackForMouseData@4");
//    if(setCallBackForMouseData)
//    {
//        setCallBackForMouseData((PCallBackForMouseData)callBackForMouseData);
//    }

//    setCallBackForButton = (PSetCallBackForButton)GetProcAddress(hDll, "_SetCallBackForMouseButton@4");
//    if(setCallBackForButton)
//    {
//        setCallBackForButton((PCallBackForButton)callBackForButton);
//        qDebug()<<"setCallBackForButton ";
//    }

//    connectMouse = (PconnectMouse)GetProcAddress(hDll, "_connectMouse@0");
//    if (!connectMouse)
//    {
//        qDebug()<<"Handle to connectMouse fail";
//    }else
//    {
//        int ret = connectMouse();
//        qDebug()<<"Handle to connectMouse success"<<ret;
//    }
//}else
//{
//    qDebug()<<"Handle to DLL  NUll";
//}

void PanDuConnectThead::run()
{
    g_iCode = PanDuWriteBoard::gestance()->connectWriteBoard();
//    qDebug()<<"PanDuConnectThead::run" << __LINE__ << g_iCode;
}

