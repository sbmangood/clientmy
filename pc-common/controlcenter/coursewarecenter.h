/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  coursewarecenter.h
 *  Description: courseware center class
 *
 *  Author: ccb
 *  Date: 2019/08/01 10:10:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/08/01    V4.5.1       创建文件
*******************************************************************************/

#ifndef COURSEWARECENTER_H
#define COURSEWARECENTER_H
#include "datacenter.h"
#include "controlcenter.h"
#include "../YMCoursewareManager/YMCoursewareManager.h"

class CoursewareCenter
{
public:
    CoursewareCenter(ControlCenter* controlCenter);
    ~CoursewareCenter();

    // 初始化课件
    void init(const QString &pluginPathName);
    // 反初始化课件
    void uninit();
    // 同步课件历史记录
    void syncCoursewareHistroy();
    //H5课件同步处理
    void updateH5SynCousewareInfo();
    // 通过docId得到当前页
    int getCurrentPage(QString docId);
    // 跳转课件页,type 1翻页 2加页 3减页
    void goCourseWarePage(int type, int pageNo, int totalNumber);
    //更新课件信息
    bool updateCoursewareInfo(QString& coursewareId, QString &coursewareMsg);
    // 加载课件
    void insertCourseWare(QJsonArray imgUrlList, QString fileId, QString h5Url, int coursewareType);

    // 加空白页
    void addPage();
     // 减页
    void delPage();
    // 翻页指定到某一个页
    void goPage(int pageIndex);
    // 设置当前页与全部页数据
    void setPageData();
    // 缓存课件信息
    void cacheDocInfo(QJsonArray coursewareUrls, QString coursewareId,int coursewareType);
    // 一页课件数据
    void sendSigDrawPage(MessageModel model);
    // 同步课件类型
    void sendSigSynCoursewareType(int courseware, QString h5Url);

private:
    ControlCenter* m_controlCenter;
    YMCoursewareManager* m_YMCoursewareManager;
};

#endif // COURSEWARECENTER_H
