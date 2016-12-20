@echo off
title Update Database Batch
color 0F

::debut

if "%1"=="" (goto error) else (set directory="%1")
if "%2"=="" (goto error) else (set login="%2")
if "%3"=="" (set host="localhost") else (set host="%3")
if "%4"=="" (set dbname="ecs") else (set dbname="%4")

mysql -N -h %host% -u %login% -p %dbname% -e "select max(idversion) from version;" > file.tmp
set /p DB_v=<file.tmp

dir /O/B *.sql | findstr /b "^[0-9]">file.tmp

for /f %%l in ( 'type file.tmp' ) do (
	firstfor.bat %%l
 	set var=%%l
	set val=%var:~0,3%
	set /a val=%val%
	if %val% GTR %L_v%(
		set L_v=%val%
		)
	)


set /a DB_v=%DB_v%
set /a L_v=%L_v%

echo Database is in version %DB_v%
echo The most up-to-date version is %L_v%

if %DB_v% EQU %L_v% (
    echo The ::database is already up-to-date. No change needed.
    goto end
    )
if %DB_v% GTR %L_v% (
    echo Error : The database has a more recent version than the local scripts. Exiting.
    goto end
    )


:end
rem del file.tmp
pause > nul
exit

:error
echo "usage : ./<script> <update directory> <login> <host> <dbname>"
pause > nul
exit