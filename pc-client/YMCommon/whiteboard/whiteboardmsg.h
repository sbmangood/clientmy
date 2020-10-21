/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  whiteboardmsg.h
 *  Description: whiteboard msg class, dock external messages
 *
 *  Author: ccb
 *  Date: 2019/05/18 10:12:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/05/18    V4.5.1       创建文件
*******************************************************************************/
#ifndef WHITEBOARDMSG_H
#define WHITEBOARDMSG_H

#include <QObject>

class WhiteBoardMsg
{
    public:
        WhiteBoardMsg()
            : msg("")
            , userId(""){ ;}
        virtual ~WhiteBoardMsg() { ;}

        QString msg;
        QString userId;
};

#endif // WHITEBOARDMSG_H
