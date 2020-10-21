#ifndef YMHOMEWORKWRITTINGBOARD_H
#define YMHOMEWORKWRITTINGBOARD_H

#include <QQmlApplicationEngine>
#include <QtQuick>
#include <QDebug>
#include <QMutex>
#include <QCursor>
#include <QPainterPath>
#include <QPolygon>
#include <QRegion>
#include <qDebug>
#include <QPainter>
#include <QQuickPaintedItem>
#include <QTimer>
#include <QQuickItem>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QTransform>
#include <QProcess>
#include<QStandardPaths>
#include<QFile>
#include "./dataconfig/datahandl/sockethandler.h"
#include "./dataconfig/datahandl/messagemodel.h"

#include "./dataconfig/datahandl/datamodel.h"

class YMHomeworkWrittingBoard : public QQuickPaintedItem
{
        Q_OBJECT
    public:
        YMHomeworkWrittingBoard(QQuickPaintedItem *parent = 0);

        double D[11] = {0.500, 0.405, 0.320, 0.245, 0.180, 0.125, 0.080, 0.045, 0.020, 0.005, 0.000};
        double E[11] = {0.500, 0.590, 0.660, 0.710, 0.740, 0.750, 0.740, 0.710, 0.660, 0.590, 0.500};
        double F[11] = {0.000, 0.005, 0.020, 0.045, 0.080, 0.125, 0.180, 0.245, 0.320, 0.405, 0.500};


    public:

        //设置画笔颜色
        Q_INVOKABLE void setPenColor(int pencolors);
        //改变画笔尺寸
        Q_INVOKABLE void changeBrushSize(double size);

        //设置鼠标类型
        Q_INVOKABLE void setCursorShapeTypes(int types);

        //画几何图形
        Q_INVOKABLE void drawLocalGraphic(QString cmd);

        //截图保存
        Q_INVOKABLE void grapItemImage(QObject *itemObj);

        //清屏
        Q_INVOKABLE void clearScreen();

    protected:
        //画图
        void paint(QPainter *painter);

        void mousePressEvent(QMouseEvent *event);
        void mouseMoveEvent(QMouseEvent *event);
        void mouseReleaseEvent(QMouseEvent *event);

    signals:
        //鼠标按压
        void sigMousePress();

        //集中画布
        void sigFocusTrailboard();

        //发送 答案写字板生成的截图地址
        void sigBeSavedGrapAnswer( QString imageUrl, int imgWidth, int imgHeight);

    public slots:
        void changePenColor(QColor color);
        void changeEraserSize(double size);

        //界面尺寸变化
        void onCtentsSizeChanged();
        //保存生成的 截图
        void saveIamge();

        //撤销
        void undo();
        //回退
        void fallback();

    private:
        //本地鼠标移动两点画线
        void drawLocalLine();
        //画椭圆
        void drawEllipse(const QRectF &rect, double brushWidth, QColor color, double angle);
        //根据多个点画线
        void drawLine(const QVector<QPointF> &points, double brushWidth, QColor color, int type);
        //绘制贝塞尔曲线
        void drawBezier(const QVector<QPointF> &points, double size, QColor penColor, int type);
        //设置鼠标形状
        void setCursorShape();

        //设置 图片生成目录 清除缓存
        void grapImageSetting();
    private:
        QPointF m_lastPoint;
        QPointF m_currentPoint;

        QMutex m_tempTrailMutex;
        QPixmap m_tempTrail;

        QColor m_penColor;
        int m_operateStatus; //0教鞭 1轨迹 2橡皮
        QVector<QPointF> m_currentTrail;//当前正在书写的轨迹坐标点集合

        QVector<QPointF> testTrail;//当前正在书写的轨迹坐标点集合

        QVector<QPointF> listr;
        QVector<QPointF> culist;
        QVector<QPointF> listt;
        double m_brushSize;//画笔大小
        double m_eraserSize;//橡皮大小
        // QSize boardSize; //画布大小
        int m_pointCount;
        int m_cursorShape;
        double m_pictureWidthRate;
        double m_pictureHeihtRate;
        SocketHandler * m_handler;
        //QPixmap tempTrail;

        QQuickItem * m_grab_item;
        QSharedPointer<QQuickItemGrabResult> m_grab_result;

        QString m_docParh;

        QMap<int, QVector<QPointF>> m_bufferPoint;
        int m_undoIndex;

        QMap<int, QList<int>> bufferPoint; //缓存轨迹操作索引
        QList<int> m_ListIndex;
        int m_currentIndex;

};

#endif // YMHOMEWORKWRITTINGBOARD_H
