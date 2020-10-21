/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  iwhiteboardcallback.h
 *  Description: whiteboard callback interface
 *
 *  Author: ccb
 *  Date: 2019/06/20 10:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/06/20    V4.5.1       创建文件
*******************************************************************************/

#ifndef IWHITEBOARDCALLBACK_H
#define IWHITEBOARDCALLBACK_H
#include "whiteboardmsg.h"
class IWhiteBoardCallBack
{
public:
    
    //回调多边形绘制数据
    virtual bool onDrawPolygon(const QJsonObject &polygonObj) = 0;
    //回调椭圆绘制数据
    virtual bool onDrawEllipse(const QJsonObject &ellipseObj) = 0;
    //回调曲线绘制数据
    virtual bool onDrawLine(const QJsonObject &lineObj) = 0;

    //回调表情绘制数据
    virtual bool onDrawExpression(const QString &expressionUrl) = 0;
    //回调图片滑动数据
    virtual bool onScroll(double scrollX,double scrollY) = 0;
    //回调图片绘制数据
    virtual bool onDrawImage(const QString &mdImageUrl, double pictureWidthRate, double pictureHeihtRate) = 0;

    //回调教鞭位置数据
    virtual bool onDrawPointer(double xPos, double yPos) = 0;

    //回撤轨迹数据
    virtual bool onUndo() = 0;
    //清除多个轨迹数据
    virtual bool onClearTrails() = 0;
    //清除多个轨迹数据
    virtual bool onClearTrails(int type,int pageNo,int totalNum) = 0;
    
    //设置当前图像高度
    virtual bool onCurrentImageHeight(double height) = 0;
    //设置缓存图像数据
    virtual bool onCurrentBeBufferedImage(const QImage &image) = 0;
    //设置当前画板高度
    virtual bool onCurrentTrailBoardHeight(double height) = 0;

    //设置图像偏移
    virtual bool onOffSetImage(double offSetY) = 0;
    //设置图像偏移
    virtual bool onOffSetImage(const QString &imageUrl, double offSetY) = 0;

    //获取当前图像高度
    virtual double getCurrentImageHeight() = 0;
    //获取中间高度
    virtual double getMidHeight() = 0;
    //重置y轴偏移
    virtual double getResetOffsetY(double offsetY, double zoomRate) = 0;
    //获取当前轨迹数据
    virtual QList<WhiteBoardMsg> getCurrentTrailsMsg() = 0;
};

#endif // IWHITEBOARDCALLBACK_H
