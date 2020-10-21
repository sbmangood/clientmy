#include <QCoreApplication>
#include "../../pc-common/yimibreakpad/yimibreakpad.h"
#include "../../pc-common/yimiIPC/ipcserver.h"
#include "ipcmsghandler.h"
#include "signalhandler.h"
#include "onsignalhandler.h"

SignalHandler g_sigHand;
int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    //启动服务端监控
    yimi_fudao_breakpad::Yimibreakpad::gestance()->monitorProcessServer();
    //启动进程服务端
    IpcMsgHandler *imh(new IpcMsgHandler);
    IpcServer *iserver(new IpcServer("server-listen",imh));
    OnSignalHandler st;
    QObject::connect(&g_sigHand,&SignalHandler::open,&st,&OnSignalHandler::onRecieve);
    return a.exec();
}
