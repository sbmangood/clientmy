#ifndef YMCLOUDCLASSMANAGERADAPTER_H
#define YMCLOUDCLASSMANAGERADAPTER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "YMHttpClient.h"

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
        Q_INVOKABLE void saveTeacherComment(long lessonId, QString prePlanId, long itemId, QJsonObject commentParm);

        //课堂练习答案单题提交
        Q_INVOKABLE void saveStudentAnswer(QJsonObject answerParm);

        //根据讲义Id给出讲义所有的栏目具体信息
        Q_INVOKABLE void getIdByColumnInfo(long lessonId, long planId, int type, QString handoutName);

        //根据栏目id给出具体的信息
        Q_INVOKABLE void findItemById(long lessonId, long planId, long itemId, QString questionId);

        //根据题目Id给出题目详情
        Q_INVOKABLE void findQuestionDetailById(long lessonId, long planId, long itemId, QString questionId);

        //保存题目或者资源生成的底图
        Q_INVOKABLE void saveBaseImage(long lessonId, long planId, long itemId,
                                       QString questionId,
                                       QString resourceId,
                                       QString baseImageUrl,
                                       int width, int height);

        //根据题目信息筛选题目
        Q_INVOKABLE void filterQuestionInfo(QString planId, QString columnId, QString questionId);

        //小图拼接长图接口
        Q_INVOKABLE void spliceImage(QString  imageList, QString key);

        //返回错因列表
        Q_INVOKABLE void getErrorReasons(long lessonId, int planId);

        //是否第一次做题提醒
        Q_INVOKABLE bool getIsOneQuestion();

        //获取音视频接口
        Q_INVOKABLE void getLessonPlanUrl();

        //获取新讲义老课件列表
        Q_INVOKABLE void getCoursewareList(long planId);

        //关闭进程前, 需要上传日志文件
        Q_INVOKABLE void doUpload_LogFile();

    public:
        //根据讲义解析所有栏目
        void analyzeItemInfo(long planId, QJsonArray itemsArrays);

    private:
        YMHttpClient * m_httpClient;
        QString m_currentIp;//当前域名
        QString tempUrl;//测试域名"

        //题型分页处理
        int m_menuType;//栏目类型
        QJsonArray m_QuestionInfo;//题目缓存Array
        QJsonArray m_resourceContentArray;//学习栏目所以信息
        int m_menuTotal;//学习栏目总题数
        int m_menuCurrentIndex;//学习栏目当前索引

        QJsonObject m_AllQuestionInfo;//栏目及题目所有信息缓存
        int m_totalQuestion;//总题型
        int m_currentQuestionIndex;//当前题目索引
        int m_currentItemId;//当前栏目Id

        QMap<long, QJsonArray> m_courseware; //老课件缓存
        QMap<long, QJsonArray> m_plandInfo; //讲义ID、栏目信息
        QMap<long, QMap<QString, QJsonObject>> m_itemInfo; //栏目ID，所有题目信息(题目Id、题目信息)
        QMap<long, QJsonArray> m_errorArray; //错因列表
        QTimer *m_repeatLessonTime;
        int m_currentNumber;

    signals:
        void requestTimerOut();
        void sigShowPage(int currentPage, int totalPage); //显示分页信号
        void sigHandoutInfo(QJsonArray dataArray);//讲义信息信号
        void sigHandoutMenuInfo(QJsonArray dataArray);// 题目类型信息信号

        //题目信息信号
        void sigQuestionInfo(
            QJsonObject dataObjecte,/*题目信息*/
            QJsonArray answerArray,/*答案解析数组*/
            QJsonArray photosArray,//快照和手写图片数组
            bool browseStatus/*浏览状态：false做题模式，true:浏览模式*/
        );
        void sigLearningTarget(QJsonObject dataObjecte);//学习目标信号
        void sigSendHandoutInfo(QJsonObject dataObjecte);//发送讲义信息信号
        void sigTopicId(QString questionId); //当前题目id、讲义Id,栏目Id
        void sigIsChildTopic(bool status);//是否有子题 true: 有，false:无
        void sigIsMenuMultiTopic(bool status);//栏目是否有多题
        void sigErrorList(QJsonArray errorList);//错因列表
        void sigPhotos(QJsonArray photosArray);//快照图片集合信号
        void sigLoadLessonFail();//获取讲义失败信号
        void sigCorreSuccess();//批改成功信号
        void sigGetQuestionFail();//获取题目信息失败信号
        void sigGetMeidiaInfo(QJsonArray dataArray);//获取音视频信号
        void sigCourseware(QString dataStr);//非结构化老课件信号
};

#endif // YMCLOUDCLASSMANAGERADAPTER_H
