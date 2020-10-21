#ifndef YMHOMEWORKMANAGERADAPTER_H
#define YMHOMEWORKMANAGERADAPTER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "YMHttpClient.h"
#include <QSsl>
#include <QSslSocket>
#include <openssl/des.h>
#include "ymcrypt.h"
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
#include "YMUserBaseInformation.h"

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

        Q_INVOKABLE void getCurrentStage();//获取当前环境配置
        Q_INVOKABLE void updateStage(int netType,QString stageInfo);//修改配置文件


    private:
        YMHttpClient * m_httpClient;

    signals:
        void lessonlistRenewSignal();
        void lodingFinished();//加载数据完成
        void requestTimerOut();
        void sigStageInfo(int netType,QString stageInfo);
        void sigMessageBoxInfo(QString strMsg); //需要提示message box的信号
    public slots:
};

#endif // YMHOMEWORKMANAGERADAPTER_H
