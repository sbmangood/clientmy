@echo off
@setlocal ENABLEDELAYEDEXPANSION

::设置色调
@color 0A

::加载环境
@call "C:\Qt\Qt5.8.0\5.8\msvc2015\bin\qtenv2.bat"
@call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat"

::设置变量
@set _QT_MAKE_=qmake
@set _VS_MAKE_=nmake
@set _CONFIGURATION_=release

%~d0	
cd %~dp0
echo %~dp0

::创建目录
mkdir .\sdk\lib
mkdir .\sdk\demo
mkdir .\sdk\dll\Answer
mkdir .\sdk\dll\Trophy
mkdir .\sdk\dll\RedPacket
mkdir .\sdk\dll\WhiteBoard
mkdir .\sdk\inc\controlcenter
mkdir .\sdk\inc\answer
mkdir .\sdk\inc\trophy
mkdir .\sdk\inc\redpacket
mkdir .\sdk\inc\whiteboard
mkdir .\sdk\inc\socketmanager
mkdir .\sdk\inc\YMAudioVideoManager
mkdir .\sdk\inc\YMCoursewareManager
mkdir .\sdk\inc\YMHandsUpManager
mkdir .\sdk\inc\YMDeviceTestManager
mkdir .\sdk\qml\whiteboard
mkdir .\sdk\qml\YMAudioVideoManager
mkdir .\sdk\qml\YMCoursewareManager
mkdir .\sdk\qml\YMHandsUpManager

::清空目录(切勿修改)
@del .\sdk\* /Q /F /S
@del ..\release\* /Q /F /S

cd "..\YMCoursewareManager"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% YMCoursewareManager.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\YMCoursewareManager.h ..\build\sdk\inc\YMCoursewareManager
@copy .\YMCoursewareManager.pri ..\build\sdk\inc\YMCoursewareManager
@copy .\YMCoursewareManagerCrtl.h ..\build\sdk\inc\YMCoursewareManager
@copy .\MessageModel.h ..\build\sdk\inc\YMCoursewareManager
@xcopy .\QML\* ..\build\sdk\qml\YMCoursewareManager /e /y

cd "..\YMAudioVideoManager"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% YMAudioVideoManager.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\iaudiovideoctrl.h ..\build\sdk\inc\YMAudioVideoManager

cd "..\YMHandsUpManager"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% YMHandsUpManager.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\IHandsUpCtrl.h ..\build\sdk\inc\YMHandsUpManager
@xcopy .\qml\* ..\build\sdk\qml\YMHandsUpManager /e /y

cd "..\answer"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% answer.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\qmldir ..\release\Answer
@copy .\ianswercallback.h ..\build\sdk\inc\answer
@copy .\ianswerctrl.h ..\build\sdk\inc\answer

cd "..\trophy"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% trophy.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\qmldir ..\release\Trophy
@copy .\itrophycallback.h ..\build\sdk\inc\trophy
@copy .\itrophyctrl.h ..\build\sdk\inc\trophy

cd "..\redpacket"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% redpacket.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\qmldir ..\release\RedPacket
@copy .\iredpacketcallback.h ..\build\sdk\inc\redpacket
@copy .\iredpacketctrl.h ..\build\sdk\inc\redpacket

cd "..\whiteboard"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% whiteboard.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\qmldir ..\release\WhiteBoard
@copy .\whiteboardmsg.h ..\build\sdk\inc\whiteboard
@copy .\iwhiteboardctrl.h ..\build\sdk\inc\whiteboard
@copy .\iwhiteboardcallback.h ..\build\sdk\inc\whiteboard
@copy .\WhiteBoard0.qml ..\build\sdk\qml\whiteboard
@copy .\whiteboard.qrc ..\build\sdk\qml\whiteboard

cd "..\socketmanager"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% socketmanager.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\isocketmessagectrl.h ..\build\sdk\inc\socketmanager
@copy .\isocketmessgaecallback.h ..\build\sdk\inc\socketmanager

cd "..\YMDeviceTestManager"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% YMDeviceTestManager.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\IDeviceTestCtrl.h ..\build\sdk\inc\YMDeviceTestManager

cd "..\controlcenter"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% controlcenter.pro
@%_VS_MAKE_% %_CONFIGURATION_%
@copy .\controlcenter.h ..\build\sdk\inc\controlcenter
@copy .\datamodel.h ..\build\sdk\inc\controlcenter
@copy .\imageprovider.h ..\build\sdk\inc\controlcenter
@copy .\getoffsetimage.h ..\build\sdk\inc\controlcenter
@copy .\YMUserBaseInformation.h ..\build\sdk\inc\controlcenter

cd "..\player"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% player.pro
@%_VS_MAKE_% %_CONFIGURATION_%

cd "..\"
::移动生成文件至指定目录
@copy .\release\*.pdb .\build\sdk\dll
@copy .\release\*.dll .\build\sdk\dll
@copy .\release\*.exe .\build\sdk\dll
@copy .\release\*.lib .\build\sdk\lib

@copy .\release\Answer\qmldir .\build\sdk\dll\Answer
@copy .\release\Answer\*.pdb .\build\sdk\dll\Answer
@copy .\release\Answer\*.dll .\build\sdk\dll\Answer
@copy .\release\Answer\*.lib .\build\sdk\lib

@copy .\release\Trophy\qmldir .\build\sdk\dll\Trophy
@copy .\release\Trophy\*.pdb .\build\sdk\dll\Trophy
@copy .\release\Trophy\*.dll .\build\sdk\dll\Trophy
@copy .\release\Trophy\*.lib .\build\sdk\lib

@copy .\release\RedPacket\qmldir .\build\sdk\dll\RedPacket
@copy .\release\RedPacket\*.pdb .\build\sdk\dll\RedPacket
@copy .\release\RedPacket\*.dll .\build\sdk\dll\RedPacket
@copy .\release\RedPacket\*.lib .\build\sdk\lib

@copy .\release\WhiteBoard\qmldir .\build\sdk\dll\WhiteBoard
@copy .\release\WhiteBoard\*.pdb .\build\sdk\dll\WhiteBoard
@copy .\release\WhiteBoard\*.dll .\build\sdk\dll\WhiteBoard
@copy .\release\WhiteBoard\*.lib .\build\sdk\lib

echo "start pack sdk"
cd ".\build"
::set _RAR_NAME_=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
::set "_RAR_NAME_=%_RAR_NAME_: =0%"
::echo %_RAR_NAME_%
.\tool\WinRAR\rar a -r -ep1 sdk.rar sdk\

echo "start upload sdk to maven"
call sdk-maven.bat upload,4.9.1,sdk.rar

::退出编译
@exit /b 0
@endlocal