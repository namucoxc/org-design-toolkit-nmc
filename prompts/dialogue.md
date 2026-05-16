# prompts/dialogue.md — 10 轮对话标准化模板

> 本文档定义 org-design-toolkit skill 启动后与用户的 10 轮对话标准化模板。每轮含问法、AskUserQuestion 参数、预期产出字段、示例答案。
>
> **核心原则**：每轮 1-3 个问题，不要塞太多；遇到客户未明确的字段，标 `[问]` 留给现场访谈，不要脑补。

---

## 第 0 轮 · RAG 案例对齐（自动执行，不需要对话）

启动后自动执行：

```bash
Glob: **/分工矩阵和工作分析/**
Glob: **/工具包/**
Glob: **/{案例*,*矩阵*,*工作分析*}.{xlsx,xls,pdf}
```

若找到关联的官方案例，自动 Read 表 1（部门分工矩阵）+ 表 2（岗位分工矩阵），提取格式参数。

若**未找到任何案例**，给用户提示：

> ⚠️ 未在工作目录中找到分工矩阵的官方案例文件。为保证产出格式符合行业官方标准，建议您：
>
> 1. 在工作目录下创建「分工矩阵和工作分析」子目录
> 2. 放入至少一份官方案例的 xlsx 文件（表 1 部门分工矩阵 + 表 2 岗位分工矩阵）
>
> 是否继续生成？（如继续，将使用 skill 内置 references/ 模板）

---

## 第 1 轮 · 企业基本信息（3 个问题）

### 问题 1.1：企业简称

```json
{
  "question": "请告诉我企业简称（用于落盘目录命名）",
  "header": "企业简称",
  "options": [{"label": "示例：示例企业", "description": "中文 2-6 字简称"}],
  "multiSelect": false
}
```

预期产出字段：`meta.short_name`

### 问题 1.2：行业归类

```json
{
  "question": "企业属于哪个行业？",
  "header": "行业",
  "options": [
    {"label": "制造业 - 通用 (Recommended)", "description": "机械/五金/注塑/电子组装等"},
    {"label": "制造业 - 精品包装", "description": "礼盒/项链盒/香水盒等"},
    {"label": "制造业 - 外贸出口", "description": "出口占比 ≥30%"},
    {"label": "制造业 - 化工 / 食品 / 其他", "description": "分别有 references 模板"}
  ],
  "multiSelect": false
}
```

预期产出字段：`meta.industry`

### 问题 1.3：是否已有前期诊断

```json
{
  "question": "是否已有前期组织诊断 / 调研 / 健康度问卷结果？",
  "header": "诊断材料",
  "options": [
    {"label": "有 (Recommended)", "description": "请提供文件路径"},
    {"label": "无", "description": "跳过相关字段"}
  ],
  "multiSelect": false
}
```

预期产出字段：`meta.has_diagnosis` / `meta.diagnosis_file_path`

---

## 第 2 轮 · 战略与发力点（2-3 个问题）

### 问题 2.1：年度战略目标

```
请告诉我企业的年度战略目标（含营收 / 利润 / 人数等关键数字）
```

预期产出字段：`strategy.annual_target`

示例答案：
> 2026 年营收 1 亿（保底）/ 1.2 亿（冲刺），净利润率回升至 10%

### 问题 2.2：一句话诊断（来自前期诊断或自填）

```
如有前期诊断的"一句话诊断"，请告诉我；如无，请简要描述企业核心问题
```

预期产出字段：`strategy.one_sentence_diagnosis`

### 问题 2.3：未来 1 年关键发力点（最多 5 项）

预期产出字段：`strategy.key_levers[]`

---

## 第 3 轮 · 组织架构现状（含多地协同判断）

### 问题 3.1：现有部门与负责人

```
请列出现有部门 / 中心，以及每个部门的负责人和大致编制
```

预期产出字段：`org_structure.departments[]`

### 问题 3.2：是否有多地协同

```json
{
  "question": "企业是否存在多地协同结构？",
  "header": "多地协同",
  "options": [
    {"label": "总部 + 单工厂", "description": "如上海总部 + 江苏工厂"},
    {"label": "总部 + 多工厂", "description": "总部统辖多个工厂"},
    {"label": "多地办公", "description": "多个城市设分公司"},
    {"label": "无", "description": "单地经营"}
  ],
  "multiSelect": false
}
```

若选了前 3 个，自动叠加 `references/multi-site-overlay.md` 模板。

预期产出字段：`org_structure.multi_site`

---

## 第 4 轮 · 岗位覆盖范围

### 问题 4.1：高管层岗位

```
请确认要做工作分析表的高管岗位（默认全覆盖）
```

预期产出字段：`positions[].high_management`（默认全选，但允许咨询师裁剪）

### 问题 4.2：中层关键岗位

```
请勾选要做工作分析表的中层关键岗位（建议 8-15 张）
```

预期产出字段：`positions[].mid_management`

