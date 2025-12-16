#!/bin/bash
# 自动提交并推送到GitHub

set -e

echo "=========================================="
echo "自动提交并推送到GitHub"
echo "=========================================="

# 检查是否有变更
if [ -z "$(git status --porcelain)" ]; then
    echo "没有文件变更，跳过提交"
    exit 0
fi

# 获取变更的文件（排除README.md和.md文件）
CHANGED_FILES=$(git diff --name-only HEAD | grep -v "README.md" | grep -v "\.md$" || true)

if [ -z "$CHANGED_FILES" ]; then
    echo "只有文档文件变更，跳过提交（README.md和.md文件被忽略）"
    exit 0
fi

# 添加所有变更
git add .

# 生成提交信息
DATE=$(date +'%Y-%m-%d %H:%M:%S')
COMMIT_MSG="自动更新: $DATE

变更文件:
$(echo "$CHANGED_FILES" | head -10)

[自动提交]"

# 提交
git commit -m "$COMMIT_MSG" || {
    echo "提交失败，可能没有变更需要提交"
    exit 0
}

# 强制推送到GitHub
echo "推送到GitHub..."
git push -f origin main

echo "=========================================="
echo "完成！代码已推送到GitHub"
echo "GitHub Actions将自动触发构建"
echo "=========================================="

