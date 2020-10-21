/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  datacenter.h
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

#ifndef DATACENTER_H
#define DATACENTER_H
#include <QMutex>

#include "messagemodel.h"
#include "H5datamodel.h"
#include "../YMAudioVideoManager/iaudiovideoctrl.h"

class DataCenter
{
protected:
    DataCenter();

public:
    ~DataCenter();
    static DataCenter* getInstance();

    int m_currentDocType;// 当前课件类型
    int m_currentPage;// 当前页
    bool m_sysnStatus;// 是否同步
    QString m_currentCourseUrl;// 当前课件url
    QString m_currentCourse;// 当前课件
    QString m_currentPlanId;// 当前讲义Id
    QString m_currentColumnId;// 当前栏目Id
    QString m_currentQuestionId;// 当前题目Id
    bool m_currentQuestionButStatus;// 当前开始做题按钮状态
    double m_offsetY;// 当前滚动的坐标

    QList<H5dataModel> m_h5Model;// H5课件数据
    QMap<QString, int> m_pageSave;//每个课件的当前显示页码
    QMap<QString, QList<MessageModel> > m_pages;// 每个课件每一页的内容

    bool m_isRemovePage;// 记录课件是否被删除
    bool m_isGotoPageRequst;
    int m_currentStep;// 课件动画步数
    int m_currPageOp;// 当前页操作
    int m_currPageNo;// 当前页面编号
    int m_currPageTotalNum;// 当前课件总页数
    double m_currentImagaeOffSetY;// 当前图片偏移量
    double m_currentImageHeight;// 当前图片高度

    QString m_supplier;
    QString m_videoType;
    QString m_microphoneState;
    QString m_cameraState;
    ROLE_TYPE m_role;
    QString m_userId;
    QString m_lessonId;
    QString m_apiVersion;
    QString m_appVersion;
    QString m_token;
    QString m_strSpeaker;
    QString m_strMicPhone;
    QString m_strCamera;
    QString m_strDllFile;
    QString m_strAppName;
    QString m_channelKey;
    QString m_channelName;

    quint32   m_uMessageNum;//发送给服务器时的消息编号
    quint32   m_uServerSn;//服务器sn消息序列号
    QMutex  m_mMessageNumMutex;//消息序号锁

    bool m_bServerResp;                  //服务器是否已回复
    bool m_bConfirmFinish;               //确认结束(退出教室)
    bool m_isOneStart;//是否第一次启动

    int m_avFlag;
    int m_avPlayTime;
    QString m_avId;

private:
    static QMutex m_instanceMutex;
    static DataCenter* m_dataCenter;
};

#endif // DATACENTER_H
