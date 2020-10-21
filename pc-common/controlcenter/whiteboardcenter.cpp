/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  whitebaordcenter.h
 *  Description: whitebaord center class
 *
 *  Author: ccb
 *  Date: 2019/07/30 13:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/07/30    V4.5.1       创建文件
*******************************************************************************/

#include <QPluginLoader>
#include "whiteboardcenter.h"
#include "./curriculumdata.h"
#include "getoffsetimage.h"
#include "messagepack.h"
#include "messagetype.h"
#include "datamodel.h"

enum TrailOperation
{
    TRAIL_CLEAR = 1,
    TRAIL_UNDO,
};

WhiteBoardCenter::WhiteBoardCenter(ControlCenter* controlCenter)
    :m_controlCenter(controlCenter)
    ,m_whiteBoardCtrl(nullptr)
{

}

WhiteBoardCenter::~WhiteBoardCenter()
{
    uninit();
}

void WhiteBoardCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("whiteboard.dll", Qt::CaseInsensitive))
    {
        QObject* instance = loadPlugin(pluginPathName);
        if(instance)
        {
            m_whiteBoardCtrl  = qobject_cast<IWhiteBoardCtrl *>(instance);
            if(nullptr == m_whiteBoardCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(instance);
                return;
            }
            m_whiteBoardCtrl->setWhiteBoardCallBack(this);
            qDebug()<< "qobject_cast is success, pluginPathName is" << pluginPathName;
        }
        else
        {
            qCritical()<< "load plugin is failed, pluginPathName is" << pluginPathName;
        }
    }
    else
    {
        qWarning()<< "plugin is invalid, pluginPathName is" << pluginPathName;
    }

}

void WhiteBoardCenter::uninit()
{
    if(m_whiteBoardCtrl)
    {
        unloadPlugin((QObject*)m_whiteBoardCtrl);
        m_whiteBoardCtrl = nullptr;
    }
    m_controlCenter = nullptr;
}

void WhiteBoardCenter::setUserAuth(QString userId, int trailState)
{
    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->setUserAuth(userId, trailState);
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, set user auth is failed" << userId<< trailState;
    }
}

void WhiteBoardCenter::selectShape(int shapeType)
{
    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->selectShape(shapeType);
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, select shape is failed" << shapeType;
    }
}

void WhiteBoardCenter::setPaintSize(double size)
{
    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->setPaintSize(size);
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, set paint size is failed" << size;
    }
}

void WhiteBoardCenter::setPaintColor(int color)
{
    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->setPaintColor(color);
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, set paint color is failed" << color;
    }
}

void WhiteBoardCenter::setErasersSize(double size)
{
    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->setErasersSize(size);
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, set eraser size is failed" << size;
    }
}

void WhiteBoardCenter::drawImage(const QString &image)
{

}

void WhiteBoardCenter::drawGraph(const QString &graph)
{

}

void WhiteBoardCenter::drawExpression(const QString &expression)
{

}

void WhiteBoardCenter::drawPointerPosition(double xpoint, double  ypoint)
{

}

void WhiteBoardCenter::undoTrail()
{
    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->undoTrail();
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, undo trail is failed" ;
    }
}

void WhiteBoardCenter::clearTrails()
{
    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->clearTrails();
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, clear trails is failed" ;
    }
}

void WhiteBoardCenter::drawTrails(const QString &imageUrl, double width, double height, double offsetY, const QString &questionId)
{
    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->drawTrails(imageUrl, width, height, offsetY, questionId);
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, draw trails is failed" ;
    }
}


bool WhiteBoardCenter::onDrawPolygon(const QJsonObject &polygonObj)
{
    return true;
}

bool WhiteBoardCenter::onDrawEllipse(const QJsonObject &ellipseObj)
{
    return true;
}

