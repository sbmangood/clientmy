#ifndef WHITEBOARD_H
#define WHITEBOARD_H
#include <QQuickPaintedItem>
#include "playmanager.h"

//轨迹绘制
class TrailRender: public QQuickPaintedItem
{
    Q_OBJECT
public:
    TrailRender(QQuickPaintedItem *parent = 0);
    ~TrailRender();

    static TrailRender* getInstance();

    //根据图片偏移量获取图片位置进行显示
    Q_INVOKABLE void getOffsetImage(QString imageUrl, double offsetY);
    //设置 当前图片的高度
    Q_INVOKABLE void setCurrentImgHeight(double height);

    void drawLine(QString line);//解析处理命令
    //画贝塞尔曲线
    void drawBezier(const QVector<QPointF> &points, double size, QColor penColor, int type);
    //画一页 此页上的所有轨迹
    void drawPage(PageModel model);
    //画一条线
    void drawLine(const QVector<QPointF> &points, double brushWidth, QColor color, int type);
    //画椭圆
    void drawEllipse(const QRectF &rect, double brushWidth, QColor color, double angle);

    void zoomInOut(double offsetX, double offsetY, double zoomRate);
    void changeBgimg(QString url, double width, double height, QString questionId);
    void cursorPointer(double pointx, double pointy);
    void updateTrails();
    void addModelMsg(QString userId, QString msg, QString currentPage);
    void clearModelMsg();

public slots:
    void onCtentsSizeChanged();
    //根据滚动坐标获取图片
    void getOffSetImage(double offsetX, double offsetY, double zoomRate);

protected:
    void paint(QPainter *painter);

signals:
    void sigZoomInOut(double offsetX, double offsetY, double zoomRate); //滚动信号
    void sigChangeBgimg(QString url, double width, double height, QString questionId);
    void sigCursorPointer(double pointx, double pointy);

private:
    double changeYPoinToLocal(double pointY);// 转换Y坐标 将接收到的坐标转换为当前坐标
    double changeYPoinToSend(double pointY);//  将当前坐标转换为 发送时的坐标

private:
    double currentImagaeOffSetY;//还原轨迹属性
    QPixmap trailPixmap;
    QMutex m_tempTrailMutex;
    double m_currentImageHeight;
    PageModel bufferModel;

    static QMutex m_instanceMutex;
    static TrailRender* m_trailRender;
};

#endif // WHITEBOARD_H
