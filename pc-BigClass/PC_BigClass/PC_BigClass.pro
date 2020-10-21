TEMPLATE = app
TARGET = PC_BigClass

QT += qml quick network core widgets
CONFIG += c++11
DESTDIR = $$PWD/../release/
#第三方库: DbgHelp, 当程序发生崩溃的时候, 打印出当前的堆栈信息, 得到文件名, 行号
LIBS += -lDbgHelp

HEADERS += *.h


SOURCES += *.cpp

RESOURCES += qml.qrc \
    images.qrc

win32: LIBS += -L$$PWD/openssl/lib/ -llibcrypto -lopenssl
INCLUDEPATH += $$PWD/openssl/include
DEPENDPATH += $$PWD/openssl/include

RC_FILE = ymico.rc

#打开编译开关： 将代码的文件信息, 行信息, 添加到可执行文件中, 目的是: 程序崩溃的时候, 知道发生在哪个文件, 哪一行
QMAKE_LFLAGS_RELEASE += /INCREMENTAL:NO /DEBUG
QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS += /MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\"
