HEADERS += \
    $$PWD/galaxy_message.pb.h \
    $$PWD/pingbackmanager.h \
    $$PWD/commdef.h



SOURCES += \
    $$PWD/galaxy_message.pb.cc \
    $$PWD/pingbackmanager.cpp



INCLUDEPATH += $$PWD
INCLUDEPATH += $$PWD/.
INCLUDEPATH += $$PWD/google
INCLUDEPATH += $$PWD/google/.
INCLUDEPATH += $$PWD/google/protobuf
INCLUDEPATH += $$PWD/google/protobuf/.
INCLUDEPATH += $$PWD/google/protobuf/io
INCLUDEPATH += $$PWD/google/protobuf/io/.
INCLUDEPATH += $$PWD/google/protobuf/util
INCLUDEPATH += $$PWD/google/protobuf/util/.
INCLUDEPATH += $$PWD/google/protobuf/util/internal
INCLUDEPATH += $$PWD/google/protobuf/util/internal/.
INCLUDEPATH += $$PWD/google/protobuf/stubs
INCLUDEPATH += $$PWD/google/protobuf/stubs/.

DEPENDPATH += $$PWD/google/libs
win32: LIBS += -L$$PWD/google/libs/ -llibprotobuf -llibprotobuf-lite -llibprotoc
