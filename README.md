# org-design-toolkit

> 🏢 中小企业组织设计交付物生成器 · Claude AI Skill
>
> 通过 5 轮结构化对话，自动产出三张分工矩阵 + 工作分析表合集 + 组织设计预览，把咨询师从 2-4 小时格式劳动中解放出来。

![version](https://img.shields.io/badge/version-2.0.3-blue) ![license](https://img.shields.io/badge/license-MIT-green) ![status](https://img.shields.io/badge/status-stable-success) ![language](https://img.shields.io/badge/language-zh--CN-orange)

---

## ✨ 这是什么？

`org-design-toolkit` 是一个面向**中小企业组织咨询**场景的 Claude AI Skill，把组织设计中最耗时的"格式劳动"——填矩阵、写工作分析表、画组织图——交给 AI 完成。咨询师专注于现场判断、权力博弈和决策。

### 🎯 解决什么问题

| 传统做法 | 用 org-design-toolkit |
|---|---|
| 咨询师手填 10 部门 × 80 项 RACI 矩阵，2-4 小时 | 10 轮对话后自动生成，5 分钟 |
| 工作分析表 15 张，每张手写一天 | 全自动生成，逐张定制 |
| 矩阵与岗位说明书人工对账 | 七道质量闸自动校验一致性 |
| 重做 1 版要重填一次 | 增量迭代机制（v1→v2→v3 + 差异报告） |

### 🌟 10 项核心特性

1. **RAG 强制前置** — 启动时强制扫描关联案例，对齐官方格式而非凭想象生成
2. **矩阵三张分表** — 部门级 / 岗位级 / 工作分析表分文件输出，便于分发
3. **RACI 本地化** — 部门级中文「主责/参与/监督」，岗位级 R/A/I 字母
4. **产出表单列必填** — 每条事项必须有物化产出，是流程治理的关键
5. **流程驱动** — 按创利流程顺序排列（不按抽象主题）
6. **表间承上启下** — 岗位矩阵增「部门职责权限」列，自动与部门矩阵一致
7. **子行业模板** — 精品包装/外贸出口/化工/食品/零售连锁/项目型/双工厂等 7+ 模板
8. **三个专项动作** — 客户产品流程图对接 / 外部资源转内部 / 双工厂协同
9. **增量迭代** — v1→v2→v3 版本机制 + 自动差异报告
10. **七道质量闸** — RACI 完整性、A 数过载、KPI 可量化、表间一致、行业适配、产出表单完整、流程顺序对齐

---

## 🚀 快速开始

### 安装

#### 方式 A · Claude Code Plugin Marketplace（推荐）

```bash
claude plugins install org-design-toolkit
```

#### 方式 B · 手动放置

```bash
# 克隆仓库
git clone https://github.com/<your-org>/org-design-toolkit.git

# 复制到 Claude Code skills 目录
cp -r org-design-toolkit ~/.claude/skills/

# 重启 Claude Code
```

### 第一次使用

1. 在用户工作目录下放一份**官方分工矩阵案例**作为格式对齐参考：

```
your-project/
└── 分工矩阵和工作分析/       # 或 "工具包"
    ├── 表1：部门分工矩阵.xlsx  # 案例 A
    └── 表2：岗位分工矩阵.xlsx  # 案例 A
```

2. 在 Claude Code 或 Cowork 中输入：

```
做一份 [企业简称] 的分工矩阵和工作分析表
```

3. skill 会自动 10 轮对话采集信息，5 分钟内输出 8 份文件。

### 输出文件

```
[企业简称]/交付/[企业简称]方案设计-[YYYYMM]/
├── 表1-[企业简称]-部门分工矩阵.xlsx       ★ 正式交付件
├── 表2-[企业简称]-岗位分工矩阵.xlsx       ★ 正式交付件（按部门分 Sheet）
├── 表3-[企业简称]-工作分析表合集.docx     ★ 正式交付件
├── [企业简称]-组织设计预览.html          ★ 正式预览件
├── 数据档案.json                          # 内部 / 下次复用
├── 校验报告.md                            # 内部 / 不交付客户
├── 澄清说明.md                            # 内部 / 不交付客户
└── CHANGELOG.md                           # 内部 / 增量迭代记录
```

---

## 📐 设计哲学

> **AI 是副驾驶，咨询师是决策者**

org-design-toolkit 的核心哲学是把咨询师从"格式劳动"中解放，把精力留在与客户决策层的博弈和判断上。

### 三大不替代

1. **不替代现场观察** — AI 不在现场，看不到老板眼神、员工反应、办公室政治
2. **不替代权力判断** — A 岗归属 = 权力分配 = 客户内部博弈结果
3. **不替代专业判断** — 咨询师的经验、直觉、对客户的深度理解，无法由 AI 替代

---

## 📂 项目结构

```
org-design-toolkit/
├── SKILL.md                          # 主文档
├── CHANGELOG.md                       # 版本变更
├── README.md                          # 本文档
├── LICENSE                            # MIT
├── CONTRIBUTING.md                    # 贡献指南
├── CODE_OF_CONDUCT.md                 # 行为准则
├── DEMO_SCRIPT.md                     # 技术演示视频脚本（2-3 分钟）
├── MARKETING_VIDEO_SCRIPT.md          # 推广视频脚本（15s / 30s / 60s · 4 平台）
├── TRIGGERS.md                        # 触发词系统（主/弱/反/协作触发）
├── prompts/
│   └── dialogue.md                    # 10 轮对话标准化模板
└── references/
    ├── industry-mfg-general.md        # 制造业通用
    ├── precious-packaging.md          # 精品包装
    ├── export-mfg.md                  # 外贸出口
    ├── industry-chemical.md           # 化工
    ├── industry-food.md               # 食品
    ├── industry-chain.md              # 零售连锁
    ├── industry-project.md            # 项目型
    └── multi-site-overlay.md          # 多地协同叠加层
```

---

## 🤝 贡献

欢迎提交：

- 新的子行业模板（医疗、教育、IT 服务等）
- bug 修复或质量闸优化
- 文档改进或翻译（英语 / 日语 / 韩语）

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

---

## 📅 版本路线图

- **v2.0.1** ⭐ 当前：5 个子行业模板 + dialogue.md + 完整社区文档
- v2.1 计划：补医疗 / 教育 / IT 服务三个子行业
- v2.2 计划：接入绩效系统、薪酬系统的下游模块
- v3.0 计划：组织变革模拟器（多版本对比）

详见 [CHANGELOG.md](./CHANGELOG.md)。

---

## 📄 许可

[MIT License](./LICENSE) · Copyright (c) 2026 org-design-toolkit contributors

---

## 🙏 致谢

本项目源于多次真实组织咨询项目的迭代经验。感谢一线咨询师在使用中提出的所有反馈与改进建议。
