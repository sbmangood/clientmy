/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  ministuwhiteboardctrlbase.cpp
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

#include "ministuwhiteboardctrl.h"
#include "getoffsetimage.h"
#include "../datahandl/sockethandler.h"



MiniStuWhiteBoardCtrl::MiniStuWhiteBoardCtrl()
    :m_socketHandler(NULL)
#ifdef USE_OSS_AUTHENTICATION
    , m_bufferModel(0, "", 1.0, 1.0, "", "0", 0, false, 0)
#else
    , m_bufferModel(0, "", 1.0, 1.0, "", "0", 0, false)
#endif
{
    m_socketHandler = SocketHandler::getInstance();
    connect(m_socketHandler, SIGNAL(sigDrawLine(QString)), this, SLOT(onDrawRemoteLine(QString)));
    connect(m_socketHandler, &SocketHandler::sigDrawPage, this, &MiniStuWhiteBoardCtrl::onDrawPage);
    connect(m_socketHandler, SIGNAL(sigZoomInOut(double, double, double)), this, SIGNAL(sigZoomInOut(double, double, double)));
    connect(m_socketHandler, SIGNAL(sigOffsetY(double)), this, SIGNAL(sigOffsetY(double)));
    connect(m_socketHandler, SIGNAL(sigSendUrl(QString,double,double,bool,QString,bool)),this,SIGNAL(sigSendUrl(QString,double,double,bool,QString,bool)));
    connect(m_socketHandler, SIGNAL( sigSendHttpUrl(QString ) ), this, SIGNAL( sigSendHttpUrl(QString ) ) ) ;
    connect(m_socketHandler, SIGNAL( sigPointerPosition(double, double ) ), this, SIGNAL( sigPointerPosition(double, double ) ) ) ;
    connect(m_socketHandler, SIGNAL(sigAuthChange(QString,int,int,int,int)), this, SIGNAL(sigAuthChange(QString,int,int,int,int)));

    connect(GetOffsetImage::instance(), SIGNAL(sigCurrentImageHeight(double)), this, SIGNAL(sigCurrentImageHeight(double)));

}

MiniStuWhiteBoardCtrl::~MiniStuWhiteBoardCtrl()
{
    if(m_socketHandler != NULL)
    {
        m_socketHandler->deleteLater(); ;
        m_socketHandler = NULL;
    }
}

bool MiniStuWhiteBoardCtrl::onDrawPolygon(const QJsonObject &polygonObj)
{
    QJsonObject object;
    object.insert("domain", QString("draw"));
    object.insert("command", QString("polygon"));
    object.insert("content", polygonObj);

    QJsonDocument doc;
    doc.setObject(object);
    QString s(doc.toJson(QJsonDocument::Compact));

    if(TemporaryParameter::gestance()->m_isStartClass && m_socketHandler)
    {
        m_socketHandler->sendLocalMessage(s, true, false);
        m_bufferModel.addMsg("temp", s);
    }
    else
    {
        qWarning() << "draw polygon is failed, m_socketHandler is null!";
        return false;
    }

    return true;
}

bool MiniStuWhiteBoardCtrl::onDrawEllipse(const QJsonObject &ellipseObj)
{
    QJsonObject object;
    object.insert("domain", QString("draw"));
    object.insert("command", QString("ellipse"));
    object.insert("content", ellipseObj);

    QJsonDocument doc;
    doc.setObject(object);
    QString s(doc.toJson(QJsonDocument::Compact));

    if(m_socketHandler)
    {
        m_socketHandler->sendLocalMessage(s, true, false);
        m_bufferModel.addMsg("temp", s);
    }
    else
    {
        qWarning() << "draw ellipse is failed, m_socketHandler is null!";
        return false;
    }
    return true;
}

bool MiniStuWhiteBoardCtrl::onDrawLine(const QVector<QPointF> &points, int operateStatus, double brushSize, double eraserSize, const QString &penColorName, double hightRate, double currentImagaeOffSetY)
{
    if(m_socketHandler != NULL)
    {
        qint32 factorVal = 0; int  factor = 1000000; double y = 0;

        QJsonArray arr;
        for (int i = 0; i < points.size(); ++i)
        {
            y = points.at(i).y();
            y = (y + currentImagaeOffSetY) *hightRate;

            factorVal = qint32(points.at(i).x() * factor);
            arr.append(factorVal);

            factorVal = qint32(y * factor);
            arr.append(factorVal);
        }

        QJsonObject obj;
        obj.insert("pts", arr);

        //画笔宽度
        factorVal = qint32(operateStatus == 1 ? (brushSize * factor) : (eraserSize * factor));
        obj.insert("width", factorVal);

        //颜色
        obj.insert("color", QString(operateStatus == 1 ? penColorName.mid(1) : "ffffff"));

        //类型(1:画笔 0:橡皮)
        obj.insert("type",  (operateStatus == 1 ? 1 : 0));

        QString s(m_socketHandler->trailReqMsgTemplate(obj));
        s = s.replace("\r\n", "").replace("\n", "").replace("\r", "").replace("\t", "").replace(" ", "");

        m_socketHandler->sendLocalMessage(s, true, false);
        m_bufferModel.addMsg("temp", s);
    }
    else
    {
        qWarning() << "draw line is failed, m_socketHandler is null!";
        return false;
    }
    return true;

}

