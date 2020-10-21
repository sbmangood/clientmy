#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlContext>
#include "YMAccountManager.h"
#include "YMAccountManagerAdapter.h"
#include "YMMassgeRemindManager.h"
#include "YMLessonManagerAdapter.h"
#include "QtQml"
#include <QSharedMemory>
#include <QEventLoop>
#include <QProcess>
#include <QObject>
#include "YMUserBaseInformation.h"
#include <QApplication>
#include <QDesktopWidget>
#include <QIcon>
#include <QMessageBox>
#include "PingThreadManagerAdapter.h"
//#include <QtWebEngine>
#include "debuglog.h"
#include "YMCallStack.h"
#include "miniClass/YMMiniLessonManager.h"

QString g_strAppFullPath = "";
QString g_strAppFileName = "";
//为了程序自动重启, 定义的一个ID
int g_ReturnCode_Restart = 773;
#define MSG_BOX_TITLE  QString(u8"精锐")
#define MSG_BOX_CONTEXT  "程序已经启动, 请先关闭程序, 再打开."

int main(int argc, char *argv[])
{
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);//webengineView
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);//加载webview时所用
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/stu64.ico")); //设置QMessageBox的标题中的ico

    //QGuiApplication app(argc,argv);

    //    YMQosManager::gestance()->initQosManager("","stu");//初始化qosManager
    //    YMQosManagerForStuM::gestance()->initQosManager("","stu");
    //===============启动辅助进程======================
    //    QString runPath = QCoreApplication::applicationDirPath();
    //    QString prcName = "yimiPrcSvr.exe";
    //    runPath += "/yimiPrcSvr.exe";
    //    QProcess* process = new QProcess;
    //    process->start("tasklist" ,QStringList()<<"/FI"<<"imagename eq "+ prcName);
    //    process->waitForFinished();
    //    QString outputStr = QString::fromLocal8Bit(process->readAllStandardOutput());
    //    if(outputStr.contains(prcName)){
    //        //先关闭进程
    //        QProcess closePrc;
    //        closePrc.execute(QString("TASKKILL /IM %1 /F") .arg(prcName));
    //        closePrc.close();
    //        QProcess *yimiPrcSvrprocess = new QProcess();
    //        yimiPrcSvrprocess->start(runPath, QStringList());
    //        qDebug() << "yimiPrcSvr::runPath:" << runPath;
    //    } else {

    //        QProcess *yimiPrcSvrprocess = new QProcess();
    //        yimiPrcSvrprocess->start(runPath, QStringList());
    //        qDebug() << "yimiPrcSvr::runPath:" << runPath;
    //    }
    //===============启动辅助进程======================
    //注冊: 程序发生异常的捕获函数
    //    SetUnhandledExceptionFilter((LPTOP_LEVEL_EXCEPTION_FILTER)ApplicationCrashHandler);

    //    //初始化埋点SDK
    //    yimipingback::PingbackManager::gestance()->InitSDK("YIMI","yunClass_2",YMUserBaseInformation::appVersion);
    //    //埋点注册用户信息
    //    yimipingback::PingbackManager::gestance()->SetUserInfo(YMUserBaseInformation::id,YMUserBaseInformation::type);

    //=======================================
    //记录当前应用程序的名称
    g_strAppFileName = QString::fromLocal8Bit(argv[0]); //解决路径中, 中文乱码的问题
    g_strAppFullPath = g_strAppFileName;
    g_strAppFileName = g_strAppFileName.mid(g_strAppFileName.lastIndexOf("\\") + 1);

    //=============================================
    //保证当前的应用程序, 只能有一个实例在运行, 避免重复登录, 被踢的现象
    QSharedMemory shared("JRStudent"); //exe被复制粘贴以后, 还是只能运行一个
    if (shared.attach())
    {
        QString strMessage = QString::fromLocal8Bit(MSG_BOX_CONTEXT);
        QMessageBox::information(NULL, MSG_BOX_TITLE, strMessage, QMessageBox::Ok, QMessageBox::Ok);
        qDebug() << QString("yimifdStudent has already been running, please exit and run again.");
        return 0;
    }
    shared.create(1);

    //=============================================
    //versionCode 从 appVersion 中获得, 比如: appVersion是3.09.01.131, 那么code是:30901
    QStringList lstVer = YMUserBaseInformation::appVersion.split(".");
    YMUserBaseInformation::versionCode = QString("%1%02%03") .arg(lstVer[0]) .arg(lstVer[1]) .arg(lstVer[2]);
    qDebug() << "==44===================" << lstVer[0] << lstVer[1] << lstVer[2] << lstVer[3] << YMUserBaseInformation::versionCode;

    //=============================================
    QFile::remove(QStringLiteral("C:/Users/Public/Desktop/一米辅导学生端.lnk"));

    // QtWebEngine::initialize();

    qmlRegisterType<YMAccountManagerAdapter>("YMAccountManagerAdapter", 1, 0, "YMAccountManagerAdapter");
    qmlRegisterType<YMMassgeRemindManager>("YMMassgeRemindManager", 1, 0, "YMMassgeRemindManager");
    qmlRegisterType<YMLessonManagerAdapter>("YMLessonManagerAdapter", 1, 0, "YMLessonManagerAdapter");
    //qmlRegisterType<YMDeviceTesting>("YMdevicetesting", 1, 1, "YMdevicetesting");
    qmlRegisterType<PingThreadManagerAdapter>("PingThreadManagerAdapter", 1, 0, "PingThreadManagerAdapter");

    qmlRegisterType<YMMiniLessonManager>("YMMiniLessonManager", 1, 0, "YMMiniLessonManager");

    YMAccountManager *accountMgr = YMAccountManager::getInstance();
    //accountMgr->getLatestVersion();

    //=============================================
    //设置http 跳转的URL的信息
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("isStageEnvironment", YMUserBaseInformation::isStageEnvironment);
    engine.rootContext()->setContextProperty("URL_ForgetPassword", YMUserBaseInformation::m_strForgetPassword);
    engine.rootContext()->setContextProperty("URL_SignUp", YMUserBaseInformation::m_strSignUp);
    engine.rootContext()->setContextProperty("URL_LiveLesson", YMUserBaseInformation::m_strLiveLesson);
    engine.rootContext()->setContextProperty("URL_ClassroomReport", YMUserBaseInformation::m_strClassroomReport);
    engine.rootContext()->setContextProperty("URL_Plan", YMUserBaseInformation::m_strPlan);
    engine.rootContext()->setContextProperty("URL_SqReport", YMUserBaseInformation::m_strSqReport);
    engine.rootContext()->setContextProperty("URL_MyLive", YMUserBaseInformation::m_strMyLive);
    engine.rootContext()->setContextProperty("URL_MiniClassOrderList", YMUserBaseInformation::m_strMiniClassOrderList);
    engine.rootContext()->setContextProperty("URL_MiniClassHomePage", YMUserBaseInformation::m_strMiniClassHomePage);

    //=============================================
    qDebug() << "888888888888" << YMUserBaseInformation::isStageEnvironment;
    QJsonArray userData = accountMgr->getUserLoginInfo();
    engine.rootContext()->setContextProperty("version", accountMgr->m_version);
    engine.rootContext()->setContextProperty("appversion", YMUserBaseInformation::appVersion);
    engine.rootContext()->setContextProperty("userInfo", userData);
    engine.rootContext()->setContextProperty("userType",YMUserBaseInformation::type);

    //=======================================
    //log文件初始化
    DebugLog::GetInstance()->init_log(g_strAppFileName);
    qInstallMessageHandler(DebugLog::GetInstance()->LogMsgOutput);     //release模式下，调试信息输出至日志文件
    //开始写第一行日志, 每次启动的时候, 才写
    qDebug() << (QString("============================================= Begin to run %1.") .arg(g_strAppFileName));

    //=======================================
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    accountMgr->getLocation();
    //=======================================
    int iResult = app.exec();
    if(iResult == g_ReturnCode_Restart) //另一个使用: g_ReturnCode_Restart的地方, 就是退出应用程序的地方
    {
        //切换测试网络环境以后, 应用程序, 自动重启, 传入qApp->applicationFilePath(), 启动自己
        QProcess::startDetached(qApp->applicationFilePath(), QStringList());
        shared.detach(); //释放内存, 在当前的情况下, 当前应用程序, 不需要只有一个实例
        return 0;
    }

    return iResult;
}

