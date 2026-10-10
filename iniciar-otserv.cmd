@echo off
title Iniciar Crystal OTServ
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0iniciar-otserv.ps1"
if errorlevel 1 pause
