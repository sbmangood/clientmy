HEADERS += \
    $$PWD/yimibreakpad.h \
    $$PWD/HttpUploader.h

SOURCES += \
    $$PWD/yimibreakpad.cpp \
    $$PWD/HttpUploader.cpp


INCLUDEPATH += $$PWD
INCLUDEPATH += $$PWD/.
INCLUDEPATH += $$PWD/breakpad
INCLUDEPATH += $$PWD/breakpad/.
INCLUDEPATH += $$PWD/breakpad/src
INCLUDEPATH += $$PWD/breakpad/src/.
INCLUDEPATH += $$PWD/breakpad/src/common
INCLUDEPATH += $$PWD/breakpad/src/client
INCLUDEPATH += $$PWD/breakpad/src/client/.
INCLUDEPATH += $$PWD/breakpad/src/client/windows
INCLUDEPATH += $$PWD/breakpad/src/client/windows/.

DEPENDPATH += $$PWD/breakpad/libs/Release
win32: LIBS += -L$$PWD//breakpad/libs/Release/ -lcommon -lcrash_generation_client -lcrash_generation_server -lcrash_report_sender -lexception_handler
