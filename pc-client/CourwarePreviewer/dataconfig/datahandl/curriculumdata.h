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
        Q_INVOKABLE QString getLessonType();

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
};

#endif // CURRICULUMDATA_H
