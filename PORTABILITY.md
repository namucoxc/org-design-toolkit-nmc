# PORTABILITY.md · 跨 AI Agent / LLM 移植指南

> `org-design-toolkit` 虽然以 Claude Code Skill 标准格式（`SKILL.md` + frontmatter）打包，但**核心是与平台无关的方法论 + prompt 模板**。本文档说明如何将本工具移植到其他 AI Agent / 大模型平台。
>
> **设计原则**：本工具 90% 的价值在 `SKILL.md`（方法论） + `prompts/dialogue.md`（对话流程） + `references/*.md`（行业事项库），这些都是纯 markdown 文本，可被任何 LLM 解析。Claude 原生支持 frontmatter 触发机制；其他平台用各自的"指令注入 / system prompt / custom instructions"接入即可。

---

## 一、移植矩阵总览

| 目标平台 | 难度 | 接入方式 | 全功能保留度 |
|---|---|---|---|
| **Claude Code** ⭐原生 | ★ | Plugin / skills 目录 | 100% |
| **Claude Desktop** | ★ | Project Instructions | 95% |
| **Cursor** | ★★ | `.cursorrules` 文件 | 90% |
| **Cline / Continue** | ★★ | Custom instructions | 90% |
| **ChatGPT (GPTs)** | ★★★ | 自定义 GPT + Knowledge Files | 85% |
| **本地 LLM**（Ollama / LM Studio）| ★★★ | System prompt 注入 + RAG | 70% |
| **通用 Prompt**（任意 LLM 一次性使用）| ★ | 复制 SKILL.md + dialogue.md 到对话框 | 60% |

---

## 二、Claude Code（原生，最佳体验）

### 2.1 Plugin marketplace 安装

```bash
claude plugins install org-design-toolkit
```

### 2.2 手动放置到 skills 目录

```bash
git clone <repo-url> ~/.claude/skills/org-design-toolkit
# 重启 Claude Code
```

**保留 100% 功能**：frontmatter 自动触发、AskUserQuestion 多选交互、Glob RAG 扫描、自检 + 质量闸全套。

---

## 三、Claude Desktop（Project Instructions）

### 3.1 创建 Project

在 Claude Desktop 创建一个新 Project，命名 "组织设计工具箱"。

### 3.2 Project Instructions 注入

把 `SKILL.md` 主体（去掉 frontmatter）复制到 Project Instructions 中。

### 3.3 上传 Knowledge Files

把以下文件作为 Project 的 Knowledge：
- `prompts/dialogue.md`
- `references/*.md`（全部 8 个子行业模板）
- `TRIGGERS.md`
- 您的官方分工矩阵案例 .xlsx

### 3.4 使用

在 Project 内对话："做一份 [企业简称] 的分工矩阵和工作分析表"，Claude 会基于注入的方法论执行。

**保留 95%**：缺少 Glob 自动扫描，需要手动上传客户文件；其他功能完整。

---

## 四、Cursor

### 4.1 创建 .cursorrules

在项目根目录创建 `.cursorrules` 文件，内容为：

```
# .cursorrules · 组织设计工具箱

你是一位组织咨询师的 AI 副驾驶。当用户说"做分工矩阵 / 出工作分析表 / 组织设计交付"时，
按 .cursor/skill/SKILL.md 的方法论执行。

核心规则：
1. 启动时强制扫描项目根目录的 "分工矩阵*" / "组织设计*" 文件夹获取官方案例
2. 用 5 轮对话采集（详见 .cursor/skill/prompts/dialogue.md）
3. RACI 编码：部门级中文「主责/参与/监督」，岗位级 R/A/I
4. 矩阵每行必填「产出表单」列
5. 输出 8 份产物到 [工作目录]/[企业简称]/交付/[YYYYMM]/
```

### 4.2 把核心文件放到 `.cursor/skill/` 子目录

```bash
mkdir -p .cursor/skill
cp -r org-design-toolkit/{SKILL.md,prompts,references,TRIGGERS.md} .cursor/skill/
```

### 4.3 使用

在 Cursor Chat 里说："做一份 XX 的分工矩阵"，Cursor 会基于 `.cursorrules` 自动响应。

**保留 90%**：Cursor 不支持多选 AskUserQuestion 交互，可用纯文本问答替代。

---

## 五、Cline / Continue（VS Code 插件）

类似 Cursor：

### 5.1 Custom Instructions

把 `SKILL.md` 主体粘贴到 Cline 的 Custom Instructions 设置中。

### 5.2 项目 README 引用

在项目根目录的 `README.md` 顶部加：

```
> 本项目使用 org-design-toolkit 组织设计工具箱。详见 ./skill-bundle/SKILL.md
```

把 skill 文件放到 `./skill-bundle/`。

**保留 90%**。

---

## 六、ChatGPT（自定义 GPT / Custom GPT）

### 6.1 创建 Custom GPT

1. ChatGPT → 我的 GPTs → 创建 GPT
2. 名称：组织设计工具箱
3. 头像 / 简介自定义
4. **Instructions 字段**：复制 `SKILL.md` 主体

### 6.2 Knowledge Files 上传

