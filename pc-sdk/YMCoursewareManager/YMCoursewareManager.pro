#-------------------------------------------------
#
# Project created by QtCreator 2019-07-12T17:44:21
#
#-------------------------------------------------

QT       -= gui

CONFIG += c++11

TARGET = YMCoursewareManager
TEMPLATE = lib
CONFIG += plugin
QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

DESTDIR = $$PWD/../release/
DEFINES += YMCOURSEWAREMANAGER_LIBRARY

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += YMCoursewareManager.cpp \
           MessageModel.cpp

HEADERS += YMCoursewareManager.h \
            MessageModel.h \
    #YMCoursewareManagerCrtl.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}
