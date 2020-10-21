#ifndef COMMDEF_H
#define COMMDEF_H
#include <QObject>
#include <QMetaEnum>
const QString   kAppType = "yihuiyun";
const QString   kSDKVersion = "V100";

enum YimiLogType {
     LOGTYPE_DEFAULT = 0,
     CLICK = 1,//点击
     PV = 2, //页面跳转
     HEARTBEAT = 3,//上课心跳信息
     OPEN = 4,//app 打开
     CRASH=5,//app crash
     EXIT =6,//app 退出
     REFRESH = 7,//页面刷新
     SEARCH = 8  //搜索
};



#endif // COMMDEF_H
