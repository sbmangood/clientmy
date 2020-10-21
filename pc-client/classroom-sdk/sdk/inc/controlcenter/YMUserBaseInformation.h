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
        static QString miniUrl,miniH5,liveroomId; //小班课url小班课h5url
};

#endif // YMUSERBASEINFORMATION_H
