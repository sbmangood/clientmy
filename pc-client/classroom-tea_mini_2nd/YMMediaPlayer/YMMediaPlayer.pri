SOURCES += \
    $$PWD/ymaudiodecoder.cpp \
    $$PWD/ympacketqueue.cpp \
    $$PWD/ymplayer.cpp \
    $$PWD/ymseek.cpp \
    $$PWD/ymvideodecoder.cpp \
    $$PWD/ymvideoplayer.cpp


HEADERS  += \
    $$PWD/ymaudiodecoder.h \
    $$PWD/ympacketqueue.h \
    $$PWD/ymplayer.h \
    $$PWD/ymseek.h \
    $$PWD/ymvideodecoder.h \
    $$PWD/ymvideoplayer.h


LIBS += -L$$PWD/ffmpeg/libs/ -lavcodec -lavutil -lavformat -lavfilter -lavdevice -lswscale -lswresample -lpostproc

INCLUDEPATH += $$PWD/ffmpeg/include
DEPENDPATH += $$PWD/ffmpeg/libs


win32: LIBS += -L$$PWD/sdl/lib/ -lSDL2 -lSDL2main

INCLUDEPATH += $$PWD/sdl/include
DEPENDPATH += $$PWD/sdl/libs
