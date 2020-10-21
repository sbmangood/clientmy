#ifndef YMCLOUDCLASSMANAGERADAPTER_H
#define YMCLOUDCLASSMANAGERADAPTER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "YMHttpClient.h"

#include"./dataconfig/datahandl/datamodel.h"
#include"../YMCommon/qosManager/YMQosManager.h"
class YMCloudClassManagerAdapter : public QObject
{
    Q_OBJECT
public:
    explicit YMCloudClassManagerAdapter(QObject *parent = 0);

    //查询栏目下的所有题目信息
    Q_INVOKABLE void getLessonPlanQuestionInfo(
            QString lessonId,/*课程Id*/
            QString prePlanId,/*讲义Id*/
            QString itemId/*栏目Id*/);

    //保存老师轨迹图片
    Q_INVOKABLE void saveTeacherTrajectory(
            QString lessonId,/*课程Id*/
            QString prePlanId,/*讲义Id*/
            QString itemId,/*栏目Id*/
            QString questionId,/*题目Id*/
            QString childQuestionId,/*子题目Id*/
            QString imageArray/*老师批注轨迹界面截图*/);

    //课程列表查看是否有课件
    Q_INVOKABLE void getLessonInfoStatus(QString lessonId);

    //根据课程ID查询讲义列表
    Q_INVOKABLE void getLessonList();

    //提交老师批注
    Q_INVOKABLE void saveTeacherComment(QJsonObject commentParm);

    //获取课程结束时评价的配置
    Q_INVOKABLE void getLessonCommentConfig();

    //课堂练习答案单题提交
    Q_INVOKABLE void saveStudentAnswer(int useTime, QString studentAnswer, QJsonObject answerParm, int isFinished, QString imageAnswerUrl, QString childQId);

    //根据讲义Id给出讲义所有的栏目具体信息
    Q_INVOKABLE void getIdByColumnInfo(long lessonId, long planId, int type, QString handoutName);

    //根据栏目id给出具体的信息
    Q_INVOKABLE void findItemById(long lessonId, long planId, long itemId, QString questionId);

    //上一题
    Q_INVOKABLE void preTopic();

    //下一题
    Q_INVOKABLE void nextTopic();

    //跳转
    Q_INVOKABLE void jumpTopic(int page);

    //获取当前显示栏目的内容是否有 baseImage
    Q_INVOKABLE QJsonObject getCurrentItemBaseImage(QJsonObject dataObjecte, int index);




public slots:
    //根据 讲义Id 和 栏目Id   返回所在页的数据信息
    // planid 讲义ID columnId 栏目Id  pageidex 页索引  发送出查到的页的数据信息 重置模型数据
    void getColumnPageData(QString planId, QString columnId, QString index);

    //根据题目Id获取题目的数据 objdata 包含 planid 讲义ID columnId 栏目Id 和 题目的id
    void getQuestionDataById(QJsonObject objData, int sigType);

    //重置页面的页数显示view m_AllQuestionInfo为当前讲义的 所有数据信息
    void resetPageView(long planId, long itemId,  QJsonObject m_AllQuestionInfo);

    //获取栏目下的 数据的数目

    QJsonArray getColumnItemNumber(QString planId, QString columnId);

    //检测讲义列表是否 为空
    bool lessonListIsEmpty();

    void justGetCourseIsSuccess();

private:

    //bool lessonListIsEmptys = true;
    YMHttpClient * m_httpClient;
    //题型分页处理
    int m_menuType;//栏目类型
    QJsonArray m_QuestionInfo;//题目缓存Array
    QJsonArray m_resourceContentArray;//
    int m_menuTotal;//学习栏目总题数
    int m_menuCurrentIndex;//学习栏目当前索引

    QJsonObject m_AllQuestionInfo;//栏目及题目所有信息缓存
    int m_totalQuestion;//总题型
    int m_currentQuestionIndex = 1;//当前题目索引

    long currentPlanIds;//当前显示的讲义id
    long currentItemIds;//当前显示的栏目id
    bool isResetPageNumber = true;

    //所有的新课件集合
    QList <QJsonObject> allNewCoursewarwList;

    QString apiUrl = StudentData::gestance()->apiUrl; //jyhd.yimifudao.com.cn

    QString tempIp = StudentData::gestance()->teachingUrl;//"stage-jyhd.yimifudao.com.cn"; // jyhd.yimifudao.com.cn //47.100.68.102:9005

    int m_currentGetCourseTimes = 0;

signals:
    void requestTimerOut();
    void sigHandoutInfo(QJsonArray dataArray);//讲义信息信号
    void sigHandoutMenuInfo(QJsonArray dataArray);// 题目类型信息信号
    void sigQuestionInfo(QJsonObject dataObjecte);//题目信息信号

    void sigSendHandoutInfo(QJsonObject dataObjecte);//发送讲义信息信号


    //***********************
    void sigLearningTarget(QJsonObject dataObjecte);//学习目标信号
    void sigKnowledgeComb(QJsonObject dataObjecte);//知识梳理信号
    void sigTypicalExample(QJsonObject dataObjecte);//典型例题信号
    void sigClassroomPractice(QJsonObject dataObjecte);//课堂练习信号

    //返回老师发送的题目的 信息 findData 为查找该题目时所用的索引信息 questionData 为题目信息
    void sigTeacherSendQuestionData(QJsonObject findData, QJsonObject questionData);
    //显示答案解析面板
    void sigShowAnswerAnalyseView(QJsonObject findData, QJsonObject questionData);
    //显示批改面板
    void sigShowCorrectView(QJsonObject findData, QJsonObject questionData);

    //上传学生答案成功 失败信号 true 为上传成功 false为上传失败 isFinished是否所有的答案都上传完成 1完成 0未完成
    void uploadStudentAnswerBackData(bool isUpSuccess, QJsonObject findData, int isFinished);

    void sigShowPage(int currentPage, int totalPage); //显示分页信号
    //void sigLearningTarget(QJsonObject dataObjecte);//学习目标信号
    void sigTopicId(QString questionId); //当前题目id、讲义Id,栏目Id

    //获取课件列表失败
    void sigGetLessonListFail();

    //课程结束时评价的配置
    void sigLessonCommentConfig(QJsonArray dataArray);
};

#endif // YMCLOUDCLASSMANAGERADAPTER_H
