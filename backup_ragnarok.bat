@echo off
echo ===================================================
echo rAthena Solo Single-Player Backup Script
echo ===================================================

set BACKUP_DIR=C:\RO_Backups\%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%
echo Creating backup directory: %BACKUP_DIR%
mkdir "%BACKUP_DIR%"

echo Backing up Database...
rem Assuming mariadb is running in docker
docker exec engineering-scoring-backend-mariadb-1 mysqldump -u root -pQWer!@34 ragnarok > "%BACKUP_DIR%\ragnarok_db.sql"

echo Backing up Custom Configurations...
xcopy /E /I /Y "conf" "%BACKUP_DIR%\conf"
xcopy /E /I /Y "npc\custom" "%BACKUP_DIR%\npc_custom"
xcopy /E /I /Y "db\import" "%BACKUP_DIR%\db_import"

echo Backup complete: %BACKUP_DIR%
pause
