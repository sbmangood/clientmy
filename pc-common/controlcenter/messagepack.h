/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  messagepack.h
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

#ifndef MESSAGEPACK_H
#define MESSAGEPACK_H
#include <QMutex>
#include <qglobal.h>
#include <QJsonObject>

class MessagePack
{
public:
    static MessagePack* getInstance();

    QString ackServerMsg(quint32 serverSn);
    QString keepAliveReqMsg(void);
    QString enterRoomReqMsg(bool &bServerResp, bool &bConfirmFinish);
    QString syncUserHistroyReqMsg(quint8 self, quint32 uServerSn);
    QString syncUserHistroyFinMsg(void);
    QString trailReqMsg(QJsonObject content, const QString &currentCourse,  const int currentPage);
    QString pointReqMsg(qint32 x, qint32 y);
    QString docReqMsg(int currPageNo, int pageTotal, QString coursewareId,QJsonArray imgUrlList,QString h5Url,int docType);
    QString avReqMsg(int playStatus, int timeSec, QString coursewareId,QString path,QString suffix);
    QString pageReqMsg(int opType, int currPageNo, int pageTotal, QString coursewareId, const int currentPage);
    QString authReqMsg(QString whoUid, qint8 upState, qint8 trailState, qint8 audioState, qint8 videoState);
    QString muteAllReqMsg(int muteAllState);
    QString kickOutReqMsg(void);
    QString exitRoomReqMsg(bool &bConfirmFinish);
    QString finishMsg(bool &bConfirmFinish);
    QString zoomMsg(QString coursewareId, double ratio, double offsetX, double offsetY, const int currentPage);
    QString operationMsg(int opType,int pageNo,int totalNum,QString coursewareId, const int currentPage);
    QString rewardMsg(QString whoUid, int rewardType, int millisecond, QString userName);
    QString rollMsg(QString whoUid, int rollType, QString userName);
    QString responderMsg(int respType, int timesec);
    QString timerMsg(int timerType, int flag, int timesec);
    QString startClassMsg(void);
    QString playAnimationMsg(int step, const QString &currentCourse,  const int currentPage);
    QString muteAllReqMsgTemplate(int muteAllState); // 全体禁音消息模板

    void fixUserSnFromServer(qint32 nMySn);

private:
    explicit MessagePack();
    ~MessagePack();

    //创建消息模板函数
    QString createMessageTemplate(QString command, quint64 lid, quint64 uid, QJsonObject content);

private:
    static QMutex m_instanceMutex;
    static MessagePack* m_messagePack;

    quint32 m_uMessageNum;//发送给服务器时的消息编号
    QMutex  m_mMessageNumMutex;//消息序号锁
};

#endif // MESSAGEPACK_H
