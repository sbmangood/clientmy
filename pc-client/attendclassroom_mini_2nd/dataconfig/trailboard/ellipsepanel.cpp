#include "ellipsepanel.h"
#include <QMouseEvent>

#include <QJsonDocument>
#include <QJsonObject>

#define PI 3.1415926

EllipsePanel::EllipsePanel(QQuickPaintedItem *parent): QQuickPaintedItem(parent)
    , m_isMoving(false)
    , m_isStretch(false)
    , m_stretchState(NOTSELECT)
    , m_angle(0)
    , m_amplificationFactor(1.0)
    , m_currentFactor(1)
{
    setAcceptHoverEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton);
    setFlag(ItemAcceptsDrops, true);



}

EllipsePanel::~EllipsePanel()
{

}

void EllipsePanel::setInitWindowType()
{
    m_stretchWidth = this->width() / 80;


    QPoint centerPoint(this->width() / 2, this->height() / 2);
    this->m_rectX = centerPoint.x() - this->width() / 20;
    this->m_rectY = centerPoint.y() - this->width() / 20;
    this->m_rectWidth = this->width() / 10;
    this->m_rectHeight = this->width() / 10;
    setStretch();

}

void EllipsePanel::setStretch()
{
    m_topStretch = QRect(QPointF(m_rectX + m_rectWidth / 2 - m_stretchWidth / 2, m_rectY - m_stretchWidth / 2).toPoint()
                         , QSize(m_stretchWidth, m_stretchWidth));
    m_bottomStretch = QRect(QPointF(m_rectX + m_rectWidth / 2 - m_stretchWidth / 2, m_rectY + m_rectHeight - m_stretchWidth / 2).toPoint()
                            , QSize(m_stretchWidth, m_stretchWidth));
    m_leftStretch = QRect(QPointF(m_rectX - m_stretchWidth / 2, m_rectY + m_rectHeight / 2 - m_stretchWidth / 2).toPoint()
                          , QSize(m_stretchWidth, m_stretchWidth));
    m_rightStretch = QRect(QPointF(m_rectX + m_rectWidth - m_stretchWidth / 2, m_rectY + m_rectHeight / 2 - m_stretchWidth / 2).toPoint()
                           , QSize(m_stretchWidth, m_stretchWidth));
}

