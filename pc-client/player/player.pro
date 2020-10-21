TEMPLATE = app

QT += qml quick core  widgets multimedia
CONFIG += c++11

#第三方库: DbgHelp, 当程序发生崩溃的时候, 打印出当前的堆栈信息, 得到文件名, 行号
LIBS += -lDbgHelp

SOURCES += main.cpp \
    ymcrypt.cpp \
    painterboard.cpp \
    filecrypt.cpp \
    bgimg.cpp \
    debuglog.cpp \
    YMCallStack.cpp


RESOURCES += qml.qrc \
    images.qrc \
    cloudview.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

include($${PWD}/cloudclassroom/cloudclassroom.pri)

HEADERS += \
    ymcrypt.h \
    painterboard.h \
    filecrypt.h \
    bgimg.h \
    debuglog.h \
    YMCallStack.h

#打开编译开关： 将代码的文件信息, 行信息, 添加到可执行文件中, 目的是: 程序崩溃的时候, 知道发生在哪个文件, 哪一行
QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

RC_FILE = ymico.rc

#==============================================
#OSS 是否使用新版本(加签的), 默认: 关
#使用了以下宏, 说明使用新的
#注释掉以下宏, 说明还是使用旧版本的
#DEFINES += USE_OSS_AUTHENTICATION

#==============================================
#本地日志文件, 是否上传到服务器, 默认: 开
#使用了以下宏, 说明上传到服务器
#注释掉以下宏, 说明不上传到服务器
DEFINES += USE_LOG_UPLOAD

#本地日志文件, 是否上传到OSS, 默认: 开
#注释掉以下宏, 说明不上传到OSS
#DEFINES += USE_OSS_UPLOAD_LOG

#本地日志上传至静态服务器
#注释掉以下宏, 说明不上传到静态服务器
DEFINES += USE_STATIC_UPLOAD_LOG
#==============================================
