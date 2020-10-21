TEMPLATE = app

QT += qml quick  core opengl widgets
QT += multimedia
QT += network

LIBS += -lopengl32 \
    -lglu32

CONFIG += c++11

LIBS += -L$$PWD\..\build-classroomdemo-Desktop_Qt_5_8_0_MSVC2015_32bit-Release\release -lcontrolcenter

SOURCES += main.cpp \
    toolbar.cpp

# 课程信息获取接口类
HEADERS += $$PWD/lessonInfo/YMLessonManager.h
SOURCES += $$PWD/lessonInfo/YMLessonManager.cpp


RESOURCES += qml.qrc    \
    ../whiteboard/whiteboard.qrc    \


include(./toolBar/toolBar.pri)                  # 工具栏View
include(./cloudDiskView/cloudDiskView.pri)      # 云盘View
include(./coursewareView/coursewareView.pri)    # 课件View
include(./audioVideoView/audioVideoView.pri)    # 音视频View

#win32: LIBS += -L$$PWD/../build-YMCoursewareManager-Desktop_Qt_5_8_0_MSVC2015_32bit-Release/release/ -lYMCoursewareManager

# Additional import path used to resolve QML modules in Qt Creator's code model
#QML_IMPORT_PATH = $$PWD/../build-classroomdemo-Desktop_Qt_5_8_0_MSVC2015_32bit-Release/release/plugins/

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =


QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO
# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    toolbar.h   \

############## 课件 ##################
include(../YMCoursewareManager/YMCoursewareManager.pri)
############## 音视频 ##################
#include(../YMAudioVideoManager/YMAudioVideoManager.pri)

