/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  whitebaordcenter.h
 *  Description: whitebaord center class
 *
 *  Author: ccb
 *  Date: 2019/07/30 13:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/07/30    V4.5.1       创建文件
*******************************************************************************/

#ifndef WHITEBOARDCENTER_H
#define WHITEBOARDCENTER_H
#include "datacenter.h"
#include "controlcenter.h"
#include "../whiteboard/iwhiteboardctrl.h"
#include "../whiteboard/iwhiteboardcallback.h"

class WhiteBoardCenter :public IWhiteBoardCtrl, public IWhiteBoardCallBack
{
public:
    WhiteBoardCenter(ControlCenter* controlCenter);
    ~WhiteBoardCenter();

    void init(const QString &pluginPathName);
    void uninit();

    //设置用户白板权限
    virtual void setUserAuth(const QString &userId, int userRole, int trailState);
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
    virtual void setWhiteBoardCallBack(IWhiteBoardCallBack* whiteBoardCallBack){;}

    //回调多边形绘制数据
    virtual bool onDrawPolygon(const QJsonObject &polygonObj);
    //回调椭圆绘制数据
    virtual bool onDrawEllipse(const QJsonObject &ellipseObj);
    //回调曲线绘制数据
    virtual bool onDrawLine(const QJsonObject &lineObj);

    //回调表情绘制数据
    virtual bool onDrawExpression(const QString &expressionUrl);
    //回调图片滑动数据
    virtual bool onScroll(double scrollX,double scrollY);
    //回调图片绘制数据
    virtual bool onDrawImage(const QString &mdImageUrl, double pictureWidthRate, double pictureHeihtRate);

    //回调教鞭位置数据
    virtual bool onDrawPointer(double xPos, double yPos);

    //回撤轨迹数据
    virtual bool onUndo();
    //清除多个轨迹数据
    virtual bool onClearTrails();
    //清除多个轨迹数据
    virtual bool onClearTrails(int type,int pageNo,int totalNum);

    //设置当前图像高度
    virtual bool onCurrentImageHeight(double height);
    //设置缓存图像数据
    virtual bool onCurrentBeBufferedImage(const QImage &image);
    //设置当前画板高度
    virtual bool onCurrentTrailBoardHeight(double height);
    //当前白板尺寸
    virtual bool onCurrentWhiteBoardSize(double width, double height);
    //设置图像偏移
    virtual bool onOffSetImage(double offSetY);
    //设置图像偏移
    virtual bool onOffSetImage(const QString &imageUrl, double offSetY);

    //获取当前图像高度
    virtual double getCurrentImageHeight();
    //获取中间高度
    virtual double getMidHeight();

    virtual double getResetOffsetY(double offsetY, double zoomRate);
    //获取当前轨迹数据
    virtual QList<WhiteBoardMsg> getCurrentTrailsMsg();

private:
    //调整轨迹消息
    QString adjustTrailMsg(const QString &trailMsg);
    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

private:
    ControlCenter* m_controlCenter;
    IWhiteBoardCtrl* m_whiteBoardCtrl;
};

#endif // WHITEBOARDCENTER_H
