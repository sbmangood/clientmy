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
//#include "./YMMediaPlayer/ymvideoplayer.h"
#include "./dataconfig/trailboard/trailboard.h"
#include "./httprequset/requsetinfor/networkaccessmanagerinfor.h"
#include "./httprequset/requsetinfor/resetipsettingfile.h"
#include "./dataconfig/datahandl/mxresloader.h"
#include "./dataconfig/trailboard/polygonpanel.h"
#include "./dataconfig/trailboard/ellipsepanel.h"
#include "./httprequset/requsetinfor/loadinformation.h"
#include "./dataconfig/trailboard/screenshotsaveimage.h"
#include "./dataconfig/datahandl/curriculumdata.h"
#include "../../pc-common/AudioVideoSDKs/AudioVideoManager.h"
#include "./videovoice/externalcallchanncel.h"
#include "./videovoice/videorender.h"
#include"./cloudclassroom/cloudclassManager/YMHomeworkManagerAdapter.h"
#include"./cloudclassroom/cloudclassManager/YMHomeworkWrittingBoard.h"
#include "./cloudclassroom/cloudclassManager/YMCloudClassManagerAdapter.h"
#include "./dataconfig/trailboard/getoffsetimage.h"
#include "./panDuWriteBoard/panduwriteboard.h"
#include "debuglog.h"
#include "YMCallStack.h"
#include "../../pc-common/coursewareManager/CourseWareViewManager.h"
#include "../YMCommon/qosV2Manager/YMQosApiMannager.h"
#include "../../pc-common/pingback/pingbackmanager.h"
#include"../YMCommon/whiteboard/whiteboard.h"
#include "../../pc-common/YMNetworkControl/YMNetworkManagerAdapert.h"

