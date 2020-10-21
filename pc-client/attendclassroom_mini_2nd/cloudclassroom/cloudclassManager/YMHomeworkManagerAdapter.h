#ifndef YMHOMEWORKMANAGERADAPTER_H
#define YMHOMEWORKMANAGERADAPTER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "YMHttpClient.h"
#include <QSsl>
#include <QSslSocket>
#include <QDataStream>
#include <QTextStream>
#include <QProcess>
#include<QFile>
#include<QDir>
#include<QMessageBox>
#include<QStandardPaths>
#include<QCoreApplication>
#include<QSettings>
#include <QTimer>
#include<QHttpPart>
#include<QNetworkInterface>
#include"./dataconfig/datahandl/datamodel.h"

/*就用了一个传图方法*/

class YMHomeWorkManagerAdapter : public QObject
{
        Q_OBJECT
    public:
        explicit YMHomeWorkManagerAdapter(QObject *parent = 0);
        //获取作业列表 注意 type 类型     为何没有总数
        Q_INVOKABLE QJsonObject getLessonWorkList(QString pageIndex, QString lessonWorkStatus);

        //作业答案单题提交
        Q_INVOKABLE bool saveStudentAnswer(QString lessonWorkId, QString questionId, QString studentAnswer, QString useTime, QString photos, QString writeImages );

        //批改完成，更改作业状态
        Q_INVOKABLE bool updateLessonWorkStatus(QString lessonWorkId);

        //答题卡界面（老师学生都用）
        Q_INVOKABLE QJsonObject getAnswerCard(QString lessonWorkId);

        //更改作业标示为已读
        Q_INVOKABLE bool updateReaded(QString lessonWorkId);

        //查看作业答题情况
        Q_INVOKABLE QJsonObject getQuestionStatus(QString lessonWorkId);

        /***************************华丽的分割线************************/
        //学生完成作业接口
        Q_INVOKABLE bool getFinishLessonWork(QString lessonWorkId);

        //老师提交批注接口
        Q_INVOKABLE bool saveTeacherComment(
            QString lessonWorkId,/*作业Id*/
            QString questionId,/*题目Id*/
            QString childQuestionId,/*子题目Id*/
            QString remarkUrl,/*评论语音url*/
            int errorType,/*错因（主观题不是全对时必填）*/
            QString teacherImages,/*老师批注照片（主观题才有，多个以英文逗号隔开）*/
            QString originImages,/*老师批注原始照片（主观题才有，多个以英文逗号隔开，顺序和teacherImages保持一致）*/
            int questionStatus,/*题目得分状态（主观题才有：0错，1对，2半对半错）*/
            double score/*得分（主观题才有）*/);

        //作业题目详情
        Q_INVOKABLE QJsonObject getHomeworkDetailList(QString lessonWorkId);

        //单题题目详情
        Q_INVOKABLE QJsonObject getDetailByOne(
            QString lessonWorkId,/*作业Id*/
            int orderNumber /*题目序号*/);

        //返回错因列表
        Q_INVOKABLE QJsonArray getErrReason();

        //学生是否完成作业接口
        Q_INVOKABLE bool getStudentIsFinish(QString lessonWorkId);

        //老师是否完成批注接口
        Q_INVOKABLE bool getIsCommented(QString lessonWorkId);

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
        Q_INVOKABLE void getLessonList(QString lessonId);

        //根据讲义Id给出所有的栏目具体信息
        Q_INVOKABLE void getRgister();

        //提交老师批注
        Q_INVOKABLE void saveTeacherComment(QJsonObject commentParm);

        //课堂练习答案单题提交
        Q_INVOKABLE void saveStudentAnswer(QJsonObject answerParm);

    private:
        YMHttpClient * m_httpClient;

        QNetworkAccessManager *m_httpAccessmanger;
        QFile * m_imageFiles;
        QHttpMultiPart * m_multiPart;

    signals:
        void lessonlistRenewSignal();
        void lodingFinished();//加载数据完成
        void requestTimerOut();
    public slots:
        //路径  题号 来源（手写或选的图）
        QString uploadImage(QString pathss, QString orderNumber, QString froms);
};

#endif // YMHOMEWORKMANAGERADAPTER_H
