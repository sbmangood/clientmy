#-------------------------------------------------
#
# Project created by QtCreator 2019-07-16T17:37:31
#
#-------------------------------------------------

QT       -= gui
QT += qml quick  core opengl widgets
QT += multimedia
QT += network

TARGET = YMAudioVideoManager
TEMPLATE = lib

CONFIG += c++11
DESTDIR = $$PWD/../release/
DEFINES += YMAUDIOVIDEOMANAGER_LIBRARY

LIBS += -luser32    \
        -lgdi32     \
        -lopengl32  \
        -lglu32

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += YMAudioVideoManager.cpp

HEADERS += YMAudioVideoManager.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}

HEADERS += \
    $$PWD/*.h \
    $$PWD/agora/*.h \
    $$PWD/iLiveSDK/*.h \
    $$PWD/LiteAV/*.h \
    $$PWD/wangyi_163/*.h \
    $$PWD/AudioVideoUtils.h \
    $$PWD/LiteAV/LiteAVVideoRenderCallback.h
SOURCES += \
    $$PWD/*.cpp \
    $$PWD/agora/*.cpp \
    $$PWD/iLiveSDK/*.cpp \
    $$PWD/LiteAV/*.cpp \
    $$PWD/wangyi_163/*.cpp \
    $$PWD/AudioVideoUtils.cpp \
    $$PWD/LiteAV/LiteAVVideoRenderCallback.cpp

############# agora #############
win32: LIBS += -L$$PWD/../common/AgoraSDK/lib/ -lagora_rtc_sdk
INCLUDEPATH += $$PWD/../common/AgoraSDK/include
DEPENDPATH += $$PWD/../common/AgoraSDK/lib

############# iLiveSDK #############
win32: LIBS += -L$$PWD/iLiveSDK/libs/ -liLiveSDK
INCLUDEPATH += $$PWD/iLiveSDK/include
DEPENDPATH += $$PWD/iLiveSDK/libs

############# LiteAV #############
win32: LIBS += -L$$PWD/LiteAV/lib/ -lliteav
INCLUDEPATH += $$PWD/LiteAV/include
DEPENDPATH += $$PWD/LiteAV/lib

############# 网易C通道其他依赖项 #############
DEFINES  += NIM_WIN_DESKTOP_ONLY_SDK
DEFINES  += NIM_SDK
DEFINES  += NIM_SDK_DLL_IMPORT
INCLUDEPATH += $$PWD/wangyi_163/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/api/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/helper
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/util/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_c_sdk/util/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_c_sdk/include/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/third_party/jsoncpp/include/json
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/third_party/libyuv/include
DEPENDPATH += $$PWD/wangyi_163/libs
win32:CONFIG(release, debug|release): {
LIBS += -L$$PWD/wangyi_163/libs/ -lnim_cpp_sdk
LIBS += -L$$PWD/wangyi_163/libs/ -llibyuv
}
else:win32:CONFIG(debug, debug|release): {
LIBS += -L$$PWD/wangyi_163/libs/ -lnim_cpp_sdk_d
LIBS += -L$$PWD/wangyi_163/libs/ -llibyuv_d
}

################## 美颜部分 #######################
HEADERS += \
    $$PWD/beautyManager/*.h \
    $$PWD/beautyManager/renderWayA/*.h \
    $$PWD/beautyManager/renderWayA/include/*.h \

SOURCES += \
    $$PWD/beautyManager/*.cpp \
    $$PWD/beautyManager/renderWayA/*.cpp \

win32: LIBS += -L$$PWD/beautyManager/renderWayA/Win32/ -lnama
INCLUDEPATH += $$PWD/beautyManager/renderWayA/include
DEPENDPATH += $$PWD/beautyManager/renderWayA/Win32

CONFIG += no_batch