bool MiniStuWhiteBoardCtrl::onDrawExpression(const QString &expressionUrl)
{
    if(m_socketHandler != NULL)
    {
        QString str = QString("0#{\"command\":\"magicface\",\"content\":\"%1\",\"domain\":\"control\"}").arg(expressionUrl);
        m_socketHandler->sendLocalMessage(str, false, false);
    }
    else
    {
        qWarning() << "draw expression is failed, m_socketHandler is null!";
        return false;
    }
    return true;
}

bool MiniStuWhiteBoardCtrl::onScroll(double scrollX,double scrollY)
{
    if(m_socketHandler != NULL)
    {
        double zoomRate = 1.0;
        QString str = QString("{\"command\":\"zoomInOut\",\"domain\":\"control\",\"content\":{\"offsetX\":\"0\",\"offsetY\":\"%1\",\"zoomRate\":\"%2\"}}").arg(QString::number( -scrollY  )).arg(QString::number(zoomRate));
        m_socketHandler->sendLocalMessage(str, true, false);
    }
    else
    {
        qWarning() << "scroll is failed, m_socketHandler is null!";
        return false;
    }
    return true;
}

bool MiniStuWhiteBoardCtrl::onDrawImage(const QString &mdImageUrl, double pictureWidthRate, double pictureHeihtRate)
{
    if( m_socketHandler != NULL )
    {
        QJsonObject json;
        json.insert("command", QString("picture"));
        json.insert("domain", QString("draw"));

        QJsonObject json1;
        json1.insert("type", QString("picture"));
        json1.insert("pageIndex", QString("%1").arg( m_socketHandler->m_currentPage + 1 ) );
        json1.insert("url", QString("%1").arg( mdImageUrl ) );
        json1.insert("width", QString("%1").arg(pictureWidthRate));
        json1.insert("height", QString("%1").arg(pictureHeihtRate));
        json.insert("content", json1);

        QJsonDocument documents;
        documents.setObject(json);
        QString str(documents.toJson(QJsonDocument::Compact));
        m_socketHandler->sendLocalMessage(str, true, true);
    }
    else
    {
        qWarning() << "draw image is failed, m_socketHandler is null!";
        return false;
    }
    return true;
}

bool MiniStuWhiteBoardCtrl::onDrawPointer(double xPos, double yPos)
{
    qint32 factorValX = 0, factorValY = 0; qint32  factor = 1000000;

    factorValX = qint32(xPos * factor);
    factorValY = qint32(yPos * factor);

    if( m_socketHandler != NULL )
    {
        //发送教鞭命令
        QString message = m_socketHandler->pointReqMsgTemplate(factorValX, factorValY);
        m_socketHandler->sendLocalMessage(message, false, false); //fix: 教鞭不需要重绘画板, 不需要加入重发队列中, 直接发送至服务器
    }
    else
    {
        qWarning() << "draw pointer is failed, m_socketHandler is null!";
        return false;
    }
    return true;
}

bool MiniStuWhiteBoardCtrl::onUndo()
{
    return true;
}

bool MiniStuWhiteBoardCtrl::onClearTrails()
{
    if(m_socketHandler != NULL)
    {
        m_socketHandler->clearScreen();
    }
    else
    {
        qWarning() << "clear trails is failed, m_socketHandler is null!";
        return false;
    }
    return true;
}

bool MiniStuWhiteBoardCtrl::onClearTrails(int type,int pageNo,int totalNum)
{
    if(m_socketHandler != NULL)
    {
        QString coursewareId = "";
        if(m_socketHandler->m_currentCourse == "DEFAULT")
        {
            coursewareId = "000000";
        }
        else
        {
            coursewareId = m_socketHandler->m_currentCourse;
        }

        QString msg = m_socketHandler->operationMsgTemplate(type, pageNo, totalNum, coursewareId);
        m_socketHandler->sendLocalMessage(msg, true, true);
    }
    else
    {
        qWarning() << "clear trails 1 is failed, m_socketHandler is null!";
        return false;
    }
    return true;
}

double MiniStuWhiteBoardCtrl::getMidHeight()
{
    return StudentData::gestance()->midHeight;
}

