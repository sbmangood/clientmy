#include <qqml.h>
#include "trophy.h"
#include "trophyplugin.h"

TrophyPlugin::TrophyPlugin(QObject *parent)
    :QQmlExtensionPlugin(parent)
{

}

TrophyPlugin::~TrophyPlugin()
{

}

void TrophyPlugin::init()
{
    Trophy::getInstance()->init();
}

void TrophyPlugin::uninit()
{
    Trophy::getInstance()->uninit();
}

void TrophyPlugin::drawTrophy()
{
    Trophy::getInstance()->drawTrophy();
}

void TrophyPlugin::setTrophyCallBack(ITrophyCallBack* trophyCallBack)
{
    Trophy::getInstance()->setTrophyCallBack(trophyCallBack);
}

void TrophyPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<Trophy>(uri, 1, 0, "Trophy");
}