int main(int argc, char *argv[])
{
    // qputenv("QSG_RENDER_LOOP", "basic" );
    QApplication app(argc, argv);

    //=======================================
    //注冊: 程序发生异常的捕获函数
    SetUnhandledExceptionFilter((LPTOP_LEVEL_EXCEPTION_FILTER)ApplicationCrashHandler);

    //=======================================
    //记录当前应用程序的名称
    QString strAppFileName = QString::fromLocal8Bit(argv[0]); //需要放在代码: QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8")); 前面, 因为: 中文乱码的问题
//    QMessageBox::critical(NULL, "aaa", strAppFileName, QMessageBox::Ok, QMessageBox::Ok); //测试中文乱码

    StudentData::gestance()->strAppFullPath  = strAppFileName;
    strAppFileName = strAppFileName.mid(strAppFileName.lastIndexOf("\\") + 1);
    StudentData::gestance()->strAppName = strAppFileName;

    //=======================================
    //保证当前的应用程序, 只能有一个实例在运行, 避免重复登录, 被踢的现象
    QSharedMemory shared("teastudentclassroom"); //exe被复制粘贴以后, 还是只能运行一个
    if (shared.attach())
    {
        qDebug() << QString("teastudentclassroom has already been running, please exit and run again.") << __FILE__ << __LINE__;
        return 0;
    }
    shared.create(1);

    //=======================================
    //检查目录, 文件是否存在, 打开文件是否成功, 文件内容是否有
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    //qDebug()<<"docPath =="<<docPath;

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
        qDebug() << QString("Dir: %1 does not existed") .arg(systemPublicFilePath) << __FILE__ << __LINE__;
        return 0;
    }

    if (!QFile::exists(systemPublicFilePath + "miniStuTemp.ini"))
    {
        qDebug() << QString("File: %1 does not existed") .arg(systemPublicFilePath + "stutemp.ini") << __FILE__ << __LINE__;
        return 0;
    }

    QFile file(systemPublicFilePath + "miniStuTemp.ini");
    if(!file.open(QIODevice::ReadOnly))
    {
        qDebug() << QString("Open file: %1 failed.") .arg(systemPublicFilePath + "stutemp.ini") << __FILE__ << __LINE__;
        return 0;
    }

    QByteArray arrys = file.readAll();
    QString backData(arrys);
    file.close();
    // QFile::remove(systemPublicFilePath +"miniStuTemp.ini");
    if(backData.length() < 1)
    {
        qDebug() << QString("backData.length() < 1") << __FILE__ << __LINE__;
        return 0;
    }

    //=======================================
    StudentData::gestance()->getRunUrl();
    //重新获取ip列表
    ResetIpSettingFile resetIpfile;
    //resetIpfile.resetIpFile(backData);
    resetIpfile.getGoodIplist( backData);
    //解析存储全局数据
    StudentData::gestance()->setDocumentParsing(backData);

    backData.replace("liveroomId","lessonId");
    YMQosManager::gestance()->initQosManager(backData,"stu");

    //=======================================
    //log文件初始化
    DebugLog::GetInstance()->init_log(strAppFileName);
    qInstallMessageHandler(DebugLog::GetInstance()->LogMsgOutput);     //release模式下，调试信息输出至日志文件
    //开始写第一行日志, 每次启动的时候, 才写
    qDebug() << (QString("============================================= Begin to run %1.") .arg(StudentData::gestance()->strAppName));
    //初始化埋点SDK
    yimipingback::PingbackManager::gestance()->InitSDK("YIMI","yunClass_2",YMUserBaseInformation::appVersion);
    //埋点注册用户信息
    yimipingback::PingbackManager::gestance()->SetUserInfo(YMUserBaseInformation::id,YMUserBaseInformation::type);
    //=======================================
    QDesktopWidget *desktopWidget =  QApplication::desktop();
    QRect rect = desktopWidget->screenGeometry();
    int width;
    int height;
    width  = rect.width();
    height  = rect.height();

    double  widths = width / 16.0;
    double  heights = (height - width / 16 ) / 9.0 ;

    double fixLength = widths > heights ? heights : widths;

    int fullWidths = width;
    int fullHeights = height;

    //全屏高度
    int fullWidth = (int) fixLength * 16;
    int fullHeight = (int) fixLength * 9;

    //全屏的x，y坐标
    int fullWidthX = ( width - fullWidth ) / 2;
    int fullHeightY = ( height - fullHeight ) / 2;

    //左边宽度
    int leftWidth =  width * 86 / 1440;
    int leftHeight = height * 900 / 900;

    int leftMidWidth =  width * 66 / 1440;
    int leftMidHeight = height * 860 / 900;

    //右边宽度
    int rightWidth = width * 200 / 1440;
    int rightHeight = height * 900 / 900;

    double midWidths = ( width - leftWidth  - rightWidth) / 16.0;
    double midFixLength = midWidths > heights ? heights : midWidths;

    //中间高度
    int midWidth = (int) midFixLength * 16;
    int midHeight = (int) midFixLength * 9;

    //中间的x，y坐标
    int midWidthX = ( width - leftWidth  - rightWidth - midWidth  ) / 2 + leftWidth;
    int midHeightY = ( height - midHeight ) / 2;

    int midHeightYs = ( height - midHeight + midWidth / 16 ) / 2 ;

    //左边x，y
    int leftWidthX = (midWidthX - leftMidWidth ) / 2;
    int leftWidthY =  (height - leftMidHeight ) / 2;

    //右边x，y
    int rightWidthX = (width -  rightWidth );
    int rightWidthY =  (height - rightHeight ) / 2;
    //  qDebug()<<"leftMidWidth =="<<leftMidWidth;
    //  qDebug()<<"leftMidHeight =="<<leftMidHeight;

    qmlRegisterType<TrailBoard>("TrailBoard", 1, 0, "TrailBoard");
    qmlRegisterType<WhiteBoard>("WhiteBoard", 1, 0, "WhiteBoard");
    qmlRegisterType<NetworkAccessManagerInfor>("NetworkAccessManagerInfor", 1, 0, "NetworkAccessManagerInfor");
    qmlRegisterType<MxResLoader>("MxResLoader", 1, 0, "MxResLoader");
    qmlRegisterType<PolygonPanel>("PolygonPanel", 1, 0, "PolygonPanel");
    qmlRegisterType<EllipsePanel>("EllipsePanel", 1, 0, "EllipsePanel");
    qmlRegisterType<LoadInforMation>("LoadInforMation", 1, 0, "LoadInforMation");
    qmlRegisterType<ScreenshotSaveImage>("ScreenshotSaveImage", 1, 0, "ScreenshotSaveImage");
    qmlRegisterType<CurriculumData>("CurriculumData", 1, 0, "CurriculumData");
    qmlRegisterType<ExternalCallChanncel>("ExternalCallChanncel", 1, 0, "ExternalCallChanncel");
    qmlRegisterType<VideoRender>("VideoRender", 1, 0, "VideoRender");
    //qmlRegisterType<YMVideoPlayer>("YMVideoPlayer", 1, 0, "YMVideoPlayer");
    qmlRegisterType<YMHomeWorkManagerAdapter>("YMHomeworkManagerAdapter", 1, 0, "YMHomeworkManagerAdapter");
    qmlRegisterType<YMHomeworkWrittingBoard>("YMHomeworkWrittingBoard", 1, 0, "YMHomeworkWrittingBoard");
    qmlRegisterType<YMCloudClassManagerAdapter>("YMCloudClassManagerAdapter", 1, 0, "YMCloudClassManagerAdapter");
    qmlRegisterType<PanDuWriteBoard>("PanDuWriteBoard", 1, 0, "PanDuWriteBoard");
    qmlRegisterType<CourseWareViewManager>("CourseWareViewManager",1,0,"CourseWareViewManager");
    qmlRegisterType<YMQosApiMannager>("YMQosApiMannager",1,0,"YMQosApiMannager");
    qmlRegisterType<YMNetworkManagerAdapert>("YMNetworkManagerAdapert",1,0,"YMNetworkManagerAdapert");

    StudentData::gestance()->midHeight = midHeight;
    StudentData::gestance()->midWidth = midWidth;
    StudentData::gestance()->fullWidth = fullWidth;
    StudentData::gestance()->fullHeight = fullHeight;
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

    QQmlApplicationEngine engine;

    //音视频线路初始化
    AudioVideoManager::getInstance();

    //全屏
    engine.rootContext()->setContextProperty("fullWidths", fullWidths );
    engine.rootContext()->setContextProperty("fullHeights", fullHeights );
    engine.rootContext()->setContextProperty("fullWidth", fullWidth );
    engine.rootContext()->setContextProperty("fullHeight", fullHeight );
    engine.rootContext()->setContextProperty("fullWidthX", fullWidthX );
    engine.rootContext()->setContextProperty("fullHeightY", fullHeightY );

    //非全屏 画布
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
    engine.rootContext()->setContextProperty("rightHeight", rightHeight );
    engine.rootContext()->setContextProperty("rightWidthX", rightWidthX );
    engine.rootContext()->setContextProperty("rightWidthY", rightWidthY );

    engine.rootContext()->setContextProperty("getOffSetImage", GetOffsetImage::instance()); //绑定qml 与 C++ 的对象, QImage对象, 在qml中, 实时展示
    engine.addImageProvider("offsetImage", GetOffsetImage::instance()->imageProvider ); //QImage对象, 显示在qml中, 使用offsetImage的地方, 参考: https://blog.csdn.net/jack_20/article/details/79034978

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

