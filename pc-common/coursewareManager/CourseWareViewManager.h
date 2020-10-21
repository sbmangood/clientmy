#ifndef COURSEWAREVIEWMANAGER_H
#define COURSEWAREVIEWMANAGER_H
#include <QObject>
#include <QBitmap>
#include <QString>
#include <QAtomicInteger>
#include "messagemodel.h"
#include "ICourseWareCallBack.h"
#include "YMHttpClient.h"

// 课件页信息CourseWarePageInfo定义
struct CourseWarePageInfo
{
private:
    QString CourseWareId; // 课件ID
    QString CourseWareType; // 课件类型
    QString url; // 课件url
    QBitmap courseWareBitamp; // 课件bitmap
    QList<int> animSetps; // 动画步骤
    int currentAnimSetp; // 当前播放setp
};

// 课件功能API类
class CourseWareViewManager: public QObject
{
    Q_OBJECT
public:
    explicit CourseWareViewManager(QObject *parent = 0);
    static CourseWareViewManager* m_CourseWareViewManager;
    YMHttpClient * m_httpClient;

    static CourseWareViewManager* getInstance()// 获取CourseWareViewManager单例
    {
        if(NULL == m_CourseWareViewManager)
        {
            m_CourseWareViewManager = new CourseWareViewManager();
        }
        return m_CourseWareViewManager;

    }

    void getCourseWareView(int coursewareType, QString courseId, QJsonArray courseArry); // 得到课件视图
    void addPage(); // 加空白页
    void addImagePage(QString url, int width, int height); // 添加图片页，默认在当前页码添加
    void delPage(); // 减页
    void goPage(int pageIndex); // 翻页指定到某一个页
    void setCourseWareData(QString message); // 设置单个课件数据
    QBitmap screenshot(int x, int y, int w, int h); // 根据指定区域截屏，返回bitmap
    void show(); // 显示当前view
    void hide(); // 隐藏当前view
    CourseWarePageInfo getPageInfo(); // 获取当前课件页信息参考CourseWarePageInfo 定义
    void setCanTouch(bool isCanTouch); // 设置是否能响应touch事件
    void setCourseWareCallBack(ICourseWareCallBack iCourseWareCallBack); // 设置回调接口

signals:
    void sigSendLocalSocketMessage(QString message, bool append, bool drawPage);// socketHandler发消息信号
    void sigGetCourseWareView();// 获取课件视图信号
    void sigGetCoursewareFaill();// 获取课件失败
    void sigShowCourseWareView();// 显示课件信号
    void sigHideCourseWareView();// 隐藏课件信号

    // 讲义信号,属性介绍：当前题目ID：讲义Id,栏目Id，题目Id, 题目类型(0:题目，1:课件截图，2:空白页),offsetY:坐标，questionBtnStatus：题目状态
    void sigCurrentQuestionId(QString planId, QString columnId, QString questionId, double offsetY, bool questionBtnStatus);
    void sigPlanChange(long lessonId, long planId, long itemId); // 当前讲义信号
    void sigCurrentColumn(long planId, long columnId); // 当前栏目
    void sigOffsetY(double offsetY); // 当前图片的偏移量
    void sigDrawPage(MessageModel model); // 当前页的所有数据
    void sigIsCourseWare(); // 删除分页时判断当前是不是课件页 如果是 发此信号提示 此页为课件页 不能被删除
    void sigChangeCurrentPage(int currentPage); // 设置当前的页
    void sigChangeTotalPage(int totalPage); // 设置全部当前的总页数
    void sigSendUrl(QString urls, double width, double height, bool isLongImg, QString questionId,bool beShowedAsLongImg); // 当前的图像信息

public:
    // 其他接口
#ifdef USE_OSS_AUTHENTICATION
    QString getOssSignUrl(QString key);//获取OSS重新签名的URL
    QString checkOssSign(QString imgUrl);//检查是否需要验签
#endif
    void drawCurrentPageData(QString currentCourseId, int pageIndex);// 根据课件id 以及传入的页数获取该页的数据, 画当前页的数据
    bool judgeCurrentPageIsBlank();// 判断当前页是不是空白页
    bool judgeCurrentPageIsCourse(QString currentCourseId, int pageIndex);// 判断当前页是否为课件
    void insertReportPicture(QString imgUrl);// 插入课堂报告的图片
    void getCurrentColumnData(QString currentCourseId, int pageIndex);// 获取当前结构化课件的栏目信息
    void drawCurrentColumnData(QJsonObject contentObj);// 跳转到新栏目时 修改当前课件栏目 获取当前栏目信息 contentObj 栏目信息
    void currentCourseDataStatus();// 发送出 当前件的数据信息 （同步完成时使用）
    int getCourseCurrentPage(QString courseId);// 获取当前课件的当前页数
    void setCourseInDefaultStatus();// 将讲义重置为默认状态 （默认状态只有一个空白页）
    void addTrailInCurrentPage(QString userId,QString trailMsg);// 在当前页添加轨迹
    void unDoCurrentTrail(QString userId);// 撤销当前的轨迹
    void clearCurrentPageTrail();// 清空当前页的数据信息
    void setCurrentQuestionStatus(bool status);// 设置当前页是否开始练习的状态
    void insertAutoPicture(QString imageUrl, double imgWidth, double imgHeight);// 插入做题时生成的图片
    void setCurrentCursorOffsetY(double yValue);// 设置当前课件的偏移量
    void addCommonCourse(QString courseId,QJsonArray imgArry);// 添加普通的课件
    void addStructCourse(QString courseId, QJsonArray columnsArray); // 添加结构化课件
    QString getCurrentCourseId(); // 获取当前的课件id
    int getCurrentCourseSize();// 获取当前课件的大小
    int getCurrentCourseCurrentIndex();// 获取当前课件的当前所处的页数
    bool judgeCourseHasDefaultPage();// 判断课件是否包含默认页
    int getDefaultCourseSize();// 获取默认课件的总页数
    void initDefaultCourse();// 初始化默认课件页
    void changeCurrentCourseIndex(int indexs);// 改变当前课件的索引
    MessageModel getCurrentMsgModel();// 获取当前被缓存的课件model
    void addTrailInCurrentBufferModel(QString userId,QString trailMsg);// 对当前的bufferModel添加轨迹

private:
    // 课件相关参数
    int m_currentPage;// 当前页
    QString m_currentCourse;// 当前课件
    QString m_currentPlanId;// 当前讲义Id
    QString m_currentColumnId;// 当前栏目Id
    QString m_currentQuestionId;// 当前题目Id
    bool m_currentQuestionButStatus;// 当前开始做题按钮状态
    double offsetY;// 当前滚动的坐标
    QMap<QString, QList<MessageModel> > m_pages;// 每个课件每一页的内容
    QMap<QString, int> m_pageSave;// 缓存每个课件的当前显示页码
#ifdef USE_OSS_AUTHENTICATION
    MessageModel currentBeBufferModel;// = MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0);
#else
    MessageModel currentBeBufferModel;// = MessageModel(0, "", 1.0, 1.0, "", "0", 0, false);
#endif

    bool m_sysnStatus;//默认值false  同步状态标示 false 没有同步完成  true 已同步完成  与课件有关联



};

#endif // CourseWareViewManager_H
