%~d0	
cd %~dp0
echo %~dp0

@del .\sdk.rar
@del .\sdk\* /Q /F /S
call sdk-maven.bat download,1.1.0,.\