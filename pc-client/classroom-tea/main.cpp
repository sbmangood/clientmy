//#include <QGuiApplication>
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
#include "./dataconfig/trailboard/trailboard.h"
#include "./httprequset/requsetinfor/networkaccessmanagerinfor.h"
#include "./dataconfig/datahandl/mxresloader.h"
#include "./dataconfig/trailboard/polygonpanel.h"
#include "./dataconfig/trailboard/ellipsepanel.h"
#include "./httprequset/requsetinfor/loadinformation.h"
#include "./dataconfig/trailboard/screenshotsaveimage.h"
#include "./dataconfig/datahandl/curriculumdata.h"
#include "../../../pc-common/AudioVideoSDKs/AudioVideoManager.h"
#include "./videovoice/externalcallchanncel.h"
#include "./videovoice/videorender.h"
#include "./dataconfig/pinghandl/handlpinginfor.h"
#include "./httprequset/requsetinfor/resetipsettingfile.h"
#include "./debuglog.h"
#include "./cloudclassroom/cloudclassManager/YMHomeworkManagerAdapter.h"
#include "./cloudclassroom/cloudclassManager/YMHomeworkWrittingBoard.h"
#include "./cloudclassroom/cloudclassManager/YMCloudClassManagerAdapter.h"
#include "./dataconfig/trailboard/getoffsetimage.h"
#include "./cloudclassroom/cloudclassManager/HtmlSytelSetting.h"
#include "./panDuWriteBoard/panduwriteboard.h"
#include "debuglog.h"
#include "YMCallStack.h"
#include"../YMCommon/qosManager/YMQosManager.h"
#include "../../pc-common/yimibreakpad/yimibreakpad.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    // app.setWindowIcon(QIcon(":/images/stu64.ico")); //设置QMessageBox的标题中的ico

    //=======================================
    //注冊: 程序发生异常的捕获函数
    //SetUnhandledExceptionFilter((LPTOP_LEVEL_EXCEPTION_FILTER)ApplicationCrashHandler);

    //=======================================
    //记录当前应用程序的名称
    QString strAppFileName = QString::fromLocal8Bit(argv[0]); //需要放在代码: QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8")); 前面, 因为: 中文乱码的问题
    //    QMessageBox::critical(NULL, "aaa", strAppFileName, QMessageBox::Ok, QMessageBox::Ok); //测试中文乱码
    StudentData::gestance()->strAppFullPath  = strAppFileName;
    strAppFileName = strAppFileName.mid(strAppFileName.lastIndexOf("\\") + 1);
    StudentData::gestance()->strAppName = strAppFileName;

    //=============================================
    //保证当前的应用程序, 只能有一个实例在运行, 避免重复登录, 被踢的现象
    QSharedMemory shared("classroom"); //exe被复制粘贴以后, 还是只能运行一个
    if (shared.attach())
    {
        qDebug() << QString("classroom has already been running, please exit and run again.") << __LINE__;
        return 0;
    }
    shared.create(1);

    //=======================================
    //检查文件是否存在
    //QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    QString docPath = DebugLog::getDocumentDir();
    //  qDebug()<<"docPath =="<<docPath;

    QString systemPublicFilePath;
    if (docPath == "")
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    systemPublicFilePath += "YiMi/temp/";

    QDir isDir;
    if (!isDir.exists(systemPublicFilePath))
    {
        qDebug() << QString("!isDir.exists") << systemPublicFilePath << __LINE__;
        return 0;
    }

    if (!QFile::exists(systemPublicFilePath + "temp.ini")) //"stutemp.ini")){
    {
        qDebug() << QString("!QFile.exists") << systemPublicFilePath + "temp.ini" << __LINE__;
        return 0;
    }

    QFile file(systemPublicFilePath + "temp.ini"); //"stutemp.ini");
    if(!file.open(QIODevice::ReadOnly))
    {
        qDebug() << QString("!file.open") << __LINE__;
        return 0;
    }
    bool isShowNewCourseTips = false;

    if (!QFile::exists(systemPublicFilePath + "CourseTips.yxt"))
    {
        QFile tF (systemPublicFilePath + "CourseTips.yxt");
        tF.open(QFile::WriteOnly);
        tF.flush();
        tF.close();
        isShowNewCourseTips = true;
    }

    QByteArray arrys = file.readAll();
    QString backData(arrys);
    file.close();
    // QFile::remove(systemPublicFilePath +"stutemp.ini");

    if(backData.length() < 1)
    {
        qDebug() << QString("backData.length() < 1") << __LINE__;
        return 0;
    }

    //=======================================
    //重新获取ip列表
    ResetIpSettingFile resetIpfile;
    //resetIpfile.resetIpFile(backData);
    resetIpfile.getGoodIplist( backData);
    StudentData::gestance()->setDocumentParsing(backData);
    YMQosManager::gestance()->initQosManager(backData,"tea");//初始化qosManager
    //获取客户端基本信息
    QJsonObject baseData = YMQosManager::gestance()->getpublicBaseData();
    std::map<std::wstring,std::wstring>baseInfoMap;
     if(!baseData.isEmpty()){
       if(baseData.contains("appType")){
         QString keyAppType = "appType";
         baseInfoMap[keyAppType.toStdWString()] = baseData.value("appType").toString().toStdWString();
       }
       if(baseData.contains("appDeviceType")){
         QString keyAppDeviceType = "appDeviceType";
         baseInfoMap[keyAppDeviceType.toStdWString()] = baseData.value("appDeviceType").toString().toStdWString();
       }
       if(baseData.contains("appVersion")){
         QString keyAppVersion = "appVersion";
         baseInfoMap[keyAppVersion.toStdWString()] = baseData.value("appVersion").toString().toStdWString();
       }
       if(baseData.contains("lessonType")){
          QString keyLessonType = "lessonType";
          QString valLessonType  = baseData.value("lessonType").toString();
          if(valLessonType.isEmpty() ){
             valLessonType = QString::number(StudentData::gestance()->m_lessonType);
          }
         baseInfoMap[keyLessonType.toStdWString()] = valLessonType.toStdWString();
       }

       if(baseData.contains("deviceType")){
         QString keyDeviceType = "deviceType";
         baseInfoMap[keyDeviceType.toStdWString()] = baseData.value("deviceType").toString().toStdWString();
       }

       if(baseData.contains("deviceInfo")){
         QString keyDeviceInfo = "deviceInfo";
         baseInfoMap[keyDeviceInfo.toStdWString()] = baseData.value("deviceInfo").toString().toStdWString();
       }
       if(baseData.contains("deviceIdentity")){
         QString keyDeviceIdentity = "deviceIdentity";
         baseInfoMap[keyDeviceIdentity.toStdWString()] = baseData.value("deviceIdentity").toString().toStdWString();
       }
       if(baseData.contains("osVersion")){
         QString keyOsVersion = "osVersion";
         baseInfoMap[keyOsVersion.toStdWString()] = baseData.value("osVersion").toString().toStdWString();
       }
       if(baseData.contains("lessonId")){
         QString keyLessonId = "lessonId";
         QString valLessonId = baseData.value("lessonId").toString();
         if(valLessonId.isEmpty()){
             valLessonId = StudentData::gestance()->m_lessonId;
         }
         baseInfoMap[keyLessonId.toStdWString()] = valLessonId.toStdWString();
       }
       if(baseData.contains("userType")){
         QString keyUserType = "userType";
         baseInfoMap[keyUserType.toStdWString()] = baseData.value("userType").toString().toStdWString();
       }
       if(baseData.contains("userName")){
         QString keyUserName = "userName";
         baseInfoMap[keyUserName.toStdWString()] = baseData.value("userName").toString().toStdWString();
       }
       if(baseData.contains("userId")){
         QString keyUserId = "userId";
         baseInfoMap[keyUserId.toStdWString()] = baseData.value("userId").toString().toStdWString();
       }
       if(baseData.contains("networkType")){
         QString keyNetworkType = "networkType";
         baseInfoMap[keyNetworkType.toStdWString()] = baseData.value("networkType").toString().toStdWString();
       }
       if(baseData.contains("operatorType")){
         QString keyOperatorType = "operatorType";
         baseInfoMap[keyOperatorType.toStdWString()] = baseData.value("operatorType").toString().toStdWString();
       }

       QString keyCrashMsg = "crashMsg";
       QString valueCrashMsg ="classroom crash";
       baseInfoMap[keyCrashMsg.toStdWString()] = valueCrashMsg.toStdWString();

       QString keyToken = "token";
       QString valueToken =  StudentData::gestance()->m_token;
       baseInfoMap[keyToken.toStdWString()] = valueToken.toStdWString();
       QString keyApiVersion = "apiVersion";
       QString valueApiVersion = StudentData::gestance()->m_apiVersion;
       baseInfoMap[keyApiVersion.toStdWString()] = valueApiVersion.toStdWString();

       QString keyCrashType = "crashType";
       QString valueCrashType ="1";//1:教室内--0:教室外
       baseInfoMap[keyCrashType.toStdWString()] = valueCrashType.toStdWString();

    }
    yimi_fudao_breakpad::Yimibreakpad::gestance()->monitorProcessClient(baseInfoMap);


    //=======================================
    //log文件初始化
    DebugLog::GetInstance()->init_log(strAppFileName);
    qInstallMessageHandler(DebugLog::GetInstance()->LogMsgOutput);     //release模式下，调试信息输出至日志文件
    //开始写第一行日志, 每次启动的时候, 才写
    qDebug() << (QString("============================================= Begin to run %1.") .arg(StudentData::gestance()->strAppName));

    //=======================================
    QDesktopWidget *desktopWidget =  QApplication::desktop();
    QRect rect = desktopWidget->screenGeometry();
    int width ;
    int height ;
    width  = rect.width() ;
    height  = rect.height() ;
    double  widths = width / 16.0 ;
    double  heights = (height - width / 16 ) / 9.0 ;

    double fixLength = widths > heights ? heights : widths;

    int fullWidths = width;
    int fullHeights = height;


    //全屏高度
    int fullWidth = (int) fixLength * 16;
    int fullHeight = (int) fixLength * 9;

    //全屏的x，y坐标
    int fullWidthX = ( width - fullWidth ) / 2 ;
    int fullHeightY = ( height - fullHeight  ) / 2 ;

    int fullHeightYs = ( height - fullHeight + fullWidth / 16 ) / 2 ;

    //左边宽度
    int leftWidth =  width * 86 / 1440 ;
    int leftHeight = height * 900 / 900;

    int leftMidWidth =  width * 66 / 1440 ;
    int leftMidHeight = height * 860 / 900;

    //右边宽度
    int rightWidth = width * 200 / 1440 ;
    int rightHeight = height * 900 / 900;

    double midWidths = ( width - leftWidth  - rightWidth) / 16.0 ;
    double midFixLength = midWidths > heights ? heights : midWidths;

    //中间高度
    int midWidth = (int) midFixLength * 16;
    int midHeight = (int) midFixLength * 9;

    //中间的x，y坐标
    int midWidthX = ( width - leftWidth  - rightWidth - midWidth  ) / 2 + leftWidth ;
    int midHeightY = ( height - midHeight ) / 2 ;

    int midHeightYs = ( height - midHeight + midWidth / 16 ) / 2 ;

    //左边x，y
    int leftWidthX = (midWidthX - leftMidWidth ) / 2;
    int leftWidthY =  (height - leftMidHeight ) / 2;

    //右边x，y
    int rightWidthX = (width -  rightWidth )  ;
    int rightWidthY =  (height - rightHeight ) / 2;

    qmlRegisterType<TrailBoard>("TrailBoard", 1, 0, "TrailBoard");
    qmlRegisterType<NetworkAccessManagerInfor>("NetworkAccessManagerInfor", 1, 0, "NetworkAccessManagerInfor");
    qmlRegisterType<MxResLoader>("MxResLoader", 1, 0, "MxResLoader");
    qmlRegisterType<PolygonPanel>("PolygonPanel", 1, 0, "PolygonPanel");
    qmlRegisterType<EllipsePanel>("EllipsePanel", 1, 0, "EllipsePanel");
    qmlRegisterType<LoadInforMation>("LoadInforMation", 1, 0, "LoadInforMation");
    qmlRegisterType<ScreenshotSaveImage>("ScreenshotSaveImage", 1, 0, "ScreenshotSaveImage");
    qmlRegisterType<CurriculumData>("CurriculumData", 1, 0, "CurriculumData");
    qmlRegisterType<ExternalCallChanncel>("ExternalCallChanncel", 1, 0, "ExternalCallChanncel");
    qmlRegisterType<VideoRender>("VideoRender", 1, 0, "VideoRender");
    qmlRegisterType<HandlPingInfor>("HandlPingInfor", 1, 0, "HandlPingInfor");
    qmlRegisterType<YMHomeWorkManagerAdapter>("YMHomeWorkManagerAdapter", 1, 0, "YMHomeWorkManagerAdapter");
    qmlRegisterType<YMHomeworkWrittingBoard>("YMHomeworkWrittingBoard", 1, 0, "YMHomeworkWrittingBoard");
    qmlRegisterType<YMCloudClassManagerAdapter>("YMCloudClassManagerAdapter", 1, 0, "YMCloudClassManagerAdapter");
    qmlRegisterType<HtmlSytelSetting>("HtmlSytelSetting", 1, 0, "HtmlSytelSetting");
    qmlRegisterType<PanDuWriteBoard>("PanDuWriteBoard", 1, 0, "PanDuWriteBoard");

    StudentData::gestance()->midHeight = midHeight;
    StudentData::gestance()->midWidth = midWidth;
    StudentData::gestance()->fullWidth = fullWidth;
    StudentData::gestance()->fullHeight = fullHeight;

    //==========================

    if(!StudentData::gestance()->m_isPublicEnvironment)
    {
        QDesktopWidget *desktop = QApplication::desktop();
        int tempWidth = desktop->screenGeometry().height() - desktop->availableGeometry().height();
        if(tempWidth < 96)
        {
            app.setWindowIcon(QIcon(":/images/stu64.ico"));
        }
        else if(tempWidth >= 96 && tempWidth < 192)
        {
            app.setWindowIcon(QIcon(":/images/stu128.ico"));
        }
        else if(tempWidth >= 192)
        {
            app.setWindowIcon(QIcon(":/images/stu256.ico"));
        }
    }else
    {
        app.setWindowIcon(QIcon(":/images/yimiico_public_test_tea.ico"));
    }
    QQmlApplicationEngine engine;
    //    AudioVideoManager::getInstance();

    DebugLog::gestance()->log("main:: initializeVideo");

    //控制OSS的全局属性
