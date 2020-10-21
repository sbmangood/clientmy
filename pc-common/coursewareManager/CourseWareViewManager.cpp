#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include "CourseWareViewManager.h"


CourseWareViewManager::CourseWareViewManager(QObject *parent): QObject(parent)
#ifdef USE_OSS_AUTHENTICATION
  , currentBeBufferModel(0, "", 1.0, 1.0, "", "0", 0, false, 0)
#else
   ,currentBeBufferModel(0, "", 1.0, 1.0, "", "0", 0, false)
#endif
{

}

// 得到课件显示视图
void CourseWareViewManager::getCourseWareView(int coursewareType, QString courseId, QJsonArray courseArry)
{
    if(coursewareType == 1)// 图片课件
    {
        addCommonCourse(courseId, courseArry);
    }
    else if(coursewareType == 2)// 结构化课件
    {
        addStructCourse(courseId, courseArry);
    }
    else if(coursewareType == 3)// H5课件
    {

    }
    emit sigGetCourseWareView();
}

// 增加空白页
void CourseWareViewManager::addPage()
{
#ifdef USE_OSS_AUTHENTICATION
    m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
    m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif
    QStringList strList = m_currentCourse.split("|");
    if(strList.size() > 1)
    {
        QString planId = strList.at(0);
        QString columnId = strList.at(1);
        emit sigCurrentQuestionId(planId, columnId, "", 0, false);
    }
}

// 添加图片页
void CourseWareViewManager::addImagePage(QString url, int width, int height)
{
    QStringList strList = m_currentCourse.split("|");
    QString questionId = "-2";
    if(strList.size() > 1)
    {
        questionId = "-1";
    }
#ifdef USE_OSS_AUTHENTICATION
    m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height, questionId, "0", 0, false, 0));
#else
    m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height, questionId, "0", 0, false));
#endif
}

// 减页
void CourseWareViewManager::delPage()
{
    if (m_pages[m_currentCourse].size() == 1)
    {
        m_pages[m_currentCourse][0].release();
        m_pages[m_currentCourse].removeAt(0);
#ifdef USE_OSS_AUTHENTICATION
        m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
        m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif

        QStringList strList = m_currentCourse.split("|");
        if(strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            emit sigCurrentQuestionId(planId, columnId, "", 0, false);
        }
        return;
    }
    m_pages[m_currentCourse][m_currentPage].release();
    m_pages[m_currentCourse].removeAt(m_currentPage);
    m_currentPage = m_currentPage >= m_pages[m_currentCourse].size() ? m_pages[m_currentCourse].size() - 1 : m_currentPage;

    QStringList strList = m_currentCourse.split("|");
    if(strList.size() > 1)
    {
        QString planId = strList.at(0);
        QString columnId = strList.at(1);
        QString docId = planId + "|" + columnId;
        if(m_pages.contains(docId))
        {
            QString questionId = m_pages[docId].at(m_currentPage).questionId;
            emit sigCurrentQuestionId(planId, columnId, questionId, 0, false);
        }
    }
}

// 翻页到指定的一页
void CourseWareViewManager::goPage(int pageIndex)
{
    pageIndex = pageIndex < 0 ? 0 : pageIndex;
    if (pageIndex > m_pages[m_currentCourse].size() - 1)
    {
        pageIndex = m_pages[m_currentCourse].size() - 1;
    }
    m_currentPage = pageIndex;

    QStringList strList =  m_currentCourse.split("|");
    if(strList.size() > 1)
    {
        QString planId = strList.at(0);
        QString columnId = strList.at(1);
        if(m_pages.contains(m_currentCourse))
        {
            if(m_pages[m_currentCourse].size() > 1)
            {
                QString questionId = m_pages[m_currentCourse].at(m_currentPage).questionId;
                double m_offsetY = m_pages[m_currentCourse].at(m_currentPage).offsetY;
                bool m_questionStatus = m_pages[m_currentCourse].at(m_currentPage).questionBtnStatus;

                m_pageSave.insert(m_currentCourse, m_currentPage);
                if(m_sysnStatus)
                {
                    emit sigCurrentQuestionId(planId, columnId, questionId, m_offsetY, m_questionStatus);
                }
            }
        }
    }
}

