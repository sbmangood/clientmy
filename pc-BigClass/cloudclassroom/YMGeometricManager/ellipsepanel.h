#ifndef ELLIPSEPANEL_H
#define ELLIPSEPANEL_H

#include <QQuickPaintedItem>
#include <QPainter>
#include <QDebug>
#include <QHoverEvent>
#include <QMouseEvent>
#include <QCursor>


enum StretchState
{
    NOTSELECT = 0,
    TOP,
    BOTTOM,
    LEFT,
    RIGHT
};

class EllipsePanel : public QQuickPaintedItem
{
        Q_OBJECT
    public:
        explicit EllipsePanel(QQuickPaintedItem *parent = 0);
        ~EllipsePanel();
        Q_INVOKABLE void setInitWindowType(QString boardId,QString dockId,QString itemId,int pageId,double lineWidth);
        Q_PROPERTY(QString doneBtnClicked READ doneBtnClicked)

        /*
         * 放大系数
         * @factors:变化的系数
         */
        Q_INVOKABLE void setAmplificationFactor(int factors );

    signals:
        void drawLocalEllipse(QString command);
        void sigToolWidgetHide();//底下工具栏隐藏

        void sigAmplificationFactor(int factors );

    public slots:

        void closePanel();


    private:

        void setStretch();
        bool isPointInEllipse(QPointF &point);
        bool isPointInStretch(QPointF &point);
        QPoint checkStretchPoint(QPoint &point);
        void checkMovingPoint(QPoint &point);
        void zoomIn(double multiple);
        void zoomOut(double multiple);
        QPointF pointBeforeRotate(QPoint &point);
        QPointF pointAfterRotate(QPoint &point, int an);

        //画图
        void paint(QPainter *painter);

        void mousePressEvent(QMouseEvent *event);
        void mouseMoveEvent(QMouseEvent *event);
        void hoverMoveEvent(QHoverEvent* event);
        void mouseReleaseEvent(QMouseEvent *event);
        void wheelEvent(QWheelEvent *event);
        QString doneBtnClicked();

    private:
        //矩形区域坐标，大小
        double m_rectX;
        double m_rectY;
        double m_rectWidth;
        double m_rectHeight;
        //四个拖拽点
        QRect m_topStretch;
        QRect m_bottomStretch;
        QRect m_leftStretch;
        QRect m_rightStretch;
        int m_stretchWidth;//拖拽点宽度
        QPoint m_beginRotatePoint;
        QPoint m_beginStretchPoint;
        QPoint m_beginPoint;
        QPoint m_endPoint;
        bool m_isMoving;
        bool m_isStretch;//是否 拖拽、移动 图形
        StretchState m_stretchState;
        qreal m_angle;//旋转角度
        QString m_boardId;
        QString m_dockId;
        int m_pageId;
        QString m_itemId;

        double m_amplificationFactor; //放大系数
        int m_currentFactor;
        double m_lineWidth;


};

#endif // ELLIPSEPANEL_H
