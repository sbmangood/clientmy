/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  coursewarecenter.cpp
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

#include "coursewarecenter.h"
#include "./curriculumdata.h"
#include "getoffsetimage.h"
#include "messagepack.h"
#include "messagetype.h"
#include "datamodel.h"

CoursewareCenter::CoursewareCenter(ControlCenter* controlCenter)
    :m_controlCenter(controlCenter)
    ,m_YMCoursewareManager(nullptr)
{

}

CoursewareCenter::~CoursewareCenter()
{
    uninit();
}

void CoursewareCenter::init(const QString &pluginPathName)
{
    QList<MessageModel> list;
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
    DataCenter::getInstance()->m_pages.insert("DEFAULT", list);

    m_YMCoursewareManager = YMCoursewareManager::getInstance();
}

void CoursewareCenter::uninit()
{
    m_controlCenter = nullptr;
}

void CoursewareCenter::syncCoursewareHistroy()
{
    DataCenter::getInstance()->m_currentPage = DataCenter::getInstance()->m_currentPage >= DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() ? DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() - 1 : DataCenter::getInstance()->m_currentPage;
    //qDebug() << "====syncCoursewareHistroy===" << m_currentPage << m_currentCourse << m_pages[m_currentCourse].size();
    MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
    model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);

    if(m_YMCoursewareManager)
    {
        m_YMCoursewareManager->sendSigDrawPage(model);
    }

    updateH5SynCousewareInfo();
    if(DataCenter::getInstance()->m_currentPlanId == "" && DataCenter::getInstance()->m_currentColumnId == "")
    {
        return;
    }
    if(m_YMCoursewareManager)
    {
        m_YMCoursewareManager->sendSigPlanChange(0, DataCenter::getInstance()->m_currentPlanId.toLong(), DataCenter::getInstance()->m_currentColumnId.toLong());
        m_YMCoursewareManager->sendSigCurrentQuestionId(DataCenter::getInstance()->m_currentPlanId, DataCenter::getInstance()->m_currentColumnId, DataCenter::getInstance()->m_currentQuestionId, DataCenter::getInstance()->m_offsetY, DataCenter::getInstance()->m_currentQuestionButStatus);
        m_YMCoursewareManager->sendSigCurrentColumn(DataCenter::getInstance()->m_currentPlanId.toLong(), DataCenter::getInstance()->m_currentColumnId.toLong());
        m_YMCoursewareManager->sendSigOffsetY(DataCenter::getInstance()->m_offsetY);
    }
}

void CoursewareCenter::updateH5SynCousewareInfo()
{
    if(DataCenter::getInstance()->m_currentDocType == 3)//H5课件同步处理
    {
        QMap<QString,int> synH5dataModel;
        for(int i = 0; i < DataCenter::getInstance()->m_h5Model.size();i++)
        {
            if(DataCenter::getInstance()->m_h5Model.at(i).m_docId.contains(DataCenter::getInstance()->m_currentCourse))
            {
                synH5dataModel.insert(DataCenter::getInstance()->m_h5Model.at(i).m_pageNo,DataCenter::getInstance()->m_h5Model.at(i).m_currentAnimStep);
            }
        }
        QJsonObject h5SynObj;
        QJsonArray h5SynArray;
        h5SynObj.insert("lessonId",StudentData::gestance()->m_lessonId);
        h5SynObj.insert("h5Url",DataCenter::getInstance()->m_currentCourseUrl);
        h5SynObj.insert("courseWareId",DataCenter::getInstance()->m_currentCourse);
        h5SynObj.insert("courseWareType",DataCenter::getInstance()->m_currentDocType);
        h5SynObj.insert("currentPageNo",DataCenter::getInstance()->m_currentPage);

        for(int k = 0; k < DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(); k++)
        {
            QJsonObject pageInfosObj;
            pageInfosObj.insert("courseWareType",DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][k].isCourware);
            pageInfosObj.insert("pageNo",k);
            pageInfosObj.insert("url","");
            int currentAnimStep = 0;
            QMap<QString,int>::const_iterator it;
            for( it=synH5dataModel.constBegin(); it!=synH5dataModel.constEnd(); ++it)
            {
                if(it.key() == QString::number(k))
                {
                    currentAnimStep = it.value();
                    break;
                }
            }
            pageInfosObj.insert("currentAnimStep",currentAnimStep);
            h5SynArray.append(pageInfosObj);
        }
        h5SynObj.insert("pageInfos",h5SynArray);
        if(m_YMCoursewareManager)
        {
            m_YMCoursewareManager->sendSigSynCoursewareInfo(h5SynObj);
            m_YMCoursewareManager->sendSigSynCoursewareStep(QString::number(DataCenter::getInstance()->m_currentPage),DataCenter::getInstance()->m_currentStep);
        }
        qDebug() << "====AAAA====" << h5SynObj;
    }
}

