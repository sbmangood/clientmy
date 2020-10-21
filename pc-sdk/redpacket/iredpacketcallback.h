#ifndef IREDPACKETCALLBACK_H
#define IREDPACKETCALLBACK_H

class IRedPacketCallBack
{
public:
    virtual ~IRedPacketCallBack(){}
    virtual bool onSendRedPackets() = 0;
    virtual bool onHitRedPacket(int packetId) = 0;

};

#endif // IREDPACKETCALLBACK_H
