#ifndef TROPHYCENTER_H
#define TROPHYCENTER_H
#include "controlcenter.h"
#include "../trophy/itrophycallback.h"
#include "../trophy/itrophyctrl.h"
class TrophyCenter : public ITrophyCallBack
{
public:
    TrophyCenter(ControlCenter* controlCenter);
    virtual ~TrophyCenter();

    void init(const QString &pluginPathName);
    void uninit();
    void drawTrophy();
    virtual bool onSendTrophy(const QString &userId, const QString &userName);

private:
    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

private:
    QObject* m_instance;
    ITrophyCtrl* m_trophyCtrl;
    ControlCenter* m_controlCenter;
};

#endif // TROPHYCENTER_H
