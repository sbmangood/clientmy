/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  ministuwhiteboardctrlbase.h
 *  Description: mini stu whiteboard control class
 *
 *  Author: ccb
 *  Date: 2019/05/21 13:12:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/05/21    V4.5.1       创建文件
*******************************************************************************/

#ifndef MINISTUWHITEBOARDCTRL_H
#define MINISTUWHITEBOARDCTRL_H

#include <QObject>
#include "../YMCommon/whiteboard/whiteboardctrlbase.h"
#include "../YMCommon/whiteboard/whiteboard.h"
#include "../datahandl/messagemodel.h"


class Msg;
class SocketHandler;
class MiniStuWhiteBoardCtrl : public WhiteBoardCtrlBase
{
    Q_OBJECT
public:
    explicit MiniStuWhiteBoardCtrl();
     ~MiniStuWhiteBoardCtrl();

    //回调多边形绘制数据
    virtual bool onDrawPolygon(const QJsonObject &polygonObj);
    //回调椭圆绘制数据
    virtual bool onDrawEllipse(const QJsonObject &ellipseObj);
    //回调曲线绘制数据
    virtual bool onDrawLine(const QVector<QPointF> &points, int operateStatus, double brushSize,
        double eraserSize, const QString &penColorName, double hightRate, double currentImagaeOffSetY);

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

    //获取中间高度（StudentData）
    virtual double getMidHeight();
    //获取当前轨迹模型数据
    virtual QList<WhiteBoardMsg> getCurrentModelMsg();

    /*使用GetOffsetImage模块*/
    //获取当前图像高度
    virtual double getCurrentImageHeight();
    //设置当前图像高度
    virtual void setCurrentImageHeight(double height);
    //设置缓存图像数据
    virtual void setCurrentBeBufferedImage(const QImage &image);
    //设置当前画板高度
    virtual void setcurrentTrailBoardHeight(double height);

    //设置图像偏移
    virtual void getOffSetImage(double offSetY);
    //设置图像偏移
    virtual void getOffSetImage(const QString &imageUrl, double offSetY);

public slots:

    void onDrawPage(MessageModel model);
    void onDrawRemoteLine(QString command);

protected:
    //统一轨迹消息结构
     QString translateTrailMsg(const QString &trailMsg);

private:
    SocketHandler *m_socketHandler;
    MessageModel m_bufferModel;


};

#endif // MINISTUWHITEBOARDCTRL_H
