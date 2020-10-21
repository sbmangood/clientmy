#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QObject>
#include <QQuickView>
#include <QApplication>
#include <QQmlContext>
#include <QtQml>
#include <QDesktopWidget>
#include <QString>
#include <QDebug>
#include <QSharedMemory>
#include "YMUserBaseInformation.h"
//#include "YMCloudClassManagerAdapter.h"
#include "imageprovider.h"
#include "getoffsetimage.h"
#include "debuglog.h"
#include "YMCallStack.h"
#include "playmanager.h"
#include "trailrender.h"
#include "filedownload.h"

QString g_strAppFullPath = "";
QString g_strAppFileName = "";


int main(int argc, char *argv[])
{

    QApplication app(argc, argv);
    //=======================================
    //注冊: 程序发生异常的捕获函数
    SetUnhandledExceptionFilter((LPTOP_LEVEL_EXCEPTION_FILTER)ApplicationCrashHandler);

    //=============================================
    //记录当前应用程序的名称
    QString strAppFileName = QString::fromLocal8Bit(argv[0]); //需要放在代码: QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8")); 前面, 因为: 中文乱码的问题
//    QMessageBox::critical(NULL, "aaa", strAppFileName, QMessageBox::Ok, QMessageBox::Ok); //测试中文乱码
    StudentData::gestance()->strAppFullPath  = strAppFileName;
    strAppFileName = strAppFileName.mid(strAppFileName.lastIndexOf("\\") + 1);
    StudentData::gestance()->strAppName = strAppFileName;

    //=============================================
    //保证当前的应用程序, 只能有一个实例在运行, 避免重复登录, 被踢的现象
    QSharedMemory shared("player"); //exe被复制粘贴以后, 还是只能运行一个
    if (shared.attach())
    {
        qDebug() << QString("player has already been running, please exit and run again.") << __FILE__ << __LINE__;
        return 0;
    }
    shared.create(1);

    //=============================================
    QQmlApplicationEngine engine;
    qmlRegisterType<TrailRender>("TrailRender", 1, 0, "TrailRender");
    qmlRegisterType<PlayManager>("PlayManager", 1, 0, "PlayManager");
    qmlRegisterType<FileDownload>("FileDownload", 1, 0, "FileDownload");
    QStringList boardList;

    QString appId = "7169a6c5ab5b4eeba2ca37b831fb9239";
    QString appKey = "7104bd73297a88252606ca5b45792e97";
    QString roomId = "359283150158827520";
    QString envType = "sit01";

    if(argc == 2)
    {
        qDebug()<< "------"<<argc<< argv[1];
        QMap<QString, QString> argvMap;
        QString appUrl = argv[1];
        appUrl = appUrl.section('?', 1);
        QStringList argvList = appUrl.split('&');
        for(int index=0; index<argvList.size(); index++)
        {
            QStringList tempList = argvList[index].split('=');
            argvMap[tempList[0]] = tempList[1];
            qDebug()<<"-----"<< argvList[index]<< tempList[0]<< tempList[1];
        }

        appId = argvMap["appId"];
        appKey = argvMap["appKey"];;
        roomId = argvMap["roomId"];
        envType = argvMap["envType"];
    }

    if(envType.trimmed().length() > 0) //如果不是生产环境
    {
        envType += "-";
    }
    QString apiUrl = "http://" + envType + "liveroom.yimifudao.com/v1.0.0/openapi";

    boardList.append(appId);//app id
    boardList.append(roomId); //课程id
    boardList.append(apiUrl);//api url

    YMUserBaseInformation::token = appKey;
//    roomId = 344193948119490686;
    YMUserBaseInformation::lessonId = roomId;
    StudentData::gestance()->m_lessonId = roomId;

    QDesktopWidget *desktopWidget =  QApplication::desktop();
    QRect rect = desktopWidget->screenGeometry();
    int width;
    int height;

    width  = rect.width() ;
    height  = rect.height() ;
    double  widths = width / 16.0 ;
    double  heights = (height - width / 16) / 9.0 ;
    double fixLength = widths > heights ? heights : widths;

    //全屏高度
    int fullWidth = (int) fixLength * 16;
    int fullHeight = (int) fixLength * 9;

    //左边宽度
    int leftWidth =  width * 86 / 1440 ;
    //右边宽度
    int rightWidth = width / 1440 ;
    double midWidths = ( width - leftWidth  - rightWidth) / 16.0 ;
    double midFixLength = midWidths > heights ? heights : midWidths;

    //中间高度
    int midWidth = (int) midFixLength * 16;
    int midHeight = (int) midFixLength * 9;
    double widthRate = width * 0.8 / 966.0;
    double heightRate = widthRate / 1.5337;

    StudentData::gestance()->spacingSize = 105 * heightRate;
    StudentData::gestance()->midHeight = midHeight;// - 105 * heightRate;
    StudentData::gestance()->midWidth = midWidth;
    StudentData::gestance()->fullWidth = fullWidth;
    StudentData::gestance()->fullHeight = fullHeight;

    //=============================================
    //log文件初始化
    DebugLog::GetInstance()->init_log(strAppFileName);
    qInstallMessageHandler(DebugLog::GetInstance()->LogMsgOutput);     //release模式下，调试信息输出至日志文件
    //开始写第一行日志, 每次启动的时候, 才写
    qDebug() << (QString("============================================= Begin to run %1.") .arg(StudentData::gestance()->strAppName));


    //=============================================
    engine.rootContext()->setContextProperty("midHeight", StudentData::gestance()->midHeight);
    engine.rootContext()->setContextProperty("midWidth", StudentData::gestance()->midWidth);
    engine.rootContext()->setContextProperty("fullWidths", fullWidth);
    engine.rootContext()->setContextProperty("fullHeights", fullHeight);
    engine.rootContext()->setContextProperty("newPlay",true);
    engine.rootContext()->setContextProperty("getOffSetImage", GetOffsetImage::instance());
    engine.addImageProvider("offsetImage", GetOffsetImage::instance()->imageProvider );
    engine.rootContext()->setContextProperty("boardList", boardList);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

