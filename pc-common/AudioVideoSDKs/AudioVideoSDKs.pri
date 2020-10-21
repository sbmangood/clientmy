HEADERS += \
    $$PWD/*.h \
    $$PWD/agora/*.h \
    $$PWD/iLiveSDK/*.h \
    $$PWD/LiteAV/*.h \
    $$PWD/wangyi_163/*.h \
    $$PWD/AudioVideoUtils.h \
    $$PWD/LiteAV/LiteAVVideoRenderCallback.h
SOURCES += \
    $$PWD/*.cpp \
    $$PWD/agora/*.cpp \
    $$PWD/iLiveSDK/*.cpp \
    $$PWD/LiteAV/*.cpp \
    $$PWD/wangyi_163/*.cpp \
    $$PWD/AudioVideoUtils.cpp \
    $$PWD/LiteAV/LiteAVVideoRenderCallback.cpp

############# agora #############
win32: LIBS += -L$$PWD/agora/lib/ -lagora_rtc_sdk
INCLUDEPATH += $$PWD/agora/include
DEPENDPATH += $$PWD/agora/lib

############# iLiveSDK #############
win32: LIBS += -L$$PWD/iLiveSDK/libs/ -liLiveSDK
INCLUDEPATH += $$PWD/iLiveSDK/include
DEPENDPATH += $$PWD/iLiveSDK/libs

############# LiteAV #############
win32: LIBS += -L$$PWD/LiteAV/lib/ -lliteav
INCLUDEPATH += $$PWD/LiteAV/include
DEPENDPATH += $$PWD/LiteAV/lib

############# 网易C通道其他依赖项 #############
DEFINES  += NIM_WIN_DESKTOP_ONLY_SDK
DEFINES  += NIM_SDK
DEFINES  += NIM_SDK_DLL_IMPORT
INCLUDEPATH += $$PWD/wangyi_163/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/api/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/helper
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/util/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_c_sdk/util/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_c_sdk/include/
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/third_party/jsoncpp/include/json
INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/third_party/libyuv/include
DEPENDPATH += $$PWD/wangyi_163/libs
win32:CONFIG(release, debug|release): {
LIBS += -L$$PWD/wangyi_163/libs/ -lnim_cpp_sdk
LIBS += -L$$PWD/wangyi_163/libs/ -llibyuv
}
else:win32:CONFIG(debug, debug|release): {
LIBS += -L$$PWD/wangyi_163/libs/ -lnim_cpp_sdk_d
LIBS += -L$$PWD/wangyi_163/libs/ -llibyuv_d
}
