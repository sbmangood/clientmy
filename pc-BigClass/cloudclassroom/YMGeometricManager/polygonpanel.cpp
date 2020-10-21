#include "polygonpanel.h"
#include <QMouseEvent>

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>


#define PI 3.1415926

PolygonPanel::PolygonPanel(QQuickPaintedItem *parent): QQuickPaintedItem(parent)
    , m_isMoving(false)
    , m_isStretch(false)
    , m_amplificationFactor(1.0)
    , m_currentFactor(1)
{
    setAcceptHoverEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton);
    setFlag(ItemAcceptsDrops, true);
}

PolygonPanel::~PolygonPanel()
{

}

void PolygonPanel::setInitWindowType( int types,QString boardId,QString dockId,QString itemId,int pageId,double lineWidth)
{
    m_boardId = boardId;
    m_dockId = dockId;
    m_pageId = pageId;
    m_itemId = itemId;
    m_lineWidth = lineWidth;
    m_polygon = types ;
    m_polygon = m_polygon < 2 ? 3 : m_polygon;

    m_stretchWidth = this->width() / 120;
    //初始化顶点
    //初始化规则：屏幕中心作为原点，原点跟每相邻的两个顶点的夹角 A 相等
    //如果是奇数个顶点则屏幕中心最上方放置第一个顶点，如果是偶数个顶点第一个顶点放置在
    //与X轴夹角为 A/2 的位置 其余顶点按逆时针顺序依次放置
    QPoint centerPoint(this->width() / 2, this->height() / 2);
    double angle = 360 / m_polygon;
    if (m_polygon % 2)
    {
        for (int i = 0; i < m_polygon; ++i)
        {
            m_points.append(QPointF(centerPoint.x() + this->width() / 20 * cos((270 - angle * i)*PI / 180)
                                    , centerPoint.y() + this->width() / 20 * sin((270 - angle * i)*PI / 180)));
        }
    }
    else
    {

        for (int i = 0; i < m_polygon; ++i)
        {
            m_points.append(QPointF(centerPoint.x() + this->width() / 20 * cos((360 - angle / 2 - angle * i)*PI / 180)
                                    , centerPoint.y() + this->width() / 20 * sin((360 - angle / 2 - angle * i)*PI / 180)));
        }
    }
    //初始化每个顶点的拖拽点
    for (int i = 0; i < m_points.size(); ++i)
    {
        m_stretchs.append(QRect(m_points.at(i).x() - m_stretchWidth / 2
                                , m_points.at(i).y() - m_stretchWidth / 2
                                , m_stretchWidth, m_stretchWidth));
    }
    update();
}

QString PolygonPanel::doneBtnClicked()
{
    qDebug() << "=====doneBtnClicked====" <<  m_points;
    QJsonArray arr;
    double factor = 1000000.0;
    for (int i = 0; i < m_points.size(); ++i)
    {
        int locationX = m_points.at(i).x() / this->width()  * factor;
        int locationY = m_points.at(i).y() / this->height() * factor;
        arr.append(QString::number(locationX));
        arr.append(QString::number(locationY));
    }
//    if (m_points.size() > 2)
//    {
//        arr.append(QString::number(m_points.at(0).x() / this->width() * factor));
//        arr.append(QString::number(m_points.at(0).y() / this->height() * factor));
//    }

    QJsonObject obj;
    obj.insert("pts", arr);
    obj.insert("boardId", m_boardId);
    obj.insert("itemId", m_itemId);
    obj.insert("pageId", QString::number(m_pageId));
    obj.insert("dockId", m_dockId);
    obj.insert("width", m_lineWidth * factor);
    obj.insert("color", QString("3ED7B7"));
    obj.insert("type", QString("polygon"));
    QJsonDocument doc;
    doc.setObject(obj);
    return  QString(doc.toJson(QJsonDocument::Compact));
}

//鼠标是否在图形内区域
bool PolygonPanel::isPointInPolygon(QPointF &point)
{
    if(m_points.size() == 2) //直线拖拽移动
    {
        QVector<QPointF> tps;
        QLineF linef(m_points[0], m_points[1]);
        tps.append(QPointF(m_points.at(0).x() + m_stretchWidth / 2 * cos((360 - linef.angle() - 90)*PI / 180)
                           , m_points.at(0).y() + m_stretchWidth / 2 * sin((360 - linef.angle() - 90)*PI / 180)));
        tps.append(QPointF(m_points.at(0).x() + m_stretchWidth / 2 * cos((360 - linef.angle() + 90)*PI / 180)
                           , m_points.at(0).y() + m_stretchWidth / 2 * sin((360 - linef.angle() + 90)*PI / 180)));
        QLineF linef2(m_points[1], m_points[0]);
        tps.append(QPointF(m_points.at(1).x() + m_stretchWidth / 2 * cos((360 - linef2.angle() - 90)*PI / 180)
                           , m_points.at(1).y() + m_stretchWidth / 2 * sin((360 - linef2.angle() - 90)*PI / 180)));
        tps.append(QPointF(m_points.at(1).x() + m_stretchWidth / 2 * cos((360 - linef2.angle() + 90)*PI / 180)
                           , m_points.at(1).y() + m_stretchWidth / 2 * sin((360 - linef2.angle() + 90)*PI / 180)));

        return QPolygonF(tps).containsPoint(point, Qt::OddEvenFill);
    }

    //多边形拖拽移动
    return QPolygonF(m_points).containsPoint(point, Qt::OddEvenFill);
}

