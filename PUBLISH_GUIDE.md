# 一键发布到 GitHub · 操作指南

> 把当前 `org-design-toolkit-public/` 目录发布到您的 GitHub 个人账号下，仓库名 `org-design-toolkit-nmc`，public 可见。

---

## 一、最快路径（一行命令）

打开 macOS Terminal，复制并执行：

```bash
cd ~/your-project-path/org-design-toolkit/ && bash publish.sh
```

脚本会自动完成 7 步：

| 步骤 | 动作 |
|---|---|
| 0/7 | 检测 git + gh CLI 是否安装（缺则尝试用 brew 自动安装） |
| 1/7 | 检测 GitHub CLI 是否已登录（未登录则引导浏览器登录） |
| 2/7 | 检查仓库是否已存在 |
| 3/7 | git init + 切换到 main 分支 + 配置 git user |
| 4/7 | git add + commit（信息："feat: initial release v2.0.2"） |
| 5/7 | 创建远程仓库（public）|
| 6/7 | push 代码 |
| 7/7 | 打 v2.0.2 tag 并推送 |

---

## 二、首次使用前的准备（如果还没装 gh CLI）

### 2.1 检查 gh CLI 是否已安装

```bash
gh --version
```

如果显示版本号，跳到 2.3 直接登录。

### 2.2 安装 gh CLI

publish.sh 会自动尝试用 brew 安装。如果失败，手动安装：

```bash
# 用 Homebrew 安装
brew install gh
```

如果没装 Homebrew，先装 Homebrew：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2.3 登录 GitHub CLI（首次）

```bash
gh auth login
```

按提示选择：

- `What account do you want to log into?` → **GitHub.com**
- `What is your preferred protocol for Git operations?` → **HTTPS**
- `Authenticate Git with your GitHub credentials?` → **Yes**
- `How would you like to authenticate GitHub CLI?` → **Login with a web browser**

复制屏幕上显示的 6 位代码，按回车，浏览器会自动打开。输入代码并授权即可。

publish.sh 也会在第 1/7 步自动检测并引导登录，如果您没提前装也可以让脚本帮您处理。

---

## 三、运行示意

```
$ bash publish.sh

━━━ 0/7 · 环境检测 ━━━
✓ 目录正确：/Users/user/.../org-design-toolkit-public
✓ git 已安装：git version 2.42.0
✓ gh CLI 已安装：gh version 2.40.0

━━━ 1/7 · GitHub 登录检测 ━━━
✓ 已登录为：nmc1029

━━━ 2/7 · 检查仓库是否已存在 ━━━
✓ 仓库 nmc1029/org-design-toolkit-nmc 不存在，将创建

━━━ 3/7 · 初始化 git 仓库 ━━━
✓ git init 完成
✓ 切换到 main 分支
✓ 已配置 git user: nmc1029 <nmc1029@gmail.com>

━━━ 4/7 · 提交代码 ━━━
✓ 添加全部文件
✓ 已提交：feat: initial release v2.0.2

━━━ 5/7 · 创建/配置远程仓库 ━━━
✓ 已创建仓库：https://github.com/nmc1029/org-design-toolkit-nmc

━━━ 6/7 · 推送代码到 GitHub ━━━
Enumerating objects: 33, done.
Counting objects: 100% (33/33), done.
Delta compression using up to 8 threads
Compressing objects: 100% (28/28), done.
Writing objects: 100% (33/33), 28.10 KiB | 5.62 MiB/s, done.
To https://github.com/nmc1029/org-design-toolkit-nmc.git
 * [new branch]      main -> main
✓ 代码已推送

━━━ 7/7 · 打 v2.0.2 tag ━━━
✓ 已创建本地 tag v2.0.2
✓ tag 已推送到远程

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ 发布完成！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  仓库地址:  https://github.com/nmc1029/org-design-toolkit-nmc
  Tag 地址:  https://github.com/nmc1029/org-design-toolkit-nmc/releases/tag/v2.0.2

  下一步建议（可选）：

  1) 打开仓库，添加 topics 标签便于发现：
     $ gh repo edit --add-topic claude-skill,org-design,raci,consulting,ai-tools,chinese

  2) 发布 GitHub Release：
     $ gh release create v2.0.2 --title 'v2.0.2 推广运营增强版' --notes-from-tag

  3) 上传 v2.0.2 .zip 包附件：
     $ gh release upload v2.0.2 ../org-design-toolkit-v2.0.2-public.zip
```

---

## 四、常见问题

### Q1：仓库名能不能改？

可以。编辑 publish.sh 第 8 行 `REPO_NAME="org-design-toolkit-nmc"`，改成您想要的名字（不能有空格，可以用 `-` 或 `_`）。

### Q2：能不能改成 private？

可以。编辑 publish.sh 第 9 行 `REPO_VISIBILITY="public"`，改为 `private`。

### Q3：发布失败怎么办？

最常见的失败原因：

| 错误 | 解决 |
|---|---|
| `gh: command not found` | 装 gh CLI：`brew install gh` |
| `error: failed to push some refs` | 仓库已有内容，先 `git pull` 或删仓库重来 |
| `authentication failed` | `gh auth login` 重新登录 |
| `remote already exists` | `git remote remove origin` 后重试 |

### Q4：想回滚怎么办？

如果发布后想撤销：

```bash
# 删除远程仓库（不可恢复）
gh repo delete nmc1029/org-design-toolkit-nmc

# 或者只删 tag
git push --delete origin v2.0.2
git tag -d v2.0.2
```

### Q5：怎么后续更新代码？

```bash
cd ~/your-project-path/org-design-toolkit/
git add .
git commit -m "fix: 修复 xxx"
git push
```

升版本时打新 tag：

```bash
git tag -a v2.0.3 -m "v2.0.3 内容描述"
git push origin v2.0.3
```

---

## 五、发布后的 3 个推广动作（可选）

发布完成后，建议立刻做这 3 件事，提升项目能见度：

### 5.1 加 topics 标签（让其他咨询师能搜到）

```bash
gh repo edit nmc1029/org-design-toolkit-nmc --add-topic claude-skill,org-design,raci,consulting,ai-tools,chinese,china
```

### 5.2 创建 Release（让用户直接下载 .zip）

```bash
gh release create v2.0.2 \
  --title "v2.0.2 推广运营增强版" \
  --notes-file CHANGELOG.md
```

如果想要 .zip 附件：

```bash
gh release upload v2.0.2 \
  ~/your-project-path/org-design-toolkit-v2.0.2-public.zip
```

### 5.3 在 README.md 加 Star 引导

打开 `README.md` 顶部，在 badges 那行后面加：

```markdown
⭐ 如果对您的咨询工作有帮助，欢迎 star + fork + 贡献子行业模板
```

---

## 六、版本

- v1.0（2026-05-13）：首版 publish.sh + 操作指南
