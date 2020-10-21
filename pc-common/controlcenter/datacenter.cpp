/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  datacenter.cpp
 *  Description: data center class
 *
 *  Author: ccb
 *  Date: 2019/07/30 10:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/07/30    V4.5.1       创建文件
*******************************************************************************/

#include "datacenter.h"

QMutex DataCenter::m_instanceMutex;
DataCenter* DataCenter::m_dataCenter = nullptr;
DataCenter::DataCenter()
    :m_uServerSn(0)
    ,m_currentPage(0)
    ,m_currPageOp(0)
    ,m_currPageNo(0)
    ,m_currPageTotalNum(0)
    ,m_isOneStart(false)
    ,m_isRemovePage(false)
    ,m_currentCourse("DEFAULT")
{

}

DataCenter::~DataCenter()
{

}

DataCenter* DataCenter::getInstance()
{
    if(nullptr == m_dataCenter)
    {
        m_instanceMutex.lock();
        if(nullptr == m_dataCenter)
        {
            m_dataCenter = new DataCenter();
        }
        m_instanceMutex.unlock();
    }
    return m_dataCenter;
}