int CoursewareCenter::getCurrentPage(QString docId)
{
    int currentPage = 1;
    currentPage = DataCenter::getInstance()->m_pageSave.value(docId, 1);
    //qDebug() << "===ControlCenter::getCurrentPage=====" << currentPage << m_pages[docId].size() << m_pageSave.value(docId, 1);
    return currentPage;
}

void CoursewareCenter::goCourseWarePage(int type, int pageNo, int totalNumber)
{
    //qDebug() << "====ControlCenter::goCourseWarePage====" << type << pageNo << totalNumber;
    QString coursewareId = "";
    if(DataCenter::getInstance()->m_currentCourse == "DEFAULT")
    {
        coursewareId = "000000";
    }
    else
    {
        coursewareId = DataCenter::getInstance()->m_currentCourse;
    }
    QString msg = MessagePack::getInstance()->pageReqMsg(type, pageNo, totalNumber, coursewareId, DataCenter::getInstance()->m_currentPage);
    if(m_controlCenter)
        m_controlCenter->sendLocalMessage(msg, true, true);
}

bool CoursewareCenter::updateCoursewareInfo(QString& coursewareId,QString& coursewareMsg)
{
    if(DataCenter::getInstance()->m_pages.contains(coursewareId))
    {
        return true;
    }
    QJsonObject couldDiskFileInfo = QJsonDocument::fromJson(coursewareMsg.toUtf8().data()).object();
    QJsonObject data = couldDiskFileInfo.take("content").toObject();
    int docType = data.take("docType").toInt();

    if(data.contains("urls"))
    {
        QJsonArray coursewareUrls;
        QJsonArray arrUrls = data.take("urls").toArray();
        for(int i = 0; i < arrUrls.size(); ++i)
        {
            coursewareUrls.append(arrUrls.at(i).toString());
        }
        cacheDocInfo(coursewareUrls, coursewareId, docType);

        if(DataCenter::getInstance()->m_pages.contains(coursewareId))
        {
            return true;
        }
    }
    return false;
}

void CoursewareCenter::insertCourseWare(QJsonArray imgUrlList, QString fileId, QString h5Url, int coursewareType)// 加载课件
{
    //qDebug() << "==insertCourseWare==" << imgUrlList.size();
    if(imgUrlList.size() > 0)
    {
        cacheDocInfo(imgUrlList, fileId,coursewareType);
        int currPageNo = getCurrentPage(fileId);
        int pageTotal = imgUrlList.size();
        QString coursewareId = fileId;
        QString message = MessagePack::getInstance()->docReqMsg(currPageNo, pageTotal, coursewareId,imgUrlList,h5Url,coursewareType);
        //qDebug() << "===insertCourseWare::message===" << message;
        if(m_controlCenter)
            m_controlCenter->sendLocalMessage(message, true, true);
    }
}

