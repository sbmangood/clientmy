TEMPLATE = app

QT += qml quick  widgets core opengl
QT += multimedia
QT += network

LIBS += -luser32
LIBS += -lgdi32
#第三方库: DbgHelp, 当程序发生崩溃的时候, 打印出当前的堆栈信息, 得到文件名, 行号
LIBS += -lDbgHelp

LIBS += -lopengl32 \
    -lglu32

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
    controls.qrc \
    cloudview.qrc \
    listenLessonView.qrc \
    ../YMCommon/courseWare/courseware.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =


# Default rules for deployment.

############### 包含音视频模块 2019-04-02 #################################################
include(../../pc-common/AudioVideoSDKs/AudioVideoSDKs.pri)
################ 包含yimibreakpad、yimiIPC模块###################################################
################ creator by Shaohua.Zhang  Date:2019/7/16######################################
include(../../pc-common/yimibreakpad/yimibreakpad.pri)
include(../../pc-common/yimiIPC/yimiIPC.pri)

win32: LIBS += -L$$PWD/beautyManager/renderWayA/Win32/ -lnama

INCLUDEPATH += $$PWD/beautyManager/renderWayA/include
DEPENDPATH += $$PWD/beautyManager/renderWayA/Win32

QMAKE_LFLAGS += /MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\"

include(deployment.pri)

include($${PWD}/dataconfig/dataconfig.pri)
include($${PWD}/httprequset/httprequset.pri)
include($${PWD}/videovoice/videovoice.pri)
include($${PWD}/cloudclassroom/cloudclassroom.pri)
#include($${PWD}/YMMediaPlayer/YMMediaPlayer.pri)
include($${PWD}/panDuWriteBoard/panduwriteboard.pri)

include($${PWD}/beautyManager/beautyManager.pri)

include(../YMCommon/qosManager/qosManager.pri)

include(../../pc-common/longLinkManager/longLinkManager.pri)
include(../YMCommon/courseWare/coursewareManager.pri)

RC_FILE = activeterminal.rc

HEADERS += \
    debuglog.h \
    YMCallStack.h

#打开编译开关： 将代码的文件信息, 行信息, 添加到可执行文件中, 目的是: 程序崩溃的时候, 知道发生在哪个文件, 哪一行
QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

DISTFILES +=

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



