# Contributing to org-design-toolkit

> 感谢您愿意为 org-design-toolkit 贡献力量。本文档说明了如何参与项目。

---

## 一、贡献类型

我们最欢迎以下贡献：

| 类型 | 难度 | 优先级 |
|---|---|---|
| 🏭 新增子行业模板（医疗/教育/IT/餐饮等） | 中 | ⭐⭐⭐ |
| 🐛 Bug 修复（质量闸误判、矩阵渲染问题） | 中 | ⭐⭐⭐ |
| ✨ 质量闸增强（新增校验维度） | 中-高 | ⭐⭐ |
| 📝 文档改进 / 错别字 | 低 | ⭐⭐ |
| 🌍 翻译（英语 / 日语 / 韩语） | 中 | ⭐⭐ |
| 🎨 演示视频 / 案例分享 | 低 | ⭐ |
| 🔌 下游模块对接（绩效系统、薪酬系统） | 高 | ⭐ |

---

## 二、提交流程

### 2.1 提交 Issue

发现 bug 或想提建议？请先搜一下是否已经有人提过：

1. 进入 [Issues](../../issues) 页面，搜索关键词
2. 如果没有同类 Issue，点 `New Issue`
3. 选择对应的模板（Bug / Feature / Industry Template）填写

### 2.2 提交 Pull Request

1. **Fork 仓库** 到自己账号
2. **创建分支**：`git checkout -b feature/your-feature-name`
3. **改代码**：参考"代码规范"
4. **本地自测**：跑一遍 skill，确保 7 道质量闸通过
5. **提交**：`git commit -m "feat: 新增医疗行业子模板"`（用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/) 风格）
6. **推送 + 发 PR**：`git push origin feature/your-feature-name`

---

## 三、新增子行业模板的规范

新模板必须放在 `references/industry-<name>.md`，结构与现有模板一致：

```markdown
# <行业名> · 子行业事项库（references/industry-<name>.md）

适用范围：...
典型企业规模：...

## 一、子行业特征
| 维度 | 本行业特征 | 与通用制造业的差异 |

## 二、N 节点核心创利流程
| # | 节点 | 行业标准时长 | 责任部门组合 |

## 三、推荐组织架构
| 部门 | 编制建议 | 关键岗位 |

## 四、推荐 KPI 范式
| 岗位 | 核心 KPI 1 | 核心 KPI 2 | 核心 KPI 3 |

## 五、典型陷阱

## 六、推荐分析诊断重点

## 七、版本
```

**质量底线**：

- ✅ 必须有具体行业数据支撑（不能凭想象编造）
- ✅ 至少包含 3 个该行业典型企业案例的引用
- ✅ 创利流程必须按真实业务顺序排列
- ✅ KPI 必须可量化（含数字目标 / 时间节点）
- ❌ 不要使用占位符 `<TBD>` 或 `<填空>`

---

## 四、代码规范

### 4.1 Markdown 文件

- 使用 GFM (GitHub Flavored Markdown)
- 列表前后留空行
- 标题使用 `#` `##` `###`，不超过 4 级
- 表格使用 `|---|---|` 标准语法

### 4.2 SKILL.md 改动

- 改动需同步更新 CHANGELOG.md
- 加入新质量闸需更新表格的"七道质量闸"为"八道质量闸"等
- 改动主流程需更新"执行顺序"章节

### 4.3 提交信息

使用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/)：

```
feat: 新增医疗行业子模板
fix: 修复质量闸 4 一致性误判
docs: 改进 dialogue.md 第 7 轮表述
refactor: 重构 references/ 目录命名
```

---

## 五、社区行为准则

请遵守 [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)。简言之：尊重、专业、不攻击、不抄袭。

---

## 六、版本发布流程

仅 Maintainer 操作：

1. 合并所有目标 PR
2. 更新 CHANGELOG.md 的版本号与日期
3. 更新 SKILL.md frontmatter 中 `version` 字段
4. `git tag v<version>` 并推送
5. 发布到 GitHub Release（附 .zip 包）
6. （可选）同步到 Claude Code marketplace

---

## 七、提问与讨论

- **问 bug**：开 Issue
- **问怎么用**：[Discussions](../../discussions) 区
- **问开发方向**：在 Discussions 的 `Ideas` 类目发帖
