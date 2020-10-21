#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlContext>
#include "YMAccountManager.h"
#include "YMAccountManagerAdapter.h"
#include "YMLessonManagerAdapter.h"
#include <QSharedMemory>
#include <QApplication>
#include <QDesktopWidget>
#include "YMDevicetesting.h"
#include"./workorder/ymworkorderways.h"
#include "YMHomeworkManagerAdapter.h"
#include "PingThreadManagerAdapter.h"
#include "debuglog.h"
#include "YMCallStack.h"
#include"../YMCommon/qosManager/YMQosManager.h"
#define MSG_BOX_TITLE  QString(u8"溢米辅导")
#define MSG_BOX_CONTEXT  "程序已经启动, 请先关闭程序, 再打开."

QString g_strAppFullPath = "";
QString g_strAppFileName = "";
//为了程序自动重启, 定义的一个ID
int g_ReturnCode_Restart = 773;

int main(int argc, char *argv[])
{
    //QGuiApplication app(argc, argv);
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/tea64.ico")); //设置QMessageBox的标题中的ico

    QTime initTime;//记录程序初始化用时
    initTime.start();
    //=======================================
    //注冊: 程序发生异常的捕获函数
    SetUnhandledExceptionFilter((LPTOP_LEVEL_EXCEPTION_FILTER)ApplicationCrashHandler);
    YMQosManager::gestance()->initQosManager("","tea");//初始化qosManager
    //===============启动辅助进程======================
    QString runPath = QCoreApplication::applicationDirPath();
    QString prcName = "yimiPrcSvr.exe";
    runPath += "/yimiPrcSvr.exe";
    QProcess* process = new QProcess;
    process->start("tasklist" ,QStringList()<<"/FI"<<"imagename eq "+ prcName);
    process->waitForFinished();
    QString outputStr = QString::fromLocal8Bit(process->readAllStandardOutput());
    if(outputStr.contains(prcName)){
        //先关闭进程
        QProcess closePrc;
        closePrc.execute(QString("TASKKILL /IM %1 /F") .arg(prcName));
        closePrc.close();
        QProcess *yimiPrcSvrprocess = new QProcess();
        yimiPrcSvrprocess->start(runPath, QStringList());
        qDebug() << "yimiPrcSvr::runPath:" << runPath;
    } else {

        QProcess *yimiPrcSvrprocess = new QProcess();
        yimiPrcSvrprocess->start(runPath, QStringList());
        qDebug() << "yimiPrcSvr::runPath:" << runPath;
    }
    //===============启动辅助进程======================
    //记录当前应用程序的名称
    g_strAppFileName = QString::fromLocal8Bit(argv[0]); //解决路径中, 中文乱码的问题
    g_strAppFullPath = g_strAppFileName;
    g_strAppFileName = g_strAppFileName.mid(g_strAppFileName.lastIndexOf("\\") + 1);
    //    qDebug() << "222222222222222" << qPrintable(g_strAppFileName);

    //=============================================
    //保证当前的应用程序, 只能有一个实例在运行, 避免重复登录, 被踢的现象
    QSharedMemory shared("yimifdTeacher"); //exe被复制粘贴以后, 还是只能运行一个
    if (shared.attach())
    {
        QString strMessage = QString::fromLocal8Bit(MSG_BOX_CONTEXT);
        QMessageBox::information(NULL, MSG_BOX_TITLE, strMessage, QMessageBox::Ok, QMessageBox::Ok);
        qDebug() << QString("yimifdTeacher has already been running, please exit and run again.");
        return 0;
    }
    shared.create(1);

    //=============================================
    //versionCode 从 appVersion 中获得, 比如: appVersion是3.09.01.131, 那么code是:30901
    QStringList lstVer = YMUserBaseInformation::appVersion.split(".");
    YMUserBaseInformation::versionCode = QString("%1%02%03") .arg(lstVer[0]) .arg(lstVer[1]) .arg(lstVer[2]);
    //qDebug() << "==44===================" << lstVer[0] << lstVer[1] << lstVer[2] << lstVer[3] << YMUserBaseInformation::versionCode;

    //=============================================
    QFile::remove(QStringLiteral("C:/Users/Public/Desktop/一米辅导教师端.lnk"));
    QQmlApplicationEngine engine;

    qmlRegisterType<YMAccountManagerAdapter>("YMAccountManagerAdapter", 1, 1, "YMAccountManagerAdapter");
    qmlRegisterType<YMLessonManagerAdapter>("YMLessonManagerAdapter", 1, 0, "YMLessonManagerAdapter");
    qmlRegisterType<YMDeviceTesting>("YMdevicetesting", 1, 1, "YMdevicetesting");
    qmlRegisterType<YMWorkOrderways>("YMWorkOrderways", 1, 0, "YMWorkOrderways");
    qmlRegisterType<YMHomeWorkManagerAdapter>("YMHomeWorkManagerAdapter", 1, 0, "YMHomeWorkManagerAdapter");
    qmlRegisterType<PingThreadManagerAdapter>("PingThreadManagerAdapter", 1, 0, "PingThreadManagerAdapter");

    YMAccountManager * accountMgr = YMAccountManager::getInstance();
    accountMgr->getLatestVersion();

    //=============================================
    //设置http 跳转的URL的信息
    engine.rootContext()->setContextProperty("isStageEnvironment", YMUserBaseInformation::isStageEnvironment);
    engine.rootContext()->setContextProperty("URL_Mis", YMUserBaseInformation::m_strMis);
    engine.rootContext()->setContextProperty("URL_ClassroomReport", YMUserBaseInformation::m_strClassroomReport);
    engine.rootContext()->setContextProperty("ListenUrl",YMUserBaseInformation::m_strListenUrl);
    engine.rootContext()->setContextProperty("Write_ListenUrl",YMUserBaseInformation::m_strWriteListenUrl);

    //=============================================
    QJsonArray userInfoArray = accountMgr->getUserLoginInfo();
    engine.rootContext()->setContextProperty("versionInfo", accountMgr->m_updateStatus); //是否要更新软件
    engine.rootContext()->setContextProperty("userInfo", userInfoArray); //自动记住密码账号
    engine.rootContext()->setContextProperty("versionValue", accountMgr->m_updateValue); //是否支持暂不更新
    engine.rootContext()->setContextProperty("versionSoftWare", accountMgr->m_versinon); //软件版本号
    //qDebug() << "main:" << accountMgr->m_updateStatus << accountMgr->m_updateValue;

    //=======================================
    //log文件初始化
    DebugLog::GetInstance()->init_log(g_strAppFileName);
    qInstallMessageHandler(DebugLog::GetInstance()->LogMsgOutput);     //release模式下，调试信息输出至日志文件
    //开始写第一行日志, 每次启动的时候, 才写
    qDebug() << (QString("============================================= Begin to run %1.") .arg(g_strAppFileName));

    //=======================================

    if(YMUserBaseInformation::m_bIsPublicTest)
    {
        app.setWindowIcon(QIcon(":/images/yimiico_public_test_tea.ico"));
    }else
    {
        //适配菜单栏图标
        QDesktopWidget *desktop = QApplication::desktop();
        int tempWidth = desktop->screenGeometry().height() - desktop->availableGeometry().height();
        if(tempWidth < 96)
        {
            app.setWindowIcon(QIcon(":/images/tea64.ico"));

        }
        else if(tempWidth >= 96 && tempWidth < 192)
        {
            app.setWindowIcon(QIcon(":/images/tea128.ico"));
        }
        else if(tempWidth >= 192)
        {
            app.setWindowIcon(QIcon(":/images/tea256.ico"));
        }
    }

    engine.load(QUrl("qrc:/main.qml"));
    accountMgr->getLatLng();

    QJsonObject obj;
    obj.insert("appVersion",YMUserBaseInformation::appVersion);
    obj.insert("time",QString::number(initTime.elapsed() / 1000));
    YMQosManager::gestance()->addBePushedMsg("appLanuch",obj);

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

