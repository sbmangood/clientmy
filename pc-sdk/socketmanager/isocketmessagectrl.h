/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  iinstantmessagectrl.h
 *  Description: instantmessage ctrl interface
 *
 *  Author: ccb
 *  Date: 2019/06/20 15:20:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/06/20    V4.5.1       创建文件
*******************************************************************************/

#ifndef IINSTANTMESSAGECTRL_H
#define IINSTANTMESSAGECTRL_H
#include <QVariantList>

class ISocketMessageCallBack;
class ISocketMessageCtrl
{
public:

    virtual ~ISocketMessageCtrl(){}
    //设置IM回调
    virtual void setSocketMessageCallBack(ISocketMessageCallBack *instantMessageCallBack = 0) = 0;
    //初始化socket message
    virtual void initSocketMessageCtrl(const QVariantList &goodIpList, const QString &address, int port, int serverDelay, int serverLost) = 0;
    //反初始化socket message
    virtual void uninitSocketMessageCtrl() = 0;
    //检查服务器回复
    virtual bool checkServerResponse(QString target, bool bConfirmFinish) = 0;
    //消息异步推送
    virtual void asynSendMessage(const QString message) = 0;
    //消息同步推送
    virtual void syncSendMessage(const QString &message) = 0;

};

Q_DECLARE_INTERFACE(ISocketMessageCtrl,"org.qt-project.Qt.Plugin.ISocketMessageCtrl/1.0")
#endif // IINSTANTMESSAGECTRL_H