// 设置单个课件数据
void CourseWareViewManager::setCourseWareData(QString message)
{
    QJsonObject dataObj = QJsonDocument::fromJson(message.toLatin1().data()).object();
    QJsonObject contentObj = dataObj.value("content").toObject();
    // 图片课件url
    QJsonArray urlArray = contentObj.value("urls").toArray();
    if(urlArray.size() == 0)
    {
        emit sigGetCoursewareFaill();
        return;
    }
    // 图片课件当前索引值
    m_currentPage = contentObj.value("pageIndex").toString().toInt();
    emit sigSendLocalSocketMessage(message, true, true);
    // 翻页
    QString pageStr = QString("{\"domain\":\"page\",\"command\":\"goto\",\"content\":{\"page\":\"" + QString::number(m_currentPage) + "\"}}");
    emit sigSendLocalSocketMessage(pageStr, true, false);// 此命令需要通过socket发出去
}

// 根据指定区域截屏
QBitmap CourseWareViewManager::screenshot(int x, int y, int w, int h)
{
    QBitmap qBitmap;
    return qBitmap;
}

// 显示当前view
void CourseWareViewManager::show()
{
    emit sigShowCourseWareView();
}

// 隐藏当前view
void CourseWareViewManager::hide()
{
    emit sigHideCourseWareView();
}

// 获取当前课件页信息
CourseWarePageInfo CourseWareViewManager::getPageInfo()
{
    CourseWarePageInfo courseWarePageInfo;
    return courseWarePageInfo;
}

// 设置是否能相应touch事件
void CourseWareViewManager::setCanTouch(bool isCanTouch)
{

}

// 设置回调接口
void CourseWareViewManager::setCourseWareCallBack(ICourseWareCallBack iCourseWareCallBack)
{

}

#ifdef USE_OSS_AUTHENTICATION
//OSS过期重新签名URL
QString CourseWareViewManager::getOssSignUrl(QString key)
{
    QVariantMap  reqParm;
    reqParm.insert("key", key);
    reqParm.insert("expiredTime", 1800 * 1000);
    reqParm.insert("token", YMUserBaseInformation::token);

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString httpUrl = m_httpClient->getRunUrl(0);
    QString url = "https://" + httpUrl + "/api/oss/make/sign"; //环境切换要注意更改
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject allDataObj = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "***********allDataObj********" << url << reqParm;
    //qDebug() << "=======aaa=========" << allDataObj << key;

    if(allDataObj.value("result").toString().toLower() == "success")
    {
        QString url = allDataObj.value("data").toString();
        qDebug() << "*********url********" << url;
        return url;
    }
    else
    {
        qDebug() << "CourseWareViewManager::getOssSignUrl" << allDataObj;
    }

    return "";
}

QString CourseWareViewManager::checkOssSign(QString imgUrl)
{
    //重新验签处理返回URL
    if(imgUrl != "" && StudentData::gestance()->coursewareSignOff)
    {
        long current_second = QDateTime::currentDateTime().toTime_t();
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        qDebug() << "==ssssssssss==" << current_second - model.expiredTime << current_second << model.expiredTime;
        if(model.expiredTime == 0 || current_second - model.expiredTime >= 1800)//30分钟该页重新请求一次验签
        {
            QString oldImgUrl = model.bgimg;
            int indexOf = oldImgUrl.indexOf(".com");
            int midOf = oldImgUrl.indexOf("?");
            QString key = oldImgUrl.mid(indexOf + 4, midOf - indexOf - 4);
            QString newImgUrl = getOssSignUrl(key);

            qDebug() << "=====drawPage::key=====" << imgUrl << newImgUrl;
            if(newImgUrl == "")
            {
                return imgUrl;
            }

            m_pages[m_currentCourse][m_currentPage].expiredTime = current_second;
            m_pages[m_currentCourse][m_currentPage].setImageUrl(newImgUrl, model.width, model.height);
            return newImgUrl;
        }
    }
    return imgUrl;
}
#endif

