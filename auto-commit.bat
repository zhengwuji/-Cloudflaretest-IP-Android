@echo off
REM 自动提交并推送到GitHub (Windows)

echo ==========================================
echo 自动提交并推送到GitHub
echo ==========================================

REM 检查是否有变更
git status --porcelain >nul 2>&1
if %errorlevel% neq 0 (
    echo 没有文件变更，跳过提交
    exit /b 0
)

REM 添加所有变更
git add .

REM 生成提交信息
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set datetime=%%a
set DATE=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2% %datetime:~8,2%:%datetime:~10,2%:%datetime:~12,2%

REM 提交
git commit -m "自动更新: %DATE%^
^
[自动提交]" || (
    echo 提交失败，可能没有变更需要提交
    exit /b 0
)

REM 强制推送到GitHub
echo 推送到GitHub...
git push -f origin main

echo ==========================================
echo 完成！代码已推送到GitHub
echo GitHub Actions将自动触发构建
echo ==========================================