//鼠标是否在拖拽点区域
bool PolygonPanel::isPointInStretch(QPoint &point)
{
    for (int i = 0; i < m_stretchs.size(); ++i)
    {
        if(m_stretchs.at(i).contains(point))
            return true;
    }
    return false;
}

//拖拽不能超出屏幕范围
QPoint PolygonPanel::checkStretchPoint(QPoint &point)
{
    point.setX(qMin(point.x(), (int)(this->width())));
    point.setX(qMax(point.x(), 0));
    point.setY(qMin(point.y(), (int)(this->height())));
    point.setY(qMax(point.y(), 0));
    return point;
}

void PolygonPanel::checkMovingPoint(QPointF &movePoint)
{
    bool canMove = true;
    //检查是否所有点都可往上移或者往下移
    for (int i = 0; i < m_points.size(); ++i)
    {
        if ( ((m_points.at(i) + movePoint).y() < 0 && movePoint.y() < 0)
             || ((m_points.at(i) + movePoint).y() > this->height() && movePoint.y() > 0))
            canMove = false;
    }
    if (!canMove)
        movePoint.setY(0);

    //检查是否所有点都可往左移或者往右移
    canMove = true;
    for (int i = 0; i < m_points.size(); ++i)
    {
        if ( ((m_points.at(i) + movePoint).x() < 0 && movePoint.x() < 0)
             || ((m_points.at(i) + movePoint).x() > this->width()) && movePoint.x() > 0)
            canMove = false;
    }
    if (!canMove)
        movePoint.setX(0);
    updatePoints(movePoint);
}

void PolygonPanel::updatePoints(QPointF &point)
{
    //更新移动后的顶点坐标
    for (int i = 0; i < m_points.size(); ++i)
    {
        QPointF p = m_points.at(i);
        m_points.replace(i, p + point);
    }
    //更新移动后的拖拽点
    for (int i = 0; i < m_stretchs.size(); ++i)
    {
        QRect r = m_stretchs.at(i);
        m_stretchs.replace(i, QRect(r.topLeft() + point.toPoint(), QSize(r.width(), r.height())));
    }
}

void PolygonPanel::zoomIn(double multiple)
{
    if(m_amplificationFactor >= 3.1)
    {
        return;
    }
    m_amplificationFactor += multiple - 1.0;

    for (int i = 0; i < m_points.size(); ++i)
    {
        QPointF p = m_points.at(i);
        QPointF ap(p.x()*multiple, p.y()*multiple);
        if( !QRectF(QPointF(0, 0), QSize(this->width(), this->height() ) ).contains(ap))
            return;
    }
    double beforeAvgX = 0, afterAvgX = 0, beforeAvgY = 0, afterAvgY = 0;
    for (int i = 0; i < m_points.size(); ++i)
    {
        QPointF p = m_points.at(i);
        beforeAvgX += p.x();
        afterAvgX += p.x() * multiple;
        beforeAvgY += p.y();
        afterAvgY += p.y() * multiple;
        m_points.replace(i, p * multiple);
        m_stretchs.replace(i, QRect(m_points.at(i).toPoint() - QPoint(m_stretchWidth / 2, m_stretchWidth / 2)
                                    , QSize(m_stretchWidth, m_stretchWidth)));
    }
    QPointF beforePoint(beforeAvgX / m_points.size(), beforeAvgY / m_points.size());
    QPointF afterPoint(afterAvgX / m_points.size(), afterAvgY / m_points.size());
    updatePoints(QPointF(beforePoint - afterPoint));
    update();
}

