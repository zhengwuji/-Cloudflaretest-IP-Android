# CF-Data Android 应用

Cloudflare IP 扫描和测速工具，支持 Android 平台。

## 功能特性

- ✅ **IP扫描**: 扫描 Cloudflare IPv4/IPv6 地址
- ✅ **延迟测试**: 测试IP的延迟、丢包率
- ✅ **下载速度测试**: 测试IP的下载速度
- ✅ **最低速度过滤**: 设置最低下载速度要求，自动过滤不符合条件的IP
- ✅ **自定义测速URL**: 支持自定义测速服务器地址
- ✅ **多架构支持**: 支持 arm64-v8a, armeabi-v7a, x86, x86_64
- ✅ **兼容性**: 支持 Android 5.0 (API 21) 及以上版本

## 系统要求

### 开发环境

- Go 1.21 或更高版本
- Android SDK (API 34)
- Android NDK
- gomobile 工具
- Gradle 8.1+

### 运行环境

- Android 5.0 (API 21) 或更高版本
- 网络连接

## 安装依赖

### 1. 安装 Go

从 [golang.org](https://golang.org/dl/) 下载并安装 Go。

### 2. 安装 gomobile

```bash
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
```

### 3. 安装 Android SDK

1. 下载并安装 [Android Studio](https://developer.android.com/studio)
2. 通过 Android Studio SDK Manager 安装：
   - Android SDK Platform 34
   - Android SDK Build-Tools
   - Android NDK

### 4. 设置环境变量

**Windows:**
```cmd
set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
set PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools
```

**Linux/macOS:**
```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
```

## 构建 APK

### Windows

```cmd
build.bat
```

### Linux/macOS

```bash
chmod +x build.sh
./build.sh
```

### 手动构建

1. **编译 Go 库为 AAR:**

```bash
# 编译 arm64 (推荐，大多数现代设备)
gomobile bind -target=android/arm64 -o app/libs/cfdata.aar ./cfdata

# 如果需要支持所有架构，分别编译：
gomobile bind -target=android/arm64 -o app/libs/cfdata-arm64.aar ./cfdata
gomobile bind -target=android/arm -o app/libs/cfdata-arm.aar ./cfdata
gomobile bind -target=android/386 -o app/libs/cfdata-386.aar ./cfdata
gomobile bind -target=android/amd64 -o app/libs/cfdata-amd64.aar ./cfdata
```

2. **提取 native 库 (如果需要多架构支持):**

从各个 AAR 文件中提取 `.so` 文件到 `app/src/main/jniLibs/` 目录。

3. **构建 APK:**

```bash
./gradlew clean assembleRelease
```

生成的 APK 位于: `app/build/outputs/apk/release/app-release.apk`

## 项目结构

```
.
├── cfdata.go              # Go 后端服务代码
├── index.html             # WebView 前端界面
├── main/                  # Android 应用代码
│   ├── AndroidManifest.xml
│   ├── java/com/cfdata/
│   │   └── MainActivity.kt
│   └── res/               # 资源文件
├── app/                   # Android 应用模块
│   ├── build.gradle
│   └── libs/             # Go 编译的 AAR 库
├── build.gradle           # 项目级构建配置
├── settings.gradle
├── gradle.properties
├── build.sh              # Linux/macOS 构建脚本
└── build.bat             # Windows 构建脚本
```

## 使用说明

1. **扫描IP**: 选择IP类型（IPv4/IPv6），设置并发数和端口，点击"开始扫描与测试"
2. **选择数据中心**: 扫描完成后，在数据中心汇总中选择要测试的数据中心
3. **查看详细测试**: 切换到"详细测试"标签页查看延迟测试结果
4. **测速**: 点击"测速"按钮测试单个IP的下载速度
5. **过滤速度**: 在详细测试页面设置最低下载速度，点击"过滤"按钮
6. **自定义测速URL**: 在控制面板中修改"测速 URL"字段

## 功能说明

### 最低下载速度过滤

- 在控制面板设置"最低下载速度 (MB/s)"
- 在详细测试页面也可以设置过滤速度
- 设置为 0 表示不过滤
- 过滤后只显示满足速度要求的IP

### 自定义测速URL

- 默认使用: `speed.cloudflare.com/__down?bytes=100000000`
- 可以修改为其他测速服务器
- URL 格式: `域名/路径` 或完整 URL
- 设置会自动保存

## 兼容性

- **最低支持**: Android 5.0 (API 21)
- **目标版本**: Android 14 (API 34)
- **架构支持**: 
  - arm64-v8a (64位 ARM，大多数现代设备)
  - armeabi-v7a (32位 ARM)
  - x86 (32位 Intel)
  - x86_64 (64位 Intel)

## 故障排除

### 构建失败

1. 确保已安装所有依赖
2. 检查 `ANDROID_HOME` 环境变量
3. 确保 Go 版本 >= 1.21
4. 运行 `gomobile init` 初始化

### 运行时错误

1. 确保设备已连接网络
2. 检查应用权限（网络访问）
3. 查看日志输出

### APK 安装失败

1. 确保设备允许安装未知来源应用
2. 检查设备架构是否支持
3. 尝试卸载旧版本后重新安装

## 许可证

本项目仅供学习和研究使用。

## 更新日志

### v1.0.0
- 初始版本
- 支持 IP 扫描和延迟测试
- 支持下载速度测试
- 支持最低速度过滤
- 支持自定义测速URL
- 多架构支持

