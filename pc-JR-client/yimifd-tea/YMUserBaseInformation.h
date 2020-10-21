﻿#ifndef YMUSERBASEINFORMATION_H
#define YMUSERBASEINFORMATION_H

#include <QObject>
#include<QSettings>
#include<QDebug>

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
        static QString envType;

        static QString logTime;//登录成功的时间
        static bool isStageEnvironment;//是否是预发布环境 默认false
        static QString miniClassToken; //小班课token

        //==================================== >>>
        //记录各个环境的URL信息(生产环境, stage环境, pre环境, dev环境)


        static QString m_strHttpHead_Test;         //记录URL中, http的头: http://test-
        static QString m_strHttpHead;         //记录URL中, http的头: http://
        static QString m_strHttpHead_Stage;   //记录URL中, http的头: http://stage-
        static QString m_strHttpHead_Pre;     //记录URL中, http的头: http://pre-
        static QString m_strHttpHead_Dev;     //记录URL中, http的头: http://dev-
        static QString m_strHttpHead_Stage2;  //记录URL中, http的头: http://stage2-
        static QString m_strMis; //记录"Mis"的URL
        static QString m_strClassroomReport; //记录"课程报告"的URL
        static QString m_strListenUrl;//试听课报告Url
        static QString m_strWriteListenUrl;//填写试听课报告Url
        //<<< ====================================
        static QString appKey,appId;
        static bool m_bIsPublicTest; //记录当前版本, 是不是"公测版本"
        static bool m_bHasExistError; //记录当前是否请求接口出错了, 出错了, 就不启动classroom.exe了
};

#endif // YMUSERBASEINFORMATION_H