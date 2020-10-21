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
QString YMUserBaseInformation::appVersion = "2.4.001"; //
QString YMUserBaseInformation::apiVersion = "2.5";
QString YMUserBaseInformation::deviceInfo = "";
QString YMUserBaseInformation::MD5Pwd = "";
QString YMUserBaseInformation::versionCode = "27"; //"25";//
QString YMUserBaseInformation::fontStr = "";
QString YMUserBaseInformation::type = "TEA";//"tea_pc_beta";// 上线时  把 更新接口传参 appName
QString YMUserBaseInformation::passWordNormal = "";         // 值  改为 tea_pc
QString YMUserBaseInformation::latitude = "";
QString YMUserBaseInformation::longitude = "";
QString YMUserBaseInformation::url = "";
QString YMUserBaseInformation::lessonId = "";

QString YMUserBaseInformation::miniUrl="https://dev-platform.yimifudao.com/v1.0.0";
QString YMUserBaseInformation::miniH5 = "http://dev-h5.yimifudao.com/classAssignment";
QString YMUserBaseInformation::liveroomId = "";

QString YMUserBaseInformation::m_strHttpHead = "http://";               //记录URL中, http的头: http://
QString YMUserBaseInformation::m_strHttpHead_Test = "http://test-";               //记录URL中, http的头: http://test-
QString YMUserBaseInformation::m_strHttpHead_Stage = "http://stage-";   //记录URL中, http的头: http://stage-
QString YMUserBaseInformation::m_strHttpHead_Stage3 = "http://stage3-";   //记录URL中, http的头: http://stage3-
QString YMUserBaseInformation::m_strHttpHead_Pre = "http://pre-";       //记录URL中, http的头: http://pre-
QString YMUserBaseInformation::m_strHttpHead_Dev = "http://dev-";       //记录URL中, http的头: http://dev-
QString YMUserBaseInformation::m_strForgetPassword = ""; //记录"忘记密码"的URL
QString YMUserBaseInformation::m_strSignUp = ""; //记录"立即注册"的URL
QString YMUserBaseInformation::m_strLiveLesson = ""; //记录"直播课"的URL
QString YMUserBaseInformation::m_strMyLive = ""; //记录"我的直播课"的URL
QString YMUserBaseInformation::m_strSqReport = ""; //记录"SQ学商"的URL
QString YMUserBaseInformation::m_strClassroomReport = ""; //记录"课程报告"的URL
QString YMUserBaseInformation::m_strMiniClassOrderList = ""; //记录小班课"订单"按钮的URL
QString YMUserBaseInformation::m_strMiniClassHomePage = ""; //记录小班课"首页"的URL
QString YMUserBaseInformation::m_strPlan = ""; //记录"课程规划"的URL

YMUserBaseInformation::YMUserBaseInformation(QObject *parent)
    : QObject(parent)
{

}

YMUserBaseInformation::~YMUserBaseInformation()
{

}
