HEADERS += \
#    $$PWD/*.h \
#    $$PWD/agora/*.h \
#    $$PWD/iLiveSDK/*.h \
#    $$PWD/processingachannel.h \
#    $$PWD/operationchannel.h \
    $$PWD/externalcallchanncel.h \
    $$PWD/videorender.h \
#    $$PWD/cameracapture.h \
#    $$PWD/wangyi_163/channel_wangyi.h \
#    $$PWD/wangyi_163/nim_utils.h \
#    $$PWD/processing_c_channel.h

SOURCES += \
#    $$PWD/*.cpp \
#    $$PWD/agora/*.cpp \
#    $$PWD/iLiveSDK/*.cpp \
#    $$PWD/processingachannel.cpp \
#    $$PWD/operationchannel.cpp \
    $$PWD/externalcallchanncel.cpp \
    $$PWD/videorender.cpp \
#    $$PWD/cameracapture.cpp \
#    $$PWD/wangyi_163/channel_wangyi.cpp \
#   $$PWD/processing_c_channel.cpp


# ==================================== >>>
# 网易C通道的
#DEFINES  += NIM_WIN_DESKTOP_ONLY_SDK
#DEFINES  += NIM_SDK
#DEFINES  += NIM_SDK_DLL_IMPORT

#INCLUDEPATH += $$PWD/wangyi_163/
#INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/
#INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/api/
#INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/helper
#INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_sdk_cpp/util/
#INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_c_sdk/util/
#INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/nim_c_sdk/include/
#INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/third_party/jsoncpp/include/json
#INCLUDEPATH += $$PWD/wangyi_163/nim_sdk/third_party/libyuv/include

#DEPENDPATH += $$PWD/wangyi_163/libs

#win32:CONFIG(release, debug|release): {
#LIBS += -L$$PWD/wangyi_163/libs/ -lnim_cpp_sdk
#LIBS += -L$$PWD/wangyi_163/libs/ -llibyuv
#}
#else:win32:CONFIG(debug, debug|release): {
#LIBS += -L$$PWD/wangyi_163/libs/ -lnim_cpp_sdk_d
#LIBS += -L$$PWD/wangyi_163/libs/ -llibyuv_d
#}

# <<< ====================================
