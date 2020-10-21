#ifndef YMCOURSEWAREMANAGERCRTL_H
#define YMCOURSEWAREMANAGERCRTL_H
#include <QObject>
#include <QJsonObject>
#include "MessageModel.h"

class YMCoursewareManagerCrtl : public QObject
{
    Q_OBJECT
public:
    virtual void sendSigCurrentQuestionId(QString planId, QString columnId, QString questionId, double offsetY, bool questionBtnStatus) = 0;
    virtual void sendSigSynCoursewareType(int courseware, QString h5Url) = 0;
    virtual void sendSigSynCoursewareInfo(QJsonObject jsonObj) = 0;// 同步课件信息-H5
    virtual void sendSigSynCoursewareStep(QString pageId, int step) = 0;// 同步课件动画步数-H5
    virtual void sendSigShowCourseware() = 0;// 显示课件信号
    virtual void sendSigHideCourseware() = 0;// 隐藏课件信号
    virtual void sendSigPlanChange(long lessonId, long planId, long itemId) = 0; // 当前讲义信号
    virtual void sendSigCurrentColumn(long planId, long columnId) = 0; // 当前栏目
    virtual void sendSigOffsetY(double offsetY) = 0;// 当前课件显示偏移量
    virtual void sendSigDrawPage(MessageModel model) = 0;// 一页课件数据
    virtual void sendSigIsCourseWare(bool isCourseware) = 0;// 是否为课件
    virtual void sendSigEnterOrSync(int sync) = 0;// 进入后同步信号
};

Q_DECLARE_INTERFACE(YMCoursewareManagerCrtl,"sdafasdfsadfsadfsadfsabc")

#endif // YMCOURSEWAREMANAGERCRTL_H
