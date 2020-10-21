#include "NetworkService.h"

#include "comm/projdef.h"
#include "baseevent/base_logic.h"
#include "stn/stn_logic.h"
#include "stnproto_logic.h"
#include "stn_callback.h"
#include "app_callback.h"

#include <windows.h>

using namespace std;

NetworkService& NetworkService::Instance()
{
	static NetworkService instance_;
	return instance_;
}

NetworkService::NetworkService()
{
	__Init();
}

NetworkService::~NetworkService()
{
}

void NetworkService::setClientVersion(uint32_t _client_version)
{
	mars::stn::SetClientVersion(_client_version);
}

void NetworkService::setClientLocalDnsIPs(std::vector<std::string> _iplist)
{
    iplist_ = _iplist;
}

std::vector<std::string> NetworkService::getClientLocalDnsIPs()
{
    return iplist_;
}

void NetworkService::setShortLinkDebugIP(const std::string& _ip, unsigned short _port)
{
	mars::stn::SetShortlinkSvrAddr(_port, _ip);
}

void NetworkService::setShortLinkPort(unsigned short _port)
{
	mars::stn::SetShortlinkSvrAddr(_port, "");
}

void NetworkService::setLongLinkAddress(const std::string& _ip, unsigned short _port, const std::string& _debug_ip)
{
	vector<uint16_t> ports;
	ports.push_back(_port);
	
	mars::stn::SetLonglinkSvrAddr(_ip, ports, _debug_ip);
}

void NetworkService::setBackupSvrAddr(const std::string& _host, std::vector<std::string> _iplist)
{
    mars::stn::SetBackupIPs(_iplist);
}

void NetworkService::OnState(uint32_t _callbackid, int _status)
{
    auto it = map_state_observer_.find(_callbackid);
    if (it != map_state_observer_.end() && it->second)
        it->second->OnState(_status);
}

void NetworkService::start()
{
	mars::baseevent::OnForeground(true);
	mars::stn::MakesureLonglinkConnected();
}

void NetworkService::destroy()
{
    mars::baseevent::OnDestroy();
}

void NetworkService::__Init()
{
	mars::stn::SetCallback(mars::stn::StnCallBack::Instance());
    mars::app::SetCallback(mars::app::ClientCallBack::Instance());
	
	mars::baseevent::OnCreate();
}

int NetworkService::startTask(CommTask* task)
{
    if (NULL == task) return 0;

	mars::stn::Task ctask;
	ctask.cmdid = task->cmdid_;
	ctask.channel_select = task->channel_select_;
    ctask.send_only = true;
	ctask.shortlink_host_list.push_back(task->host_);
	ctask.cgi = task->cgi_;
	ctask.user_context = (void*)task;
	mars::stn::StartTask(ctask);
	map_task_[ctask.taskid] = task;
	return ctask.taskid;
}

bool NetworkService::Req2Buf(uint32_t _taskid, void* const _user_context, AutoBuffer& _outbuffer, AutoBuffer& _extend, int& _error_code, const int _channel_select)
{
	auto it = map_task_.find(_taskid);
    if (it == map_task_.end()) return false;
    if( it->second )
       return it->second->Req2Buf(_taskid, _user_context, _outbuffer, _extend, _error_code, _channel_select);
    else
       return false;

}

int NetworkService::Buf2Resp(uint32_t _taskid, void* const _user_context, const AutoBuffer& _inbuffer, const AutoBuffer& _extend, int& _error_code, const int _channel_select)
{
	auto it = map_task_.find(_taskid);
    if (it == map_task_.end()) return mars::stn::kTaskFailHandleDefault;
    if (it->second)
      return it->second->Buf2Resp(_taskid, _user_context, _inbuffer, _extend, _error_code, _channel_select);
    else
      return mars::stn::kTaskFailHandleDefault;
}

int NetworkService::OnTaskEnd(uint32_t _taskid, void* const _user_context, int _error_type, int _error_code)
{
	auto it = map_task_.find(_taskid);
	if (it != map_task_.end())
	{
		delete it->second;
		map_task_.erase(it);
	}
	
	return 0;
}

void NetworkService::OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend)
{
    auto it = map_push_observer_.find(_cmdid);
    if (it != map_push_observer_.end() && it->second)
		it->second->OnPush(_channel_id, _cmdid, _taskid, _body, _extend);
}

void NetworkService::setPushObserver(uint32_t _cmdid, PushObserver* _observer)
{
    map_push_observer_[_cmdid] = _observer;
}

void NetworkService::setStateObserver(uint32_t _callbackid, StateObserver* _observer)
{
    map_state_observer_[_callbackid] = _observer;
}
