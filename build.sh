#!/bin/bash

# CF-Data Android APK 构建脚本
# 支持多种Android架构

set -e

echo "=========================================="
echo "CF-Data Android APK 构建脚本"
echo "=========================================="

# 检查是否安装了必要的工具
command -v gomobile >/dev/null 2>&1 || { echo "错误: 需要安装 gomobile. 运行: go install golang.org/x/mobile/cmd/gomobile@latest"; exit 1; }
command -v go >/dev/null 2>&1 || { echo "错误: 需要安装 Go"; exit 1; }

# 初始化 gomobile
echo "初始化 gomobile..."
gomobile init || true

# 创建输出目录
mkdir -p app/libs
mkdir -p app/src/main/jniLibs

# 支持的架构
ARCHS=("arm64" "arm" "386" "amd64")
ARCH_NAMES=("arm64-v8a" "armeabi-v7a" "x86" "x86_64")

echo ""
echo "开始编译 Go 库..."

# 编译各个架构的库
for i in "${!ARCHS[@]}"; do
    ARCH=${ARCHS[$i]}
    ARCH_NAME=${ARCH_NAMES[$i]}
    echo "编译架构: $ARCH_NAME ($ARCH)"
    
    # 编译 AAR
    gomobile bind -target=android/$ARCH -o app/libs/cfdata-$ARCH.aar ./cfdata || {
        echo "警告: 架构 $ARCH 编译失败，跳过..."
        continue
    }
done

# 合并所有架构到一个AAR（如果需要）
echo ""
echo "合并架构..."

# 创建通用AAR（使用arm64作为主要架构，其他架构的so文件需要手动合并）
if [ -f "app/libs/cfdata-arm64.aar" ]; then
    cp app/libs/cfdata-arm64.aar app/libs/cfdata.aar
    echo "使用 arm64 作为主要架构"
fi

# 提取并合并所有架构的so文件
echo "提取 native 库..."
for i in "${!ARCHS[@]}"; do
    ARCH=${ARCHS[$i]}
    ARCH_NAME=${ARCH_NAMES[$i]}
    
    if [ -f "app/libs/cfdata-$ARCH.aar" ]; then
        echo "提取 $ARCH_NAME 的 native 库..."
        unzip -q -o app/libs/cfdata-$ARCH.aar -d app/libs/temp-$ARCH/ || true
        
        if [ -d "app/libs/temp-$ARCH/jni/$ARCH_NAME" ]; then
            mkdir -p app/src/main/jniLibs/$ARCH_NAME
            cp -r app/libs/temp-$ARCH/jni/$ARCH_NAME/* app/src/main/jniLibs/$ARCH_NAME/ || true
        fi
        
        rm -rf app/libs/temp-$ARCH
    fi
done

# 检查是否安装了 Android SDK
if [ -z "$ANDROID_HOME" ]; then
    echo ""
    echo "警告: ANDROID_HOME 未设置"
    echo "请设置 ANDROID_HOME 环境变量指向 Android SDK 路径"
    echo "然后运行: ./gradlew assembleRelease"
    exit 0
fi

# 构建 APK
echo ""
echo "开始构建 APK..."
./gradlew clean assembleRelease

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "构建成功！"
    echo "APK 位置: app/build/outputs/apk/release/app-release.apk"
    echo "=========================================="
else
    echo ""
    echo "构建失败，请检查错误信息"
    exit 1
fi

