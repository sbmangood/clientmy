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
mkdir .\cloud_classroom

::清空目录(切勿修改)
@del .\cloud_classroom\* /Q /F /S
@del ..\release\* /Q /F /S

::更新classroom-sdk
@echo "update classroom sdk"
@call "..\classroom-sdk\sdk-download.bat"
@echo "complite update classroom sdk"

@echo "back bat path"
%~d0	
cd %~dp0	
@xcopy ..\classroom-sdk\sdk\dll\* .\cloud_classroom /e /y

@echo "cloudclassroom--begin"
cd "..\cloudclassroom"
::编译前先清空编译文件
@del .\release\* /Q /F /S
::自动化编译
@%_QT_MAKE_% cloudclassroom.pro
@%_VS_MAKE_% %_CONFIGURATION_% 

::移动pdb和exe文件
cd "..\"
@copy .\release\cloudclassroom.pdb .\build\cloud_classroom
@copy .\release\cloudclassroom.exe .\build\cloud_classroom
@echo "cloudclassroom--end"

echo "start pack cloudclassroom"
cd ".\build"
::set _RAR_NAME_=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
::set "_RAR_NAME_=%_RAR_NAME_: =0%"
::echo %_RAR_NAME_%
..\classroom-sdk\tool\WinRAR\rar a -r -ep1 cloud_classroom.rar cloud_classroom\

echo "start upload sdk to maven"
call .\cloud-maven.bat upload,1.1.0,cloud_classroom.rar

::退出编译
@exit /b 0
@endlocal
