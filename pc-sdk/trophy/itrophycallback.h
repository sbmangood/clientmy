#ifndef ITROPHYCALLBACK_H
#define ITROPHYCALLBACK_H

class ITrophyCallBack
{
public:
    virtual ~ITrophyCallBack(){}
    virtual bool onSendTrophy(const QString &userId, const QString &userName) = 0;

};

#endif // ITROPHYCALLBACK_H
