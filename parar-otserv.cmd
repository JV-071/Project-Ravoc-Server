@echo off
title Parar Crystal OTServ
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0parar-otserv.ps1"
if errorlevel 1 pause
