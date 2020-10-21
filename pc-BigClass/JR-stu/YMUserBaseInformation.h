﻿#ifndef YMUSERBASEINFORMATION_H
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

        static QString geolocation;
        static bool stuUserType;
        static QString sqId;//测评id

        static QString logTime;
        static bool isStageEnvironment;//是否是预发布环境 默认false

        //==================================== >>>
        //记录各个环境的URL信息(生产环境, stage环境, pre环境, dev环境)

        static QString m_strHttpHead_Test;         //记录URL中, http的头: http://test-
        static QString m_strHttpHead;         //记录URL中, http的头: http://
        static QString m_strHttpHead_Stage;   //记录URL中, http的头: http://stage-
        static QString m_strHttpHead_Stage3;   //记录URL中, http的头: http://stage3-
        static QString m_strHttpHead_Pre;     //记录URL中, http的头: http://pre-
        static QString m_strHttpHead_Dev;     //记录URL中, http的头: http://dev-

        static QString m_strForgetPassword; //记录"忘记密码"的URL
        static QString m_strSignUp; //记录"立即注册"的URL
        static QString m_strLiveLesson; //记录"直播课"的URL
        static QString m_strClassroomReport; //记录"课程报告"的URL
        static QString m_strPlan; //记录"课程规划"的URL
        static QString m_strSqReport; //记录"SQ学商"的URL
        static QString m_strMyLive; //记录"我的直播课"的URL
        static QString miniUrl,miniH5; //小班课url小班课h5url
        static QString m_strMiniClassOrderList; //记录小班课"订单"按钮的URL
        static QString m_strMiniClassHomePage; //记录小班课"首页"的URL
        //<<< ====================================

        static bool m_bIsPublicTest; //记录当前版本, 是不是"公测版本"
        static bool m_bHasExistError; //记录当前是否请求接口出错了, 出错了, 就不启动classroom.exe了
};

#endif // YMUSERBASEINFORMATION_H