void CoursewareCenter::goPage(int pageIndex)
{
    pageIndex = pageIndex < 0 ? 0 : pageIndex;
    pageIndex = pageIndex > DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() ? DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() : pageIndex;
    DataCenter::getInstance()->m_currentPage = pageIndex;
    QStringList strList = DataCenter::getInstance()->m_currentCourse.split("|");
    if (strList.size() > 1)
    {
        QString planId = strList.at(0);
        QString columnId = strList.at(1);
        if (DataCenter::getInstance()->m_pages.contains(DataCenter::getInstance()->m_currentCourse))
        {
            if (DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() > 1)
            {
                QString questionId = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].at(DataCenter::getInstance()->m_currentPage).questionId;
                double m_offsetY = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].at(DataCenter::getInstance()->m_currentPage).offsetY;
                bool m_questionStatus = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].at(DataCenter::getInstance()->m_currentPage).questionBtnStatus;
                DataCenter::getInstance()->m_pageSave.insert(DataCenter::getInstance()->m_currentCourse, DataCenter::getInstance()->m_currentPage);
                if (DataCenter::getInstance()->m_sysnStatus)
                {
                    if(m_YMCoursewareManager)
                    {
                        m_YMCoursewareManager->sendSigCurrentQuestionId(planId, columnId, questionId, m_offsetY, m_questionStatus);
                    }
                }
            }
        }
    }
}

void CoursewareCenter::addPage()
{
    DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].insert(++DataCenter::getInstance()->m_currentPage, MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
    QStringList strList = DataCenter::getInstance()->m_currentCourse.split("|");
    if (strList.size() > 1)
    {
        QString planId = strList.at(0);
        QString columnId = strList.at(1);
        if(m_YMCoursewareManager)
        {
            m_YMCoursewareManager->sendSigCurrentQuestionId(planId, columnId, "", 0, false);
        }
    }
}

void CoursewareCenter::delPage()
{
    //如果是课件不能删除
    MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
    if(model.isCourware && DataCenter::getInstance()->m_sysnStatus)
    {
        if(NULL != m_YMCoursewareManager)
        {
            m_YMCoursewareManager->sendSigIsCourseWare(true);
        }
        DataCenter::getInstance()->m_isRemovePage = true;
        return;
    }

    if (DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() == 1)
    {
        DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][0].release();
        DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].removeAt(0);
        DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
        QStringList strList = DataCenter::getInstance()->m_currentCourse.split("|");
        if (strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            if(m_YMCoursewareManager)
            {
                m_YMCoursewareManager->sendSigCurrentQuestionId(planId, columnId, "", 0, false);
            }
        }
        return;
    }
    DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage].release();
    DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].removeAt(DataCenter::getInstance()->m_currentPage);
    DataCenter::getInstance()->m_currentPage = DataCenter::getInstance()->m_currentPage >= DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() ? DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size() - 1 : DataCenter::getInstance()->m_currentPage;

    QStringList strList = DataCenter::getInstance()->m_currentCourse.split("|");
    if (strList.size() > 1)
    {
        QString planId = strList.at(0);
        QString columnId = strList.at(1);
        QString docId = planId + "|" + columnId;
        if (DataCenter::getInstance()->m_pages.contains(docId))
        {
            QString questionId = DataCenter::getInstance()->m_pages[docId].at(DataCenter::getInstance()->m_currentPage).questionId;
            if(m_YMCoursewareManager)
            {
                m_YMCoursewareManager->sendSigCurrentQuestionId(planId, columnId, questionId, 0, false);
            }
        }
    }
    if(NULL != m_YMCoursewareManager)
    {
        m_YMCoursewareManager->sendSigIsCourseWare(false);
    }
}

void CoursewareCenter::setPageData()
{
    MessageModel model = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse][DataCenter::getInstance()->m_currentPage];
    model.setPage(DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size(), DataCenter::getInstance()->m_currentPage);
    if(m_YMCoursewareManager)
    {
        m_YMCoursewareManager->sendSigDrawPage(model);
    }
}

