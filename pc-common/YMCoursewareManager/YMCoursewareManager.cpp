#include "YMCoursewareManager.h"

YMCoursewareManager* YMCoursewareManager::m_YMCoursewareManager = NULL;

YMCoursewareManager::YMCoursewareManager()
{
    m_YMCoursewareManager = this;
}

YMCoursewareManager::~YMCoursewareManager()
{

}

YMCoursewareManager* YMCoursewareManager::getInstance()
{
    if(NULL == m_YMCoursewareManager)
    {
        m_YMCoursewareManager = new YMCoursewareManager();
    }
    return m_YMCoursewareManager;
}

void YMCoursewareManager::release()
{
    if(NULL != m_YMCoursewareManager)
    {
        delete m_YMCoursewareManager;
        m_YMCoursewareManager = NULL;
    }
}

void YMCoursewareManager::sendSigCurrentQuestionId(QString planId, QString columnId, QString questionId, double offsetY, bool questionBtnStatus)// 当前栏目Id
{
    emit sigCurrentQuestionId(planId, columnId, questionId, offsetY, questionBtnStatus);
}

void YMCoursewareManager::sendSigSynCoursewareType(int courseware, QString h5Url)// 同步课件类型
{
    emit sigSynCoursewareType(courseware, h5Url);
}

void YMCoursewareManager::sendSigSynCoursewareInfo(QJsonObject jsonObj)// 同步课件信息-H5
{
    emit sigSynCoursewareInfo(jsonObj);
}

void YMCoursewareManager::sendSigSynCoursewareStep(QString pageId, int step)// 同步课件动画步数-H5
{
    emit sigSynCoursewareStep(pageId, step);
}

void YMCoursewareManager::sendSigShowCourseware()// 显示课件信号
{
    emit sigShowCourseware();
}

void YMCoursewareManager::sendSigHideCourseware()// 隐藏课件信号
{
    emit sigHideCourseware();
}

void YMCoursewareManager::sendSigPlanChange(long lessonId, long planId, long itemId) // 当前讲义信号
{
    emit sigPlanChange(lessonId, planId, itemId);
}

void YMCoursewareManager::sendSigCurrentColumn(long planId, long columnId) // 当前栏目
{
    emit sigCurrentColumn(planId, columnId);
}

void YMCoursewareManager::sendSigOffsetY(double offsetY)// 当前课件显示偏移量
{
    emit sigOffsetY(offsetY);
}

void YMCoursewareManager::sendSigDrawPage(MessageModel model)// 一页课件数据
{
    emit sigOffsetY(model.offsetY);
    //emit sigDrawPage(model);
    bool isLongImg = (model.questionId == "") ? false :  (model.bgimg == ""  ? false : true);
    emit sigSendUrl(model.bgimg, model.width, model.height, isLongImg, model.questionId);
    emit sigCurrentPage(model.getCurrentPage());
    emit sigTotalPage(model.getTotalPage());
}

void YMCoursewareManager::sendSigIsCourseWare(bool isCourseware)// 是否为课件
{
    emit sigIsCourseWare(isCourseware);
}

void YMCoursewareManager::sendSigEnterOrSync(int sync)// 进入后同步信号
{
    emit sigEnterOrSync(sync);
}