void PolygonPanel::zoomOut(double multiple)
{
    if(m_amplificationFactor <= 1.0)
    {
        return;
    }
    m_amplificationFactor = m_amplificationFactor - multiple + 1.0;
    double beforeAvgX = 0, afterAvgX = 0, beforeAvgY = 0, afterAvgY = 0;
    for (int i = 0; i < m_points.size(); ++i)
    {
        QPointF p = m_points.at(i);
        beforeAvgX += p.x();
        afterAvgX += p.x() / multiple;
        beforeAvgY += p.y();
        afterAvgY += p.y() / multiple;
        m_points.replace(i, p / multiple);
        m_stretchs.replace(i, QRect(m_points.at(i).toPoint() - QPoint(m_stretchWidth / 2, m_stretchWidth / 2)
                                    , QSize(m_stretchWidth, m_stretchWidth)));
    }

    QPointF beforePoint(beforeAvgX / m_points.size(), beforeAvgY / m_points.size());
    QPointF afterPoint(afterAvgX / m_points.size(), afterAvgY / m_points.size());
    updatePoints(QPointF(beforePoint - afterPoint));
    update();
}

//直线上的两点P1(X1,Y1) P2(X2,Y2)。直线方程AX+BY+C=0，A B C分别等于：
//A = Y2 - Y1, B = X1 - X2, C = X2*Y1 - X1*Y2
void PolygonPanel::drawGuide(QPainter *painter)
{
    //四边形辅助线
    if (m_stretchs.size() == 4 && m_isStretch)
    {
        QPointF thisp = m_points.at(m_stretchIndex), pre, next, other;
        switch (m_stretchIndex)
        {
            case 0:
                pre = m_points.at(3);
                next = m_points.at(1);
                other = m_points.at(2);
                break;
            case 1:
                pre = m_points.at(0);
                next = m_points.at(2);
                other = m_points.at(3);
                break;
            case 2:
                pre = m_points.at(1);
                next = m_points.at(3);
                other = m_points.at(0);
                break;
            default:
                pre = m_points.at(2);
                next = m_points.at(0);
                other = m_points.at(1);
                break;
        }
        if (other.x() == pre.x() || other.y() == pre.y()) {}
        else
        {
            double a = other.y() - pre.y();
            double b = pre.x() - other.x();
            double c = other.x() * pre.y() - other.y() * pre.x();
            //X = (-BY-C)/A  Y = (-AX-C)/B
            QPointF p1(-c / a, 0);
            QPointF p2((-b * this->height() - c) / a, this->height());
            double tx = (-b * next.y() - c) / a;
            // 点到直线距离 |AX+BY+C|/sqrt(A^2+B^2)
            c = c - a * (next.x() - tx);
            double distance = qAbs(a * thisp.x() + b * thisp.y() + c) / sqrt(a * a + b * b);
            if (distance <= this->width() / 80)
                painter->drawLine(QPointF(p1.x() + next.x() - tx, p1.y()), QPointF(p2.x() + next.x() - tx, p2.y()));
        }
        if (other.x() == next.x() || other.y() == next.y()) {}
        else
        {
            double a = other.y() - next.y();
            double b = next.x() - other.x();
            double c = other.x() * next.y() - other.y() * next.x();
            //X = (-BY-C)/A  Y = (-AX-C)/B
            QPointF p1(-c / a, 0);
            QPointF p2((-b * this->height() - c) / a, this->height());
            double tx = (-b * pre.y() - c) / a;
            // 点到直线距离 |AX+BY+C|/sqrt(A^2+B^2)
            c = c - a * (pre.x() - tx);
            double distance = qAbs(a * thisp.x() + b * thisp.y() + c) / sqrt(a * a + b * b);
            if (distance <= this->width() / 80)
                painter->drawLine(QPointF(p1.x() + pre.x() - tx, p1.y()), QPointF(p2.x() + pre.x() - tx, p2.y()));
        }
    }
    else if (m_stretchs.size() == 3 && m_isStretch)
    {
        QPointF thisp = m_points.at(m_stretchIndex), pre, next;
        switch (m_stretchIndex)
        {
            case 0:
                pre = m_points.at(2);
                next = m_points.at(1);
                break;
            case 1:
                pre = m_points.at(0);
                next = m_points.at(2);
                break;
            default:
                pre = m_points.at(1);
                next = m_points.at(0);
                break;
        }
        QPointF center((pre.x() + next.x()) / 2, (pre.y() + next.y()) / 2);
        qreal r = sqrt(pow(center.x() - pre.x(), 2) + pow(center.y() - pre.y(), 2));
        qreal pointAngle = QLineF(center, pre).angle();
        QPointF preP(center.x() + r * cos((270 - pointAngle)*PI / 180)
                     , center.y() + r * sin((270 - pointAngle)*PI / 180));

        double a = preP.y() - center.y();
        double b = center.x() - preP.x();
        double c = preP.x() * center.y() - preP.y() * center.x();
        //X = (-BY-C)/A  Y = (-AX-C)/B
        QPointF p1(-c / a, 0);
        QPointF p2((-b * this->height() - c) / a, this->height());
        // 点到直线距离 |AX+BY+C|/sqrt(A^2+B^2)
        double distance = qAbs(a * thisp.x() + b * thisp.y() + c) / sqrt(a * a + b * b);
        if (distance <= this->width() / 80)
            painter->drawLine(p1, p2);
    }
}

