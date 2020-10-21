TEMPLATE = app
TARGET = ministudentclassroom
QT += qml quick  widgets core multimedia network


LIBS += -luser32
LIBS += -lgdi32
#第三方库: DbgHelp, 当程序发生崩溃的时候, 打印出当前的堆栈信息, 得到文件名, 行号
LIBS += -lDbgHelp

CONFIG += c++11

SOURCES += main.cpp \
    debuglog.cpp \
    YMCallStack.cpp

RESOURCES += qml.qrc \
    toolbar.qrc \
    trailboard.qrc \
    myimages.qrc \
    tipwindow.qrc \
    videotool.qrc \
    cloudview.qrc \
    minitools.qrc \
    ../../pc-common/coursewareManager/courseware.qrc	\
    ../YMCommon/whiteboard/whiteboard.qrc \
    ../../pc-common/YMNetworkControl/networkProject.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.

include($${PWD}/dataconfig/dataconfig.pri)
include($${PWD}/httprequset/httprequset.pri)
include($${PWD}/videovoice/videovoice.pri)
include($${PWD}/cloudclassroom/cloudclassroom.pri)
include($${PWD}/panDuWriteBoard/panduwriteboard.pri)
include($${PWD}/miniClass/miniClass.pri)
include(../../pc-common/pingback/pingback.pri)
include(../YMCommon/qosV2Manager/qosV2Manager.pri)
include(../YMCommon/whiteboard/whiteboard.pri)
include(../../pc-common/YMNetworkControl/networkManager.pri)
include(../../pc-common/longLinkManager/longLinkManager.pri)
include(../../pc-common/AudioVideoSDKs/AudioVideoSDKs.pri)
include(../../pc-common/coursewareManager/coursewareManager.pri)

RC_FILE = activeterminal.rc

QMAKE_LFLAGS += /MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\"

HEADERS += \
    debuglog.h \
    YMCallStack.h

#打开编译开关： 将代码的文件信息, 行信息, 添加到可执行文件中, 目的是: 程序崩溃的时候, 知道发生在哪个文件, 哪一行
QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

DEFINES += USE_MINI_STU_WHITEBOARD
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

DISTFILES +=
