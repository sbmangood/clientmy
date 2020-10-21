TEMPLATE = app
TARGET = JRStudent

QT += qml quick network  core widgets
CONFIG += c++11

#第三方库: DbgHelp, 当程序发生崩溃的时候, 打印出当前的堆栈信息, 得到文件名, 行号
LIBS += -lDbgHelp

SOURCES += main.cpp \
    YMRemoteManager.cpp \
    YMHttpClient.cpp \
    YMHttpResponse.cpp \
    YMFileTransportResponse.cpp \
    YMAccountManager.cpp \
    YMUserBaseInformation.cpp \
    YMLessonManagerAdapter.cpp \
    YMMassgeRemindManager.cpp \
    ymcrypt.cpp \
    YMAccountManagerAdapter.cpp \
    PingThreadManager.cpp \
    PingThreadManagerAdapter.cpp \
    debuglog.cpp \
    YMCallStack.cpp \
    miniClass/YMMiniLessonManager.cpp

RESOURCES += qml.qrc \
    images.qrc
win32: LIBS += -L$$PWD/openssl/lib/ -llibcrypto -lopenssl
#win32: LIBS += -L$$PWD/agora/lib/ -lagora_rtc_sdk


INCLUDEPATH += $$PWD/openssl/include
DEPENDPATH += $$PWD/openssl/include

#INCLUDEPATH += $$PWD/agora/include
#DEPENDPATH += $$PWD/agora/include
include(../jwtcpp/jwtcpp.pri)

RC_FILE = ymico.rc #线上版本用这个图标
#RC_FILE = ymtestico.rc #公测版本用这个图标


HEADERS += \
    YMRemoteManager.h \
    YMHttpClient.h \
    YMHttpResponseHandler.h \
    YMFileTransportEventHandler.h \
    YMHttpResponse.h \
    YMFileTransportResponse.h \
    YMAccountManager.h \
    YMEncryption.h \
    YMUserBaseInformation.h \
    YMLessonManagerAdapter.h \
    YMMassgeRemindManager.h \
    ymcrypt.h \
    YMAccountManagerAdapter.h \
    agora/agoraengineeventhandler.h \
    agora/agorapacketobserver.h \
    agora/include/IAgoraMediaEngine.h \
    agora/include/IAgoraRtcEngine.h \
    PingThreadManager.h \
    PingThreadManagerAdapter.h \
    debuglog.h \
    YMCallStack.h \
    miniClass/YMMiniLessonManager.h

#打开编译开关： 将代码的文件信息, 行信息, 添加到可执行文件中, 目的是: 程序崩溃的时候, 知道发生在哪个文件, 哪一行
QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

QMAKE_LFLAGS += /MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\"

#==============================================
#本地日志文件, 是否上传到服务器, 默认: 开
#使用了以下宏, 说明上传到服务器
#注释掉以下宏, 说明不上传到服务器
#DEFINES += USE_LOG_UPLOAD

#本地日志文件, 是否上传到OSS, 默认: 开
#注释掉以下宏, 说明不上传到OSS
#DEFINES += USE_OSS_UPLOAD_LOG

#本地日志上传至静态服务器
#注释掉以下宏, 说明不上传到静态服务器
#DEFINES += USE_STATIC_UPLOAD_LOG
#==============================================
