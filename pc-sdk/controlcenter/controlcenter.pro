#-------------------------------------------------
#
# Project created by QtCreator 2019-06-24T17:38:42
#
#-------------------------------------------------

QT       -= gui
QT += qml quick  core opengl
QT += multimedia
QT += network

TARGET = controlcenter
TEMPLATE = lib

QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

DESTDIR = $$PWD/../release/
DEFINES += CONTROLCENTER_LIBRARY

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += controlcenter.cpp\
#    debuglog.cpp \
    messagepack.cpp \
    messagemodel.cpp \
    YMUserBaseInformation.cpp \
    getoffsetimage.cpp \
    curriculumdata.cpp \
    H5datamodel.cpp \
    datacenter.cpp \
    whiteboardcenter.cpp \
    socketmanagercenter.cpp \
    audiovideocenter.cpp \
    coursewarecenter.cpp \
    HandsUpCenter.cpp \
    redpacketscenter.cpp \
    httpclient.cpp \
    trophycenter.cpp \
    answercenter.cpp \
    devicetestcenter.cpp


HEADERS += controlcenter.h\
#    debuglog.h \
    messagepack.h \
    messagetype.h \
    messagemodel.h \
    YMEncryption.h \
    YMUserBaseInformation.h \
    getoffsetimage.h \
    imageprovider.h \
    curriculumdata.h \
    H5datamodel.h \
    datamodel.h \
    datacenter.h \
    whiteboardcenter.h \
    socketmanagercenter.h \
    audiovideocenter.h \
    coursewarecenter.h \
    HandsUpCenter.h \
    redpacketscenter.h \
    httpclient.h \
    trophycenter.h \
    answercenter.h \
    devicetestcenter.h

#include(../longLinkManager/longLinkManager.pri)
#include(../pingback/pingback.pri)

############# 课件 #############
win32: LIBS += -L$$PWD/../release/ -lYMCoursewareManager
INCLUDEPATH += $$PWD/../YMCoursewareManager
DEPENDPATH += $$PWD/../release

unix {
    target.path = /usr/lib
    INSTALLS += target
}