上传以下文件作为 Knowledge：
- `prompts/dialogue.md`
- `references/*.md`（8 个子行业模板）
- `TRIGGERS.md`
- 您的官方分工矩阵案例 .xlsx

### 6.3 Capabilities

开启：
- ✅ Code Interpreter（用于读 xlsx + 生成 xlsx）
- ✅ File search（RAG 检索 Knowledge）

### 6.4 使用

发布为 Private GPT，对话使用。

**保留 85%**：
- ✅ 完整方法论
- ✅ 文件读取 / 生成
- ⚠️ 不支持 Glob 自动扫描，需手动上传客户文件
- ⚠️ 不支持 AskUserQuestion 多选，改为纯文本问答

---

## 七、本地 LLM（Ollama / LM Studio）

### 7.1 System Prompt 注入

把 `SKILL.md` 主体（10-15 KB）作为系统提示词。

注意：本地 LLM 上下文窗口需 ≥16K，建议用：
- Qwen2.5 32B 及以上
- Llama 3.3 70B
- DeepSeek V2.5

### 7.2 RAG 工具链

需自建 RAG 流程：
1. `references/*.md` 向量化
2. 客户既有材料向量化
3. 启动时检索相关 chunk 注入上下文

推荐工具：
- LangChain
- LlamaIndex
- Open WebUI（自带 RAG）

### 7.3 文件生成

需自建工具调用层：
- Python openpyxl 生成 xlsx
- Python python-docx 生成 docx

建议用 [Open Interpreter](https://github.com/OpenInterpreter/open-interpreter) 这类支持代码执行的本地 Agent。

**保留 70%**：方法论完整，但需自己实现 RAG + 工具调用 + 多选交互。

---

## 八、通用 Prompt（任意 LLM 一次性使用）

### 8.1 适用场景

- 临时使用，不想配置 plugin
- 大模型 API 直调
- ChatGPT 普通对话（非 GPTs）

### 8.2 Prompt 模板

直接把以下内容粘到对话框：

```
我需要你扮演组织咨询师的 AI 副驾驶，帮我生成 [企业简称] 的组织设计交付物。

请你按以下方法论执行：

【方法论】
[此处粘贴 SKILL.md 的核心方法论：§五 矩阵格式标准 + §六 七道质量闸 + §七 三个专项动作]

【对话流程】
[此处粘贴 prompts/dialogue.md 的 5 轮融合版]

【行业模板】
[此处粘贴所选行业的 references/industry-xxx.md 全文]

现在开始第 1 轮对话。
```

### 8.3 输出处理

LLM 输出的矩阵数据如果是 markdown table 格式，可以用以下任一方式转 xlsx：
- 在线工具 [tableconvert.com](https://tableconvert.com)
- VS Code Markdown All in One 插件 + Markdown Preview
- 自建 Python 脚本：`pandas.read_markdown()` → `df.to_excel()`

**保留 60%**：方法论完整，但无 RAG / 无文件读写 / 无质量闸自动校验。

---

## 九、移植后的差异说明

| 功能 | Claude 原生 | Cursor/Cline | ChatGPT GPTs | 本地 LLM | 通用 Prompt |
|---|---|---|---|---|---|
| Frontmatter 自动触发 | ✅ | ❌（用规则） | ✅ | ❌ | ❌ |
| AskUserQuestion 多选交互 | ✅ | ❌（纯文本） | ❌（纯文本） | ❌ | ❌ |
| Glob 自动扫描案例 | ✅ | ⚠️（需手动） | ❌（需手传） | 自建 | ❌ |
| 7 道质量闸自动校验 | ✅ | ✅ | ✅ | 自建 | ❌ |
| 8 份产物自动生成 | ✅ | ✅ | ✅ | 自建 | ⚠️（markdown 手转） |
| 增量迭代版本号 | ✅ | ✅ | ⚠️ | 自建 | ❌ |

**结论**：核心方法论 100% 可移植，自动化程度按平台递减。

---

## 十、贡献新的平台适配

如果您把本工具成功移植到其他平台，欢迎贡献适配文档：

1. 在仓库根目录新建 `adapters/<platform-name>/README.md`
2. 说明该平台的接入方式 + 限制 + 验证案例
3. 提交 PR，标签 `adapter`

期待的平台贡献：
- Dify
- Coze
- AutoGen
- LangGraph
- LangChain Agents
- 元宝
- 通义千问 助手
- 文心一言 插件

---

## 十一、设计哲学回顾

> **方法论是核心，平台是载体**

本工具的真正价值不在于"它在 Claude 上跑得多顺"，而在于：

1. **沉淀了真实组织咨询项目的 10 项设计原则**（见 SKILL.md）
2. **打磨出了 5 轮融合对话流程**（见 prompts/dialogue.md）
3. **建立了 7+ 个子行业事项库**（见 references/）
4. **明确了 7 道质量闸**（见 SKILL.md §六）

这些跨平台都成立。Claude 给的是最佳工程实现，其他平台同样能用——只是您可能要多花几小时做适配。

---

## 十二、版本

- v1.0（2026-05-13）：首版移植指南，覆盖 7 个目标平台
