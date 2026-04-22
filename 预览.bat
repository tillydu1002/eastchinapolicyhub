@echo off
chcp 65001 >nul
echo ===============================================
echo  华东政务信息站点 - 本地预览
echo ===============================================
echo.
echo  即将在 http://localhost:8000 启动本地服务
echo  浏览器会自动打开，按 Ctrl+C 可停止
echo.
cd /d "%~dp0"
start "" "http://localhost:8000/index.html"
"C:\Users\tillydu\.workbuddy\binaries\python\envs\default\Scripts\python.exe" -m http.server 8000
