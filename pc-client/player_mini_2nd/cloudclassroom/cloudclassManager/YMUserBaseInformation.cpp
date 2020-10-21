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

YMUserBaseInformation::YMUserBaseInformation(QObject *parent)
    : QObject(parent)
{

}

YMUserBaseInformation::~YMUserBaseInformation()
{

}
