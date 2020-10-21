#ifndef POLYGONPANEL_H
#define POLYGONPANEL_H

#include <QQuickPaintedItem>
#include <QPainter>
#include <QDebug>
#include <QHoverEvent>
#include <QMouseEvent>
#include <QCursor>


class PolygonPanel : public QQuickPaintedItem
{
        Q_OBJECT
    public:
        explicit PolygonPanel(QQuickPaintedItem *parent = 0);
        ~PolygonPanel();

        Q_INVOKABLE   void setInitWindowType( int types );
        Q_PROPERTY(QString doneBtnClicked READ doneBtnClicked)
        /*
         * 放大系数
         * @factors:变化的系数
         */
        Q_INVOKABLE void setAmplificationFactor(int factors );

    signals:
        void drawLocalPolygon(QString command);
        void sigToolWidgetHide();//底下工具栏隐藏
        void sigAmplificationFactor(int factors );

    public slots:
        void closePanel();



    private:
        bool isPointInPolygon(QPointF &point );
        bool isPointInStretch(QPoint &point );
        QPoint checkStretchPoint(QPoint &point);
        void checkMovingPoint(QPointF &point);
        void updatePoints(QPointF &point);
        void zoomIn(double multiple);
        void zoomOut(double multiple);
        void drawGuide(QPainter *painter);

        //画图
        void paint(QPainter *painter);

        void mousePressEvent(QMouseEvent *event);
        void mouseMoveEvent(QMouseEvent *event);
        void hoverMoveEvent(QHoverEvent* event);
        void mouseReleaseEvent(QMouseEvent *event);

        void wheelEvent(QWheelEvent *event);

        QString doneBtnClicked();

    private:
        QVector<QPointF> m_points;//顶点
        QVector<QRect> m_stretchs;//拖拽点
        int m_polygon;//多边形顶点数量
        int m_stretchWidth;//拖拽点宽度
        int m_stretchIndex;
        // QPainter m_painter;
        QPoint m_beginPoint;
        QPoint m_endPoint;
        bool m_isMoving;
        bool m_isStretch;//是否 拖拽、移动 图形


        double m_amplificationFactor; //放大系数
        int m_currentFactor;


};

#endif // POLYGONPANEL_H
