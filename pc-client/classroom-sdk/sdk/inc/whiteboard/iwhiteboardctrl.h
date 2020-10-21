/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  iwhiteboardctrl.h
 *  Description: whiteboard ctrl interface
 *
 *  Author: ccb
 *  Date: 2019/06/20 10:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/06/20    V4.5.1       创建文件
*******************************************************************************/

#ifndef IWHITEBOARDCTRL_H
#define IWHITEBOARDCTRL_H

class IWhiteBoardCallBack;
class IWhiteBoardCtrl
{
public:

    virtual ~IWhiteBoardCtrl(){;}
    //设置用户白板权限
    virtual void setUserAuth(QString userId, int trailState) = 0;
    //设置鼠标形状
    virtual void selectShape(int shapeType) = 0;
    //设置画笔尺寸
    virtual void setPaintSize(double size) = 0;
    //设置画笔颜色
    virtual void setPaintColor(int color) = 0;
    //设置橡皮大小
    virtual void setErasersSize(double size) = 0;

    //绘制图像
    virtual void drawImage(const QString &image) = 0;
    //绘制图形
    virtual void drawGraph(const QString &graph) = 0;
    //绘制表情
    virtual void drawExpression(const QString &expression) = 0;
    //绘制教鞭位置
    virtual void drawPointerPosition(double xpoint, double  ypoint) = 0;

    //回撤
    virtual void undoTrail() = 0;
    //清屏
    virtual void clearTrails() = 0;
    //绘制整屏轨迹
    virtual void drawTrails(const QString &imageUrl, double width, double height, double offsetY, const QString &questionId) = 0;

    //设置白板回调
    virtual void setWhiteBoardCallBack(IWhiteBoardCallBack* whiteBoardCallBack = 0) = 0;

};

Q_DECLARE_INTERFACE(IWhiteBoardCtrl,"org.qt-project.Qt.Plugin.IWhiteBoardCtrl/1.0")
#endif // IWHITEBOARDCTRL_H