bool WhiteBoardCenter::onDrawLine(const QJsonObject &lineObj)
{
    if(m_controlCenter != nullptr)
    {
        QString s(MessagePack::getInstance()->trailReqMsg(lineObj, DataCenter::getInstance()->m_currentCourse, DataCenter::getInstance()->m_currentPage));
        s = s.replace("\r\n", "").replace("\n", "").replace("\r", "").replace("\t", "").replace(" ", "");
        m_controlCenter->sendLocalMessage(s, true, false);
    }
    else
    {
        qWarning() << "draw line is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

bool WhiteBoardCenter::onDrawExpression(const QString &expressionUrl)
{
    return true;
}

bool WhiteBoardCenter::onScroll(double scrollX,double scrollY)
{
    return true;
}

bool WhiteBoardCenter::onDrawImage(const QString &mdImageUrl, double pictureWidthRate, double pictureHeihtRate)
{
    return true;
}

bool WhiteBoardCenter::onDrawPointer(double xPos, double yPos)
{
    qint32 factorValX = 0, factorValY = 0; qint32  factor = 1000000;

    factorValX = qint32(xPos * factor);
    factorValY = qint32(yPos * factor);

    if(nullptr != m_controlCenter)
    {
        //发送教鞭命令
        QString message = MessagePack::getInstance()->pointReqMsg(factorValX, factorValY);
        m_controlCenter->syncSendMessage(message); //教鞭不需要重绘画板, 不需要加入重发队列中, 直接发送至服务器
    }
    else
    {
        qWarning() << "draw pointer is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

bool WhiteBoardCenter::onUndo()
{
    int totalPage = 0;
    QString coursewareId = DataCenter::getInstance()->m_currentCourse;
    if(DataCenter::getInstance()->m_currentCourse == "DEFAULT")
    {
        coursewareId = "000000";
    }
    if (DataCenter::getInstance()->m_pages.contains(DataCenter::getInstance()->m_currentCourse))
    {
        totalPage = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size();
    }
    QString msg = MessagePack::getInstance()->operationMsg(TRAIL_UNDO, DataCenter::getInstance()->m_currentPage, totalPage, coursewareId, DataCenter::getInstance()->m_currentPage);
    if(m_controlCenter)
        m_controlCenter->sendLocalMessage(msg, true, true);
    return true;
}

bool WhiteBoardCenter::onClearTrails()
{
    int totalPage = 0;
    QString coursewareId = DataCenter::getInstance()->m_currentCourse;
    if(DataCenter::getInstance()->m_currentCourse == "DEFAULT")
    {
        coursewareId = "000000";
    }
    if (DataCenter::getInstance()->m_pages.contains(DataCenter::getInstance()->m_currentCourse))
    {
        totalPage = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size();
    }
    QString msg = MessagePack::getInstance()->operationMsg(TRAIL_CLEAR, DataCenter::getInstance()->m_currentPage, totalPage, coursewareId, DataCenter::getInstance()->m_currentPage);

    if(m_controlCenter)
        m_controlCenter->sendLocalMessage(msg, true, true);
    return true;
}

bool WhiteBoardCenter::onClearTrails(int type,int pageNo,int totalNum)
{
    int totalPage = 0;
    QString coursewareId = DataCenter::getInstance()->m_currentCourse;
    if(DataCenter::getInstance()->m_currentCourse == "DEFAULT")
    {
        coursewareId = "000000";
    }
    if (DataCenter::getInstance()->m_pages.contains(DataCenter::getInstance()->m_currentCourse))
    {
        totalPage = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size();
    }
    QString msg = MessagePack::getInstance()->operationMsg(type, DataCenter::getInstance()->m_currentPage, totalPage, coursewareId, DataCenter::getInstance()->m_currentPage);

    if(m_controlCenter)
        m_controlCenter->sendLocalMessage(msg, true, true);
    return true;
}

bool WhiteBoardCenter::onCurrentImageHeight(double height)
{
    GetOffsetImage::instance()->currrentImageHeight = height;
    return true;
}

bool WhiteBoardCenter::onCurrentBeBufferedImage(const QImage &image)
{
    GetOffsetImage::instance()->currentBeBufferedImage = image;
    return true;
}

bool WhiteBoardCenter::onCurrentTrailBoardHeight(double height)
{
    GetOffsetImage::instance()->currentTrailBoardHeight = height;
    return true;
}

bool WhiteBoardCenter::onOffSetImage(double offSetY)
{
    GetOffsetImage::instance()->getOffSetImage(offSetY);
    return true;
}

bool WhiteBoardCenter::onOffSetImage(const QString &imageUrl, double offSetY)
{
    GetOffsetImage::instance()->getOffSetImage(imageUrl, offSetY);
    return true;
}

double WhiteBoardCenter::getCurrentImageHeight()
{
    if(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage].bgimg.isEmpty())
    {
        return GetOffsetImage::instance()->currentTrailBoardHeight;
    }
    else
    {
        return GetOffsetImage::instance()->currrentImageHeight;
    }
}

double WhiteBoardCenter::getResetOffsetY(double offsetY, double zoomRate)
{
    return 0;
}

double WhiteBoardCenter::getMidHeight()
{
    return StudentData::gestance()->midHeight;
}

QList<WhiteBoardMsg> WhiteBoardCenter::getCurrentTrailsMsg()
{
    QList<WhiteBoardMsg> whiteBoardMsgs;
    foreach (Msg mess, DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage].getMsgs())
    {
        WhiteBoardMsg m;
        m.msg = adjustTrailMsg(mess.msg);
        m.userId = "temp";
        whiteBoardMsgs.append(m);
    }

    return whiteBoardMsgs;
}

QString WhiteBoardCenter::adjustTrailMsg(const QString &trailMsg)
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


QObject* WhiteBoardCenter::loadPlugin(const QString &pluginPath)
{
    QObject *plugin = nullptr;
    QFile file(pluginPath);
    if (!file.exists())
    {
        qWarning()<< pluginPath<< "file is not file";
        return plugin;
    }

    QPluginLoader loader(pluginPath);
    plugin = loader.instance();
    if (nullptr == plugin)
    {
        qCritical()<< pluginPath<< "failed to load plugin" << loader.errorString();
    }

    return plugin;
}

void WhiteBoardCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}
