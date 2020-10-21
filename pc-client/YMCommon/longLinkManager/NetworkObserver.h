#ifndef _PUSH_OBSERVER_H_
#define _PUSH_OBSERVER_H_
#include <map>
#include <string>

#include "comm/autobuffer.h"

class PushObserver
{
public:
    virtual void OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend) = 0;
};

class StateObserver
{
public:
    virtual void OnState(int _status) = 0;
};

#endif
