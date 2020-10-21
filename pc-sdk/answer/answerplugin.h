#ifndef ANSWERPLUGIN_H
#define ANSWERPLUGIN_H
#include <QQmlExtensionPlugin>
#include "answer.h"
#include "ianswerctrl.h"
#include "ianswercallback.h"

class Answerplugin : public QQmlExtensionPlugin, public IAnswerCtrl
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.Plugin.IAnswerCtrl/1.0")
    Q_INTERFACES(IAnswerCtrl)
public:
    Answerplugin(QObject *parent = 0);
    virtual ~Answerplugin();

    virtual void init();
    virtual void uninit();
    virtual void drawAnswer(const QJsonObject &answerDataObj);
    virtual void answerStatistics(const QJsonObject &answerDataObj);
    virtual void answerCancel();
    virtual void answerForceFin();

    //设置答题器回调
    virtual void setAnswerCallBack(IAnswerCallBack* answerCallBack = 0);
    virtual void registerTypes(const char *uri);

};

#endif // ANSWERPLUGIN_H
