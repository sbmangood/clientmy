#ifndef _COMM_TASK_H_
#define _COMM_TASK_H_

#include <iostream>

enum ChannelType
{
    ChannelType_ShortConn = 1,
    ChannelType_LongConn = 2,
    ChannelType_All = 3
} ;

class AutoBuffer;

class CommTask
{
public:
	virtual bool Req2Buf(uint32_t _taskid, void* const _user_context, AutoBuffer& _outbuffer, AutoBuffer& _extend, int& _error_code, const int _channel_select);
	virtual int Buf2Resp(uint32_t _taskid, void* const _user_context, const AutoBuffer& _inbuffer, const AutoBuffer& _extend, int& _error_code, const int _channel_select);

    uint32_t taskid_;
    ChannelType channel_select_;
    uint32_t cmdid_;
    std::string cgi_;
    std::string host_;
	std::string user_;
	std::string to_;
	std::string text_;
	std::string access_token_;
	std::string topic_;
};

#endif /* _COMM_TASK_H_ */
