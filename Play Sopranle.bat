@echo off
title Sopranle server
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve.ps1"
pause