---

## 第 5 轮 · 核心创利流程（含产品流程图对接）

### 问题 5.1：客户是否提供了产品流程图

```json
{
  "question": "客户是否提供了产品交付流程图或工作流程图（如 PDF / PNG）？",
  "header": "产品流程图",
  "options": [
    {"label": "有 (Recommended)", "description": "请提供文件路径，自动纳入矩阵主线"},
    {"label": "无 - 用 references 默认流程", "description": "使用 references/[行业].md 中的默认流程"}
  ],
  "multiSelect": false
}
```

若选"有"，AI 自动读取流程图，提取节点 + 时长 + 责任部门，纳入矩阵作为「产品交付流程」一级模块。

预期产出字段：`strategy.core_profit_flow[]` / `strategy.core_profit_flow_pdf_source`

---

## 第 6 轮 · 跨部门关键事项清单（50-80 项）

### 问题 6.1：在 references 模板基础上确认或补充

AI 先输出 references 模板中的 50-80 项跨部门关键事项，让咨询师 review 并补充：

```
基于您选择的「[行业]」模板，以下是默认的 60 项跨部门关键事项。请 review 并告诉我：
1. 哪些可以保留？（默认全选）
2. 哪些需要删除？（不适用本企业）
3. 还有哪些需要补充？（本企业特有）
```

预期产出字段：`matrix_items.company_level[]`

---

## 第 7 轮 · 部门内关键事项（一部门 20-30 项）

### 问题 7.1：选择要做岗位分工矩阵的核心部门

```json
{
  "question": "要做岗位分工矩阵的部门有哪些？（建议选 3-5 个核心部门）",
  "header": "核心部门",
  "options": [
    {"label": "业务部 (Recommended)", "description": "营销核心"},
    {"label": "跟单部", "description": "研产销协同枢纽"},
    {"label": "研发部 / 技术部", "description": "新品核心"},
    {"label": "生产部", "description": "交付核心"}
  ],
  "multiSelect": true
}
```

### 问题 7.2：每个部门的内部岗位清单

AI 自动从工作分析表清单 + references 模板生成默认岗位清单，让咨询师 review。

预期产出字段：`matrix_items.department_level{部门名: 事项列表}`

---

## 第 8 轮 · 历史包袱与灰色地带

### 问题 8.1：列出 5-10 个咨询师在现场访谈中要追问的灰色地带

示例：
- 采购总监由谁担任？内部 vs 外招？
- 外协人员转内部的薪酬包 / 时间表？
- 关键岗位的内部关系链？（不写入正式交付件，仅咨询师备忘）

预期产出字段：`gray_zones[]`

---

## 第 9 轮 · 产出表单清单（v2.0 新增）

### 问题 9.1：客户已有的表单 / 制度

```
客户当前已有的"产出表单"清单是什么？（如：日报模板 / 周报模板 / 评审纪要等）
```

预期产出字段：`output_documents[]`

### 问题 9.2：建议新建的表单

```
基于矩阵中的事项，建议新建哪些表单？（每条事项必须对应一个表单）
```

预期产出字段：`output_documents_new[]`

---

## 第 10 轮 · 预审阅 schema（v2.0 新增）

### 问题 10.1：把整合后的 JSON schema 摘要给咨询师过目

```
我已经把前 9 轮的信息整合为如下 JSON schema：

{
  "meta": {...},
  "strategy": {...},
  "org_structure": {...},
  "positions": [15 张],
  "matrix_items": {
    "company_level": 65 项,
    "department_level": {4 部门 × 25 项}
  },
  "gray_zones": [8 项],
  "output_documents": [80 个表单]
}

是否符合预期？需要调整哪些字段？
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

## 对话节奏建议

| 轮 | 平均耗时 | 关键节点 |
|---|---|---|
| 第 0 轮（RAG 自动） | 30 秒 | 静默执行 |
| 第 1 轮（基本信息） | 1-2 分钟 | 3 个必问项 |
| 第 2 轮（战略） | 2-3 分钟 | 含一句话诊断 |
| 第 3 轮（架构 + 多地） | 2-3 分钟 | 关键叠加层判断 |
| 第 4 轮（岗位范围） | 1-2 分钟 | 多选 |
| 第 5 轮（创利流程） | 3-5 分钟 | **客户流程图对接是关键** |
| 第 6 轮（公司级事项） | 5-10 分钟 | 50-80 项 review |
| 第 7 轮（部门内事项） | 5-10 分钟 | 3-5 部门 |
| 第 8 轮（灰色地带） | 2-3 分钟 | 5-10 项 |
| 第 9 轮（产出表单） | 3-5 分钟 | 法治化核心 |
| 第 10 轮（预审） | 1-2 分钟 | 拍板生成 |
| **合计** | **25-45 分钟** | 比传统 2-4 小时大幅压缩 |

---

## 版本

- v1.0（2026-05-12）
