@echo off
@pushd .
set exit_code=0

NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
	echo This setup needs admin permissions. Please run this file as admin.
	pause
	exit
)

call npm install -g git-run

rem cd %SETUP_DIR%

IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF DEFINED PROCESSOR_ARCHITEW6432 (
    set git_bin="%PROGRAMFILES(X86)%\Git\bin"
  ) ELSE (
    set git_bin="%ProgramFiles%\Git\bin"
  )
) ELSE IF %PROCESSOR_ARCHITECTURE% == AMD64 (
    set git_bin="%PROGRAMFILES(X86)%\Git\bin"
    ) ELSE (
  set git_bin="%ProgramFiles%\Git\bin"
)
set git_bin="%ProgramFiles%\Git\bin"
:: Remove qoutes
SET git_bin=%git_bin:"=%
@echo ------------------------------------
@echo    Git tag processing
@echo ------------------------------------
:: Preprocessing parameters

:: Preprocessing parameter 1
:1
IF [%1] EQU [] (
  @echo ===-------------------------------------------===----------
  @echo   ERROR: Missing Git repo directories file 
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO USAGE
)
:: Preprocessing parameter 2
:4
IF [%2] EQU [] (
  @echo ===-------------------------------------------===
  @echo   ERROR: Missing branch name
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO USAGE
)

:: Preprocessing parameter 3
:5
IF [%3] EQU [] (
  @echo ===-------------------------------------------===
  @echo   ERROR: Missing tag parameter
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO USAGE
)

GOTO PROCESSING

:GO_FOLDER_UP_IF_NOT_ROOT

:PROCESSING
@echo ------------------------------------------------------------------------------------------
@echo -   Tagging git remote repositories
@echo -   Full path to the Input file with the repositories : %1
@echo -   Branch to be tagged       : %2
@echo -   Tag       : %3
@echo ------------------------------------------------------------------------------------------

CD /d %~dp1
:: To get latest abbriviated hash from git
:: git log -n 1  --pretty="format:%h"
:: To get current tag
:: git describe --tags
:: git describe --tags --long | sed "s/v\([0-9]*\).*/\1/"'

::Download each repositories from the input file
rem FOR /F "tokens=1 delims=" %%A in (%1) do ("%git_bin%\git.exe" clone %%A)
::Add each download repo to the gr tag
for /D %%B in (*) do ( gr @tag %%B )
::Aply the tag for all the repos tagged and push it

rem for /D %%B in (*) do ( @echo %%B)
rem FOR /F "tokens=1 delims=" %%A in (%1) do ("%git_bin%\git.exe" clone %%A)
::!current_tag! 
REM FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/\(v[0-9]*\.[0-9]*\.[0-9]*\)-[0-9]*-g.*/\1/"') do SET tag_only=%%A
REM FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v\([0-9]*\).*/\1/"') do SET major_version=%%A
REM FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v[0-9]*\.\([0-9]*\).*/\1/"') do SET minor_version=%%A
REM FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/"') do SET revision=%%A
REM FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v[0-9]*\.[0-9]*\.[0-9]*-\([0-9]*\).*/\1/"') do SET commits_since_tag=%%A
REM FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v[0-9]*\.[0-9]*\.[0-9]*-[0-9]*-g\(.*\)/\1/"') do SET git_hash=%%A
REM SET git_hash=!git_hash: =!
REM FOR /F "tokens=1 delims=" %%A in ('"!git_bin!\git.exe" describe !tag_only! --tags --long') do SET git_tag_complete_with_hash=%%A
REM FOR /F "tokens=1 delims=" %%A in ('echo !git_tag_complete_with_hash! ^| sed "s/v[0-9]*\.[0-9]*\.[0-9]*-[0-9]*-g\(.*\)/\1/"') do SET git_tag_hash=%%A
REM SET git_tag_hash=!git_tag_hash: =!

REM @echo   Tag Only:          !tag_only!
REM @echo   Current Tag:       !current_tag!
REM @echo   Major Version:     !major_version!
REM @echo   Minor Version:     !minor_version!
REM @echo   Revision:          !revision!
REM @echo   Commits since tag: !commits_since_tag!
REM @echo   Git Hash:          !git_hash!
REM @echo   Git Tag Hash:      !git_tag_hash!


GOTO FINITO

:USAGE
@echo --------------------------------------------------------------------------------------
@echo  usage: gitversion.bat folder_with_git_repo inputfile outputfile
@echo  example: gitversion.bat c:\my_git_repo version_input.h version.h
@echo -
@echo  Important note: This expects tags to be in format: Anything else won't work. 
@echo  v1.0.123 where 1 is major, 0 is minor and 123 is revision
@echo  -
@echo  parameters replaced in input file:
@echo     $MAJOR_VERSION$     - the major version number
@echo     $MINOR_VERSION$     - the minor version number
@echo     $REVISION$          - the revision number
@echo     $COMMITS_SINCE_TAG$ - number of commits since last tag
@echo     $GIT_TAG_HASH$      - git hash for the tag
@echo     $GIT_HASH$          - the current git hash 
@echo                          (will be same as GIT_HASH if the current tag is checked out)
@echo --------------------------------------------------------------------------------------

:FINITO
EndLocal&SET exit_code=!exit_code!
popd
exit /B !exit_code!