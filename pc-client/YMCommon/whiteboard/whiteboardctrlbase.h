/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  whiteboardctrlbase.h
 *  Description: whiteboard control base class
 *
 *  Author: ccb
 *  Date: 2019/05/20 09:12:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/05/20    V4.5.1       创建文件
*******************************************************************************/


#ifndef WHITEBOARDCTRLBASE_H
#define WHITEBOARDCTRLBASE_H
#include <QObject>
#include "whiteboardmsg.h"

class WhiteBoardCtrlBase : public QObject
{
    Q_OBJECT
public:
    WhiteBoardCtrlBase() { ;}
    virtual ~WhiteBoardCtrlBase(){ ;}

    //回调多边形绘制数据
    virtual bool onDrawPolygon(const QJsonObject &polygonObj) =0;
    //回调椭圆绘制数据
    virtual bool onDrawEllipse(const QJsonObject &ellipseObj) =0;
    //回调曲线绘制数据
    virtual bool onDrawLine(const QVector<QPointF> &points, int operateStatus, double brushSize,
        double eraserSize, const QString &penColorName, double hightRate, double currentImagaeOffSetY) =0;

    //回调表情绘制数据
    virtual bool onDrawExpression(const QString &expressionUrl) =0;
    //回调图片滑动数据
    virtual bool onScroll(double scrollX,double scrollY) =0;
    //回调图片绘制数据
    virtual bool onDrawImage(const QString &mdImageUrl, double pictureWidthRate, double pictureHeihtRate) =0;

    //回调教鞭位置数据
    virtual bool onDrawPointer(double xPos, double yPos) =0;

    //回撤轨迹数据
    virtual bool onUndo() =0;
    //清除多个轨迹数据
    virtual bool onClearTrails() =0;
    //清除多个轨迹数据
    virtual bool onClearTrails(int type,int pageNo,int totalNum){return false;}

    //获取中间高度（StudentData）
    virtual double getMidHeight() =0;
    //获取当前轨迹模型数据
    virtual QList<WhiteBoardMsg> getCurrentModelMsg() =0;

    /*使用GetOffsetImage模块*/
    //获取当前图像高度
    virtual double getCurrentImageHeight() =0;
    //设置当前图像高度
    virtual void setCurrentImageHeight(double height) =0;
    //设置缓存图像数据
    virtual void setCurrentBeBufferedImage(const QImage &image) =0;
    //设置当前画板高度
    virtual void setcurrentTrailBoardHeight(double height) =0;

    //设置图像偏移
    virtual void getOffSetImage(double offSetY) =0;
    //设置图像偏移
    virtual void getOffSetImage(const QString &imageUrl, double offSetY) =0;

    //重置y轴偏移
    virtual double resetOffsetY(double offsetY, double zoomRate) {return 0;}


/*
    void selectShape(shapeType);
    void setPaint(color, size);
    void setEraser(size);
    void drawImage(image);
    void drawGraph(graph);
    void drawExpression(expression);
    void undo();

    void clearTrails();
    void drawTrails(trails);
    void setCallback(IWhiteBoardCallback); */

signals:
    //曲线绘制信号
    void sigDrawLine(QString command);
    //整屏绘制信号
    void sigDrawPage(QString questionId, double offsetY, bool isBlank);
    //图片偏移信号
    void getOffSetImage(double offsetX, double offsetY, double zoomRate);

    //Y轴偏移信号
    void sigOffsetY(double offsetY);
    void sigSendUrl(QString urls, double width, double height, bool isLongImg, QString questionId,bool beShowedAsLongImg);  
    void sigSendUrl(QString urls, double width, double height, bool isLongImg, QString questionId);
    void sigSendHttpUrl(QString urls);

    //当前图像高度
    void sigCurrentImageHeight(double height);
    //教鞭坐标位置
    void sigPointerPosition(double xPoint, double yPoint);
    //白板授权信号
    void sigAuthChange(QString userId,int up,int trail,int audio,int video);
    //滚动长图命令
    void sigZoomInOut(double offsetX, double offsetY, double zoomRate);

protected:
    //统一轨迹消息结构
    virtual QString translateTrailMsg(const QString &trailMsg){return QString(); }

};

#endif // WHITEBOARDCTRLBASE_H
