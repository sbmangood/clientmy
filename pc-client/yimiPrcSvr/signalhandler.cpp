#include "signalhandler.h"

SignalHandler::SignalHandler(QObject *parent) : QObject(parent)
{

}

void SignalHandler::EmitSignal(QString msg){

    emit open(msg);
}
