#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlContext>
#include <QSharedMemory>
#include <QApplication>
#include <QDesktopWidget>
#include <QMessageBox>
#include "YMAccountManager.h"
#include "YMAccountManagerAdapter.h"
#include "YMLessonManagerAdapter.h"
#include "YMCallStack.h"
#include "YMStageManagerAdapter.h"

QString g_strAppFullPath = "";
QString g_strAppFileName = "";
//为了程序自动重启, 定义的一个ID
int g_ReturnCode_Restart = 773;
#define MSG_BOX_TITLE  QString(u8"大班课")
#define MSG_BOX_CONTEXT  "程序已经启动, 请先关闭程序, 再打开."

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/tea64x64.ico"));

    //注冊: 程序发生异常的捕获函数
    SetUnhandledExceptionFilter((LPTOP_LEVEL_EXCEPTION_FILTER)ApplicationCrashHandler);

    g_strAppFileName = QString::fromLocal8Bit(argv[0]); //解决路径中, 中文乱码的问题
    g_strAppFullPath = g_strAppFileName;
    g_strAppFileName = g_strAppFileName.mid(g_strAppFileName.lastIndexOf("\\") + 1);

    QSharedMemory shared("Big_Class");
    if (shared.attach())
    {
        QString strMessage = QString::fromLocal8Bit(MSG_BOX_CONTEXT);
        QMessageBox::information(NULL, MSG_BOX_TITLE, strMessage, QMessageBox::Ok, QMessageBox::Ok);
        qDebug() << QString("Big_Class has already been running, please exit and run again.") << __LINE__;
        return 0;
    }
    shared.create(1);

    QStringList lstVer = YMUserBaseInformation::appVersion.split(".");
    YMUserBaseInformation::versionCode = QString("%1%02%03") .arg(lstVer[0]) .arg(lstVer[1]) .arg(lstVer[2]);

    QFile::remove(QStringLiteral("C:/Users/Public/Desktop/PC_Sdkdemo.lnk"));
    QQmlApplicationEngine engine;

    qmlRegisterType<YMAccountManagerAdapter>("YMAccountManagerAdapter", 1, 1, "YMAccountManagerAdapter");
    qmlRegisterType<YMLessonManagerAdapter>("YMLessonManagerAdapter", 1, 0, "YMLessonManagerAdapter");
    qmlRegisterType<YMStageManagerAdapter>("YMStageManagerAdapter", 1, 0, "YMStageManagerAdapter");
    YMAccountManager * accountMgr = YMAccountManager::getInstance();
    engine.rootContext()->setContextProperty("isStageEnvironment", YMUserBaseInformation::isStageEnvironment);
    QJsonArray userInfoArray = accountMgr->getUserLoginInfo();
    engine.rootContext()->setContextProperty("versionInfo", accountMgr->m_updateStatus); //是否要更新软件
    engine.rootContext()->setContextProperty("userInfo", userInfoArray); // 自动记住密码账号
    engine.rootContext()->setContextProperty("versionValue", accountMgr->m_updateValue); //是否支持暂不更新
    engine.rootContext()->setContextProperty("versionSoftWare", accountMgr->m_versinon); //软件版本号
    qDebug() << "====main:===" << YMUserBaseInformation::isStageEnvironment;

    //适配菜单栏图标
    QDesktopWidget *desktop = QApplication::desktop();
    int tempWidth = desktop->screenGeometry().height() - desktop->availableGeometry().height();
    if(tempWidth < 96)
    {
        app.setWindowIcon(QIcon(":/images/tea64x64.ico"));

    }
    else if(tempWidth >= 96 && tempWidth < 192)
    {
        app.setWindowIcon(QIcon(":/images/tea128x128.ico"));
    }
    else if(tempWidth >= 192)
    {
        app.setWindowIcon(QIcon(":/images/tea256x256.ico"));
    }
    engine.load(QUrl("qrc:/main.qml"));
    accountMgr->getLatLng();

    int iResult = app.exec();
    if(iResult == g_ReturnCode_Restart)
    {
        QProcess::startDetached(qApp->applicationFilePath(), QStringList());
        shared.detach();
        return 0;
    }
    return iResult;
}
