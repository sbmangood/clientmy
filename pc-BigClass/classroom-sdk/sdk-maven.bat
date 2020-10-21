@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

@set FILE_NAME=sdk.rar
@set FILE_PATH=com/yimi/room/pc-sdk
@set MAVEN_PATH=http://192.168.1.108:8081/artifactory/libs-release-local
@set MAVEN_USER=jenkins:AP9P6JxWuMomVc9M

%~d0	
cd %~dp0
echo %~dp0

:: upload,4.8.1,sdk.rar
call :parse_options %1,%2,%3

::退出编译
@exit /b 0
@endlocal


:throw
	echo "error: "%1"
	exit 1
GOTO:EOF 


:usage
  echo
  echo "Usage: maven.sh [-h] [upload] [download]"
  echo
  echo "upload <version> <file>  - Upload to maven. [e.g.]: ./maven.sh upload 1.0.0 localFile.zip"
  echo "download <version> <sdkpath>      - Download from maven. [e.g.]: ./maven.sh download 1.0.1 sdkpath"
  echo "-h                       - This help text."
  echo
GOTO:EOF 

:parse_options
	echo "parse_options %1"
	if "%1"=="" (
		echo "agrc is error"  
		exit 1
	) else (
		if "%1"=="-h" (
			call :usage 
			exit 0
		)
		if "%1"=="upload" (
			echo "parse_options %1 %2 %3"
			call :upload %2,%3 
		)
		if "%1"=="download" ( 
			echo "parse_options %1 %2 %3"
			call :download %2,%3
		)
	)
GOTO:EOF

:upload
	echo "upload argc , %1, %2"	
	  if "%1" == ""	(
		call :throw "version null"
	  )
	  if "%2" == ""	(
		call :throw "file null"
	  )

	  if exist %2 ( 
		echo "%2 is exist"
	  ) else (
		call :throw "file %2 is not exist"
	  ) 

	  echo "Uploading... "
	  echo "%2 -> %MAVEN_PATH%/%FILE_PATH%/%1/%FILE_NAME%"
	  .\tool\curl-7.64.1-I386\curl -u %MAVEN_USER% -T %2 %MAVEN_PATH%/%FILE_PATH%/%1/%FILE_NAME%
	  echo "Done!"
	
GOTO:EOF

:download 
	echo "download argc , %1 %2"	
	  if "%1" == ""	(
		call :throw "version null"
	  )
	  if "%2" == ""	(
		call :throw "file null"
	  )

	  if exist %2 ( 
		echo "%2 is exist"
	  ) else (
		call :throw "path %2 is not exist"
	  ) 

	  @set SDK_PATH=%2
	  echo "download... "
	  echo "%MAVEN_PATH%/%FILE_PATH%/%1/%FILE_NAME% -> %SDK_PATH%"
	  .\tool\curl-7.64.1-I386\curl -u %MAVEN_USER% -o %SDK_PATH%sdk.rar %MAVEN_PATH%/%FILE_PATH%/%1/%FILE_NAME%
	  echo "Done!"
	  
	  echo "unpack... "
	  @del %SDK_PATH%sdk\* /Q /F /S
	  mkdir %SDK_PATH%sdk\
	  .\tool\WinRAR\rar x %SDK_PATH%sdk.rar %SDK_PATH%sdk\
	  echo "Done!"

GOTO:EOF

