/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  whiteboardctrinstance.cpp
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

#include "whiteboardctrlinstance.h"
#ifdef USE_WHITEBOARD
#include "../../classroom-tea/dataconfig/trailboard/whiteboardctrl.h"
#endif

#ifdef USE_MINI_WHITEBOARD
#include "../../classroom-tea_mini_2nd/dataconfig/trailboard/miniwhiteboardctrl.h"
#endif

#ifdef USE_MINI_STU_WHITEBOARD
#include "../../classroom-stu_mini_2nd/dataconfig/trailboard/ministuwhiteboardctrl.h"
#endif

QMutex WhiteBoardCtrlInstance::m_mutex;
WhiteBoardCtrlBase* WhiteBoardCtrlInstance::m_whiteBoardCtrl = nullptr;
WhiteBoardCtrlBase* WhiteBoardCtrlInstance::getInstance()
{
    m_mutex.lock();
    if(nullptr == m_whiteBoardCtrl)
    {

#ifdef USE_WHITEBOARD
            m_whiteBoardCtrl = new WhiteBoardCtrl();
#endif

#ifdef USE_MINI_WHITEBOARD
            m_whiteBoardCtrl = new MiniWhiteBoardCtrl();
#endif

#ifdef USE_MINI_STU_WHITEBOARD
            m_whiteBoardCtrl = new MiniStuWhiteBoardCtrl();
#endif

    }
    m_mutex.unlock();

    return m_whiteBoardCtrl;
}
