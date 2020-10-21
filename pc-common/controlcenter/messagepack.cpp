/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  messagepack.cpp
 *  Description: msg pack class
 *
 *  Author: ccb
 *  Date: 2019/7/03 11:07:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/7/03    V4.5.1       创建文件
*******************************************************************************/

#include <QMutexLocker>
#include "messagepack.h"
#include "messagetype.h"
#include "datamodel.h"

QMutex MessagePack::m_instanceMutex;
MessagePack* MessagePack::m_messagePack = nullptr;
MessagePack* MessagePack::getInstance()
{
    if(nullptr == m_messagePack)
    {
        m_instanceMutex.lock();
        if(nullptr == m_messagePack)
        {
            m_messagePack = new MessagePack();
        }
        m_instanceMutex.unlock();
    }

    return m_messagePack;
}

MessagePack::MessagePack()
{
    m_uMessageNum = 1;
}

MessagePack::~MessagePack()
{
}

//回执服务器请求消息模板
QString MessagePack::ackServerMsg(quint32 serverSn)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    //协议中的content内容
    content.insert(kSocketSn, (qint32)serverSn);
    content.insert(kSocketRwnd, 1);//暂时滑动窗口为1

    QString msg = createMessageTemplate(kSocketAck, lid, uid, content);
    return msg;
}

//客户端心跳信息模板
QString MessagePack::keepAliveReqMsg()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    QString msg = createMessageTemplate(kSocketHb, lid, uid, content);
    return msg;
}

//进入房间请求消息模板
QString MessagePack::enterRoomReqMsg(bool &bServerResp, bool &bConfirmFinish)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    qDebug() << "UID:" << StudentData::gestance()->m_currentUserId << StudentData::gestance()->m_lessonId <<  uid;

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketTk, StudentData::gestance()->m_token);
    content.insert(kSocketAppVersion, StudentData::gestance()->m_appVersion);
    content.insert(kSocketSysInfo, StudentData::gestance()->m_sysInfo);
    content.insert(kSocketDevInfo, StudentData::gestance()->m_deviceInfo);
    content.insert(kSocketUserType, kSocketTEA);
    content.insert(kSocketPlat, kSocketTPC);

    //进入房间-第一条信息
    bServerResp = true;

    //进入房间-结束课程设置为false
    bConfirmFinish = false;

    QString msg = createMessageTemplate(kSocketEnterRoom, lid, uid, content);
    return msg;
}

QString MessagePack::syncUserHistroyReqMsg(quint8 self, quint32 uServerSn)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    //fix: 新协议lid,uid使用string
    QString qsLid = QString::number(lid);
    QString qsUid = QString::number(uid);

     //协议中的content内容
    content.insert(kSocketLid, qsLid);
    content.insert(kSocketUid, qsUid);
    content.insert(kSocketSynMn,(qint32)uServerSn);
    content.insert(kSocketIncludeSelf, self);

    QJsonDocument doc(content);
    return QString(doc.toJson(QJsonDocument::Compact));
}

