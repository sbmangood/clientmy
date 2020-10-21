#ifndef IPCMSGHANDLER_H
#define IPCMSGHANDLER_H
#include "../../pc-common/yimiIPC/ihandlemsg.h"

class IpcMsgHandler : public IHandleMsg
{
public:
    IpcMsgHandler();
    void handle(const QString &msg);
};

#endif // IPCMSGHANDLER_H
