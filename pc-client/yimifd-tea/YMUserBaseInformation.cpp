﻿#include "YMUserBaseInformation.h"

QString YMUserBaseInformation::token = "";
QString YMUserBaseInformation::mobileNo = "";
QString YMUserBaseInformation::userName = "";
QString YMUserBaseInformation::passWord = "";
QString YMUserBaseInformation::realName = "";
QString YMUserBaseInformation::nickName = "";
QString YMUserBaseInformation::id = "";
QString YMUserBaseInformation::sex = "";
QString YMUserBaseInformation::email = "";
QString YMUserBaseInformation::headPicture = "";
QString YMUserBaseInformation::role = "";
QString YMUserBaseInformation::roleId = "";
QString YMUserBaseInformation::system = "";
QString YMUserBaseInformation::pcVersion = "";
QString YMUserBaseInformation::pcName = "";
QString YMUserBaseInformation::appVersion = "5.04.06.132";
QString YMUserBaseInformation::apiVersion = "2.4";
QString YMUserBaseInformation::deviceInfo = "";
QString YMUserBaseInformation::MD5Pwd = "";
QString YMUserBaseInformation::versionCode;// = "39"; // 线上 36, versionCode 小于服务器上的时候, 会提示更新下载, 发布线上版本的时候, 需要加1
QString YMUserBaseInformation::fontStr = "";
QString YMUserBaseInformation::type = "TEA";//"tea_pc_beta";// 上线时  把 更新接口传参 appName
QString YMUserBaseInformation::passWordNormal = "";         // 值  改为 tea_pc
QString YMUserBaseInformation::latitude = "";
QString YMUserBaseInformation::longitude = "";
QString YMUserBaseInformation::url = "https://api.1mifd.com.cn/v2.4";

QString YMUserBaseInformation::logTime = "";

bool YMUserBaseInformation::isStageEnvironment = false;

//==================================== >>>
//记录各个环境的URL信息(生产环境, stage环境, pre环境, dev环境)

QString YMUserBaseInformation::m_strMis = ""; //记录"Mis"的URL
QString YMUserBaseInformation::m_strClassroomReport = ""; //记录"课程报告"的URL

QString YMUserBaseInformation::m_strListenUrl;//试听课报告Url
QString YMUserBaseInformation::m_strWriteListenUrl;//填写试听课报告Url

bool YMUserBaseInformation::m_bIsPublicTest = false; //记录当前版本, 是不是"公测版本"
bool YMUserBaseInformation::m_bHasExistError = false; //记录当前是否请求接口出错了, 出错了, 就不启动classroom.exe了

QString YMUserBaseInformation::m_strHttpHead = "http://";               //记录URL中, http的头: http://
QString YMUserBaseInformation::m_strHttpHead_Test = "http://test-";               //记录URL中, http的头: http://test-
QString YMUserBaseInformation::m_strHttpHead_Stage = "http://stage-";   //记录URL中, http的头: http://stage-
QString YMUserBaseInformation::m_strHttpHead_Pre = "http://pre-";       //记录URL中, http的头: http://pre-
QString YMUserBaseInformation::m_strHttpHead_Dev = "http://dev-";       //记录URL中, http的头: http://dev-
QString YMUserBaseInformation::m_strHttpHead_Stage2 = "http://stage2-"; //记录URL中, http的头: http://stage2-
//<<< ====================================

YMUserBaseInformation::YMUserBaseInformation(QObject *parent)
    : QObject(parent)
{

}

YMUserBaseInformation::~YMUserBaseInformation()
{

}

