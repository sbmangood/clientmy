#ifndef YMLESSONMANAGERADAPTER_H
#define YMLESSONMANAGERADAPTER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include "YMHttpClient.h"
#include<QSsl>
#include<QSslSocket>
#include <openssl/des.h>
#include "ymcrypt.h"
#include<QDataStream>
#include<QTextStream>
#include<QSettings>
#include<QNetworkConfigurationManager>
class YMLessonManagerAdapter
    : public QObject
    , public YMHttpResponseHandler
{
        Q_OBJECT
    public:
        YMLessonManagerAdapter(QObject *parent = 0);
        ~YMLessonManagerAdapter();

        Q_INVOKABLE void getTeachLessonInfo(QString dateTime);
        Q_INVOKABLE void getTeachLessonListInfo(QJsonObject data);
        Q_INVOKABLE void getEnterClass(QString lessonId,int interNetGrade);
        Q_INVOKABLE void getListen(QString userId); //旁听
        Q_INVOKABLE void getLookCourse(QJsonObject lessonInfo);
        Q_INVOKABLE void getRepeatPlayer(QJsonObject lessonInfo);

        Q_INVOKABLE QJsonObject getLiveLessonDetailData(QString lessonId);
        //年级、科目查询
        Q_INVOKABLE void getUserSubjectInfo();

        //教研课表查询
        Q_INVOKABLE void getEmLessons(QJsonObject data);

        //查看是否有报告
        Q_INVOKABLE int getReportFlag(QString lessonId);

        //获取服务IP进行转换
        Q_INVOKABLE void getCloudServer();

        //显示课程详情课后评价信息
        Q_INVOKABLE int getLessonComment(QString lessonId);

        //设置
        Q_PROPERTY(QString lessonType READ getLessonType WRITE setLessonType)
        Q_PROPERTY(QString lessonPlanStartTime READ getLessonPlanStartTime WRITE setLessonPlanStartTime)
        Q_PROPERTY(QString lessonPlanEndTime READ getLessonPlanEndTime WRITE setLessonPlanEndTime)

        //获取年级信息
        Q_INVOKABLE QJsonObject getGrades();

    public slots:
        void getEnterClassresult(QNetworkReply *reply);
        void enterClassTimerOut();
        void getCloudServerIpTimeOut();//获取服务端ip超时

        void runClassRoom(QJsonObject roomData);
        void runPlayer(QJsonObject roomData);
        void runCourse(QJsonObject roomData);
        void getDayLessonData(QString dayData);//根据日期获取当天课程
        void getMonthLessonData(QString startDay,QString endDay);

        void onGetMonthLessonDataFinish(QNetworkReply *reply);
        void onGetDayLessonDataFinish(QNetworkReply *reply);
    public:
        void enterClass();
        void enterListen(); //旁听
        void downLoadFile(QJsonObject data, QString filePath);
        void errorLog(QString message);
        QVariantList getStuTraila(QString trailId, QString fileName, QString fileDir);
        void getStuVideo(QString videoId, QString fileName, QString fileDir);

        QString des_decrypt(const std::string &cipherText);
        QString des_encrypt(const QString &clearText);
        void encrypt(QString source, QString target);
        QList<QString> decrypt(QString source);

        QString lessonPlanStartTime = "";
        QString getLessonPlanStartTime()
        {
            return lessonPlanStartTime;
        }

        void setLessonPlanStartTime(QString time)
        {
            lessonPlanStartTime = time;
        }

        QString lessonPlanEndTime = "";

        QString getLessonPlanEndTime()
        {
            return lessonPlanEndTime;
        }

        void setLessonPlanEndTime(QString time)
        {
            lessonPlanEndTime = time;
        }
        QString currentLessonId = "";

        QString lessonType;
        void setLessonType( QString v)
        {
            if(v == "10" || v == "O")
            {
                lessonType = "O";
            }
            else
            {
                lessonType = "A";
            }
        }
        QString getLessonType()
        {
            return lessonType;
        }



        //重设进入教室的Ip选择 以服务器指定的优先级为最高（ type =1 ）  若服务器未指定则次优先级为 用户自己选择的ip (type = 2)
        void resetSelectIp(int type, QString ip);


    protected:
        virtual void onResponse(int reqCode, const QString &data);

        void onRespGetRepeatPlayer(const QString &data);

    private:
        YMHttpClient * m_httpClint;

        typedef void (YMLessonManagerAdapter::* HttpRespHandler)(const QString& data);
        QMap<int, HttpRespHandler> m_respHandlers;


        QVariantList m_ipPort;
        QJsonObject m_repeatData;
        QJsonObject m_classData;
        QString m_domain;
        QString m_ipAddress;
        QString m_port;
        //查看课件字段
        QString requestData;
        int m_listen;//旁听状态
        bool m_listenOrClass;//监听或者进入教室状态 true 进入教室， false进入旁听
        QTimer *m_timer;
        bool isStop;
        QString m_udpPort;//
        bool teaInClassRoomFlag;//true在教室false不在、当前老师是否在教室
        int offSingle;// 0关单  1 不能关单 是否关单,
        int applicationType;// 0不是标准试听课，1是
        int reportFlag;// 0没有 1有、是否有报告
        QTimer *m_getIpTimer;//获取serverIp是否超时

    signals:
        void teachLessonInfoChanged(QJsonObject lessonInfo);
        void teacherLesonListInfoChanged(QJsonObject lessonInfo);
        void lessonlistRenewSignal();
        void programRuned();
        void setDownValue(int min, int max);
        void downloadChanged(int currentValue);
        void downloadFinished();
        void listenChange(int status);
        void loadingFinished();
        void requstTimeOuted();//请求超时
        //年级、科目信号
        void sigUserSubjectInfo(QJsonObject subjectInfo);

        //教研课表信号
        void sigEmLesson(QJsonObject dataObj);

        //录播未生成信号
        void sigRepeatPlayer();

        //是否在教室弹窗
        void sigIsJoinClassroom(QString teacherName);

        void sigMessageBoxInfo(QString strMsg); //需要提示message box的信号
        //cc已经在教室弹窗
        void sigCCHasInRoom();


        void sigGetMonthLessonData(QJsonArray monthData);
        void sigGetDayLessonData(QJsonArray dayData);
        void sigInvalidToken();
private:
    void setBufferEnterRoomIp(QString currentIp,QString port);
    QString getBufferEnterRoomIP();
    QString getBufferEnterRoomPort();

};

#endif // YMLESSONMANAGERADAPTER_H