QList<WhiteBoardMsg> MiniStuWhiteBoardCtrl::getCurrentModelMsg()
{
    QList<WhiteBoardMsg> whiteBoardMsgs;
    foreach (Msg mess, m_bufferModel.getMsgs())
    {
        WhiteBoardMsg m;
        m.msg = this->translateTrailMsg(mess.msg);
        m.userId = "temp";

        whiteBoardMsgs.append(m);
    }

    return whiteBoardMsgs;
}

double MiniStuWhiteBoardCtrl::getCurrentImageHeight()
{
    return GetOffsetImage::instance()->currrentImageHeight;
}

void MiniStuWhiteBoardCtrl::setCurrentImageHeight(double height)
{
    GetOffsetImage::instance()->currrentImageHeight = height;
}

void MiniStuWhiteBoardCtrl::setCurrentBeBufferedImage(const QImage &image)
{
    GetOffsetImage::instance()->currentBeBufferedImage = image;
}

void MiniStuWhiteBoardCtrl::setcurrentTrailBoardHeight(double height)
{
    GetOffsetImage::instance()->currentTrailBoardHeight = height;
}

void MiniStuWhiteBoardCtrl::getOffSetImage(double offSetY)
{
    GetOffsetImage::instance()->getOffSetImage(offSetY);
}

void MiniStuWhiteBoardCtrl::getOffSetImage(const QString &imageUrl, double offSetY)
{
    GetOffsetImage::instance()->getOffSetImage(imageUrl, offSetY);
}

void MiniStuWhiteBoardCtrl::onDrawPage(MessageModel model)
{
    m_bufferModel.clear();
    m_bufferModel = model;

    if(!model.bgimg.isEmpty() && ("2" == model.currentCoursewareType || "1" == model.currentCoursewareType))
    {
        if(model.zoomRate > 1.0)
        {
            GetOffsetImage::instance()->getOffSetImage(model.bgimg, model.offsetY / model.zoomRate);
        }
        else
        {
            GetOffsetImage::instance()->getOffSetImage(model.bgimg, model.offsetY);
        }
    }

    emit sigDrawPage(model.questionId, model.offsetY, true);

    bool isLongImg = (model.questionId == "") ? false :  (model.bgimg == ""  ? false : true);
    emit sigSendUrl(model.bgimg, model.width, model.height, isLongImg, model.questionId);

//    emit sigChangeCurrentPage(model.getCurrentPage());
//    emit sigChangeTotalPage(model.getTotalPage());
}

void MiniStuWhiteBoardCtrl::onDrawRemoteLine(QString command)
{
    if(m_socketHandler)
    {
        m_bufferModel.addMsg("temp", command);
        emit sigDrawLine(this->translateTrailMsg(command));
    }
    else
    {
        qWarning() << "draw remote line is failed, m_socketHandler is null!";
    }
}

QString MiniStuWhiteBoardCtrl::translateTrailMsg(const QString &trailMsg)
{
    QJsonParseError err;
    QString translateMsg;
    QJsonDocument document = QJsonDocument::fromJson(trailMsg.toUtf8(), &err);
    if (err.error == QJsonParseError::NoError)
    {
        QJsonObject tempDocumentObj = document.object();
        QJsonObject tempContentObj = tempDocumentObj.take("content").toObject();

        QString command = document.object().take("cmd").toString();
        QJsonValue contentVal = document.object().take("content");
        double  factor = 1000000.000000;

        if (command == "trail") //统一小组与1v1 课轨迹数据结构
        {
            tempDocumentObj.insert("command", QString("trail"));
            tempDocumentObj.insert("domain", QString("draw"));

            QJsonObject contentObj = contentVal.toObject();

            //调整轨迹宽、鼠标类型数据
            int tempType =contentObj.take("type").toInt();
            double tempWidth = double((contentObj.take("width").toVariant().toLongLong()) / factor);
            tempContentObj.insert("type", QString( tempType == 1 ? "pencil" : "eraser"));
            tempContentObj.insert("width", QString::number(tempWidth, 'f', 6));

            QJsonArray trails = contentObj.take("pts").toArray();
            double x = 0, y = 0;
            int size = trails.size();
            qint32 factorVal = 0;

            //调整轨迹坐标数据
            QJsonArray arr;
            for(int i = 0; i < size; ++i)
            {
                factorVal = trails.at(i).toInt();
                if((i % 2) == 0)
                {
                    x = factorVal / factor;
                }

                if((i % 2) == 1)
                {
                    y = factorVal / factor;
                    QJsonObject obj;
                    obj.insert("x", QString::number(x, 'f', 6));
                    obj.insert("y", QString::number(y, 'f', 6));
                    arr.append(obj);
                }
            }

            tempContentObj.insert("trail", arr);
            tempDocumentObj.insert("content", tempContentObj);
            QJsonDocument doc(tempDocumentObj);
            translateMsg = QString(doc.toJson(QJsonDocument::Compact));
        }

    }
    else
    {
        qWarning() << "json trail msg  parse is failed!";
    }
    return translateMsg;
}
