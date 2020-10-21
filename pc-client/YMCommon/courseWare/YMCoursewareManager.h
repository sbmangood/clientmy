#ifndef YMCOURSEWAREMANAGER_H
#define YMCOURSEWAREMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "messagemodel.h"
#include "YMHttpClient.h"
class YMCoursewareManager
        : public QObject
{
    Q_OBJECT
public:
    YMCoursewareManager(QObject *parent = 0);
    ~YMCoursewareManager();

    static YMCoursewareManager * gestance()
    {
        static YMCoursewareManager * coursewareManager = new YMCoursewareManager();
        return coursewareManager;
    }
signals:

    //课件信号

    /*讲义信号
         *属性介绍：当前题目ID：讲义Id,栏目Id，题目Id, 题目类型(0:题目，1:课件截图，2:空白页),offsetY:坐标，questionBtnStatus：题目状态
         */
    void sigCurrentQuestionId(
            QString planId,
            QString columnId,
            QString questionId,
            double offsetY,
            bool questionBtnStatus);

    void sigPlanChange(long lessonId, long planId, long itemId); //当前讲义信号

    void sigCurrentColumn(long planId, long columnId); //当前栏目

    void sigOffsetY(double offsetY);//当前图片的偏移量

    void sigDrawPage(MessageModel model);//当前页的所有数据

    //删除分页时判断当前是不是课件页 如果是 发此信号提示 此页为课件页 不能被删除
    void sigIsCourseWare();

    void sigChangeCurrentPage(int currentPage); //设置当前的页
    void sigChangeTotalPage(int totalPage); //设置全部当前的总页数
    //当前的图像信息
    void sigSendUrl(QString urls, double width, double height, bool isLongImg, QString questionId,bool beShowedAsLongImg);

public slots:

public:
    //课件相关参数
    int m_currentPage;//当前页
    QString m_currentCourse;//当前课件
    QString m_currentPlanId;//当前讲义Id
    QString m_currentColumnId;//当前栏目Id
    QString m_currentQuestionId;//当前题目Id
    bool m_currentQuestionButStatus;//当前开始做题按钮状态
    double offsetY;//当前滚动的坐标
    QMap<QString, QList<MessageModel> > m_pages;//每个课件每一页的内容
    QMap<QString, int> m_pageSave;//缓存每个课件的当前显示页码
    //MessageModel currentBeBufferModel;//当前被缓存的课件model
#ifdef USE_OSS_AUTHENTICATION
    MessageModel currentBeBufferModel = MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0);
#else
    MessageModel currentBeBufferModel = MessageModel(0, "", 1.0, 1.0, "", "0", 0, false);
#endif
    bool m_sysnStatus;//默认值false  同步状态标示 false 没有同步完成  true 已同步完成  与课件有关联

public:

#ifdef USE_OSS_AUTHENTICATION
    QString getOssSignUrl(QString key);//获取OSS重新签名的URL
    QString checkOssSign(QString imgUrl);//检查是否需要验签
#endif
    //根据课件id 以及传入的页数获取 该页的数据
    void drawCurrentPageData(QString currentCourseId, int pageIndex);//画当前页的数据

    bool justCurrentPageIsCourse(QString currentCourseId, int pageIndex);//判断当前页是否为课件

    void insertReportPicture(QString imgUrl);//插入课堂报告的图片

    //获取当前结构化课件的栏目信息 与 drawModle 信号有一致之处 后边进一步优化
    void getCurrentColumnData(QString currentCourseId, int pageIndex);

    //跳转到新栏目时 修改当前课件栏目 获取当前栏目信息 contentObj 栏目信息
    void drawCurrentColumnData(QJsonObject contentObj);

    //删除当前页
    void deleteCurrentPage();

    //插入空白页
    void insertBlankPage();

    //根据出入页数进行翻页
    void goPageByindex(int pageIndex);

    //发送出 当前件的数据信息 （同步完成时使用）
    void currentCourseDataStatus();

    //获取当前课件的当前页数
    int getCourseCurrentPage(QString courseId);

    //将讲义重置为默认状态 （默认状态只有一个空白页）
    void setCourseInDefaultStatus();

    //插入图片
    void insertPicture(QString url,double width,double height);

    //在当前页添加轨迹
    void addTrailInCurrentPage(QString userId,QString trailMsg);

    //撤销当前的轨迹
    void unDoCurrentTrail(QString userId);

    //清空当前页的数据信息
    void clearCurrentPageTrail();

    //设置当前页是否开始练习的状态
    void setCurrentQuestionStatus(bool status);

    //插入做题时生成的图片
    void insertAutoPicture(QString imageUrl, double imgWidth, double imgHeight);

    //设置当前课件的偏移量
    void setCurrentCursorOffsetY(double yValue);

    //添加普通的课件
    void addCommonCourse(QString courseId,QJsonArray imgArry);

    //添加结构化课件
    void addStructCourse(QString courseId, QJsonArray columnsArray);

    //获取当前的课件id
    QString getCurrentCourseId();

    //获取当前课件的大小
    int getCurrentCourseSize();

    //获取当前课件的当前所处的页数
    int getCurrentCourseCurrentIndex();

    //判断课件是否包含默认页
    bool justCourseHasDefaultPage();

    //获取默认课件的总页数
    int getDefaultCourseSize();

    //初始化默认课件页
    void initDefaultCourse();

    //改变当前课件的索引
    void changeCurrentCursouIndex(int indexs);

    //获取当前被缓存的课件model
    MessageModel getCurrentMsgModel();

    //判断当前页是不是空白页
    bool justCurrentPageIsBlank();

    //对当前的bufferModel添加轨迹
    void addTrailInCurrentBufferModel(QString userId,QString trailMsg);
private:
    YMHttpClient * m_httpClient;

};

#endif // YMCOURSEWAREMANAGER_H
