#include <QQmlApplicationEngine>
#include <QApplication>
#include <QQuickView>
#include <QQuickItem>
#include <QDesktopWidget>
#include <QQmlContext>
#include <QDebug>
#include <QTextCodec>
#include <QStandardPaths>
#include <QSharedMemory>
#include <QDir>
#include "toolbar.h"
#include "screenshotsaveimage.h"
#include "../classroom-sdk/sdk/inc/controlcenter/controlcenter.h"
#include "lessonInfo/YMLessonManager.h"
#include "./YMNetworkControl/YMNetworkManagerAdapert.h"
#include "./audioVideoView/VideoRender.h"
#include "./debugLog/debuglog.h"
#include "classinfomanager.h"
#include "dumphelper.h"
#include "uploadFileManager/UploadFileManager.h"
#include "./YMGeometricManager/ellipsepanel.h"
#include "./YMGeometricManager/polygonpanel.h"

int main(int argc, char *argv[])
{
    SetUnhandledExceptionFilter(ExceptionFilter);

    QApplication app(argc, argv);

    QString strAppFileName = QString::fromLocal8Bit(argv[0]);
    StudentData::gestance()->strAppFullPath  = strAppFileName;
    strAppFileName = strAppFileName.mid(strAppFileName.lastIndexOf("\\") + 1);
    StudentData::gestance()->strAppName = strAppFileName;

    // log文件初始化
    DebugLog::GetInstance()->init_log(strAppFileName);
    qInstallMessageHandler(DebugLog::GetInstance()->LogMsgOutput);

    // 一次只允许运行一个实例
    QSharedMemory shared("cloudclassroom");
    if (shared.attach())
    {
        qDebug() << QString("cloudclassroom has already been running, please exit and run again.") << __LINE__;
        return 0;
    }
    shared.create(1);

    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    QString systemPublicFilePath;
    if (docPath == "")
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    systemPublicFilePath = systemPublicFilePath + "YiMi/temp/" + "miniTemp.ini";

    qmlRegisterType<ToolBar>("ToolBar", 1, 0, "ToolBar");
    qmlRegisterType<YMLessonManager>("YMLessonManager",1,0,"YMLessonManager");
    qmlRegisterType<VideoRender>("VideoRender", 1, 0, "VideoRender");
    qmlRegisterType<YMNetworkManagerAdapert>("YMNetworkManagerAdapert",1,0,"YMNetworkManagerAdapert");
    qmlRegisterType<ClassInfoManager>("ClassInfoManager", 1, 0, "ClassInfoManager");
    qmlRegisterType<UploadFileManager>("UploadFileManager", 1, 0, "UploadFileManager");
    qmlRegisterType<EllipsePanel>("EllipsePanel",1,0,"EllipsePanel");
    qmlRegisterType<PolygonPanel>("PolygonPanel",1,0,"PolygonPanel");
    qmlRegisterType<ScreenshotSaveImage>("ScreenshotSaveImage", 1, 0, "ScreenshotSaveImage");


    ControlCenter::getInstance();

    QDesktopWidget *desktopWidget =  QApplication::desktop();
    QRect rect = desktopWidget->screenGeometry();
    int width = rect.width();
    int height = rect.height();
    double  widths = width / 16.0 ;
    double  heights = (height - width / 16 ) / 9.0 ;
    double fixLength = widths > heights ? heights : widths;
    int fullWidths = width;
    int fullHeights = height;
    //全屏高度
    int fullWidth = (int) fixLength * 16;
    int fullHeight = (int) fixLength * 9;

    //右边宽度
    int rightWidth = width * 240 / 1440 ;

    double midWidths = ( width  - rightWidth) / 16.0 ;
    double midFixLength = midWidths > heights ? heights : midWidths;
    //中间高度
    int midWidth = (int) midFixLength * 16;
    int midHeight = (int) midFixLength * 9;

    QQmlApplicationEngine engine;

    //全屏
    engine.rootContext()->setContextProperty("fullWidths", fullWidths );
    engine.rootContext()->setContextProperty("fullHeights", fullHeights );
    engine.rootContext()->setContextProperty("fullWidth", fullWidth );
    engine.rootContext()->setContextProperty("fullHeight", fullHeight );

    //非全屏画布
    engine.rootContext()->setContextProperty("midWidth", midWidth );
    engine.rootContext()->setContextProperty("midHeight", midHeight );

    engine.addImportPath(QCoreApplication::applicationDirPath());

    engine.rootContext()->setContextProperty("getOffSetImage", ControlCenter::getInstance()->getGetOffsetImageInstance());
    engine.addImageProvider("offsetImage", ControlCenter::getInstance()->getImageProvider());

    //356754139247546368 356742243828109312 357832639710760960
    QString roomId = "381050873645633536", userId = "123654", nickName = "%E6%AE%B7%E6%82%A6", userType = "0";

    int socketTcpPort = 5250;
    int socketHttpPort = 5251;
    QString socketIp = "115.159.218.155";
    QString channelKey, channelName, token, uid, chatRoomId,title,agoraAppid;
    int userRole = 0;//0老师 1 学生 2助教
    int statusCode = 0;
    int sumCredit = 1000, redCount = 100, normalRange = 40, limitRange = 20, creditMax = 300, redTime = 10, countDownTime = 3;
    QString appId = "kiFBIeLYvxOuWFgwWOy1XFFFehdA2ovo";
    QString appKey = "L6X0TIPFLQGkwEKM";
    QString envType = "sit01";
    QVariantList ipList;
    int groupId = 0;
    int classType = 0;  // 房间类型 （0：1对1，1：1对6，2：1对12，3：大班课）
    if(argc == 2)
    {
        QMap<QString, QString> argvMap;
        QString appUrl = argv[1];
        appUrl = appUrl.section('?', 1);
        QStringList argvList = appUrl.split('&');
        for(int index=0; index<argvList.size(); index++)
        {
            QStringList tempList = argvList[index].split('=');
            argvMap[tempList[0]] = tempList[1];
        }

        appId = argvMap["appId"];
        appKey = argvMap["appKey"];
        roomId = argvMap["roomId"];
        userId = argvMap["userId"];
        userRole = argvMap["userRole"].toInt();
        nickName = argvMap["nickName"];
        sumCredit = argvMap.find("sumCredit") == argvMap.end() ? 1000 : argvMap["sumCredit"].toInt();
        redCount = argvMap.find("redCount") == argvMap.end() ? 100 : argvMap["redCount"].toInt();
        normalRange = argvMap.find("normalRange") == argvMap.end() ? 40 : argvMap["normalRange"].toInt();
        limitRange = argvMap.find("limitRange") == argvMap.end() ? 20 : argvMap["limitRange"].toInt();
        creditMax = argvMap.find("creditMax") == argvMap.end() ? 300 : argvMap["creditMax"].toInt();
        redTime = argvMap.find("redTime") == argvMap.end() ? 10 : argvMap["redTime"].toInt();
        countDownTime = argvMap.find("countDownTime") == argvMap.end() ? 3 : argvMap["countDownTime"].toInt();
        userType = argvMap["userRole"];
        groupId = argvMap["groupId"].toInt();
        envType = argvMap["envType"];
        qDebug()<< "argvs----"<< appId<< appKey<< roomId<< userId<< userRole<< nickName<< sumCredit<< redCount<< normalRange
                << limitRange<< creditMax<< redTime<< countDownTime<< userType<< groupId<< envType;
    }

    nickName = DebugLog::gestance()->UrlCode(nickName.toStdString()).c_str();

    if(envType.trimmed().length() > 0) //如果不是生产环境
    {
        envType += "-";
    }
    QString apiUrl = "http://" + envType + "liveroom.yimifudao.com/v1.0.0/openapi";
    ClassInfoManager* classInfoMgr = ClassInfoManager::getInstance();
    classInfoMgr->init(appId, appKey, apiUrl, roomId, userId, userRole);
    classInfoMgr->registerClassroomEventInfo();
    classInfoMgr->getCloudDiskList(roomId, apiUrl, appId, false);// 此处先查询一次课件列表信息，后面同步课件需要使用课件名称

    if(classInfoMgr)
    {
        QString errStatus = "";
        if(0 != classInfoMgr->getSocketAddr(socketIp, socketTcpPort, socketHttpPort))
        {
           errStatus = "1002" ;
        }
        if(0 != classInfoMgr->getSocketIpList(socketTcpPort, ipList))
        {
           errStatus = "1001" ;
        }
        if(0 != classInfoMgr->getEnterRoomInfo(channelKey, channelName, token, uid, chatRoomId, title,statusCode, classType,agoraAppid))
        {
           errStatus = "1003" ;
        }
        engine.rootContext()->setContextProperty("errStatus", errStatus );
        engine.rootContext()->setContextProperty("className", title );
        engine.rootContext()->setContextProperty("statusCode", statusCode );
    }
    engine.rootContext()->setContextProperty("socketIp", socketIp );
    engine.rootContext()->setContextProperty("currentGroupId", groupId );
    engine.rootContext()->setContextProperty("teaNickName",nickName);
    engine.rootContext()->setContextProperty("userRole",userRole);
    engine.rootContext()->setContextProperty("userId",userId);
    engine.rootContext()->setContextProperty("roomId",roomId);

    QJsonObject infoObj;
    QString chatRoomUrl = "http://" + envType + "im.yimifudao.com/";
    infoObj.insert("classType", one_to_one);// 教室类型
    infoObj.insert("nickName", nickName);
    infoObj.insert("userRole", userRole);
    infoObj.insert("groupId",  groupId);
    infoObj.insert("userId",   userId);
    infoObj.insert("classroomId", roomId);
    infoObj.insert("chatRoomId", chatRoomId);
    infoObj.insert("apiUrl", apiUrl);
    infoObj.insert("chatRoomUrl", chatRoomUrl);
    infoObj.insert("appKey", appKey);
    infoObj.insert("appId", appId);
    infoObj.insert("envType", envType);
    ControlCenter::getInstance()->setUserInfo(infoObj);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QDir::setCurrent(QCoreApplication::applicationDirPath());

    ControlCenter* control = ControlCenter::getInstance();
    control->setServerAddr(ipList, socketHttpPort, socketIp, socketTcpPort);
    control->setRedPackets(sumCredit,redCount,normalRange,limitRange,creditMax,redTime,countDownTime);
    control->setAudioVideoInfo(channelKey, channelName, token, uid, chatRoomId,agoraAppid);
    control->initControlCenter(appId, appKey, roomId, groupId, userId, nickName, userRole, classType);

    //初始化埋点SDK
    yimipingback::PingbackManager::gestance()->InitSDK("YIMI", appId,"1.1.0");
    //埋点注册用户信息
    yimipingback::PingbackManager::gestance()->SetUserInfo(userId, userRole == 0 ?"TEA": "STU");


    return app.exec();
}
