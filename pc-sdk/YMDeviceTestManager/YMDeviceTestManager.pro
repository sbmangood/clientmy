#-------------------------------------------------
#
# Project created by QtCreator 2019-09-19T11:56:46
#
#-------------------------------------------------

QT       += core gui

TARGET = YMDeviceTestManager
TEMPLATE = lib
CONFIG += plugin
QT += multimedia network
CONFIG += c++11
DESTDIR = $$PWD/../release/
DEFINES += YMDEVICETESTMANAGER_LIBRARY

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

HEADERS += $$PWD/*.h      \
           $$PWD/agora/*.h \

SOURCES += $$PWD/*.cpp      \
           $$PWD/agora/*.cpp \

DISTFILES += YMDeviceTestManager.json

INCLUDEPATH += $$PWD/../common/AgoraSDK/include
win32: LIBS += -L$$PWD/../common/AgoraSDK/lib/ -lagora_rtc_sdk
DEPENDPATH += $$PWD/../common/AgoraSDK/lib

unix {
    target.path = /usr/lib
    INSTALLS += target
}

