# prompts/dialogue.md — 5 轮融合对话模板（v2.0.3）

> 本文档定义 `org-design-toolkit` skill 启动后与用户的 5 轮对话标准化模板。每轮含问法、AskUserQuestion 参数、预期产出字段。
>
> v2.0.3 起从 10 轮简化为 5 轮（12-18 分钟）。如需快速通道，见末尾"3 轮极简版"。
>
> **核心原则**：每轮 2-4 个相关问题打包问，AskUserQuestion 支持多选；遇到客户未明确的字段，标 `[问]` 留给现场访谈。

---

## 第 0 轮 · RAG 案例对齐 + 既有材料预填（自动执行，0 问题）

启动后自动执行：

```bash
# 优先级 1：官方案例
Glob: **/{分工矩阵*,组织设计*,工作分析*}/**
# 优先级 2：客户既有材料
Glob: **/[企业简称]/**/{诊断*,调研*,组织*,产品流程*}.{docx,pptx,pdf,xlsx}
```

读取后自动预填以下字段，并标 `[数]` 来源：

- 表 1 部门分工矩阵案例的列结构、RACI 编码、流程顺序
- 客户前期诊断结论 → 预填 `strategy.one_sentence_diagnosis`
- 客户组织架构图 → 预填 `org_structure.departments`
- 客户产品流程图 → 预填 `strategy.core_profit_flow`

若未找到官方案例：友好提示用户上传，不要凭空编造格式。

---

## 第 1 轮 · 企业画像 + 战略（融合：旧 1+2 轮）

**预算时长**：3-5 分钟
**问题数**：3-4 个 AskUserQuestion 一次性打包问

### 问题 1.1：企业基本信息

```json
{
  "question": "请告诉我企业基本信息（一次提供以下 4 项）",
  "header": "企业基本信息",
  "options": [
    {"label": "示例：示例企业", "description": "企业简称（中文 2-6 字）+ 全称 + 员工数 + 业务模式"}
  ],
  "multiSelect": false
}
```

预期字段：`meta.short_name` / `meta.full_name` / `enterprise.headcount` / `enterprise.business_model`

### 问题 1.2：行业归类

```json
{
  "question": "企业属于哪个行业？",
  "header": "行业",
  "options": [
    {"label": "制造业 - 通用 (Recommended)", "description": "机械/五金/注塑/电子组装"},
    {"label": "制造业 - 精品包装 / 外贸出口", "description": "礼盒/项链盒/出口为主"},
    {"label": "制造业 - 化工 / 食品", "description": "有强监管 / EHS / 食安部"},
    {"label": "零售连锁 / 项目型 / 其他", "description": "选这个后会进一步细分"}
  ],
  "multiSelect": false
}
```

预期字段：`meta.industry`

### 问题 1.3：战略与发力点

```json
{
  "question": "企业年度战略目标 + 一句话诊断 + 关键发力点（一次提供 3 块）",
  "header": "战略",
  "options": [
    {"label": "已有前期诊断材料 (Recommended)", "description": "我自动读取并预填，您 review 即可"},
    {"label": "现场口述", "description": "请直接告诉我 3 块内容"}
  ],
  "multiSelect": false
}
```

预期字段：`strategy.annual_target` / `strategy.one_sentence_diagnosis` / `strategy.key_levers[]`

---

## 第 2 轮 · 组织架构 + 岗位范围（融合：旧 3+4 轮）

**预算时长**：3-4 分钟
**问题数**：2-3 个

### 问题 2.1：组织架构 + 多地协同识别

```json
{
  "question": "请列出现有部门 + 负责人 + 编制；同时告诉我是否有多地协同结构",
  "header": "组织架构",
  "options": [
    {"label": "单地经营 (Recommended)", "description": "所有部门在同一地点"},
    {"label": "总部 + 单工厂", "description": "如总部在城市 + 工厂在产业带"},
    {"label": "总部 + 多工厂", "description": "总部统辖多个工厂"},
    {"label": "多地办公 / 集团 + 子公司", "description": "多地分公司或集团结构"}
  ],
  "multiSelect": false
}
```

若选了后 3 个，自动叠加 `references/multi-site-overlay.md` 模板。

预期字段：`org_structure.departments[]` / `org_structure.multi_site`

### 问题 2.2：岗位覆盖范围

```json
{
  "question": "要做工作分析表的岗位（默认：高管全覆盖 + 中层关键 8-15 张）",
  "header": "岗位",
  "options": [
    {"label": "标准版：高管全 + 中层关键 (Recommended)", "description": "12-22 张"},
    {"label": "精简版：仅高管", "description": "7-10 张，适合 <100 人企业"},
    {"label": "完整版：高管 + 中层 + 基层关键", "description": "20-30 张，适合 >300 人企业"}
  ],
  "multiSelect": false
}
```

预期字段：`positions[]`

---

## 第 3 轮 · 核心流程 + 公司级事项（融合：旧 5+6 轮）

**预算时长**：4-6 分钟
**问题数**：1-2 个

### 问题 3.1：客户是否提供了产品流程图

```json
{
  "question": "客户是否提供了产品交付流程图 / 工作流程图？",
  "header": "产品流程图",
  "options": [
    {"label": "有 (Recommended)", "description": "我自动读取并纳入矩阵主线"},
    {"label": "无 - 用 references 默认流程", "description": "使用所选行业的默认创利流程"}
  ],
  "multiSelect": false
}
```

