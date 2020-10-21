/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  miniwhiteboardctrlbase.cpp
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
#include <QPluginLoader>
#include "miniwhiteboardctrl.h"
#include "getoffsetimage.h"
#include "../datahandl/sockethandler.h"

MiniWhiteBoardCtrl::MiniWhiteBoardCtrl(SocketHandler* socketHandler)
    :m_socketHandler(socketHandler)
#ifdef USE_OSS_AUTHENTICATION
    , m_bufferModel(0, "", 1.0, 1.0, "", "0", 0, false, 0)
#else
    , m_bufferModel(0, "", 1.0, 1.0, "", "0", 0, false)
#endif
{
    QString path = QCoreApplication::applicationDirPath() + "/WhiteBoard/whiteboard.dll";
    init(path);

    connect(m_socketHandler, SIGNAL(sigDrawLine(QString)), this, SLOT(onDrawRemoteLine(QString)));
    connect(m_socketHandler, &SocketHandler::sigDrawPage, this, &MiniWhiteBoardCtrl::onDrawPage);
    connect(m_socketHandler, SIGNAL(sigZoomInOut(double, double, double)), this, SLOT(getOffSetImage(double, double, double)));
    connect(m_socketHandler, SIGNAL(sigOffsetY(double)), this, SIGNAL(sigOffsetY(double)));
    connect(m_socketHandler, SIGNAL(sigSendUrl(QString,double,double,bool,QString,bool)),this,SIGNAL(sigSendUrl(QString,double,double,bool,QString,bool)));
    connect(m_socketHandler, SIGNAL( sigSendHttpUrl(QString ) ), this, SIGNAL( sigSendHttpUrl(QString ) ) ) ;

    connect(GetOffsetImage::instance(), SIGNAL(sigCurrentImageHeight(double)), this, SIGNAL(sigCurrentImageHeight(double)));

}

MiniWhiteBoardCtrl::~MiniWhiteBoardCtrl()
{
    if(m_socketHandler != NULL)
    {
        m_socketHandler->deleteLater(); ;
        m_socketHandler = NULL;
        uninit();
    }
}

void MiniWhiteBoardCtrl::onDrawPage(MessageModel model)
{
    m_bufferModel.clear();
    m_bufferModel = model;

    if(nullptr != m_whiteBoardCtrl)
    {
        m_whiteBoardCtrl->drawTrails(model.bgimg, model.width, model.height, model.offsetY, model.questionId);
    }
    else
    {
        qWarning()<< "m_whiteBoardCtrl is null!, draw trails is failed" ;
    }
}

void MiniWhiteBoardCtrl::onDrawRemoteLine(QString command)
{
    if(m_socketHandler != NULL)
    {
        m_bufferModel.addMsg("temp", command);
        //emit sigDrawLine(adjustTrailMsg(command));
    }
    else
    {
        qWarning() << "draw remote line is failed, m_socketHandler is null!";
    }
}


void MiniWhiteBoardCtrl::init(const QString &pluginPathName)
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

void MiniWhiteBoardCtrl::uninit()
{
    if(m_whiteBoardCtrl)
    {
        unloadPlugin((QObject*)m_whiteBoardCtrl);
        m_whiteBoardCtrl = nullptr;
    }
}


bool MiniWhiteBoardCtrl::onDrawPolygon(const QJsonObject &polygonObj)
{
    return true;
}

bool MiniWhiteBoardCtrl::onDrawEllipse(const QJsonObject &ellipseObj)
{
    return true;
}



