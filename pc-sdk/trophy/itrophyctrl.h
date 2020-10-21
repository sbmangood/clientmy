#ifndef ITROPHYCTRL_H
#define ITROPHYCTRL_H
#include "itrophycallback.h"

class ITrophyCtrl
{
public:
    virtual ~ITrophyCtrl(){}
    virtual void init() = 0;
    virtual void uninit() = 0;
    virtual void drawTrophy() = 0;
    //设置奖杯回调
    virtual void setTrophyCallBack(ITrophyCallBack* trophyCallBack = 0) = 0;

};
Q_DECLARE_INTERFACE(ITrophyCtrl,"org.qt-project.Qt.Plugin.ITrophyCtrl/1.0")
#endif // ITROPHYCTRL_H