// 初始化默认课件页
void CourseWareViewManager::initDefaultCourse()
{
#ifdef USE_OSS_AUTHENTICATION
    m_httpClient = YMHttpClient::defaultInstance();
    m_httpUrl = m_httpClient->getRunUrl(1);
#endif

    QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif
    m_pages.insert("DEFAULT", list);
    m_currentPage = 0;
    m_currentCourse = "DEFAULT";
    m_sysnStatus = false;
}

void CourseWareViewManager::drawCurrentPageData(QString currentCourseId, int pageIndex)
{
    MessageModel model = m_pages[currentCourseId][pageIndex];
    model.setPage(m_pages[currentCourseId].size(), pageIndex);
#ifdef USE_OSS_AUTHENTICATION
    model.bgimg = checkOssSign(model.bgimg);
#endif
    currentBeBufferModel.clear();
    currentBeBufferModel = model;
    emit sigDrawPage(model);
    // 处理当前页需要被发送出去的数据
    bool isLongImg = (getCurrentMsgModel().questionId == "") ? false :  (getCurrentMsgModel().bgimg == ""  ? false : true);
    emit sigSendUrl(getCurrentMsgModel().bgimg, getCurrentMsgModel().width, getCurrentMsgModel().height, isLongImg, getCurrentMsgModel().questionId, getCurrentMsgModel().beShowedAsLongImg);
    emit sigOffsetY(model.offsetY);
    emit sigChangeCurrentPage(model.getCurrentPage());
    emit sigChangeTotalPage(model.getTotalPage());
}

bool CourseWareViewManager::judgeCurrentPageIsBlank()
{
    if(getCurrentMsgModel().height == 1 && getCurrentMsgModel().questionId != "" && getCurrentMsgModel().questionId != "-1" && getCurrentMsgModel().questionId != "-2" && getCurrentMsgModel().bgimg != "")
    {
        return false;// 不是空白页
    }
    return true;// 是空白页
}

bool CourseWareViewManager::judgeCurrentPageIsCourse(QString currentCourseId, int pageIndex)
{
    MessageModel model = m_pages[currentCourseId][pageIndex];
    return model.isCourware;
}

void CourseWareViewManager::insertReportPicture(QString imgUrl)
{
    QStringList strList = m_currentCourse.split("|");
    QString questionId = "-2";
    if(strList.size() > 1)
    {
        questionId = "-1";
    }
#ifdef USE_OSS_AUTHENTICATION
    MessageModel model = MessageModel(0, imgUrl, 1, 1, questionId, "0", 0, false, 0);
    model.beShowedAsLongImg = true;
    m_pages[m_currentCourse].insert(++m_currentPage,model);
#else
    MessageModel model = MessageModel(0, imgUrl, 1, 1, questionId, "0", 0, false);
    model.beShowedAsLongImg = true;
    m_pages[m_currentCourse].insert(++m_currentPage,model);
#endif
}

void CourseWareViewManager::getCurrentColumnData(QString currentCourseId, int pageIndex)
{
    QStringList strList = currentCourseId.split("|");
    if(strList.size() > 1)//新课件的时候才发这个信号
    {
        QString planId = strList.at(0);
        QString columnId = strList.at(1);
        MessageModel model = m_pages[currentCourseId][pageIndex];
        m_pageSave.insert(m_currentCourse, m_currentPage);
        emit sigCurrentQuestionId(planId, columnId, model.questionId, model.offsetY, model.questionBtnStatus);
    }
}

void CourseWareViewManager::drawCurrentColumnData(QJsonObject contentObj)
{
    QString columnId = contentObj.value("columnId").toString();
    QString planId = contentObj.value("planId").toString();
    QString docId = planId + "|" + columnId;
    if(m_pages.contains(docId))
    {
        m_currentCourse = docId;
        m_currentPage = m_pageSave.value(m_currentCourse, 0);
        m_currentPage = m_currentPage == 0 ? 1 : m_currentPage;
        if(m_currentPage >= m_pages[docId].size())
        {
            m_currentPage = 0;
            return;
        }
        QString currentQustionId = m_pages[docId].at(m_currentPage).questionId;
        drawCurrentPageData(docId,m_currentPage);
        if(m_sysnStatus)
        {
            emit sigCurrentQuestionId(planId, columnId, currentQustionId, 0, false);
        }
        m_currentPlanId = planId;
        m_currentColumnId = columnId;
        m_currentQuestionId = currentQustionId;
        emit sigCurrentColumn(planId.toLong(), columnId.toLong());
    }
}

