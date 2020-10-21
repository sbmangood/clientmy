SOURCES += $$PWD/*.cpp 

HEADERS += $$PWD/*.h

RESOURCES += $$PWD/uploadFile.qrc

win32: LIBS += -L$$PWD/../../classroom-sdk/sdk/lib -lYMUploadManager
INCLUDEPATH += $$PWD/../../classroom-sdk/sdk/inc/YMUploadManager
DEPENDPATH += $$PWD/../../classroom-sdk/sdk/lib
