#include "stn_callback.h"

#include "comm/autobuffer.h"
#include "xlog/xlogger.h"
#include "stn/stn.h"
#include "NetworkService.h"

namespace mars {
    namespace stn {
        
StnCallBack* StnCallBack::instance_ = NULL;
        
StnCallBack* StnCallBack::Instance() {
    if(instance_ == NULL) {
        instance_ = new StnCallBack();
    }
    
    return instance_;
}
        
void StnCallBack::Release() {
    delete instance_;
    instance_ = NULL;
}
        
bool StnCallBack::MakesureAuthed() {
    return true;
}


void StnCallBack::TrafficData(ssize_t _send, ssize_t _recv) {
    xdebug2(TSF"send:%_, recv:%_", _send, _recv);
}
        
std::vector<std::string> StnCallBack::OnNewDns(const std::string& _host) {
    return NetworkService::Instance().getClientLocalDnsIPs();
}

void StnCallBack::OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend) {
    NetworkService::Instance().OnPush(_channel_id, _cmdid, _taskid, _body, _extend);
}

bool StnCallBack::Req2Buf(uint32_t _taskid, void* const _user_context, AutoBuffer& _outbuffer, AutoBuffer& _extend, int& _error_code, const int _channel_select) {
	return NetworkService::Instance().Req2Buf(_taskid, _user_context, _outbuffer, _extend, _error_code, _channel_select);
}

int StnCallBack::Buf2Resp(uint32_t _taskid, void* const _user_context, const AutoBuffer& _inbuffer, const AutoBuffer& _extend, int& _error_code, const int _channel_select) {
	return NetworkService::Instance().Buf2Resp(_taskid, _user_context, _inbuffer, _extend, _error_code, _channel_select);
}

int StnCallBack::OnTaskEnd(uint32_t _taskid, void* const _user_context, int _error_type, int _error_code) {
	NetworkService::Instance().OnTaskEnd(_taskid, _user_context, _error_type, _error_code);
	
	return 0;
}

void StnCallBack::OnLongLinkIPPortReport(const std::string& _ip, uint16_t _port) {

}

void StnCallBack::OnLongLinkStatusChange(int _status) {
    NetworkService::Instance().OnState(kLongLinkStateCallbackId, _status);
}

void StnCallBack::ReportConnectStatus(int _status, int longlink_status) {
    
    switch (longlink_status) {
        case mars::stn::kServerFailed:
        case mars::stn::kServerDown:
        case mars::stn::kGateWayFailed:
            break;
        case mars::stn::kConnecting:
            break;
        case mars::stn::kConnected:
            break;
        case mars::stn::kNetworkUnkown:
            return;
        default:
            return;
    }
}

int StnCallBack::GetLonglinkIdentifyCheckBuffer(AutoBuffer& _identify_buffer, AutoBuffer& _buffer_hash, int32_t& _cmdid) {
	_cmdid = 2;
	
    return IdentifyMode::kCheckNever;
}

bool StnCallBack::OnLonglinkIdentifyResponse(const AutoBuffer& _response_buffer, const AutoBuffer& _identify_buffer_hash) {
    return false;
}


void StnCallBack::RequestSync() {
	
}

    }
}






