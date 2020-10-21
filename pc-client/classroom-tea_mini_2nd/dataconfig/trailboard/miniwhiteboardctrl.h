/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  miniwhiteboardctrlbase.h
 *  Description: mini whiteboard control class
 *
 *  Author: ccb
 *  Date: 2019/05/20 10:12:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/05/20    V4.5.1       创建文件
*******************************************************************************/

#ifndef MINIWHITEBOARDCTRL_H
#define MINIWHITEBOARDCTRL_H

#include <QObject>
#include "../datahandl/messagemodel.h"
#include "../classroom-sdk/sdk/inc/whiteboard/iwhiteboardcallback.h"
#include "../classroom-sdk/sdk/inc/whiteboard/iwhiteboardctrl.h"
#include "../classroom-sdk/sdk/inc/whiteboard/whiteboardmsg.h"

class Msg;
class SocketHandler;
class MiniWhiteBoardCtrl : public QObject, public IWhiteBoardCallBack
{
    Q_OBJECT
public:
    explicit MiniWhiteBoardCtrl(SocketHandler* socketHandler);
     ~MiniWhiteBoardCtrl();

public slots:

    void onDrawPage(MessageModel model);
    void onDrawRemoteLine(QString command);

private:
    SocketHandler *m_socketHandler;
    MessageModel m_bufferModel;


public:
    void init(const QString &pluginPathName);
    void uninit();
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
    IWhiteBoardCtrl* m_whiteBoardCtrl;

};

#endif // MINIWHITEBOARDCTRL_H
