@ECHO OFF

SET make="C:\Program Files (x86)\GnuWin32\bin\make.exe"
SET mopt=

SET tall=All
SET trun=Run
SET tcln=Clean

ECHO Makefile Options
ECHO ================
ECHO.
ECHO   1	Make Clean
ECHO   2	Make All
ECHO   3	Make All (Clean)
ECHO   4	Make Run
ECHO   5	Make Run (Clean)
ECHO   Q	Quit
ECHO.
choice.exe /N /C 12345Q /M "Please choose: "
IF "%ERRORLEVEL%" == "1" GOTO MAKE_CLEAN
IF "%ERRORLEVEL%" == "2" GOTO MAKE_ALL
IF "%ERRORLEVEL%" == "3" GOTO MAKE_CLEAN_ALL
IF "%ERRORLEVEL%" == "4" GOTO MAKE_RUN
IF "%ERRORLEVEL%" == "5" GOTO MAKE_CLEAN_RUN
IF "%ERRORLEVEL%" == "6" GOTO END
GOTO END

:MAKE_CLEAN
%make% %mopt% %tcln%
GOTO END

:MAKE_ALL
%make% %mopt% %tall%
GOTO END

:MAKE_RUN
%make% %mopt% %trun%
GOTO END

:MAKE_CLEAN_ALL
%make% %mopt% %tcln% %tall%
GOTO END

:MAKE_CLEAN_RUN
%make% %mopt% %tcln% %trun%
GOTO END

:END
PAUSE
