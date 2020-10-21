#ifndef TROPHYPLUGIN_H
#define TROPHYPLUGIN_H
#include <QQmlExtensionPlugin>
#include "trophy.h"
#include "itrophyctrl.h"
#include "itrophycallback.h"

class TrophyPlugin : public QQmlExtensionPlugin, public ITrophyCtrl
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.Plugin.ITrophyCtrl/1.0")
    Q_INTERFACES(ITrophyCtrl)

public:
    TrophyPlugin(QObject *parent = 0);
    virtual ~TrophyPlugin();

    virtual void init();
    virtual void uninit();
    virtual void drawTrophy();
    //设置奖杯回调
    virtual void setTrophyCallBack(ITrophyCallBack* trophyCallBack = 0);
    virtual void registerTypes(const char *uri);
};

#endif // TROPHYPLUGIN_H