void CoursewareCenter::cacheDocInfo(QJsonArray coursewareUrls, QString coursewareId,int coursewareType)
{
    qDebug()<< "====cacheDocInfo===" << coursewareUrls<<coursewareId << DataCenter::getInstance()->m_sysnStatus
            <<  coursewareType << DataCenter::getInstance()->m_pages.contains("DEFAULT") << DataCenter::getInstance()->m_pages.contains(coursewareId);
    if (DataCenter::getInstance()->m_pages.contains("DEFAULT"))
    {
        DataCenter::getInstance()->m_pages.insert(coursewareId, DataCenter::getInstance()->m_pages.value("DEFAULT"));
        DataCenter::getInstance()->m_pages.remove("DEFAULT");
        DataCenter::getInstance()->m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = DataCenter::getInstance()->m_currentCourse;
        DataCenter::getInstance()->m_currentPage = DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size();//coursewareType == 3 ? 0 : DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].size();
        QString qustionId = coursewareType == 3 ? "h5" : "1";
        for (int i = 0; i < coursewareUrls.size(); ++i)
        {
            DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].append(MessageModel(1, coursewareUrls.at(i).toString(), 1.0, 1.0,qustionId, "0", 0, false));
        }
        qDebug() << "===111111111===" << DataCenter::getInstance()->m_currentPage << DataCenter::getInstance()->m_currentCourse;
    }
    else if (!DataCenter::getInstance()->m_pages.contains(coursewareId))
    {
        QList<MessageModel> list;
        list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
        DataCenter::getInstance()->m_pages.insert(coursewareId, list);
        DataCenter::getInstance()->m_pageSave.insert(DataCenter::getInstance()->m_currentCourse, DataCenter::getInstance()->m_currentPage);
        TemporaryParameter::gestance()->m_pageSave.insert(DataCenter::getInstance()->m_currentCourse, DataCenter::getInstance()->m_currentPage);
        DataCenter::getInstance()->m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = DataCenter::getInstance()->m_currentCourse;
        DataCenter::getInstance()->m_currentPage = 1;//(coursewareType == 3) ? 0 : 1;
        QString qustionId = coursewareType == 3 ? "h5" : "1";
        for (int i = 0; i < coursewareUrls.size(); ++i)
        {
            DataCenter::getInstance()->m_pages[DataCenter::getInstance()->m_currentCourse].append(MessageModel(1, coursewareUrls.at(i).toString(), 1.0, 1.0,qustionId,"", 0, false));
        }
        qDebug() << "===222222222===" << DataCenter::getInstance()->m_currentPage << DataCenter::getInstance()->m_currentCourse;
    }
    else
    {
        DataCenter::getInstance()->m_pageSave.insert(DataCenter::getInstance()->m_currentCourse, DataCenter::getInstance()->m_currentPage);
        TemporaryParameter::gestance()->m_pageSave.insert(DataCenter::getInstance()->m_currentCourse, DataCenter::getInstance()->m_currentPage);
        DataCenter::getInstance()->m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = DataCenter::getInstance()->m_currentCourse;
        DataCenter::getInstance()->m_currentPage = DataCenter::getInstance()->m_pageSave.value(DataCenter::getInstance()->m_currentCourse, 0);
        qDebug() << "===3333333333===" << DataCenter::getInstance()->m_currentPage << DataCenter::getInstance()->m_currentCourse;
    }
    if(coursewareType == 3 && DataCenter::getInstance()->m_sysnStatus)
    {
        qDebug()<<"==================================coursewareType == 3 && m_sysnStatus=================================";
        DataCenter::getInstance()->m_currentDocType = coursewareType;
        updateH5SynCousewareInfo();
    }
    DataCenter::getInstance()->m_currentPlanId = coursewareId;
}

void CoursewareCenter::sendSigDrawPage(MessageModel model)
{
    if(m_YMCoursewareManager)
    {
        m_YMCoursewareManager->sendSigDrawPage(model);
    }
}

void CoursewareCenter::sendSigSynCoursewareType(int courseware, QString h5Url)
{
    if(m_YMCoursewareManager)
    {
        m_YMCoursewareManager->sendSigSynCoursewareType(courseware, h5Url);
    }
}

