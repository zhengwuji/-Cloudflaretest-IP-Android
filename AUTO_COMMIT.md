# 自动提交和推送说明

## 功能说明

项目已配置自动提交和推送功能，当代码发生变更时会自动推送到GitHub，并触发GitHub Actions自动构建和发布。

## 自动推送规则

- ✅ **代码文件变更**: 自动提交并推送
- ❌ **README.md变更**: 忽略，不触发自动推送
- ❌ **其他.md文件变更**: 忽略，不触发自动推送

## 使用方法

### 方法1: Git Hook（自动）

已配置Git post-commit hook，每次`git commit`后会自动推送到GitHub。

**注意**: Git hook只在本地仓库有效，如果从其他机器克隆，需要重新设置。

### 方法2: 手动运行脚本

#### Windows:
```cmd
auto-commit.bat
```

#### Linux/macOS:
```bash
chmod +x auto-commit.sh
./auto-commit.sh
```

### 方法3: 手动推送

```bash
git add .
git commit -m "你的提交信息"
git push -f origin main
```

## GitHub Actions 自动构建

当代码推送到GitHub后，会自动触发以下流程：

1. ✅ 检测代码变更（排除README.md和.md文件）
2. ✅ 设置构建环境（Go, Java, Android SDK）
3. ✅ 编译Go库为AAR（多架构）
4. ✅ 构建Android APK
5. ✅ 自动创建GitHub Release
6. ✅ 上传APK到Release

## Release 信息

每次构建完成后会自动创建Release，包含：

- **标签**: `v{构建编号}-{提交哈希}`
- **标题**: `版本 v{构建编号} - {日期时间}`
- **更新日志**: 
  - 更新日期
  - 提交信息
  - 构建编号
  - 提交哈希
  - 功能特性列表

## 注意事项

1. **强制推送**: 使用`git push -f`强制推送，会覆盖远程分支
2. **构建时间**: GitHub Actions构建通常需要5-10分钟
3. **构建状态**: 可以在GitHub仓库的Actions标签页查看构建状态
4. **Release**: APK会自动上传到Releases页面

## 禁用自动推送

如果需要禁用自动推送，可以：

1. 删除或重命名`.git/hooks/post-commit`文件
2. 手动提交时使用`git commit --no-verify`跳过hook

## 故障排除

### Hook不执行
- 检查`.git/hooks/post-commit`文件是否存在且有执行权限
- Linux/macOS: `chmod +x .git/hooks/post-commit`

### 推送失败
- 检查GitHub仓库权限
- 检查网络连接
- 查看Git错误信息

### 构建失败
- 查看GitHub Actions日志
- 检查代码是否有语法错误
- 确认依赖是否正确配置