#ifdef USE_OSS_AUTHENTICATION
    engine.rootContext()->setContextProperty("disibleOss", false );
#else
    engine.rootContext()->setContextProperty("disibleOss", true );
#endif

    //全屏
    engine.rootContext()->setContextProperty("fullWidths", fullWidths );
    engine.rootContext()->setContextProperty("fullHeights", fullHeights );
    engine.rootContext()->setContextProperty("fullWidth", fullWidth );
    engine.rootContext()->setContextProperty("fullHeight", fullHeight );
    engine.rootContext()->setContextProperty("fullWidthX", fullWidthX );
    engine.rootContext()->setContextProperty("fullHeightY", fullHeightY );
    engine.rootContext()->setContextProperty("fullHeightYs", fullHeightYs );

    //非全屏画布
    engine.rootContext()->setContextProperty("midWidth", midWidth );
    engine.rootContext()->setContextProperty("midHeight", midHeight );
    engine.rootContext()->setContextProperty("midWidthX", midWidthX );
    engine.rootContext()->setContextProperty("midHeightY", midHeightY );
    engine.rootContext()->setContextProperty("midHeightYs", midHeightYs );

    //左边
    engine.rootContext()->setContextProperty("leftWidth", leftWidth );
    engine.rootContext()->setContextProperty("leftHeight", leftHeight );
    engine.rootContext()->setContextProperty("leftMidWidth", leftMidWidth );
    engine.rootContext()->setContextProperty("leftMidHeight", leftMidHeight );
    engine.rootContext()->setContextProperty("leftWidthX", leftWidthX );
    engine.rootContext()->setContextProperty("leftWidthY", leftWidthY );

    //右边
    engine.rootContext()->setContextProperty("rightWidth", rightWidth );
    engine.rootContext()->setContextProperty("rightHeight", rightHeight);
    engine.rootContext()->setContextProperty("rightWidthX", rightWidthX);
    engine.rootContext()->setContextProperty("rightWidthY", rightWidthY);

    //是否显示过新的课件显示提示窗
    engine.rootContext()->setContextProperty("isShowNewCourseTips", isShowNewCourseTips);

    GetOffsetImage::instance()->initGetoffsetImg(midHeight,midWidth,fullHeight,fullWidth,StudentData::gestance()->m_lessonId,StudentData::gestance()->isCouldUseNewBoard());
    engine.rootContext()->setContextProperty("getOffSetImage", GetOffsetImage::instance());
    engine.addImageProvider("offsetImage", GetOffsetImage::instance()->imageProvider );
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}