bool MiniWhiteBoardCtrl::onDrawLine(const QJsonObject &lineObj)
{
    if(m_socketHandler != nullptr)
    {
        QString s(m_socketHandler->trailReqMsgTemplate(lineObj));
        s = s.replace("\r\n", "").replace("\n", "").replace("\r", "").replace("\t", "").replace(" ", "");
        m_socketHandler->sendLocalMessage(s, true, false);
    }
    else
    {
        qWarning() << "draw line is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

bool MiniWhiteBoardCtrl::onDrawExpression(const QString &expressionUrl)
{
    return true;
}

bool MiniWhiteBoardCtrl::onScroll(double scrollX,double scrollY)
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

        QString message = m_socketHandler->zoomMsgTemplate(coursewareId,0.0,0.0,scrollY);
        m_socketHandler->sendLocalMessage(message, true, false);
    }
    else
    {
        qWarning() << "scroll is failed, m_socketHandler is null!";
        return false;
    }
    return true;
}

bool MiniWhiteBoardCtrl::onDrawImage(const QString &mdImageUrl, double pictureWidthRate, double pictureHeihtRate)
{
    return true;
}

bool MiniWhiteBoardCtrl::onDrawPointer(double xPos, double yPos)
{
    qint32 factorValX = 0, factorValY = 0; qint32  factor = 1000000;

    factorValX = qint32(xPos * factor);
    factorValY = qint32(yPos * factor);

    if(nullptr != m_socketHandler)
    {
        //发送教鞭命令
        QString message = m_socketHandler->pointReqMsgTemplate(factorValX, factorValY);
        m_socketHandler->sendLocalMessage(message, false, false); //fix: 教鞭不需要重绘画板, 不需要加入重发队列中, 直接发送至服务器
    }
    else
    {
        qWarning() << "draw pointer is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

bool MiniWhiteBoardCtrl::onUndo()
{

    return true;
}

bool MiniWhiteBoardCtrl::onClearTrails()
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

bool MiniWhiteBoardCtrl::onClearTrails(int type,int pageNo,int totalNum)
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

bool MiniWhiteBoardCtrl::onCurrentImageHeight(double height)
{
    GetOffsetImage::instance()->currrentImageHeight = height;
    return true;
}

bool MiniWhiteBoardCtrl::onCurrentBeBufferedImage(const QImage &image)
{
    GetOffsetImage::instance()->currentBeBufferedImage = image;
    return true;
}

bool MiniWhiteBoardCtrl::onCurrentTrailBoardHeight(double height)
{
    GetOffsetImage::instance()->currentTrailBoardHeight = height;
    return true;
}

bool MiniWhiteBoardCtrl::onOffSetImage(double offSetY)
{
    GetOffsetImage::instance()->getOffSetImage(offSetY);
    return true;
}

bool MiniWhiteBoardCtrl::onOffSetImage(const QString &imageUrl, double offSetY)
{
    GetOffsetImage::instance()->getOffSetImage(imageUrl, offSetY);
    return true;
}

double MiniWhiteBoardCtrl::getCurrentImageHeight()
{
    if(m_socketHandler->m_pages[m_socketHandler->m_currentCourse][m_socketHandler->m_currentPage].bgimg.isEmpty())
    {
        return GetOffsetImage::instance()->currentTrailBoardHeight;
    }
    else
    {
        return GetOffsetImage::instance()->currrentImageHeight;
    }
}

double MiniWhiteBoardCtrl::getResetOffsetY(double offsetY, double zoomRate)
{
    return 0;
}

double MiniWhiteBoardCtrl::getMidHeight()
{
    return StudentData::gestance()->midHeight;
}

QList<WhiteBoardMsg> MiniWhiteBoardCtrl::getCurrentTrailsMsg()
{
    QList<WhiteBoardMsg> whiteBoardMsgs;
    foreach (Msg mess, m_socketHandler->m_pages[m_socketHandler->m_currentCourse][m_socketHandler->m_currentPage].getMsgs())
    {
        WhiteBoardMsg m;
        m.msg = adjustTrailMsg(mess.msg);
        m.userId = "temp";
        whiteBoardMsgs.append(m);
    }

    return whiteBoardMsgs;
}

QString MiniWhiteBoardCtrl::adjustTrailMsg(const QString &trailMsg)
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


QObject* MiniWhiteBoardCtrl::loadPlugin(const QString &pluginPath)
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

void MiniWhiteBoardCtrl::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}