void CourseWareViewManager::currentCourseDataStatus()
{
    drawCurrentPageData(m_currentCourse, m_currentPage);
    if(m_currentPlanId == "" && m_currentColumnId == "")
    {
        return;
    }
    emit sigPlanChange(0, m_currentPlanId.toLong(), m_currentColumnId.toLong());
    emit sigCurrentQuestionId(m_currentPlanId, m_currentColumnId, m_currentQuestionId, offsetY, m_currentQuestionButStatus);
    emit sigCurrentColumn(m_currentPlanId.toLong(), m_currentColumnId.toLong());
    emit sigOffsetY(offsetY);
}

int CourseWareViewManager::getCourseCurrentPage(QString courseId)
{
    int currentPage = 1;
    currentPage = m_pageSave.value(courseId, 1);
    return currentPage;
}

void CourseWareViewManager::setCourseInDefaultStatus()
{
    m_pages.clear();
    m_pageSave.clear();
    QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
    list.append(MessageModel(0, "", 1.0, 1.0, "", "1", 0, false, 0));
#else
    list.append(MessageModel(0, "", 1.0, 1.0, "", "1", 0, false));
#endif
    m_pages.insert("DEFAULT", list);
    m_currentPage = 0;
    m_currentCourse = "DEFAULT";
    drawCurrentPageData(m_currentCourse,m_currentPage);
}

void CourseWareViewManager::addTrailInCurrentPage(QString userId,QString trailMsg)
{
    m_pages[m_currentCourse][m_currentPage].addMsg(userId, trailMsg);
}

void CourseWareViewManager::unDoCurrentTrail(QString userId)
{
    m_pages[m_currentCourse][m_currentPage].undo(userId);
}

void CourseWareViewManager::clearCurrentPageTrail()
{
    m_pages[m_currentCourse][m_currentPage].clear();
}

void CourseWareViewManager::setCurrentQuestionStatus(bool status)
{
    if(status)
    {
        //m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(true);
        m_currentQuestionButStatus = true;
    }
    else
    {
        //m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(false);
        m_currentQuestionButStatus = false;
    }
}

void CourseWareViewManager::insertAutoPicture(QString imageUrl, double imgWidth, double imgHeight)
{
    m_pages[m_currentCourse][m_currentPage].bgimg = imageUrl;
    m_pages[m_currentCourse][m_currentPage].width = imgWidth;
    m_pages[m_currentCourse][m_currentPage].height = imgHeight;
    m_pages[m_currentCourse][m_currentPage].questionBtnStatus = false;
    //m_pages[m_currentCourse][m_currentPage].setImageUrl(imageUrl, imgWidth, imgHeight);
}

void CourseWareViewManager::setCurrentCursorOffsetY(double yValue)
{
    m_pages[m_currentCourse][m_currentPage].offsetY = yValue;//.setOffsetY(yValue);
}

void CourseWareViewManager::addCommonCourse(QString courseId, QJsonArray imgArry)
{
    if (m_pages.contains("DEFAULT"))
    {
        m_pages.insert(courseId, m_pages.value("DEFAULT"));
        m_pages.remove("DEFAULT");
        m_currentCourse = courseId;
        m_currentPage = m_pages[m_currentCourse].size();
        for (int i = 0; i < imgArry.size(); ++i)
        {
#ifdef USE_OSS_AUTHENTICATION
            m_pages[m_currentCourse].append(MessageModel(1, imgArry.at(i).toString(), 1.0, 1.0, "", "0", 0, false, 0));
#else
            m_pages[m_currentCourse].append(MessageModel(1, imgArry.at(i).toString(), 1.0, 1.0, "", "0", 0, false));
#endif
        }
    }
    else if (!m_pages.contains(courseId))
    {
        QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
        list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
        list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif
        m_pages.insert(courseId, list);
        m_pageSave.insert(m_currentCourse, m_currentPage);
        m_currentCourse = courseId;
        m_currentPage = 1;
        for (int i = 0; i < imgArry.size(); ++i)
        {
#ifdef USE_OSS_AUTHENTICATION
            m_pages[m_currentCourse].append(MessageModel(1, imgArry.at(i).toString(), 1.0, 1.0, "", "0", 0, false, 0));
#else
            m_pages[m_currentCourse].append(MessageModel(1, imgArry.at(i).toString(), 1.0, 1.0, "", "0", 0, false));
#endif
        }
    }
    else
    {
        m_pageSave.insert(m_currentCourse, m_currentPage);
        m_currentCourse = courseId;
        m_currentPage = m_pageSave.value(m_currentCourse, 0);
    }
    m_currentPlanId = courseId;
}

