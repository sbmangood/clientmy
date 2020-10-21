#ifndef CURRICULUMDATA_H
#define CURRICULUMDATA_H

#include <QObject>
#include <QStringList>
#include <QDebug>
#include "./datamodel.h"

class CurriculumData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString curriculumName READ curriculumName)
    Q_PROPERTY(QString startToEndTime READ startToEndTime)
    Q_PROPERTY(int beginClassTimeData READ beginClassTimeData  WRITE setBeginClassTimeData NOTIFY beginClassTimeDataChanged)
    Q_PROPERTY(QString studentName READ studentName)
    Q_PROPERTY(QString flipStudentName READ flipStudentName)
    Q_PROPERTY(QString exitStudentName READ exitStudentName)
    Q_PROPERTY(QString applyExitStudentName READ applyExitStudentName)
    Q_PROPERTY(QString enterRoomRequestName READ enterRoomRequestName)
    Q_PROPERTY(QString droppedRoomName READ droppedRoomName)
    Q_PROPERTY(QString cameraStatusName READ cameraStatusName)
    Q_PROPERTY(int courseTimeTotalLength READ courseTimeTotalLength)
    Q_PROPERTY(QString curriculumId READ curriculumId)
    Q_PROPERTY(QStringList listAllUserId READ listAllUserId)

public:
    explicit CurriculumData(QObject *parent = 0);
    virtual ~CurriculumData();

    //得到用户的姓名
    Q_INVOKABLE  QString getUserName(QString userId);

    //设置视频的所有的id
    Q_INVOKABLE void getListAllUserId();

    //得到用户的url
    Q_INVOKABLE  QString getUserUrl(QString userId);

    //判断用户是否在线
    Q_INVOKABLE  QString justUserOnline(QString userId);

    //得到是否是视频聊天
    Q_INVOKABLE  QString getIsVideo();

    //是否是老师
    Q_INVOKABLE QString isTeacher(QString userId);

    //获得操作权限
    Q_INVOKABLE QString getUserBrushPermissions();

    //获得某个用户的操作权限
    Q_INVOKABLE QString getUserIdBrushPermissions(QString userId);

    //得到用户的类型
    Q_INVOKABLE  QString getUserType(QString userId);

    //得到当前用户的类型
    Q_INVOKABLE  QString getCurrentUserType();

    //判断老师是否在线
    Q_INVOKABLE bool  justTeacherOnline();

    //判断A学生是否在线
    Q_INVOKABLE bool  justAStundentOnline();

    //获得开课时间
    Q_INVOKABLE QString getStartClassTimelen();

    //判断是否已经开课
    Q_INVOKABLE bool justIsStartClass();

    //查看用户是否有翻页权限
    Q_INVOKABLE bool isUserPagePermissions();

    //得到用户摄像头状态
    Q_INVOKABLE QString getUserCamcera(QString userId);

    //得到用户话筒状态
    Q_INVOKABLE QString getUserPhone(QString userId);

    //得到用户的通道
    Q_INVOKABLE QString getUserChanncel();

    //得到所有的ip列表
    Q_INVOKABLE QStringList getAllIpList();

    //获取用户所有信息
    Q_INVOKABLE QJsonObject getUserInfo(QString userId);

    //获取课程类型
    Q_INVOKABLE int getLessonType();

    Q_INVOKABLE int getSubjectId();

    Q_INVOKABLE int getApplicationType();

    //获取是不是标准试听课
    Q_INVOKABLE bool getIsStandardLesson();

    //获取是否已经生产试听课报告
    Q_INVOKABLE bool getLessonReportStatus();

    //获取当前的角色类型
    Q_INVOKABLE int getCurrentRoleType();

    //获取当前第一次进入教室时是不是旁听身份
    Q_INVOKABLE bool getCurrentIsAttend();

    //获取老师的Id
    Q_INVOKABLE QString getTeacherId();

    //获取当前用户的id
    Q_INVOKABLE QString getCurrentUserId();

    //返回持麦者的user id
    Q_INVOKABLE QString getJoinMicId();

    //获取旁听Id
    Q_INVOKABLE QString getListenId();

    //获取结束课程时试听课报告的地址
    //Q_INVOKABLE QString getEndLessonH5Url();

    //返回当前cccr的id
    Q_INVOKABLE QString getCurrentCcCameraStatus ();
    //获取当前持麦者的Id
    Q_INVOKABLE QString getCurrentOrderId ();

    //判断userId, 是否是学生
    Q_INVOKABLE bool doCheck_ID_Is_Student(QString userId);

    Q_INVOKABLE void setCouldDirectExit( bool couldDirectExit);

    //获取是否生成试听课报告
    Q_INVOKABLE bool getIsReportStatus();

    //关闭报告写入课程Id
    Q_INVOKABLE void writeReport(QString lessonId);

    //根据用户id判断用户是否在线
    Q_INVOKABLE bool justUserIsOnline(QString userId);

    //判断cc是否在线
    Q_INVOKABLE bool justCCIsOnline();

    //获取CC的id
    Q_INVOKABLE QString getCCId();

    //判断学生是否在线
    Q_INVOKABLE bool justStudentIsOnline();

    //得到a学生的姓名
    Q_INVOKABLE  QString getAStudentName();

signals:
    void beginClassTimeDataChanged();
    void sigListAllUserId(QStringList list);


public slots:


public:
    void setBeginClassTimeData(int&beginClassTimeData );

private:
    //获得课程名称
    QString curriculumName();
    //获得课程id
    QString curriculumId();
    //开始到结束时间
    QString startToEndTime();

    //获得课程时间总长度
    int courseTimeTotalLength();
    //开始上课的时间
    int beginClassTimeData();
    //学生的姓名
    QString studentName();
    //翻页学生的名字
    QString flipStudentName();
    //退出教室的学生名称
    QString exitStudentName();
    //申请退出教室
    QString applyExitStudentName();
    //b学生进入房间
    QString enterRoomRequestName();
    //掉线学生的姓名
    QString droppedRoomName();
    //摄像头状态跟话筒的状态的姓名
    QString cameraStatusName();
    //返回所有用户的id
    QStringList listAllUserId();

    QString getEndLessonH5Url();

};

#endif // CURRICULUMDATA_H
