#include "app_callback.h"
#include "comm/autobuffer.h"

namespace mars {
    namespace app {

ClientCallBack* ClientCallBack::instance_ = NULL;

ClientCallBack* ClientCallBack::Instance() {
    if(instance_ == NULL) {
        instance_ = new ClientCallBack();
    }
    
    return instance_;
}

void ClientCallBack::Release() {
    delete instance_;
    instance_ = NULL;
}

std::string ClientCallBack::GetAppFilePath(){
    return "";
}
        
AccountInfo ClientCallBack::GetAccountInfo() {
    AccountInfo info;

    return info;
}

unsigned int ClientCallBack::GetClientVersion() {
	unsigned int version = 0;
	
    return version;
}

DeviceInfo ClientCallBack::GetDeviceInfo() {
    DeviceInfo info;

    info.devicename = "Windows";
    info.devicetype = 1;
    
    return info;
}

}}