QString MessagePack::syncUserHistroyFinMsg()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    QString msg = createMessageTemplate(kSocketSynFin, lid, uid, content);
    return msg;
}

 QString MessagePack::trailReqMsg(QJsonObject content, const QString &currentCourse,  const int currentPage)
 {
     if(!content.isEmpty())
     {
         quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
         quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

         //fix: 协议中新增dockId pageId
         QString dockId = currentCourse;
         if(dockId == kSocketDockDefault)
         {
             dockId = "000000"; //fix: 本地有kSocketDockDefault, 则设置为QString("0")
         }

         QString pageId = QString::number(currentPage);

         content.insert(kSocketDocDockId, dockId);
         content.insert(kSocketPageId, pageId);

         QString msg = createMessageTemplate(kSocketTrail, lid, uid, content);
         return msg;
     }
     else
     {
         return "";
     }
 }

 QString MessagePack::pointReqMsg(qint32 x, qint32 y)
 {
     quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
     quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

     QJsonObject content;

      //协议中的content内容
     content.insert(kSocketPointX, x);
     content.insert(kSocketPointY, y);

     QString msg = createMessageTemplate(kSocketPoint, lid, uid, content);
     return msg;
 }

 QString MessagePack::docReqMsg(int currPageNo, int pageTotal, QString coursewareId,QJsonArray imgUrlList,QString h5Url,int docType)
 {
     quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
     quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

     QJsonObject content;

      //协议中的content内容
     content.insert(kSocketDocPageNo, currPageNo);
     content.insert(kSocketDocTotalNum, pageTotal);
     content.insert(kSocketDocDockId, coursewareId);
     content.insert(kSocketDocUrls,imgUrlList);
     content.insert(kSocketH5Url,h5Url);
     content.insert(kSocketDocType,docType);
     QString msg = createMessageTemplate(kSocketDoc, lid, uid, content);
     return msg;
 }

 QString MessagePack::avReqMsg(int playStatus, int timeSec, QString coursewareId,QString path,QString suffix)
  {
      quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
      quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

      QJsonObject content;

       //协议中的content内容
      content.insert(kSocketAVFlag, playStatus);
      content.insert(kSocketTime, timeSec);
      content.insert(kSocketDocDockId, coursewareId);
      content.insert(kSocketAVPath,path);
      content.insert(kSocketAVSuffix,suffix);
      QString msg = createMessageTemplate(kSocketAV, lid, uid, content);
      return msg;
  }

QString MessagePack::pageReqMsg(int opType, int currPageNo, int pageTotal, QString coursewareId, const int currentPage)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketPageOpType, opType);
    content.insert(kSocketDocPageNo, currPageNo);
    content.insert(kSocketDocTotalNum, pageTotal);
    content.insert(kSocketDocDockId, coursewareId);

    //fix: 协议中新增pageId
    QString pageId = QString::number(currentPage);
    content.insert(kSocketPageId, pageId);

    QString msg = createMessageTemplate(kSocketPage, lid, uid, content);
    return msg;
}

QString MessagePack::authReqMsg(QString whoUid, qint8 upState, qint8 trailState, qint8 audioState, qint8 videoState)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    //fix: 新协议lid,uid使用string
    QString qsWhoUid = whoUid;

     //协议中的content内容
    content.insert(kSocketUid, qsWhoUid);
    content.insert(kSocketAuthUp, upState);
    content.insert(kSocketTrail, trailState);
    content.insert(kSocketAuthAudio, audioState);
    content.insert(kSocketAuthVideo, videoState);
    qDebug() << "=====pageReqMsgTemplate========";
    QString msg = createMessageTemplate(kSocketAuth, lid, uid, content);
    return msg;
}

QString MessagePack::muteAllReqMsg(int muteAllState)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketMuteAllRet, muteAllState);

    QString msg = createMessageTemplate(kSocketMuteAll, lid, uid, content);
    return msg;
}

QString MessagePack::kickOutReqMsg()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    QString msg = createMessageTemplate(kSocketKickOut, lid, uid, content);
    return msg;
}

QString MessagePack::exitRoomReqMsg(bool &bConfirmFinish)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    //退出房间-设置为true
    bConfirmFinish = true;

    QString msg = createMessageTemplate(kSocketExitRoom, lid, uid, content);
    return msg;
}

QString MessagePack::finishMsg(bool &bConfirmFinish)
{
    quint64 lid = StudentData::gestance()->m_lessonId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    //退出房间-结束课程设置为true
    bConfirmFinish = true;

    QString msg = createMessageTemplate(kSocketFinish, lid, uid, content);
    return msg;
}

QString MessagePack::zoomMsg(QString coursewareId, double ratio, double offsetX, double offsetY, const int currentPage)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    QString pageId = QString::number(currentPage);

    //调节精度
    int  factor = 1000000;

    qint32 factorRatio = qint32(ratio * factor);
    qint32 factorOffsetX = qint32(offsetX * factor);
    qint32 factorOffsetY = qint32(offsetY * factor);

     //协议中的content内容
    content.insert(kSocketDocDockId, coursewareId);
    content.insert(kSocketPageId, pageId);
    content.insert(kSocketRatio, factorRatio);
    content.insert(kSocketOffsetX, factorOffsetX);
    content.insert(kSocketOffsetY, factorOffsetY);

    QString msg = createMessageTemplate(kSocketZoom, lid, uid, content);
    return msg;
}

