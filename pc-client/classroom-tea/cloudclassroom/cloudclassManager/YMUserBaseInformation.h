#ifndef YMUSERBASEINFORMATION_H
#define YMUSERBASEINFORMATION_H

#include <QObject>

class YMUserBaseInformation : public QObject
{
        Q_OBJECT
    public:
        explicit YMUserBaseInformation(QObject *parent = 0);
        ~YMUserBaseInformation();
        static QString type, token, mobileNo, userName, passWord, realName;
        static QString nickName, id, sex, email, headPicture, roleId, role;
        static QString system, pcVersion, pcName;
        static QString appVersion, apiVersion;
        static QString MD5Pwd, deviceInfo;
        static QString versionCode;
        static QString fontStr;
        static QString passWordNormal;//明文密码
        static QString longitude, latitude; //经纬度
        static QString url;
        static QString lessonId;

        //=========================
        static int offSingle;//0 可以 1不能、是否关单",
        static int applicationType;//0不是标准试听课，1是
        static int reportFlag;//0没有1有、是否有报告
        static int lessonType;//0,1试听课, 10订单课、课程类型",
        static int subjectId;//0      演示课
        static QString endLessonH5Url;//结束课程时试听课报告的h5页面地址

        static long currentDateTimes;//记录当前时间

        static QString aStudentName;//A学生真实姓名
};

#endif // YMUSERBASEINFORMATION_H
