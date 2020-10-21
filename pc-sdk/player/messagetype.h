/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  messagetype.h
 *  Description: msg type
 *
 *  Author: ccb
 *  Date: 2019/7/03 11:30:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/7/03    V4.5.1       创建文件
*******************************************************************************/

#ifndef MESSAGETYPE_H
#define MESSAGETYPE_H

//协议指令管理--begin
const QString kSocketCmd = "cmd";
const QString kSocketSn = "sn";
const QString kSocketMn = "mn";
const QString kSocketVer = "v";
const QString kSocketLid = "lid";
const QString kSocketUid = "uid";
const QString kSocketTs = "ts";
const QString kSocketHb = "hb";
const QString kSocketAck = "ack";
const QString kSocketContent = "content";
const QString kSocketEnterRoom = "enterRoom";
const QString kSocketExitRoom = "exitRoom";
const QString kSocketEnterFailed = "enterFailed";
const QString kSocketFinish = "finish";
const QString kSocketUsersStatus = "usersStatus";
const QString kSocketSynFin = "synFin";
const QString kSocketTrail = "trail";
const QString kSocketPoint = "point";
const QString kSocketDoc = "doc";
const QString kSocketDocUrls = "urls";
const QString kSocketAV = "av";
const QString kSocketPage = "page";
const QString kScoketPageId = "pageId";
const QString kSocketAuth = "auth";
const QString kSocketMuteAll = "muteAll";
const QString kSocketKickOut = "kickOut";
const QString kSocketZoom = "zoom";
const QString kSocketTk = "tk";
const QString kSocketRwnd = "rwnd";
const QString kSocketAppVersion = "appVersion";
const QString kSocketSysInfo = "sysInfo";
const QString kSocketDevInfo = "deviceInfo";
const QString kSocketUserType = "userType";
const QString kSocketPlat = "plat";
const QString kSocketIsOnline = "isOnline";
const QString kSocketCode = "code";
const QString kSocketIncludeSelf = "includeSelf";
const QString kSocketSynMn = "synMn";
const QString kSocketHttpData = "data";
const QString kSocketHttpMsgs = "msgs";
const QString kSocketDocPageNo = "pageNo";
const QString kSocketDocTotalNum = "totalNum";
const QString kSocketDocDockId = "dockId";
const QString kSocketAVFlag = "flag";
const QString kSocketTime = "time";
const QString kSocketPageOpType = "type";
const QString kSocketAuthUp = "up";
const QString kSocketAuthAudio = "audio";
const QString kSocketAuthVideo = "video";
const QString kSocketMuteAllRet = "ret";
const QString kSocketTEA = "TEA";
const QString kSocketTPC = "T";
const QString kSocketSPC = "S";
const QString kSocketSTU = "STU";
const QString kSocketPointX = "x";
const QString kSocketPointY = "y";
const QString kSocketOnlineState = "isOnline";
const QString kSocketDockDefault = "DEFAULT";
const QString kSocketDockDefaultZero = "000000";
const QString kSocketSuccess = "success";
const QString kSocketImages = "images";
const QString kSocketRatio = "ratio";
const QString kSocketOffsetX = "offsetX";
const QString kSocketOffsetY = "offsetY";
const QString kSocketOperation = "operation";
const QString kSocketReward = "reward";
const QString kSocketRoll = "roll";
const QString kSocketResponder = "responder";
const QString kSocketTimer = "timer";
const QString kSocketFlag = "flag";
const QString kSocketType = "type";
const QString kSocketStartClass = "startClass";
const QString kSocketStart = "start";
const QString kSocketEnd = "end";
const QString kSocketH5Url = "h5Url";
const QString kSocketDocType = "docType";
const QString kSocketPlayAnimation = "playAnimation";
const QString kSocketStep = "step";
const QString kSocketPageNo = "pageNo";
const QString kSocketPageId = "pageId";
//协议指令管理--end

#endif // MESSAGETYPE_H
