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
    Q_INVOKABLE void getEnterClass(QString lessonId);
    Q_INVOKABLE void getListen(QString userId);
    Q_INVOKABLE void getLookCourse(QJsonObject lessonInfo);
    Q_INVOKABLE void getRepeatPlayer(QJsonObject lessonInfo);

    Q_INVOKABLE QJsonObject getLiveLessonDetailData(QString lessonId);
    //年级、科目查询
    Q_INVOKABLE void getUserSubjectInfo();

    //教研课表查询
    Q_INVOKABLE void getEmLessons(QJsonObject data);

    //设置
    Q_PROPERTY(QString lessonType READ getLessonType WRITE setLessonType)

    //获取小班课课列表
    Q_INVOKABLE void getCurrentLessonTable(QString dateTime);

    //小班课我的课程
    Q_INVOKABLE void getMyLessonInfo(int page,int pageSize);

    //获取小班课课程目录
    Q_INVOKABLE void getCatalogs(QString classId);

    //小班课进入教室数据获取
    Q_INVOKABLE void getJoinClassRoomInfo(QString executionPlanId);

    //拓课云进入教室
    Q_INVOKABLE void getJoinTalkClassRoomInfo(QString executionPlanId);

    //小班课浏览课件
    Q_INVOKABLE void browseCourseware(QString executionPlanId);

	// 得到旁听课程列表(小班课)
    Q_INVOKABLE void getAttendLessonListInfo(QJsonObject data);
    // 得到教师列表(旁听)(小班课)
    Q_INVOKABLE void getListenTeachers();
    // 得到当前老师学科和年级(小班课)
    Q_INVOKABLE void findGradeAndSubject();
    // 小班课二期旁听-进入旁听
    Q_INVOKABLE void getListenClassroom(QString executionPlanId);
	
    //小班课查看录播
    Q_INVOKABLE void getPlayback(QString executionPlanId);

    //设置开课时间
    Q_INVOKABLE void setQosStartTime(qlonglong startTime,qlonglong endTime);


public slots:
    void getEnterClassresult(QNetworkReply *reply);
    void enterClassTimerOut();
public:
    void downloadMiniPlayFile(QJsonArray dataArray);
    void writeFile(QString liveroomId,QString path,int fileNumber,QString suffix);
    void getCloudServer();
    void getListenCloudServerIp();// 小班课旁听
    void enterListenClass();// 小班课旁听教室
    void enterClass();
    void enterListen();
    void downLoadFile(QJsonObject data, QString filePath);
    void errorLog(QString message);
    QVariantList getStuTraila(QString trailId, QString fileName, QString fileDir);
    void getStuVideo(QString videoId, QString fileName, QString fileDir);
    void qosV2Mannage();

    QString des_decrypt(const std::string &cipherText);
    QString des_encrypt(const QString &clearText);
    void encrypt(QString source, QString target);
    QList<QString> decrypt(QString source);

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
    YMHttpClient * m_httpClient;

    typedef void (YMLessonManagerAdapter::* HttpRespHandler)(const QString& data);
    QMap<int, HttpRespHandler> m_respHandlers;

    QMap<int, HttpRespHandler> m_playbackHandlers;

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
    QString m_tcpPort;//
    QString m_httpPort;
    QString execPlanId;
    QString m_startTime,m_endTime;
    QString m_lessonId;
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

    //小班课我的课表
    void sigCurrentLessonInfo(QJsonObject lessonInfo);
    //小班课我的课程
    void sigMyLessonInfo(QJsonObject lessonInfo);
    //小班课课程目录
    void sigCatalogsInfo(QJsonObject catalogsInfo);
    //小班课进入教室数据信号
    void sigJoinClassroom(QJsonObject joinClassroomInfo);
    //小班课浏览课件失败信号
    void sigBrowseCoursewareFail();

    //小班课录播接口
    void sigPlaybackInfo(QJsonObject playbackData);
    void sigJoinClassroomStaus();//进入教室信号
	
	void attendLessonListInfoChanged(QJsonObject lessonListInfo);// 旁听课程列表信号(小班课)
    void listenTeachersListInfoChanged(QJsonObject teacherListInfo);// 老师列表信号（小班课）
    void gradeAndSubjectInfoChanged(QJsonObject gradeSubjectInfo);// 当前老师学科和年级(小班课)
    void loadingAttendLessonListInfoFinished();// 加载旁听课程列表完成信号(小班课)
    void sigJoinClassroomFail();//进入教室失败信号

};

#endif // YMLESSONMANAGERADAPTER_H
