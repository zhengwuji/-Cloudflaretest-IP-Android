# 构建说明

## 快速开始

### Windows

1. 确保已安装 Go 和 Android SDK
2. 运行构建脚本：
```cmd
build.bat
```

### Linux/macOS

1. 确保已安装 Go 和 Android SDK
2. 运行构建脚本：
```bash
chmod +x build.sh
./build.sh
```

## 详细步骤

### 1. 准备环境

#### 安装 Go
- 下载: https://golang.org/dl/
- 安装后设置 GOPATH 和 PATH

#### 安装 gomobile
```bash
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
```

#### 安装 Android SDK
- 下载 Android Studio: https://developer.android.com/studio
- 安装 Android SDK Platform 34
- 安装 Android NDK
- 设置环境变量 ANDROID_HOME

### 2. 编译 Go 库

#### 单架构编译（推荐，仅 arm64）
```bash
gomobile bind -target=android/arm64 -o app/libs/cfdata.aar ./cfdata
```

#### 多架构编译（支持所有设备）
```bash
# arm64 (64位 ARM，大多数现代设备)
gomobile bind -target=android/arm64 -o app/libs/cfdata-arm64.aar ./cfdata

# arm (32位 ARM)
gomobile bind -target=android/arm -o app/libs/cfdata-arm.aar ./cfdata

# x86 (32位 Intel)
gomobile bind -target=android/386 -o app/libs/cfdata-386.aar ./cfdata

# x86_64 (64位 Intel)
gomobile bind -target=android/amd64 -o app/libs/cfdata-amd64.aar ./cfdata
```

### 3. 提取 Native 库（多架构）

如果编译了多个架构，需要提取 `.so` 文件：

#### Windows
```cmd
# 提取 arm64
powershell Expand-Archive -Path app\libs\cfdata-arm64.aar -DestinationPath app\libs\temp-arm64 -Force
xcopy /E /I /Y app\libs\temp-arm64\jni\arm64-v8a app\src\main\jniLibs\arm64-v8a\
rmdir /S /Q app\libs\temp-arm64

# 提取 arm
powershell Expand-Archive -Path app\libs\cfdata-arm.aar -DestinationPath app\libs\temp-arm -Force
xcopy /E /I /Y app\libs\temp-arm\jni\armeabi-v7a app\src\main\jniLibs\armeabi-v7a\
rmdir /S /Q app\libs\temp-arm

# 提取 x86
powershell Expand-Archive -Path app\libs\cfdata-386.aar -DestinationPath app\libs\temp-386 -Force
xcopy /E /I /Y app\libs\temp-386\jni\x86 app\src\main\jniLibs\x86\
rmdir /S /Q app\libs\temp-386

# 提取 x86_64
powershell Expand-Archive -Path app\libs\cfdata-amd64.aar -DestinationPath app\libs\temp-amd64 -Force
xcopy /E /I /Y app\libs\temp-amd64\jni\x86_64 app\src\main\jniLibs\x86_64\
rmdir /S /Q app\libs\temp-amd64
```

#### Linux/macOS
```bash
# 提取 arm64
unzip -q -o app/libs/cfdata-arm64.aar -d app/libs/temp-arm64/
cp -r app/libs/temp-arm64/jni/arm64-v8a app/src/main/jniLibs/
rm -rf app/libs/temp-arm64

# 提取 arm
unzip -q -o app/libs/cfdata-arm.aar -d app/libs/temp-arm/
cp -r app/libs/temp-arm/jni/armeabi-v7a app/src/main/jniLibs/
rm -rf app/libs/temp-arm

# 提取 x86
unzip -q -o app/libs/cfdata-386.aar -d app/libs/temp-386/
cp -r app/libs/temp-386/jni/x86 app/src/main/jniLibs/
rm -rf app/libs/temp-386

# 提取 x86_64
unzip -q -o app/libs/cfdata-amd64.aar -d app/libs/temp-amd64/
cp -r app/libs/temp-amd64/jni/x86_64 app/src/main/jniLibs/
rm -rf app/libs/temp-amd64
```

### 4. 构建 APK

#### 使用 Gradle Wrapper
```bash
# Windows
gradlew.bat assembleRelease

# Linux/macOS
./gradlew assembleRelease
```

#### 使用本地 Gradle
```bash
gradle assembleRelease
```

### 5. 安装 APK

生成的 APK 位于：
- `app/build/outputs/apk/release/app-release.apk`

安装到设备：
```bash
adb install app/build/outputs/apk/release/app-release.apk
```

## 常见问题

### 问题：gomobile 命令未找到
**解决**: 确保 Go bin 目录在 PATH 中，或使用完整路径：
```bash
$GOPATH/bin/gomobile bind ...
```

### 问题：ANDROID_HOME 未设置
**解决**: 设置环境变量：
```bash
# Windows
set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk

# Linux/macOS
export ANDROID_HOME=$HOME/Android/Sdk
```

### 问题：编译失败，找不到 Android SDK
**解决**: 
1. 检查 ANDROID_HOME 环境变量
2. 确保已安装 Android SDK Platform 34
3. 在 `local.properties` 文件中设置：
```properties
sdk.dir=C\:\\Users\\YourName\\AppData\\Local\\Android\\Sdk
```

### 问题：APK 安装失败
**解决**:
1. 确保设备允许安装未知来源应用
2. 卸载旧版本：`adb uninstall com.cfdata`
3. 检查设备架构是否支持

### 问题：运行时崩溃
**解决**:
1. 检查日志：`adb logcat | grep cfdata`
2. 确保所有 native 库都已正确打包
3. 检查设备架构匹配

## 优化建议

1. **仅编译需要的架构**: 如果只针对现代设备，只需编译 arm64
2. **使用 ProGuard**: 在 release 构建中启用代码混淆以减小 APK 大小
3. **签名 APK**: 使用密钥签名 APK 以便分发

