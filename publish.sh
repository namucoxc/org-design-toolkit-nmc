#!/bin/bash
# ============================================================
# org-design-toolkit 一键发布脚本
# 用途：在 macOS 上把当前目录发布到您的 GitHub 个人账号下
# 仓库名：org-design-toolkit-nmc（public）
# 动作：git init → commit → 创建 GitHub repo → push → 打 v2.0.6 tag
# ============================================================
set -e

# === 配置 ===
REPO_NAME="org-design-toolkit-nmc"
REPO_VISIBILITY="public"
REPO_DESCRIPTION="组织设计交付物生成器 · Claude AI Skill · 5 分钟产出 8 份交付件"
TAG="v2.0.6"
TAG_MESSAGE="v2.0.6 企业名保护协议（RAG 案例企业名/细分行业专属名词不外泄到执行与输出）"
COMMIT_MESSAGE="feat: v2.0.6 企业名保护协议"

# === 颜色 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

step() { echo ""; echo -e "${BLUE}━━━ $1 ━━━${NC}"; }
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
err()  { echo -e "${RED}✗ $1${NC}"; }

# === 当前目录检测 ===
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

step "0/7 · 环境检测"

# 检查是否在正确目录
if [ ! -f "SKILL.md" ] || [ ! -f "README.md" ]; then
  err "未在 skill 源码目录下运行。请进入 org-design-toolkit-public 目录后重新执行。"
  exit 1
fi
ok "目录正确：$HERE"

# 检查 git
if ! command -v git &>/dev/null; then
  err "未检测到 git。请先安装：brew install git"
  exit 1
fi
ok "git 已安装：$(git --version)"

# 检查 gh CLI
if ! command -v gh &>/dev/null; then
  warn "未检测到 GitHub CLI (gh)"
  echo "正在尝试用 brew 安装……"
  if command -v brew &>/dev/null; then
    brew install gh
  else
    err "未检测到 Homebrew。请手动安装 gh:"
    err "  访问 https://cli.github.com/  或运行："
    err "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    err "  brew install gh"
    exit 1
  fi
fi
ok "gh CLI 已安装：$(gh --version | head -1)"

# === 1. gh 登录 ===
step "1/7 · GitHub 登录检测"

if gh auth status &>/dev/null; then
  GH_USER=$(gh api user --jq .login)
  ok "已登录为：$GH_USER"
else
  warn "未登录 GitHub CLI"
  echo "即将开始登录流程……"
  echo "提示：选择 GitHub.com → HTTPS → 用浏览器登录"
  read -p "回车继续 (Ctrl+C 取消)" _
  gh auth login
  GH_USER=$(gh api user --jq .login)
  ok "登录成功：$GH_USER"
fi

# === 2. 检查仓库是否已存在 ===
step "2/7 · 检查仓库是否已存在"

if gh repo view "$GH_USER/$REPO_NAME" &>/dev/null; then
  warn "仓库 $GH_USER/$REPO_NAME 已存在"
  read -p "是否继续推送到已有仓库？(y/N) " ans
  if [[ ! "$ans" =~ ^[Yy]$ ]]; then
    err "用户取消"
    exit 1
  fi
  REPO_EXISTS=1
else
  ok "仓库 $GH_USER/$REPO_NAME 不存在，将创建"
  REPO_EXISTS=0
fi

# === 3. 初始化 git ===
step "3/7 · 初始化 git 仓库"

if [ -d ".git" ]; then
  warn "已存在 .git 目录"
  read -p "是否清理后重新初始化？(y/N) " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    rm -rf .git
    ok "已清理旧 .git"
  fi
fi

if [ ! -d ".git" ]; then
  git init -q
  ok "git init 完成"
fi

git checkout -q -B main
ok "切换到 main 分支"

# 配置 user.name / user.email（如未配置）
if ! git config user.email &>/dev/null; then
  USER_EMAIL=$(gh api user --jq .email 2>/dev/null || echo "")
  if [ -z "$USER_EMAIL" ] || [ "$USER_EMAIL" = "null" ]; then
    USER_EMAIL="${GH_USER}@users.noreply.github.com"
  fi
  git config user.email "$USER_EMAIL"
  git config user.name "$GH_USER"
  ok "已配置 git user: $GH_USER <$USER_EMAIL>"
fi

# === 4. 添加并提交 ===
step "4/7 · 提交代码"

git add .
ok "添加全部文件"

# 检查是否有改动
if git diff --cached --quiet; then
  warn "无文件改动可提交"
else
  git commit -q -m "$COMMIT_MESSAGE"
  ok "已提交：$COMMIT_MESSAGE"
fi

# === 5. 创建 / 配置远程仓库 ===
step "5/7 · 创建/配置远程仓库"

if [ "$REPO_EXISTS" = "0" ]; then
  gh repo create "$REPO_NAME" \
    --"$REPO_VISIBILITY" \
    --description "$REPO_DESCRIPTION" \
    --source=. \
    --remote=origin \
    --push=false
  ok "已创建仓库：https://github.com/$GH_USER/$REPO_NAME"
else
  if ! git remote get-url origin &>/dev/null; then
    git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
    ok "已添加远程仓库"
  else
    ok "远程仓库已配置：$(git remote get-url origin)"
  fi
fi

# === 6. 推送代码 ===
step "6/7 · 推送代码到 GitHub"

# 用 --force-with-lease：本地是 rm -rf .git 重新初始化的孤立快照，无远程祖先。
# --force-with-lease 比 --force 安全：若远程被他人推过则拒绝。
git push -u origin main --force-with-lease
ok "代码已推送"

# === 7. 打 tag ===
step "7/7 · 打 $TAG tag"

if git rev-parse "$TAG" &>/dev/null; then
  warn "tag $TAG 已存在"
else
  git tag -a "$TAG" -m "$TAG_MESSAGE"
  ok "已创建本地 tag $TAG"
fi

git push origin "$TAG"
ok "tag 已推送到远程"

# === 完成 ===
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ 发布完成！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  仓库地址:  https://github.com/$GH_USER/$REPO_NAME"
echo "  Tag 地址:  https://github.com/$GH_USER/$REPO_NAME/releases/tag/$TAG"
echo ""
echo "  下一步建议（可选）："
echo ""
echo "  1) 打开仓库，添加 topics 标签便于发现："
echo "     $ gh repo edit --add-topic claude-skill,org-design,raci,consulting,ai-tools,chinese"
echo ""
echo "  2) 发布 GitHub Release："
echo "     $ gh release create $TAG --title 'v2.0.6 企业名保护协议' --notes-from-tag"
echo ""
echo "  3) 上传 v2.0.6 .zip 包附件："
echo "     $ gh release upload $TAG ../org-design-toolkit-v2.0.6-public.zip"
echo ""
