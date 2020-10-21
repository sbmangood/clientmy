#include "CommTask.h"
#include "stn/stn_logic.h"

using namespace std;

bool CommTask::Req2Buf(uint32_t _taskid, void* const _user_context, AutoBuffer& _outbuffer, AutoBuffer& _extend, int& _error_code, const int _channel_select)
{
    std::string req_context_(((CommTask*)_user_context)->text_);
    if (req_context_.length())
    {
        _outbuffer.AllocWrite(req_context_.length());
        _outbuffer.Write(req_context_.data(), req_context_.length());
    }

	return true;
}

int CommTask::Buf2Resp(uint32_t _taskid, void* const _user_context, const AutoBuffer& _inbuffer, const AutoBuffer& _extend, int& _error_code, const int _channel_select)
{
    return mars::stn::kTaskFailHandleNoError;
}

