HEADERS += \
    $$PWD/app_callback.h \
    $$PWD/CommTask.h \
    $$PWD/longlink_packer.h \
    $$PWD/NetworkService.h \
    $$PWD/NetworkObserver.h \
    $$PWD/stn_callback.h \
    $$PWD/shortlink_packer.h \
    $$PWD/stnproto_logic.h


SOURCES += \
    $$PWD/app_callback.cpp \
    $$PWD/CommTask.cpp \
    $$PWD/longlink_packer.cc \
    $$PWD/NetworkService.cpp \
    $$PWD/shortlink_packer.cc \
    $$PWD/stn_callback.cpp


INCLUDEPATH += $$PWD/mars
INCLUDEPATH += $$PWD/mars/.
INCLUDEPATH += $$PWD/mars/comm/windows
INCLUDEPATH += $$PWD/mars/comm/windows/.


DEPENDPATH += $$PWD/mars/libs
win32: LIBS += -L$$PWD/mars/libs/ -lapp -lbaseevent -lcomm -lmars-boost -lsdt -lstn -lxlog
