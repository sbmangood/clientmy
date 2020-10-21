#-------------------------------------------------
#
# Project created by QtCreator 2019-08-29T14:47:47
#
#-------------------------------------------------

QT       += widgets qml quick

TARGET = RedPacket
TEMPLATE = lib
CONFIG += plugin
uri = RedPacket
DESTDIR = $$PWD/../release/RedPacket/

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    redpacket.cpp \
    redpacketplugin.cpp

HEADERS += \
    redpacket.h \
    iredpacketcallback.h \
    iredpacketctrl.h \
    redpacketplugin.h
DISTFILES += redpacket.json

unix {
    target.path = /usr/lib
    INSTALLS += target
}