void PolygonPanel::paint(QPainter *painter)
{
    painter->setPen(QPen(QColor(62, 215, 183), 2, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawPolygon(QPolygonF(m_points));
    //画拖拽点
    painter->setPen(QPen(QColor(255, 255, 255), 1, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter->setBrush(QBrush(QColor(255, 255, 255),Qt::SolidPattern));
    for (int i = 0; i < m_stretchs.size(); ++i)
        painter->drawEllipse(m_stretchs.at(i));

    painter->setPen(QPen(QColor(62, 215, 183), 1, Qt::DashLine, Qt::RoundCap, Qt::RoundJoin));
    //画拖拽点辅助线
    if (m_isStretch)
    {
        QPointF p = m_points.at(m_stretchIndex);
        painter->drawLine(QPointF(p.x(), 0), QPointF(p.x(), this->height()));
        painter->drawLine(QPointF(0, p.y()), QPointF(this->width(), p.y()));
    }
    drawGuide(painter);
}

//退出编辑
void PolygonPanel::exitEidt()
{

}

void PolygonPanel::mousePressEvent(QMouseEvent *event)
{
    m_beginPoint = event->pos();
    if(isPointInStretch(event->pos()))
    {
        for (int i = 0; i < m_stretchs.size(); ++i)
        {
            if(m_stretchs.at(i).contains(m_beginPoint))
                m_stretchIndex = i;
        }
        m_isStretch = true;
    }
    else if(isPointInPolygon(QPointF(event->pos())))
        m_isMoving = true;
    //}
    emit sigHover(m_isMoving);
    qDebug() << "=====mousePressEvent=====" << m_isMoving;
}

void PolygonPanel::mouseMoveEvent(QMouseEvent *event)
{
    //    if(event->buttons() & Qt::LeftButton)
    //    {
    m_endPoint = this->checkStretchPoint(event->pos());
    if (m_isStretch)
    {
        //拖拽顶点先检查顶点不能超过屏幕范围
        //之后把拖拽后的顶点替换掉拖拽之前的对应顶点
        //顶点拖拽点也要随之更新
        QPointF targetPoint = m_endPoint - m_beginPoint + m_points.at(m_stretchIndex);
        m_points.replace(m_stretchIndex, targetPoint);
        m_stretchs.replace(m_stretchIndex, QRect(targetPoint.x() - m_stretchWidth / 2
                           , targetPoint.y() - m_stretchWidth / 2
                           , m_stretchWidth, m_stretchWidth));
    }
    else if (m_isMoving)
    {
        //移动图形时先检查每个顶点是否超过屏幕范围
        //超出则不移动
        QPointF movePoint = m_endPoint - m_beginPoint;
        checkMovingPoint(movePoint);
    }
    m_beginPoint = m_endPoint;
    update();
    //}
    //设置鼠标样式
    if(isPointInStretch(event->pos()))
        setCursor(Qt::PointingHandCursor);
    else if(isPointInPolygon(QPointF(event->pos())))
        setCursor(Qt::SizeAllCursor);
    else if(!isPointInPolygon(QPointF(event->pos())))
        setCursor(Qt::ArrowCursor);
}

void PolygonPanel::hoverMoveEvent(QHoverEvent *event)
{
    if(isPointInStretch(event->pos()))
        setCursor(Qt::PointingHandCursor);
    else if(isPointInPolygon(QPointF(event->pos() ) ) )
        setCursor(Qt::SizeAllCursor);
    else if(!isPointInPolygon(QPointF(event->pos() ) ) )
        setCursor(Qt::ArrowCursor);
}

void PolygonPanel::mouseReleaseEvent(QMouseEvent *event)
{
    //    if (event->button() == Qt::LeftButton)
    //    {
    m_isStretch = false;
    m_isMoving = false;
    update();
    //  }
}

void PolygonPanel::wheelEvent(QWheelEvent *event)
{

    if (event->delta() > 0)
    {
        //emit sigAmplificationFactor(m_currentFactor + 1 );
        emit sigAmplificationFactor( 1 );
    }
    else
    {
        emit sigAmplificationFactor( 2 );
    }
}



void PolygonPanel::closePanel()
{

}


//放大系数
void PolygonPanel::setAmplificationFactor(int factors)
{
    //qDebug()<<"m_currentFactor =="<<m_currentFactor<<"factors =="<<factors;
    if((factors - m_currentFactor ) > 0)
    {
        double step = (factors - m_currentFactor ) / 100.0 + 1.0;
        zoomIn(step);//放大图形
    }
    if((factors - m_currentFactor ) < 0)
    {
        double step = (m_currentFactor - factors  ) / 100.0 + 1.0;
        zoomOut(step);//缩小图形
    }
    m_currentFactor = factors;
}
