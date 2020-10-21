/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  whiteboard.h
 *  Description: whiteboard class
 *
 *  Author: ccb
 *  Date: 2019/05/17 13:00:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/05/17    V4.5.1       创建文件
*******************************************************************************/

#ifndef WHITEBOARDMANAGER_H
#define WHITEBOARDMANAGER_H

#include <QMutex>
#include <QTimer>
#include <QPainter>
#include <QQuickPaintedItem>
#include <QtCore/qglobal.h>
#include "iwhiteboardctrl.h"
#include "iwhiteboardcallback.h"

class WhiteBoard : public QQuickPaintedItem
{
    Q_OBJECT
public:
    explicit WhiteBoard(QQuickPaintedItem *parent = 0);
    ~WhiteBoard();

    static WhiteBoard* getInstance();
    //设置白板回调
    void setWhiteBoardCallBack(IWhiteBoardCallBack* whiteBoardCallBack);
    //设置用户白板权限
    void setUserAuth(const QString &userId, int userRole, int trailState);

    //设置画笔颜色
    Q_INVOKABLE void setPenColor(int pencolors);
    //改变画笔尺寸
    Q_INVOKABLE void changeBrushSize(double size);
    //设置鼠标类型
    Q_INVOKABLE void setCursorShapeTypes(int types);
    //设置橡皮的大小
    Q_INVOKABLE void setEraserSize(double size);

    //回撤
    Q_INVOKABLE void undo();
    //清屏
    Q_INVOKABLE  void clearScreen();
    //清屏、撤销
    Q_INVOKABLE  void clearScreen(int type,int pageNo,int totalNum);

    //画几何图形
    Q_INVOKABLE void drawLocalGraphic(const QString &cmd, double backGroundHeight, double ImageY);

    //设置表情的url
    Q_INVOKABLE void setInterfaceUrls(const QString &urls);
    //上传图片成功后发送url
    Q_INVOKABLE void upLoadSendUrlHttp(const QString &https);

    //设置图片的比例系数
    Q_INVOKABLE void setPictureRate(double widthRate, double heightRate);
    //滚动长图命令
    Q_INVOKABLE void updataScrollMap(double scrollY);
    //设置当前图片高度
    Q_INVOKABLE void setCurrentImageHeight(int height);
    //根据图片偏移量获取图片位置进行显示
    Q_INVOKABLE void getOffsetImage(const QString &imageUrl, double offsetY);

signals:

    //集中画布
    void sigFocusTrailboard();
    //Y轴偏移信号
    void sigOffsetY(double offsetY);
    //当前图像高度
    void sigCurrentImageHeight(double height);
    //滚动长图命令
    void sigZoomInOut(double offsetX, double offsetY, double zoomRate);

    //鼠标位置、状态信号
    void sigCursorPointer(bool statues, int pointx, int pointy);
    //教鞭位置信号
    void sigPointerPosition(double xPoint, double yPoint);

    void sigSendHttpUrl(QString urls);
    void sigSendUrl(QString urls, double width, double height, bool isLongImg, QString questionId,bool beShowedAsLongImg);

    //鼠标按压
    void sigMousePress();
    //鼠标弹起
    void sigMouseRelease();

    //白板授权信号
    void sigAuthChange(QString userId,int up,int trail,int userRole);       //userRole: 0=老师，1=学生，2=助教

public slots:
    //改变画笔颜色
    void changePenColor(const QColor &color);
    //远端轨迹绘制
    void drawRemoteLine(const QString &command);
    //整屏轨迹绘制
    void drawPage(const QString &questionId, double offsetY, bool isBlank);

    //设置当前图片地址
    void setCurrentImgUrl(const QString &url);
    //发送图片url
    void onSigSendUrl(const QString &urls, double width, double height);
    //根据滚动坐标获取图片
    void getOffSetImage(double offsetX, double offsetY, double zoomRate);

    //界面尺寸变化
    void onCtentsSizeChanged();
    //隐藏教鞭
    void onPointerTimerout();
    //教鞭位置
    void  onSigPointerPosition(double xpoint, double  ypoint);

protected:
    //画图
    void paint(QPainter *painter);
    void mousePressEvent(QMouseEvent *event);
    void mouseMoveEvent(QMouseEvent *event);
    void mouseReleaseEvent(QMouseEvent *event);

private:
    //设置鼠标形状
    void setCursorShape();

    //本地鼠标移动画线
    void drawLocalLine();
    //解析轨迹命令
    void parseTrail(QString command);

    //画椭圆
    void drawEllipse(const QRectF &rect, double brushWidth, const QColor &color, double angle);
    //根据多个点画线
    void drawLine(const QVector<QPointF> &points, double brushWidth, const QColor &color, int type);
    //绘制贝塞尔曲线
    void drawBezier(const QVector<QPointF> &points, double size, const QColor &penColor, int type);

    double changeYPoinToLocal(double pointY);
    double changeYPoinToSend(double pointY);

    QJsonObject getLineJsonObj(const QVector<QPointF> &points, int operateStatus, double brushSize,
                      double eraserSize, const QString &penColorName, double hightRate, double currentImagaeOffSetY);

private:
    int m_pointCount;
    int m_cursorShape;
    int m_operateStatus; //0教鞭 1轨迹 2橡皮
    int m_currentImageHeight;

    double m_brushSize;//画笔大小
    double m_eraserSize;//橡皮大小
    double m_pictureWidthRate;
    double m_pictureHeihtRate;
    double m_currentImagaeOffSetY;//还原轨迹属性

    QPointF m_lastPoint;
    QPointF m_currentPoint;

    QMutex m_tempTrailMutex;
    QPixmap m_tempTrail;

    QColor m_penColor;
    QVector<QPointF> m_currentTrail;//当前正在书写的轨迹坐标点集合

    QString currentImgUrl;
    QTimer *m_pointerTimer;//教鞭隐藏时间

    static QMutex m_instanceMutex;
    static WhiteBoard* m_whiteBoard;
    IWhiteBoardCallBack* m_whiteBoardCallBack;

};

#endif // WHITEBOARDMANAGER_H

