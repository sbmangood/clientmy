#ifndef _MARS_SERVICE_PROXY_H_
#define _MARS_SERVICE_PROXY_H_
#include <queue>
#include <map>
#include <string>

#include "comm/autobuffer.h"

#include "CommTask.h"
#include "NetworkObserver.h"

const int kLongLinkStateCallbackId = 2001;

class NetworkService
{
public:
	static NetworkService& Instance();

    bool Req2Buf(uint32_t _taskid, void* const _user_context, AutoBuffer& _outbuffer, AutoBuffer& _extend, int& _error_code, const int _channel_select);
	int Buf2Resp(uint32_t _taskid, void* const _user_context, const AutoBuffer& _inbuffer, const AutoBuffer& _extend, int& _error_code, const int _channel_select);

    int OnTaskEnd(uint32_t _taskid, void* const _user_context, int _error_type, int _error_code);

    void OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend);

	void setClientVersion(uint32_t _client_version);

    void setClientLocalDnsIPs(std::vector<std::string> _iplist);
    std::vector<std::string> getClientLocalDnsIPs(void);

    void setShortLinkDebugIP(const std::string& _ip, unsigned short _port);

    void setShortLinkPort(unsigned short _port);

    void setLongLinkAddress(const std::string& _ip, unsigned short _port, const std::string& _debug_ip = "");
    void setBackupSvrAddr(const std::string& _host, std::vector<std::string> _iplist);

    void OnState(uint32_t _callbackid, int _status);

	void start();
    void destroy();

    int startTask(CommTask* task);

	void setPushObserver(uint32_t _cmdid, PushObserver* _observer);
    void setStateObserver(uint32_t _callbackid, StateObserver* _observer);

protected:
	NetworkService();
	~NetworkService();

	void __Init();

private:
    std::vector<std::string> iplist_;

    std::map<uint32_t, CommTask*> map_task_;

    std::map<uint32_t, StateObserver*> map_state_observer_;
    std::map<uint32_t, PushObserver*> map_push_observer_;
};

#endif
