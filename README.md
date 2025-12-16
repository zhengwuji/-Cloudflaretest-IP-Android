# Cloudflare IP 测速工具 (Android)

一个用于扫描 Cloudflare IP、测试延迟和下载速度的 Android 应用程序。

## ✨ 功能特性

- ✅ **IP扫描和延迟测试** - 快速扫描 Cloudflare IPv4/IPv6 地址
- ✅ **下载速度测试** - 测试实际下载速度
- ✅ **最低下载速度过滤** - 过滤低于指定速度的 IP
- ✅ **自定义测速URL** - 支持自定义测速地址
- ✅ **自定义测速结果数量** - 控制返回结果数量
- ✅ **实时显示测速结果** - 扫描结果页面实时显示下载速度
- ✅ **多架构支持** - 支持 arm64-v8a、armeabi-v7a、x86、x86_64 和 universal 版本

## 🏗️ 技术架构

### 后端 (Go)
- **语言**: Go 1.21+
- **核心库**: `cfdata.go` - 使用 `gomobile bind` 编译为 Android AAR 库
- **WebSocket**: 实时通信，支持扫描进度、测试结果推送
- **并发扫描**: 多线程 IP 扫描和延迟测试
- **嵌入资源**: 使用 `embed.FS` 嵌入 `index.html` 静态文件

### 前端 (Android)
- **语言**: Kotlin
- **UI**: WebView 加载嵌入式 HTML 界面
- **通信**: WebSocket 与 Go 后端实时通信
- **多架构**: 支持 ARM、x86 等多种架构

## 📦 自动构建流程

项目使用 GitHub Actions 实现自动化构建和发布：

### 工作流 1: 自动构建检查 (`auto-build.yml`)
- **触发条件**: Push 到 main/master 分支（忽略 .md 文件）
- **功能**: 检查代码变更

### 工作流 2: 构建并发布 APK (`build-and-release.yml`)
- **触发条件**: 
  - Push 到 main/master 分支（忽略 .md 文件）
  - 手动触发 (workflow_dispatch)
  
- **构建步骤**:
  1. 安装 Go 1.21 环境
  2. 安装 `gomobile` 工具
  3. 配置 Java 17 和 Android SDK
  4. 编译多架构 Go 库（arm64、arm、x86、x86_64）
  5. 提取 Native 库到 `jniLibs`
  6. 生成签名密钥库
  7. 使用 Gradle 构建 APK
  8. 创建 GitHub Release 并上传所有 APK 文件

- **生成的 APK 文件**:
  - `com.cfdata-arm64-v8a-release.apk` - 适用于现代 64 位 ARM 设备 (推荐)
  - `com.cfdata-armeabi-v7a-release.apk` - 适用于 32 位 ARM 设备
  - `com.cfdata-x86-release.apk` - 适用于 x86 模拟器和设备
  - `com.cfdata-x86_64-release.apk` - 适用于 64 位 x86 设备
  - `com.cfdata-universal-release.apk` - 通用版本（包含所有架构，体积较大）

## 🚀 安装说明

1. 前往 [Releases](../../releases) 页面
2. 下载对应设备架构的 APK 文件（不确定可下载 universal 版本）
3. 在设备上允许安装未知来源应用
4. 安装并运行

## 🛠️ 本地开发

### 前置要求
- Go 1.21+
- Java 17
- Android SDK (API 34)
- Android NDK 25.1.8937393
- Gradle 8.5+

### 编译步骤

1. **安装 gomobile**
```bash
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
```

2. **编译 Go 库**
```bash
# 编译 arm64-v8a
gomobile bind -target=android/arm64 -androidapi=21 -o app/libs/cfdata-arm64.aar .

# 编译 armeabi-v7a
gomobile bind -target=android/arm -androidapi=21 -o app/libs/cfdata-arm.aar .

# 编译 x86
gomobile bind -target=android/386 -androidapi=21 -o app/libs/cfdata-x86.aar .

# 编译 x86_64
gomobile bind -target=android/amd64 -androidapi=21 -o app/libs/cfdata-x86_64.aar .
```

3. **提取 Native 库**
```bash
mkdir -p app/src/main/jniLibs
unzip -q -o app/libs/cfdata-arm64.aar -d app/libs/temp-arm64/
cp -r app/libs/temp-arm64/jni/arm64-v8a app/src/main/jniLibs/
# ... 重复其他架构
```

4. **构建 APK**
```bash
./gradlew clean assembleRelease
```

## 📄 配置文件说明

- **`antigravity规则.yaml`** - Antigravity AI 助手配置
- **`.github/workflows/auto-build.yml`** - 自动构建检查工作流
- **`.github/workflows/build-and-release.yml`** - APK 构建和发布工作流
- **`build.gradle`** - 项目级 Gradle 配置
- **`cfdata.go`** - Go 核心代码（IP 扫描、延迟测试、速度测试）
- **`index.html`** - 嵌入式 Web UI

## 📝 使用说明

1. 打开应用
2. 选择 IP 类型（IPv4/IPv6）
3. 设置扫描线程数
4. 点击"开始扫描"
5. 选择数据中心进行详细测试
6. 查看测速结果并复制优选 IP

## ⚙️ 自定义配置

应用支持以下自定义选项：
- 测速 URL
- 扫描线程数
- 端口号
- 延迟阈值
- 最低下载速度
- 最大结果数量

## 🔒 签名说明

自动构建使用临时生成的密钥库进行签名，参数如下：
- **Keystore**: `app/release.keystore`
- **Alias**: `cfdata`
- **Password**: `cfdata123456`

⚠️ **生产环境请使用安全的密钥库！**

## 📊 数据来源

- **IP 列表**: `https://www.baipiao.eu.org/cloudflare/ips-v4` / `ips-v6`
- **位置信息**: `https://www.baipiao.eu.org/cloudflare/locations`

## 📜 许可证

本项目仅供学习和研究使用。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**注意**: 本项目会在每次 push 到 main/master 分支时自动触发构建和发布流程（.md 文件除外）。