若有，自动读取，提取节点+时长+责任部门，纳入表 1 作为「产品交付流程」一级模块。

预期字段：`strategy.core_profit_flow[]` / `strategy.core_profit_flow_pdf_source`

### 问题 3.2：公司级跨部门事项 review

AI 先基于 references 模板生成 50-80 项跨部门事项，咨询师 review：

```
基于您选择的「[行业]」模板，以下是默认的 60 项跨部门关键事项。
请告诉我：
1. 哪些保留（默认全选）
2. 哪些删除（不适用本企业）
3. 还需补充哪些（本企业特有）
```

预期字段：`matrix_items.company_level[]`

---

## 第 4 轮 · 部门内事项 + 灰色地带 + 产出表单（融合：旧 7+8+9 轮）

**预算时长**：3-5 分钟
**问题数**：2-3 个

### 问题 4.1：选择要做岗位分工矩阵的核心部门

```json
{
  "question": "要做岗位分工矩阵的部门有哪些？（建议 3-5 个）",
  "header": "核心部门",
  "options": [
    {"label": "业务部 (Recommended)", "description": "营销核心"},
    {"label": "跟单部 / 运营部", "description": "研产销协同枢纽"},
    {"label": "研发部 / 技术部", "description": "新品核心"},
    {"label": "生产部", "description": "交付核心"}
  ],
  "multiSelect": true
}
```

预期字段：`matrix_items.department_level{}`

AI 自动从 references 模板生成每部门 20-30 项默认事项，咨询师 review。

### 问题 4.2：灰色地带 + 产出表单（合并问）

```
请告诉我：
1. 现场访谈要追问的灰色地带（5-10 条，如：采购总监由谁担任？外协人员转内部计划？）
2. 客户已有的产出表单清单 + 建议新建的表单（每条事项必须有对应表单）
```

预期字段：`gray_zones[]` / `output_documents[]`

---

## 第 5 轮 · 生成前预审 schema（保留旧第 10 轮）

**预算时长**：1-2 分钟
**问题数**：1 个

### 问题 5.1：JSON schema 摘要确认

```
我已经把前 4 轮信息整合为 JSON schema：

{
  "meta": { 企业简称、行业、规模、业务模式 },
  "strategy": { 年度目标、一句话诊断、关键发力点 },
  "org_structure": { 10 部门 / 含多地协同 },
  "positions": [15 张工作分析表岗位],
  "matrix_items": {
    "company_level": [65 项跨部门事项],
    "department_level": { 4 部门 × 25 项 }
  },
  "gray_zones": [8 条灰色地带],
  "output_documents": [80 个产出表单]
}

是否符合预期？
```

```json
{
  "question": "schema 是否符合预期？",
  "header": "预审",
  "options": [
    {"label": "符合预期，可以生成 (Recommended)", "description": "直接生成 8 份产物"},
    {"label": "需调整字段", "description": "请说明调整点"},
    {"label": "重新走某几轮", "description": "请说明哪几轮"}
  ],
  "multiSelect": false
}
```

---

## 5 轮版执行节奏总览

| 轮 | 主题 | 预算时长 | 问题数 | 融合自旧轮 |
|---|---|---|---|---|
| 0 | RAG 自动 + 既有材料预填 | 30 秒 | 0 | 旧第 0 步 |
| 1 | 企业画像 + 战略 | 3-5 分钟 | 3 | 旧 1+2 |
| 2 | 组织架构 + 岗位范围 | 3-4 分钟 | 2 | 旧 3+4 |
| 3 | 核心流程 + 公司级事项 | 4-6 分钟 | 2 | 旧 5+6 |
| 4 | 部门事项 + 灰色地带 + 产出表单 | 3-5 分钟 | 2 | 旧 7+8+9 |
| 5 | 预审 schema | 1-2 分钟 | 1 | 旧 10 |
| **合计** | — | **12-18 分钟** | **10 个 AskUserQuestion** | — |

相比 10 轮版（25-45 分钟）**节省 50%+ 时间**，问题数也从 20+ 个降到 10 个。

---

## 附录 · 3 轮极简版（快速通道 · 5-8 分钟）

适用场景：高预填项目（已有前期诊断 + 客户流程图 + 官方案例齐备）。

### 第 1 轮 · 基础采集（4 大块合一 · 3-4 分钟）

一次性问完：
- 企业简称 + 行业 + 规模
- 战略目标 + 一句话诊断（如有前期诊断材料则自动预填）
- 现有部门 + 多地协同识别
- 岗位覆盖范围（高管全 + 中层关键）

### 第 2 轮 · 事项 review（3 大块合一 · 2-3 分钟）

AI 先基于 references + RAG 既有材料生成"流程 + 跨部门事项 + 部门事项 + 灰色地带 + 产出表单"完整草稿，让咨询师一次性 review：

- 保留 / 删除 / 补充
- 灰色地带补充
- 产出表单确认

### 第 3 轮 · 预审拍板（1 分钟）

JSON schema 摘要 → 拍板 → 生成 8 份产物。

**触发条件**：用户明确说"快速做""3 轮版""极简模式"时启用。

---

## 版本

- v2.0.3（2026-05-13）：从 10 轮简化为 5 轮融合版 + 3 轮极简版
- v1.0（2026-05-12）：10 轮原版
