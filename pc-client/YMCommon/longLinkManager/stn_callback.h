#ifndef STNCALLBACK_h
#define STNCALLBACK_h

#include "stn/stn_logic.h"

namespace mars {
    namespace stn {
        
class StnCallBack : public Callback {
    
private:
    StnCallBack() {}
    ~StnCallBack() {}
    StnCallBack(StnCallBack&);
    StnCallBack& operator = (StnCallBack&);
    
public:
    static StnCallBack* Instance();
    static void Release();
    
    virtual bool MakesureAuthed();
	
    virtual void TrafficData(ssize_t _send, ssize_t _recv);
	
    virtual std::vector<std::string> OnNewDns(const std::string& _host);
    
	virtual void OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend);
    
	virtual bool Req2Buf(uint32_t _taskid, void* const _user_context, AutoBuffer& _outbuffer, AutoBuffer& _extend, int& _error_code, const int _channel_select);
    virtual int Buf2Resp(uint32_t _taskid, void* const _user_context, const AutoBuffer& _inbuffer, const AutoBuffer& _extend, int& _error_code, const int _channel_select);
    
	virtual int  OnTaskEnd(uint32_t _taskid, void* const _user_context, int _error_type, int _error_code);
    
	virtual void OnLongLinkIPPortReport(const std::string& _ip, uint16_t _port);
	virtual void OnLongLinkStatusChange(int _status);
	
	virtual void ReportConnectStatus(int _status, int longlink_status);
    virtual int  GetLonglinkIdentifyCheckBuffer(AutoBuffer& _identify_buffer, AutoBuffer& _buffer_hash, int32_t& _cmdid);
    virtual bool OnLonglinkIdentifyResponse(const AutoBuffer& _response_buffer, const AutoBuffer& _identify_buffer_hash);
    
	virtual void RequestSync();

private:
    static StnCallBack* instance_;
    
};
    }
}

#endif /* STNCALLBACK_h */