QString CourseWareViewManager::getCurrentCourseId()
{
    return m_currentCourse;
}

int CourseWareViewManager::getCurrentCourseCurrentIndex()
{
    return m_currentPage;
}

bool CourseWareViewManager::judgeCourseHasDefaultPage()
{
    return m_pages.contains("DEFAULT");
}

void CourseWareViewManager::addStructCourse(QString courseId, QJsonArray columnsArray)
{
    if(columnsArray.size() <= 0)
    {
        m_currentPage = 1;
        return;
    }
    QString itemId;
    for(int i = 0; i < columnsArray.size(); i++)
    {
        QJsonObject columnObj = columnsArray.at(i).toObject();
        QString columnId = columnObj.value("columnId").toString();
        QJsonArray questionsArray = columnObj.value("questions").toArray();
        if(i == 0 )
        {
            itemId = columnId;
        }
        QString docId = courseId + "|" + columnId;
        if (m_pages.contains("DEFAULT"))
        {
            m_pages.insert(docId, m_pages.value("DEFAULT"));
            m_pages.remove("DEFAULT");
            m_currentCourse = docId;
            m_currentPage = m_pages[m_currentCourse].size();
            for(int z = 0; z < questionsArray.size(); z++)
            {
                QString questionId = questionsArray.at(z).toString();
#ifdef USE_OSS_AUTHENTICATION
                m_pages[m_currentCourse].append(MessageModel(1, "", 1.0, 1.0, questionId, columnId, 0, false, 0));
#else
                m_pages[m_currentCourse].append(MessageModel(1, "", 1.0, 1.0, questionId, columnId, 0, false));
#endif
            }
        }
        else if (!m_pages.contains(docId))
        {
            QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
            list.append(MessageModel(0, "", 1.0, 1.0, "", columnId, 0, false, 0));
#else
            list.append(MessageModel(0, "", 1.0, 1.0, "", columnId, 0, false));
#endif
            m_pages.insert(docId, list);
            m_pageSave.insert(m_currentCourse, m_currentPage);
            m_currentCourse = docId;
            m_currentPage = 1;
            for(int z = 0; z < questionsArray.size(); z++)
            {
                QString questionId = questionsArray.at(z).toString();
#ifdef USE_OSS_AUTHENTICATION
                m_pages[m_currentCourse].append(MessageModel(1, "", 1.0, 1.0, questionId, columnId, 0, false, 0));
#else
                m_pages[m_currentCourse].append(MessageModel(1, "", 1.0, 1.0, questionId, columnId, 0, false));
#endif
            }
        }
        else
        {
            m_pageSave.insert(m_currentCourse, m_currentPage);
        }
    }
}

int CourseWareViewManager::getCurrentCourseSize()
{
    return m_pages[m_currentCourse].size();
}

int CourseWareViewManager::getDefaultCourseSize()
{
    return m_pages.value("DEFAULT").size();
}

void CourseWareViewManager::changeCurrentCourseIndex(int indexs)
{
    m_currentPage = indexs;
}

MessageModel CourseWareViewManager::getCurrentMsgModel()
{
    return currentBeBufferModel;
}

void CourseWareViewManager::addTrailInCurrentBufferModel(QString userId, QString trailMsg)
{
    currentBeBufferModel.addMsg(userId,trailMsg);
}
