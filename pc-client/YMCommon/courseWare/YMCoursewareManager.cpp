#include "YMCoursewareManager.h"
#include <QStandardPaths>
#include <QCoreApplication>

/*
*课件数据存储管理类
*/

YMCoursewareManager::YMCoursewareManager(QObject *parent)
    : QObject(parent)
{
    initDefaultCourse();
}

YMCoursewareManager::~YMCoursewareManager()
{

}

#ifdef USE_OSS_AUTHENTICATION
//OSS过期重新签名URL
QString YMCoursewareManager::getOssSignUrl(QString key)
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
        qDebug() << "YMCoursewareManager::getOssSignUrl" << allDataObj;
    }

    return "";
}
#endif

#ifdef USE_OSS_AUTHENTICATION
QString YMCoursewareManager::checkOssSign(QString imgUrl)
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

void YMCoursewareManager::initDefaultCourse()
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

void YMCoursewareManager::drawCurrentPageData(QString currentCourseId, int pageIndex)
{
    MessageModel model = m_pages[currentCourseId][pageIndex];
    model.setPage(m_pages[currentCourseId].size(), pageIndex);
#ifdef USE_OSS_AUTHENTICATION
    model.bgimg = checkOssSign(model.bgimg);
#endif
    currentBeBufferModel.clear();
    currentBeBufferModel = model;
    emit sigDrawPage(model);

    //处理当前页需要被发送出去的数据

    bool isLongImg = (getCurrentMsgModel().questionId == "") ? false :  (getCurrentMsgModel().bgimg == ""  ? false : true);

    emit sigSendUrl(getCurrentMsgModel().bgimg, getCurrentMsgModel().width, getCurrentMsgModel().height, isLongImg, getCurrentMsgModel().questionId, getCurrentMsgModel().beShowedAsLongImg);
    qDebug() << "==TrailBoard::drawPage::new=="
             << getCurrentMsgModel().height
             << getCurrentMsgModel().questionId
             << getCurrentMsgModel().offsetY
             << getCurrentMsgModel().bgimg;
    //qDebug() << "=======TrailBoard::drawPage========" <<  getCurrentMsgModel().bgimg << isLongImg  << getCurrentMsgModel().width << getCurrentMsgModel().height << "question:" + getCurrentMsgModel().questionId;


    emit sigOffsetY(model.offsetY);//可去除 待优化
    emit sigChangeCurrentPage(model.getCurrentPage());
    emit sigChangeTotalPage(model.getTotalPage());
}

bool YMCoursewareManager::justCurrentPageIsBlank()
{
    if(getCurrentMsgModel().height == 1 && getCurrentMsgModel().questionId != "" && getCurrentMsgModel().questionId != "-1" && getCurrentMsgModel().questionId != "-2" && getCurrentMsgModel().bgimg != "")
    {
        return false;//不是空白页
    }
    return true;//是空白页
}

bool YMCoursewareManager::justCurrentPageIsCourse(QString currentCourseId, int pageIndex)
{
    MessageModel model = m_pages[currentCourseId][pageIndex];
    return model.isCourware;
}

void YMCoursewareManager::insertReportPicture(QString imgUrl)
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

void YMCoursewareManager::getCurrentColumnData(QString currentCourseId, int pageIndex)
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

