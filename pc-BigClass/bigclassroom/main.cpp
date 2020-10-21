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
#include "../classroom-sdk/sdk/inc/controlcenter/controlcenter.h"
#include "lessonInfo/YMLessonManager.h"
#include "./YMNetworkControl/YMNetworkManagerAdapert.h"
#include "./audioVideoView/VideoRender.h"
#include "./debugLog/debuglog.h"
#include "classinfomanager.h"
#include "dumphelper.h"
#include "uploadFileManager/UploadFileManager.h"

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
    QSharedMemory shared("bigclassroom");
    if (shared.attach())
    {
        qDebug() << QString("bigclassroom-tea has already been running, please exit and run again.") << __LINE__;
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
    QString roomId = "359282136269721600", userId = "6868", nickName = "%E6%AE%B7%E6%82%A6", userType = "0";


    int socketTcpPort = 5250;
    int socketHttpPort = 5251;
    QString socketIp = "115.159.218.155";
    QString channelKey, channelName, token, uid, chatRoomId,title;
    int userRole = 0;//0老师 1 学生 2助教
    int statusCode = 0;
    int sumCredit = 1000, redCount = 100, normalRange = 40, limitRange = 20, creditMax = 300, redTime = 10, countDownTime = 3;
    QString appId = "7169a6c5ab5b4eeba2ca37b831fb9239";
    QString appKey = "yimi_324122469776515704_ccb123456_m9if1K_1566806110610";
    QString envType = "sit01";
    QVariantList ipList;
    int groupId = 0;
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

    if(classInfoMgr)
    {
        classInfoMgr->getSocketAddr(socketIp, socketTcpPort, socketHttpPort);
        classInfoMgr->getSocketIpList(socketTcpPort, ipList);
        classInfoMgr->getEnterRoomInfo(channelKey, channelName, token, uid, chatRoomId, title,statusCode);
        engine.rootContext()->setContextProperty("className", title );
        engine.rootContext()->setContextProperty("statusCode", statusCode );
    }
    engine.rootContext()->setContextProperty("socketIp", socketIp );
    engine.rootContext()->setContextProperty("currentGroupId", groupId );
    engine.rootContext()->setContextProperty("teaNickName",nickName);

    QJsonObject infoObj;
    QString chatRoomUrl = "http://" + envType + "im.yimifudao.com/";
    infoObj.insert("nickName", nickName);
    infoObj.insert("userRole", userRole);
    infoObj.insert("groupId",  groupId);
    infoObj.insert("userId",   userId);
    infoObj.insert("classroomId", roomId);
    infoObj.insert("chatRoomId", chatRoomId);
    infoObj.insert("apiUrl", apiUrl);
    infoObj.insert("chatRoomUrl", chatRoomUrl);
    infoObj.insert("appKey", appKey);
    infoObj.insert("envType", envType);
    ControlCenter::getInstance()->setUserInfo(infoObj);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QDir::setCurrent(QCoreApplication::applicationDirPath());

    ControlCenter* control = ControlCenter::getInstance();
    control->setServerAddr(ipList, socketHttpPort, socketIp, socketTcpPort);
    control->setRedPackets(sumCredit,redCount,normalRange,limitRange,creditMax,redTime,countDownTime);
    control->setAudioVideoInfo(channelKey, channelName, token, uid, chatRoomId);
    control->initControlCenter(appId, appKey, roomId, groupId, userId, nickName, userRole, 1);

    return app.exec();
}
