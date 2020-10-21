/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  whiteboardctrinstance.h
 *  Description: whiteboard control instance class
 *
 *  Author: ccb
 *  Date: 2019/05/22 10:10:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/05/22    V4.5.1       创建文件
*******************************************************************************/

#ifndef WHITEBOARDCTRLINSTANCE_H
#define WHITEBOARDCTRLINSTANCE_H
#include <QMutex>

class WhiteBoardCtrlBase;
class WhiteBoardCtrlInstance
{
private:
    WhiteBoardCtrlInstance() {;}

public:
    static WhiteBoardCtrlBase* getInstance();
private:
    static QMutex m_mutex;
    static WhiteBoardCtrlBase* m_whiteBoardCtrl;
};

#endif // WHITEBOARDCTRLINSTANCE_H
