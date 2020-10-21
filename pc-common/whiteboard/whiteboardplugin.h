#ifndef QMLPLUGIN_PLUGIN_H
#define QMLPLUGIN_PLUGIN_H

#include <QQmlExtensionPlugin>
#include "iwhiteboardctrl.h"
#include "whiteboard.h"
#include "iwhiteboardcallback.h"

class WhiteBoardPlugin : public QQmlExtensionPlugin, public IWhiteBoardCtrl
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.Plugin.IWhiteBoardCtrl/1.0")
    Q_INTERFACES(IWhiteBoardCtrl)

public:
    explicit WhiteBoardPlugin(QObject *parent = 0);
    ~WhiteBoardPlugin();

    void registerTypes(const char *uri);

    //设置用户白板权限
    virtual void setUserAuth(QString userId, int trailState);
    //设置鼠标形状
    virtual void selectShape(int shapeType);
    //设置画笔尺寸
    virtual void setPaintSize(double size);
    //设置画笔颜色
    virtual void setPaintColor(int color);
    //设置橡皮大小
    virtual void setErasersSize(double size);

    //绘制图像
    virtual void drawImage(const QString &image);
    //绘制图形
    virtual void drawGraph(const QString &graph);
    //绘制表情
    virtual void drawExpression(const QString &expression);
    //绘制教鞭位置
    virtual void drawPointerPosition(double xpoint, double  ypoint);

    //回撤
    virtual void undoTrail();
    //清屏
    virtual void clearTrails();
    //绘制整屏轨迹
    virtual void drawTrails(const QString &imageUrl, double width, double height, double offsetY, const QString &questionId);

    //设置白板回调
    virtual void setWhiteBoardCallBack(IWhiteBoardCallBack* whiteBoardCallBack = 0);


private:
    IWhiteBoardCallBack* m_whiteBoardCallBack;

};

#endif // QMLPLUGIN_PLUGIN_H

