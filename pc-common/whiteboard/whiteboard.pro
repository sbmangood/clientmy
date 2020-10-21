#-------------------------------------------------
#
# Project created by QtCreator 2019-06-24T16:34:10
#
#-------------------------------------------------

QT       += widgets qml quick


TARGET = WhiteBoard
TEMPLATE = lib
CONFIG += plugin
#TARGET = $$qtLibraryTarget($$TARGET)
uri = WhiteBoard

DEFINES += WHITEBOARDSDK_LIBRARY

QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

DESTDIR = $$PWD/../build-classroomdemo-Desktop_Qt_5_8_0_MSVC2015_32bit-Release/release/WhiteBoard/

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += whiteboard.cpp   \
#    $$PWD/whiteboardctrlinstance.cpp \
    whiteboardplugin.cpp

HEADERS += whiteboard.h \
#    $$PWD/whiteboardctrlinstance.h    \
    $$PWD/whiteboardmsg.h \
    $$PWD/iwhiteboardctrl.h \
    $$PWD/iwhiteboardcallback.h \
    whiteboardplugin.h

RESOURCES += images.qrc    \

DISTFILES += whiteboard.json \
    qmldir \
    qmldir

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}
qmldir.files = qmldir

unix {
    target.path = /usr/lib
    INSTALLS += target
}
