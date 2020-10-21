#include "YMUserBaseInformation.h"

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
QString YMUserBaseInformation::appVersion = "5.04.06.131";
QString YMUserBaseInformation::apiVersion = "2.4";
QString YMUserBaseInformation::deviceInfo = "";
QString YMUserBaseInformation::MD5Pwd = "";
QString YMUserBaseInformation::versionCode;// = "31019"; // 线上 36, versionCode 小于服务器上的时候, 会提示更新下载, 发布线上版本的时候, 需要加1
QString YMUserBaseInformation::fontStr = "";
QString YMUserBaseInformation::type = "STU";
QString YMUserBaseInformation::passWordNormal = "";
QString YMUserBaseInformation::geolocation = "0,0";
bool YMUserBaseInformation::stuUserType = false;
QString YMUserBaseInformation::sqId = 0;
QString YMUserBaseInformation::logTime = "";
bool YMUserBaseInformation::isStageEnvironment = false;
QString YMUserBaseInformation::miniUrl="https://dev-platform.yimifudao.com.cn/v1.0.0";
QString YMUserBaseInformation::miniH5 = "http://dev-h5.yimifudao.com.cn/classAssignment";

//==================================== >>>
//记录各个环境的URL信息(生产环境, stage环境, pre环境, dev环境)

QString YMUserBaseInformation::m_strForgetPassword = ""; //记录"忘记密码"的URL
QString YMUserBaseInformation::m_strSignUp = ""; //记录"立即注册"的URL
QString YMUserBaseInformation::m_strLiveLesson = ""; //记录"直播课"的URL
QString YMUserBaseInformation::m_strClassroomReport = ""; //记录"课程报告"的URL
QString YMUserBaseInformation::m_strPlan = ""; //记录"课程规划"的URL
QString YMUserBaseInformation::m_strSqReport = ""; //记录"SQ学商"的URL
QString YMUserBaseInformation::m_strMyLive = ""; //记录"我的直播课"的URL
QString YMUserBaseInformation::m_strMiniClassOrderList = ""; //记录小班课"订单"按钮的URL
QString YMUserBaseInformation::m_strMiniClassHomePage = ""; //记录小班课"首页"的URL
bool YMUserBaseInformation::m_bIsPublicTest = false; //记录当前版本, 是不是"公测版本"
bool YMUserBaseInformation::m_bHasExistError = false; //记录当前是否请求接口出错了, 出错了, 就不启动classroom.exe了

QString YMUserBaseInformation::m_strHttpHead = "http://";               //记录URL中, http的头: http://
QString YMUserBaseInformation::m_strHttpHead_Test = "http://test-";               //记录URL中, http的头: http://test-
QString YMUserBaseInformation::m_strHttpHead_Stage = "http://stage-";   //记录URL中, http的头: http://stage-
QString YMUserBaseInformation::m_strHttpHead_Stage3 = "http://stage3-";   //记录URL中, http的头: http://stage3-
QString YMUserBaseInformation::m_strHttpHead_Pre = "http://pre-";       //记录URL中, http的头: http://pre-
QString YMUserBaseInformation::m_strHttpHead_Dev = "http://dev-";       //记录URL中, http的头: http://dev-
//<<< ====================================

YMUserBaseInformation::YMUserBaseInformation(QObject *parent)
    : QObject(parent)
{

}

YMUserBaseInformation::~YMUserBaseInformation()
{

}
