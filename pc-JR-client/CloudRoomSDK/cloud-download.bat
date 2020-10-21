%~d0	
cd %~dp0
echo %~dp0

@del .\cloud_classroom.rar
@del .\cloud_classroom\* /Q /F /S
call cloud-maven.bat download,1.1.0,.\