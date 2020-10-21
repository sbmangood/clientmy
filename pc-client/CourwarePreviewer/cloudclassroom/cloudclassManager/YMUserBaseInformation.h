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
    static bool currentIsOldVersion;//当前是不是新版本或者老版本 为了兼容16:9
    static int isMiniClass;//是不是小班课查看课件
};

#endif // YMUSERBASEINFORMATION_H
