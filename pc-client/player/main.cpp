#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QObject>
#include <QQuickView>
#include <QApplication>
#include <QQmlContext>
#include <QtQml>
#include <QDesktopWidget>
#include "painterboard.h"
#include <QString>
#include <QDebug>
#include <QSharedMemory>
#include <QMessageBox>
#include "./cloudclassroom/cloudclassManager/YMUserBaseInformation.h"
#include "./cloudclassroom/cloudclassManager/YMCloudClassManagerAdapter.h"
#include "./cloudclassroom/cloudclassManager/imageprovider.h"
#include "./cloudclassroom/cloudclassManager/getoffsetimage.h"
#include "debuglog.h"
#include "YMCallStack.h"

QString g_strAppFullPath = "";
QString g_strAppFileName = "";

int main(int argc, char *argv[])
{
#ifdef USE_OSS_UPLOAD_LOG
    if(argc != 11)
    {
        qDebug() << QString("argc != 11") << __FILE__ << __LINE__;
        return 0;
    }
#else
    if(argc < 10)
    {
        qDebug() << QString("argc != 10") << __FILE__ << __LINE__;
        return 0;
    }
#endif
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/stu64.ico")); //设置QMessageBox的标题中的ico

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
    qmlRegisterType<PainterBoard>("PainterBoard", 1, 0, "PainterBoard");
    qmlRegisterType<YMCloudClassManagerAdapter>("YMCloudClassManagerAdapter", 1, 0, "YMCloudClassManagerAdapter");
    QStringList boardList;

    boardList.append(QString::fromUtf8(argv[1])); //课程ID
    boardList.append(QString::fromUtf8(argv[2]));//时间
    boardList.append(QString::fromUtf8(QByteArray::fromHex(QByteArray(argv[3]))));//相关信息
    boardList.append(QString::fromUtf8(QByteArray::fromHex(QByteArray(argv[4]))));//路径
    boardList.append(QString::fromUtf8(argv[5]));//轨迹文件名
    boardList.append(QString::fromUtf8(argv[6]));//类型（学生或者老师)

    YMUserBaseInformation::type =  QString::fromUtf8(argv[6]);//"TEA";//
    YMUserBaseInformation::token =  QString::fromUtf8(argv[7]);//"83673cbf7a2077f65e8ade55b12550f2";//
    YMUserBaseInformation::apiVersion = QString::fromUtf8(argv[8]);//"2.4";//
    YMUserBaseInformation::appVersion =  QString::fromUtf8(argv[9]); //"2.4.0005";//
    YMUserBaseInformation::lessonId  = QString::fromUtf8(argv[1]);//"300572"; //
    StudentData::gestance()->m_lessonId = QString::fromUtf8(argv[1]);
    StudentData::gestance()->m_userName = QString::fromUtf8(argv[10]); // user name
#ifdef USE_OSS_UPLOAD_LOG
    YMUserBaseInformation::id = QString::fromUtf8(argv[10]);
#endif

//    YMUserBaseInformation::type =  "TEA";//QString::fromUtf8(argv[6]);//
//    YMUserBaseInformation::token =  "5391bb2a701b06ab60bcf199d624f05a";//QString::fromUtf8(argv[7]);//
//    YMUserBaseInformation::apiVersion = "2.4";//QString::fromUtf8(argv[8]);//
//    YMUserBaseInformation::appVersion =  "2.4.0005";//QString::fromUtf8(argv[9]); //
//    YMUserBaseInformation::lessonId = "2618219"; //QString::fromUtf8(argv[1]);//
//    YMUserBaseInformation::id = "272923";
//    StudentData::gestance()->m_lessonId = "2618219";

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
    int rightWidth = width * 200 / 1440 ;

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

#if 0
    //第一次从老师, 或者学生的主程序进入, 结合下面的打印, 获得命令行参数内容
    //通过以下打印到日志文件中的信息, 从日志文件中, 复制粘贴出来, 设置为: 当前应用程序的命令行参数, 就可以单独在qt creator中运行了
    //命令行参数, 比如： 1067020 201807 e38090e7bc96e58fb731303637303230e38091e59b9be5b9b4e7baa72fe695b0e5ada620e590b4e5ae9de5ae9d 433a2f55736572732f61646d696e2f446f63756d656e74732f59694d692f3230313830372f31303637303230 2.encrypt TEA cc264a83e1a98c8f99dac0c7af6a4ae3 2.4 3.1.002
    //各个命令行参数之间, 以空格间隔
    qDebug() << "=============================== >>>";
    int i = 0;
    for(i = 0; i < 10; i++)
    {
        qDebug() << argv[i];
    }
    qDebug() << "<<< ===============================";
#endif

    //=============================================
    engine.rootContext()->setContextProperty("midHeight", StudentData::gestance()->midHeight);
    engine.rootContext()->setContextProperty("midWidth", StudentData::gestance()->midWidth);
    engine.rootContext()->setContextProperty("newPlay",StudentData::gestance()->isNewPlay);
    engine.rootContext()->setContextProperty("getOffSetImage", GetOffsetImage::instance());
    engine.addImageProvider("offsetImage", GetOffsetImage::instance()->imageProvider );
    engine.rootContext()->setContextProperty("boardList", boardList);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