//判断点是否在椭圆内 f(x,y)= x^2/a^2 + y^2/b^2<=1
bool EllipsePanel::isPointInEllipse(QPointF &point)
{
    QPointF centerPoint(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
    double a = m_rectWidth / 2, b = m_rectHeight / 2;
    //把矩形中心点作为原点(0,0)
    QPointF transPoint = point - centerPoint;
    if (pow(transPoint.x() / a, 2) + pow(transPoint.y() / b, 2) <= 1)
        return true;
    return false;
}

bool EllipsePanel::isPointInStretch(QPointF &point)
{
    if (m_topStretch.contains(point.toPoint()))
    {
        m_stretchState = TOP;
        return true;
    }
    else if (m_bottomStretch.contains(point.toPoint()))
    {
        m_stretchState = BOTTOM;
        return true;
    }
    else if (m_leftStretch.contains(point.toPoint()))
    {
        m_stretchState = LEFT;
        return true;
    }
    else if (m_rightStretch.contains(point.toPoint()))
    {
        m_stretchState = RIGHT;
        return true;
    }
    return false;
}

//检查拖拽点不超过屏幕范围
QPoint EllipsePanel::checkStretchPoint(QPoint &point)
{
    QPoint movePoint = point - m_beginStretchPoint;
    switch (m_stretchState)
    {
        case TOP:
            m_rectY += movePoint.y();
            m_rectHeight -= movePoint.y() * 2;
            break;
        case BOTTOM:
            m_rectY -= movePoint.y();
            m_rectHeight += movePoint.y() * 2;
            break;
        case LEFT:
            m_rectX += movePoint.x();
            m_rectWidth -= movePoint.x() * 2;
            break;
        case RIGHT:
            m_rectX -= movePoint.x();
            m_rectWidth += movePoint.x() * 2;
            break;
        default:
            break;
    }
    return point;
}

void EllipsePanel::checkMovingPoint(QPoint &point)
{
    QRect screenRect(0, 0, this->width(), this->height());
    if(screenRect.contains(QPointF(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2).toPoint() + point))
    {
        m_rectX += point.x();
        m_rectY += point.y();
    }
}

void EllipsePanel::zoomIn(double multiple)
{
    if(m_amplificationFactor >= 3.1)
    {
        return;
    }
    m_amplificationFactor += multiple - 1.0;

    QPointF beforeCenter(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
    m_rectX = m_rectX * multiple;
    m_rectY = m_rectY * multiple;
    m_rectWidth = m_rectWidth * multiple;
    m_rectHeight = m_rectHeight * multiple;
    QPointF afterCenter(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
    m_rectX += (beforeCenter - afterCenter).x();
    m_rectY += (beforeCenter - afterCenter).y();
    setStretch();
    update();
}

void EllipsePanel::zoomOut(double multiple)
{
    if(m_amplificationFactor <= 1.0)
    {
        return;
    }
    m_amplificationFactor = m_amplificationFactor - multiple + 1.0;
    QPointF beforeCenter(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
    m_rectX = m_rectX / multiple;
    m_rectY = m_rectY / multiple;
    m_rectWidth = m_rectWidth / multiple;
    m_rectHeight = m_rectHeight / multiple;
    QPointF afterCenter(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
    m_rectX += (beforeCenter - afterCenter).x();
    m_rectY += (beforeCenter - afterCenter).y();
    setStretch();
    update();
}

//根据鼠标所在的点获取此点旋转前的位置
//f(x,y) = (a+r*cosA, b+r*sinA)
QPointF EllipsePanel::pointBeforeRotate(QPoint &point)
{
    QPointF center(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
    QLineF line(center, point);
    qreal pointm_angle = line.angle();
    qreal r = sqrt(pow(center.x() - point.x(), 2) + pow(center.y() - point.y(), 2));
    return QPointF(center.x() + r * cos((pointm_angle + m_angle) * PI / 180)
                   , center.y() + r * sin((pointm_angle + m_angle) * PI / 180));
}

QPointF EllipsePanel::pointAfterRotate(QPoint &point, int an)
{
    QPointF center(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
    QLineF line(center, point);
    qreal pointm_angle = line.angle();
    qreal r = sqrt(pow(center.x() - point.x(), 2) + pow(center.y() - point.y(), 2));
    return QPointF(center.x() + r * cos((an - pointm_angle + m_angle) * PI / 180)
                   , center.y() + r * sin((an - pointm_angle + m_angle) * PI / 180));
}

void EllipsePanel::paint(QPainter *painter)
{
    painter->setPen(QPen(QColor(0, 174, 255), 2, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter->setRenderHint(QPainter::Antialiasing);
    painter->save();
    //平移画布到矩形中心点
    painter->translate(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
    painter->rotate(m_angle);
    painter->drawEllipse(QRectF(-m_rectWidth / 2, -m_rectHeight / 2, m_rectWidth, m_rectHeight));
    //qDebug()<<"m_angle hh=="<<m_angle;
    //画拖拽点
    painter->setPen(QPen(QColor(0, 174, 255), 1, Qt::DashLine, Qt::RoundCap, Qt::RoundJoin));
    painter->drawEllipse(QRectF(QPointF(-m_stretchWidth / 2, -m_rectHeight / 2 - m_stretchWidth / 2).toPoint()
                                , QSize(m_stretchWidth, m_stretchWidth)));
    painter->drawEllipse(QRectF(QPointF(-m_stretchWidth / 2, m_rectHeight / 2 - m_stretchWidth / 2).toPoint()
                                , QSize(m_stretchWidth, m_stretchWidth)));
    painter->drawEllipse(QRectF(QPointF(-m_rectWidth / 2 - m_stretchWidth / 2, -m_stretchWidth / 2).toPoint()
                                , QSize(m_stretchWidth, m_stretchWidth)));
    painter->drawEllipse(QRectF(QPointF(m_rectWidth / 2 - m_stretchWidth / 2, -m_stretchWidth / 2).toPoint()
                                , QSize(m_stretchWidth, m_stretchWidth)));
    painter->restore();
    //画拖拽点辅助线
    if(m_isStretch)
    {
        painter->setPen(QPen(QColor(0, 174, 255), 1, Qt::DashLine, Qt::RoundCap, Qt::RoundJoin));
        QPoint centerPoint;
        QPointF rotatePoint;
        switch(m_stretchState)
        {
            case TOP:
            {
                centerPoint = QPoint(m_topStretch.x() + m_topStretch.width() / 2, m_topStretch.y() + m_topStretch.height() / 2);
                rotatePoint = pointAfterRotate(centerPoint, 180);
            }
            break;
            case LEFT:
            {
                centerPoint = QPoint(m_leftStretch.x() + m_leftStretch.width() / 2, m_leftStretch.y() + m_leftStretch.height() / 2);
                rotatePoint = pointAfterRotate(centerPoint, 0);
            }
            break;
            case RIGHT:
            {
                centerPoint = QPoint(m_rightStretch.x() + m_rightStretch.width() / 2, m_rightStretch.y() + m_rightStretch.height() / 2);
                rotatePoint = pointAfterRotate(centerPoint, 0);
            }
            break;
            case BOTTOM:
            {
                centerPoint = QPoint(m_bottomStretch.x() + m_bottomStretch.width() / 2, m_bottomStretch.y() + m_bottomStretch.height() / 2);
                rotatePoint = pointAfterRotate(centerPoint, 180);
            }
            break;
            default:
                break;
        }
        painter->drawLine(QPointF(0, rotatePoint.y()), QPointF(this->width(), rotatePoint.y()));
        painter->drawLine(QPointF(rotatePoint.x(), 0), QPointF(rotatePoint.x(), this->height()));
    }

}


void EllipsePanel::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
    {
        m_beginPoint = event->pos();
        m_beginRotatePoint = event->pos();
        m_beginStretchPoint = pointBeforeRotate(event->pos()).toPoint();
        if (isPointInStretch(pointBeforeRotate(event->pos())))
        {
            m_isStretch = true;
        }
        else if (isPointInEllipse(pointBeforeRotate(event->pos())))
        {
            m_isMoving = true;
        }
    }
}

void EllipsePanel::mouseMoveEvent(QMouseEvent *event)
{
    if (event->buttons() & Qt::LeftButton)
    {
        if (m_isStretch)
        {
            m_endPoint = checkStretchPoint(pointBeforeRotate(event->pos()).toPoint());
            QPointF centerPoint(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
            m_angle += QLineF(centerPoint, (m_beginRotatePoint)).angle() - QLineF(centerPoint, (event->pos())).angle();
            m_beginRotatePoint = event->pos();
        }
        else if (m_isMoving)
        {
            m_endPoint = event->pos();
            checkMovingPoint(QPoint(m_endPoint - m_beginPoint));
        }
        else
        {
            m_endPoint = event->pos();
            QPointF centerPoint(m_rectX + m_rectWidth / 2, m_rectY + m_rectHeight / 2);
            m_angle += QLineF(centerPoint, m_beginPoint).angle() - QLineF(centerPoint, m_endPoint).angle();
        }
        setStretch();
        update();
        m_beginPoint = m_endPoint;
        m_beginStretchPoint = m_endPoint;
    }

    if (isPointInStretch(pointBeforeRotate(event->pos())))
        setCursor(Qt::PointingHandCursor);
    else if(isPointInEllipse(pointBeforeRotate(event->pos())))
        setCursor(Qt::SizeAllCursor);
    else if(!isPointInEllipse(pointBeforeRotate(event->pos())))
        setCursor(Qt::ArrowCursor);
}

void EllipsePanel::hoverMoveEvent(QHoverEvent *event)
{
    if (isPointInStretch(pointBeforeRotate(event->pos())))
        setCursor(Qt::PointingHandCursor);
    else if(isPointInEllipse(pointBeforeRotate(event->pos())))
        setCursor(Qt::SizeAllCursor);
    else if(!isPointInEllipse(pointBeforeRotate(event->pos())))
        setCursor(Qt::ArrowCursor);
}

void EllipsePanel::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
    {
        m_stretchState = NOTSELECT;
        m_isMoving = false;
        m_isStretch = false;
        update();
    }
}

void EllipsePanel::wheelEvent(QWheelEvent *event)
{
    if (event->delta() > 0)
    {
        //emit sigAmplificationFactor(m_currentFactor + 1 );
        emit sigAmplificationFactor( 1 );

    }
    else
    {
        //   emit sigAmplificationFactor( m_currentFactor - 1 );
        emit sigAmplificationFactor( 2 );
    }
}

QString  EllipsePanel::doneBtnClicked()
{
    // qDebug()<<"this->width() =="<<this->width()<<"this->height() =="<<this->height()<<"m_angle =="<<m_angle;
    QJsonObject obj;
    obj.insert("x", QString::number(m_rectX / this->width(), 'f', 6));
    obj.insert("y", QString::number(m_rectY / this->height(), 'f', 6));
    obj.insert("width", QString::number(m_rectWidth / this->width(), 'f', 6));
    obj.insert("height", QString::number(m_rectHeight / this->height(), 'f', 6));
    obj.insert("domain", QString("draw"));
    obj.insert("command", QString("ellipse"));
    obj.insert("angle", QString::number(m_angle, 'f', 6));
    QJsonDocument doc;
    doc.setObject(obj);
    return  QString(doc.toJson(QJsonDocument::Compact));

}

void EllipsePanel::closePanel()
{

}



// 放大系数
void EllipsePanel::setAmplificationFactor(int factors)
{
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
