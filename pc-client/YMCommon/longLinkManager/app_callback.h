#ifndef appcomm_callback_h
#define appcomm_callback_h

#include "app/app.h"
#include "app/app_logic.h"

namespace mars {
    namespace app {

class ClientCallBack : public Callback {
    
private:
    ClientCallBack() {}
    ~ClientCallBack() {}
    ClientCallBack(ClientCallBack&);
    ClientCallBack& operator = (ClientCallBack&);
    
    
public:
    static ClientCallBack* Instance();
    static void Release();
    
    virtual std::string GetAppFilePath();
    virtual AccountInfo GetAccountInfo();
    virtual unsigned int GetClientVersion();
    virtual DeviceInfo GetDeviceInfo();
    
private:
    static ClientCallBack* instance_;
};
        
}}

#endif /* appcomm_callback_h */