QString MessagePack::operationMsg(int opType, int pageNo, int totalNum,QString coursewareId, const int currentPage)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketPageOpType,opType);
    content.insert(kSocketDocPageNo, pageNo);
    content.insert(kSocketDocTotalNum, totalNum);
    QString pageId = QString::number(currentPage);
    content.insert(kSocketPageId,pageId);
    content.insert(kSocketDocDockId,coursewareId);

    QString msg = createMessageTemplate(kSocketOperation, lid, uid, content);
    return msg;
}

QString MessagePack::rewardMsg(QString whoUid, int rewardType, int millisecond, QString userName)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketUid, whoUid);
    content.insert(kSocketType, rewardType);
    content.insert(kSocketTime, millisecond);
    content.insert(kSocketName, userName);

    QString msg = createMessageTemplate(kSocketReward, lid, uid, content);
    return msg;
}

QString MessagePack::rollMsg(QString whoUid, int rollType, QString userName)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketUid, whoUid);
    content.insert(kSocketType, rollType);
    content.insert(kSocketName, userName);

    QString msg = createMessageTemplate(kSocketRoll, lid, uid, content);
    return msg;
}

QString MessagePack::responderMsg(int respType, int timesec)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketType, respType);
    content.insert(kSocketTime, timesec);

    QString msg = createMessageTemplate(kSocketResponder, lid, uid, content);
    return msg;
}

QString MessagePack::timerMsg(int timerType, int flag, int timesec)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketType, timerType);
    content.insert(kSocketFlag, flag);
    content.insert(kSocketTime, timesec);

    QString msg = createMessageTemplate(kSocketTimer, lid, uid, content);
    return msg;
}

QString MessagePack::startClassMsg()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    QString msg = createMessageTemplate(kSocketStartClass, lid, uid, content);
    return msg;
}

QString MessagePack::playAnimationMsg(int step, const QString &currentCourse,  const int currentPage)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketDocPageNo, currentPage);
    content.insert(kSocketDocDockId,currentCourse);
    QString pageId = QString::number(currentPage);
    content.insert(kSocketPageId, pageId);
    content.insert(kSocketStep, step);

    QString msg = createMessageTemplate(kSocketPlayAnimation, lid, uid, content);
    return msg;
}

void MessagePack::fixUserSnFromServer(qint32 nMySn)
{
    QMutexLocker locker(&m_mMessageNumMutex);
    m_uMessageNum = nMySn;
}

// 全体禁音消息模板
QString MessagePack::muteAllReqMsgTemplate(int muteAllState)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketMuteAllRet, muteAllState);

    QString msg = createMessageTemplate(kSocketMuteAll, lid, uid, content);
    return msg;
}

//通用消息创建模板
QString MessagePack::createMessageTemplate(QString command, quint64 lid, quint64 uid, QJsonObject content)
{
    QJsonObject messageTemplate;
    if(kSocketAck == command || kSocketEnterRoom == command || kSocketHb == command || kSocketSynFin == command || kSocketPoint == command)
    {
        QMutexLocker locker(&m_mMessageNumMutex);
        messageTemplate[kSocketSn] = 0;
    }
    else
    {
        QMutexLocker locker(&m_mMessageNumMutex);
        messageTemplate[kSocketSn]  = (qint32)(m_uMessageNum++);
    }

    messageTemplate[kSocketVer] = COMMUNICATION_PROTOCOL_VER;
    messageTemplate[kSocketCmd] = command;

    QString qsLid = QString::number(lid);
    QString qsUid = QString::number(uid);

    messageTemplate.insert(kSocketLid, qsLid);
    messageTemplate.insert(kSocketUid, qsUid);

    //协议中的content内容
    if(!content.isEmpty())
    {
        messageTemplate[kSocketContent] = content;
    }

    QJsonDocument doc(messageTemplate);
    return QString(doc.toJson(QJsonDocument::Compact));
}