void YMCoursewareManager::drawCurrentColumnData(QJsonObject contentObj)
{
    QString columnId = contentObj.value("columnId").toString();
    QString planId = contentObj.value("planId").toString();
    QString docId = planId + "|" + columnId;
    qDebug() << "*********draw::column*********" << planId << columnId;
    if(m_pages.contains(docId))
    {
        m_currentCourse = docId;
        m_currentPage = m_pageSave.value(m_currentCourse, 0);
        //qDebug() << "**********m_currentPage111**********" << m_currentPage;
        m_currentPage = m_currentPage == 0 ? 1 : m_currentPage;
        //qDebug() << "*********currentPage**********" << m_currentPage << m_pages[docId].size() << m_pageSave.value(m_currentCourse,0) << m_sysnStatus;
        if(m_currentPage >= m_pages[docId].size())
        {
            m_currentPage = 0;
            qDebug() << "******return**********";
            return;

        }

        QString currentQustionId = m_pages[docId].at(m_currentPage).questionId;

        drawCurrentPageData(docId,m_currentPage);

        //qDebug() << "=======draw::column2222=======" << m_currentCourse << m_currentPage << planId << columnId << currentQustionId ;
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

void YMCoursewareManager::deleteCurrentPage()
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

void YMCoursewareManager::insertBlankPage()
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

void YMCoursewareManager::goPageByindex(int pageIndex)
{
    pageIndex = pageIndex < 0 ? 0 : pageIndex;
    if (pageIndex > m_pages[m_currentCourse].size() - 1)
        pageIndex = m_pages[m_currentCourse].size() - 1;
    m_currentPage = pageIndex;

    QStringList strList =  m_currentCourse.split("|");
    //qDebug() << "========goto::page=======" << m_currentCourse << m_currentPage << strList.size();
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

void YMCoursewareManager::currentCourseDataStatus()
{
    //画一页
    drawCurrentPageData(m_currentCourse, m_currentPage);
    qDebug() << "############m_sysnStatus##############" << m_currentPlanId << m_currentColumnId;
    if(m_currentPlanId == "" && m_currentColumnId == "")
    {
        return;
    }
    emit sigPlanChange(0, m_currentPlanId.toLong(), m_currentColumnId.toLong());
    emit sigCurrentQuestionId(m_currentPlanId, m_currentColumnId, m_currentQuestionId, offsetY, m_currentQuestionButStatus);
    emit sigCurrentColumn(m_currentPlanId.toLong(), m_currentColumnId.toLong());
    emit sigOffsetY(offsetY);
}

int YMCoursewareManager::getCourseCurrentPage(QString courseId)
{
    int currentPage = 1;
    currentPage = m_pageSave.value(courseId, 1);
    qDebug() << "===getCourseCurrentPage=====" << currentPage << m_pages[courseId].size() << m_pageSave.value(courseId, 1);
    return currentPage;
}

void YMCoursewareManager::setCourseInDefaultStatus()
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
    //画一页
    drawCurrentPageData(m_currentCourse,m_currentPage);
}

void YMCoursewareManager::insertPicture(QString url,double width,double height)
{
    QStringList strList = m_currentCourse.split("|");
    QString questionId = "-2";
    if(strList.size() > 1)
    {
        questionId = "-1";
    }
    qDebug() << "=======picture===========" << m_currentCourse << m_currentPage  << url << questionId;
#ifdef USE_OSS_AUTHENTICATION
    m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height, questionId, "0", 0, false, 0));
#else
    m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height, questionId, "0", 0, false));
#endif
}

void YMCoursewareManager::addTrailInCurrentPage(QString userId,QString trailMsg)
{
    qDebug()<<"addTrailInCurrentPage"<<userId<<trailMsg<<m_currentPage;
    m_pages[m_currentCourse][m_currentPage].addMsg(userId, trailMsg);
}

void YMCoursewareManager::unDoCurrentTrail(QString userId)
{
    m_pages[m_currentCourse][m_currentPage].undo(userId);
}

void YMCoursewareManager::clearCurrentPageTrail()
{
    m_pages[m_currentCourse][m_currentPage].clear();
}

void YMCoursewareManager::setCurrentQuestionStatus(bool status)
{
    if(status)
    {
        m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(true);
        m_currentQuestionButStatus = true;
    }else
    {
        m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(false);
        m_currentQuestionButStatus = false;
    }
}

void YMCoursewareManager::insertAutoPicture(QString imageUrl, double imgWidth, double imgHeight)
{
    m_pages[m_currentCourse][m_currentPage].bgimg = imageUrl;
    m_pages[m_currentCourse][m_currentPage].width = imgWidth;
    m_pages[m_currentCourse][m_currentPage].height = imgHeight;
    m_pages[m_currentCourse][m_currentPage].questionBtnStatus = false;
    m_pages[m_currentCourse][m_currentPage].setImageUrl(imageUrl, imgWidth, imgHeight);
}

void YMCoursewareManager::setCurrentCursorOffsetY(double yValue)
{
    m_pages[m_currentCourse][m_currentPage].setOffsetY(yValue);
    qDebug() << "=========bufferoffsetY1========" << yValue;
}

void YMCoursewareManager::addCommonCourse(QString courseId, QJsonArray imgArry)
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

QString YMCoursewareManager::getCurrentCourseId()
{
    return m_currentCourse;
}

int YMCoursewareManager::getCurrentCourseCurrentIndex()
{
    return m_currentPage;
}

bool YMCoursewareManager::justCourseHasDefaultPage()
{
    return m_pages.contains("DEFAULT");
}

void YMCoursewareManager::addStructCourse(QString courseId, QJsonArray columnsArray)
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

int YMCoursewareManager::getCurrentCourseSize()
{
    return m_pages[m_currentCourse].size();
}

int YMCoursewareManager::getDefaultCourseSize()
{
    return m_pages.value("DEFAULT").size();
}

void YMCoursewareManager::changeCurrentCursouIndex(int indexs)
{
    m_currentPage = indexs;
}

MessageModel YMCoursewareManager::getCurrentMsgModel()
{
    return currentBeBufferModel;
}

void YMCoursewareManager::addTrailInCurrentBufferModel(QString userId,QString trailMsg)
{
    currentBeBufferModel.addMsg(userId,trailMsg);
}
