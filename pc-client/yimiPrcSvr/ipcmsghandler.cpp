#include "ipcmsghandler.h"
#include "signalhandler.h"
extern SignalHandler g_sigHand;
IpcMsgHandler::IpcMsgHandler()
{

}

void IpcMsgHandler::handle(const QString &msg){

   printf("handle msg:%s\n",qPrintable(msg));
   g_sigHand.EmitSignal(msg);
}
