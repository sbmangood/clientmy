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
#include "../controlcenter/controlcenter.h"
#include "lessonInfo/YMLessonManager.h"

#include "./audioVideoView/VideoRender.h"
#include "./debugLog/debuglog.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QString strAppFileName = QString::fromLocal8Bit(argv[0]);
    StudentData::gestance()->strAppFullPath  = strAppFileName;
    strAppFileName = strAppFileName.mid(strAppFileName.lastIndexOf("\\") + 1);
    StudentData::gestance()->strAppName = strAppFileName;

    // 一次只允许运行一个实例
    QSharedMemory shared("classroomdemo");
    if (shared.attach())
    {
        qDebug() << QString("classroomdemo has already been running, please exit and run again.") << __LINE__;
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

    ControlCenter::getInstance();

    // log文件初始化
    DebugLog::GetInstance()->init_log(strAppFileName);
    qInstallMessageHandler(DebugLog::GetInstance()->LogMsgOutput);

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
    int rightWidthX = (width -  rightWidth );
    int rightWidthY =  (height - rightHeight ) / 2;

    QQmlApplicationEngine engine;

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
    engine.addImportPath(QCoreApplication::applicationDirPath());

    engine.rootContext()->setContextProperty("getOffSetImage", ControlCenter::getInstance()->getGetOffsetImageInstance());
    engine.addImageProvider("offsetImage", ControlCenter::getInstance()->getImageProvider());

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QDir::setCurrent(QCoreApplication::applicationDirPath());
    //qDebug()<< "---------------"<<QCoreApplication::applicationDirPath();

    ControlCenter* control = ControlCenter::getInstance();
//    control->initControlCenter(QCoreApplication::applicationDirPath(), systemPublicFilePath, width, height);
    control->setServerAddr("115.159.218.155", 5251, "115.159.218.155", 5250); //123.206.203.83
    control->setRedPackets();
    control->initControlCenter("", "yimi_324122469776515704_ccb123456_m9if1K_1566806110610", "354937763033780224",0, "324122469776515709", "",0,1);

    return app.exec();
}
