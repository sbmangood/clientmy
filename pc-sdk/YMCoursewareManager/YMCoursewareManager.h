#ifndef YMCOURSEWAREMANAGER_H
#define YMCOURSEWAREMANAGER_H

#include <QtCore/qglobal.h>
#include <QObject>
#include <QJsonObject>
#include <QString>
#include "MessageModel.h"

#if defined(YMCOURSEWAREMANAGER_LIBRARY)
#  define YMCOURSEWAREMANAGERSHARED_EXPORT Q_DECL_EXPORT
#else
#  define YMCOURSEWAREMANAGERSHARED_EXPORT Q_DECL_IMPORT
#endif

class YMCOURSEWAREMANAGERSHARED_EXPORT YMCoursewareManager : public QObject //,public YMCoursewareManagerCrtl
{
    Q_OBJECT
public:
    YMCoursewareManager();
private:
    static YMCoursewareManager *m_YMCoursewareManager;

public:
    virtual ~YMCoursewareManager();
    static YMCoursewareManager *getInstance();// 课件管理类单例
    static void release();// 课件管理类单例释放

    /**********************************
     * 发信号通知qml的接口
     * *******************************/
    void sendSigCurrentQuestionId(QString planId, QString columnId, QString questionId, double offsetY, bool questionBtnStatus);
    void sendSigSynCoursewareType(int courseware, QString h5Url);
    void sendSigSynCoursewareInfo(QJsonObject jsonObj);// 同步课件信息-H5
    void sendSigSynCoursewareStep(QString pageId, int step);// 同步课件动画步数-H5
    void sendSigShowCourseware();// 显示课件信号
    void sendSigHideCourseware();// 隐藏课件信号
    void sendSigPlanChange(long lessonId, long planId, long itemId); // 当前讲义信号
    void sendSigCurrentColumn(long planId, long columnId); // 当前栏目
    void sendSigOffsetY(double offsetY);// 当前课件显示偏移量
    void sendSigDrawPage(MessageModel model);// 一页课件数据
    void sendSigIsCourseWare(bool isCourseware);// 是否为课件
    void sendSigEnterOrSync(int sync);// 进入后同步信号
    void sendSigPlayAnimation(QString pageId, int step);// 设置动画播放
    void sendSigH5GoPage(int pageIndex);// H5
    void sendSigH5AddPage();
    void sendSigH5DelPage();
    void sendSigAnimationInfo(int pageNo, int step);// 动画信息

signals:
    // 讲义信号属性介绍：当前题目ID：讲义Id,栏目Id，题目Id, 题目类型(0:题目，1:课件截图，2:空白页),offsetY:坐标，questionBtnStatus：题目状态
    void sigCurrentQuestionId(QString planId, QString columnId, QString questionId, double offsetY, bool questionBtnStatus);
    void sigCurrentCourse(QString currentCourse);// 当前课件信号,解耦TemporaryParameter::gestance()->m_currentCourse = m_currentCourse, 信号传出后连接槽函数实现
    void sigPageSaveInsert(QString currentCourse, int currentPage);// 保存课件页信号，解耦TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage), 信号传出后连接槽函数实现
    void sigSynCoursewareType(int courseware, QString h5Url);
    void sigSynCoursewareInfo(QJsonObject jsonObj);// 同步课件信息-H5
    void sigSynCoursewareStep(QString pageId, int step);// 同步课件动画步数-H5
    void sigShowCourseware();// 显示课件信号
    void sigHideCourseware();// 隐藏课件信号
    // 同步历史记录
    void sigPlanChange(long lessonId, long planId, long itemId); // 当前讲义信号
    void sigCurrentColumn(long planId, long columnId); // 当前栏目
    void sigOffsetY(double offsetY);// 当前课件显示偏移量
    void sigDrawPage(MessageModel model);// 一页课件数据
    void sigTotalPage(int totalPage);// 总页数
    void sigIsCourseWare(bool isCourseware);// 是否为课件
    void sigEnterOrSync(int sync);// 进入后同步信号
    void sigSendUrl(QString urls, double width, double height, bool isLongImg, QString questionId);
    void sigCurrentPage(int currentPage);// 当前页码信号
    void sigPlayAnimation(QString pageId, int step);// 设置动画播放
    void sigH5GoPage(int pageIndex);// H5
    void sigH5AddPage();
    void sigH5DelPage();
    void sigAnimationInfo(int pageNo, int step);// 动画信息

};

#endif // YMCOURSEWAREMANAGER_H
