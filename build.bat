@echo off
REM CF-Data Android APK 构建脚本 (Windows)
REM 支持多种Android架构

echo ==========================================
echo CF-Data Android APK 构建脚本
echo ==========================================

REM 检查是否安装了必要的工具
where gomobile >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 需要安装 gomobile. 运行: go install golang.org/x/mobile/cmd/gomobile@latest
    exit /b 1
)

where go >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 需要安装 Go
    exit /b 1
)

REM 初始化 gomobile
echo 初始化 gomobile...
gomobile init

REM 创建输出目录
if not exist "app\libs" mkdir app\libs
if not exist "app\src\main\jniLibs" mkdir app\src\main\jniLibs

echo.
echo 开始编译 Go 库...

REM 编译各个架构的库
echo 编译架构: arm64-v8a
gomobile bind -target=android/arm64 -o app\libs\cfdata-arm64.aar .\cfdata
if %errorlevel% neq 0 (
    echo 警告: arm64 架构编译失败
)

echo 编译架构: armeabi-v7a
gomobile bind -target=android/arm -o app\libs\cfdata-arm.aar .\cfdata
if %errorlevel% neq 0 (
    echo 警告: arm 架构编译失败
)

echo 编译架构: x86
gomobile bind -target=android/386 -o app\libs\cfdata-386.aar .\cfdata
if %errorlevel% neq 0 (
    echo 警告: x86 架构编译失败
)

echo 编译架构: x86_64
gomobile bind -target=android/amd64 -o app\libs\cfdata-amd64.aar .\cfdata
if %errorlevel% neq 0 (
    echo 警告: x86_64 架构编译失败
)

REM 使用 arm64 作为主要架构
if exist "app\libs\cfdata-arm64.aar" (
    copy /Y app\libs\cfdata-arm64.aar app\libs\cfdata.aar >nul
    echo 使用 arm64 作为主要架构
)

REM 提取并合并所有架构的so文件
echo.
echo 提取 native 库...

REM 提取 arm64
if exist "app\libs\cfdata-arm64.aar" (
    echo 提取 arm64-v8a 的 native 库...
    powershell -Command "Expand-Archive -Path app\libs\cfdata-arm64.aar -DestinationPath app\libs\temp-arm64 -Force" 2>nul
    if exist "app\libs\temp-arm64\jni\arm64-v8a" (
        xcopy /E /I /Y app\libs\temp-arm64\jni\arm64-v8a app\src\main\jniLibs\arm64-v8a\ >nul
    )
    rmdir /S /Q app\libs\temp-arm64 2>nul
)

REM 提取 arm
if exist "app\libs\cfdata-arm.aar" (
    echo 提取 armeabi-v7a 的 native 库...
    powershell -Command "Expand-Archive -Path app\libs\cfdata-arm.aar -DestinationPath app\libs\temp-arm -Force" 2>nul
    if exist "app\libs\temp-arm\jni\armeabi-v7a" (
        xcopy /E /I /Y app\libs\temp-arm\jni\armeabi-v7a app\src\main\jniLibs\armeabi-v7a\ >nul
    )
    rmdir /S /Q app\libs\temp-arm 2>nul
)

REM 提取 x86
if exist "app\libs\cfdata-386.aar" (
    echo 提取 x86 的 native 库...
    powershell -Command "Expand-Archive -Path app\libs\cfdata-386.aar -DestinationPath app\libs\temp-386 -Force" 2>nul
    if exist "app\libs\temp-386\jni\x86" (
        xcopy /E /I /Y app\libs\temp-386\jni\x86 app\src\main\jniLibs\x86\ >nul
    )
    rmdir /S /Q app\libs\temp-386 2>nul
)

REM 提取 x86_64
if exist "app\libs\cfdata-amd64.aar" (
    echo 提取 x86_64 的 native 库...
    powershell -Command "Expand-Archive -Path app\libs\cfdata-amd64.aar -DestinationPath app\libs\temp-amd64 -Force" 2>nul
    if exist "app\libs\temp-amd64\jni\x86_64" (
        xcopy /E /I /Y app\libs\temp-amd64\jni\x86_64 app\src\main\jniLibs\x86_64\ >nul
    )
    rmdir /S /Q app\libs\temp-amd64 2>nul
)

REM 检查是否安装了 Android SDK
if "%ANDROID_HOME%"=="" (
    echo.
    echo 警告: ANDROID_HOME 未设置
    echo 请设置 ANDROID_HOME 环境变量指向 Android SDK 路径
    echo 然后运行: gradlew.bat assembleRelease
    exit /b 0
)

REM 构建 APK
echo.
echo 开始构建 APK...
call gradlew.bat clean assembleRelease

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo 构建成功！
    echo APK 位置: app\build\outputs\apk\release\app-release.apk
    echo ==========================================
) else (
    echo.
    echo 构建失败，请检查错误信息
    exit /b 1
)

