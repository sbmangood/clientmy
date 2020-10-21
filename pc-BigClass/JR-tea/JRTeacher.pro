TEMPLATE = app
TARGET = JRTeacher

QT += qml quick network core widgets
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
    ymcrypt.cpp \
    YMAccountManagerAdapter.cpp \
    workorder/ymworkorderways.cpp \
    YMHomeworkManagerAdapter.cpp \
    PingThreadManager.cpp \
    PingThreadManagerAdapter.cpp \
    debuglog.cpp \
    YMCallStack.cpp

RESOURCES += qml.qrc \
    images.qrc \
    workorder.qrc
win32: LIBS += -L$$PWD/openssl/lib/ -llibcrypto -lopenssl

INCLUDEPATH += $$PWD/openssl/include
DEPENDPATH += $$PWD/openssl/include



RC_FILE = ymico.rc #线上版本用这个图标
#RC_FILE = ymtestico.rc #公测版本用这个图标
# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

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
    ymcrypt.h \
    YMAccountManagerAdapter.h \
    workorder/ymworkorderways.h \
    YMHomeworkManagerAdapter.h \
    PingThreadManager.h \
    PingThreadManagerAdapter.h \
    debuglog.h \
    YMCallStack.h
include(../jwtcpp/jwtcpp.pri)

#打开编译开关： 将代码的文件信息, 行信息, 添加到可执行文件中, 目的是: 程序崩溃的时候, 知道发生在哪个文件, 哪一行
QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

QMAKE_LFLAGS += /MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\"

#==============================================
#工单OSS验签宏定义
#使用宏则进行OSS验签
#注释宏则不进行验签
#DEFINES += USE_OSS_AUTHENTICATION

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
