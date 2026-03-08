# Memory-Distill

让 AI 记住你的每一次纠错，永远不需要第二次纠正同一个问题。

Memory-Distill 是一套面向 AI Native 开发的长期记忆管理系统。它通过一套精心设计的「蒸馏」机制，将你在开发过程中对 AI 的零散纠错转化为可持久执行的项目规则。

## 解决的痛点

- **遗忘曲线**：AI 在长对话或跨任务中极易忘记用户之前的纠错和偏好。
- **维护成本**：手动整理项目规范（如 `.cursorrules`）繁琐且难以随开发实时同步。
- **配置断层**：不同成员或不同环境下，AI 对特定项目的认知无法自动保持一致。

## 核心架构：两层记忆模型

系统将记忆明确分为两层，实现快速捕捉与高质量沉淀的平衡：

1. **Layer 1：对话碎片 (.logs/)**
   - **特点**：原始、具象、快速记录。
   - **用途**：在任务结束时，忠实记录用户改了什么。
2. **Layer 2：提纯规则 (.memory/)**
   - **特点**：抽象、指令化、全局生效。
   - **用途**：由 AI 过滤掉一次性修改，提炼出跨任务通用的「硬规则」。

## 项目亮点

- **零干预进化**：无需用户手动维护，AI 在任务收尾时自动完成记忆的提取、提纯与去重。
- **两层记忆架构**：通过 `.logs/`（感性碎片）与 `.memory/`（理性规则）的解耦，有效过滤开发中的偶发性尝试，防止噪音污染长期规则库。
- **自动化自愈**：系统首次运行会自动检测并初始化必要的目录结构与索引，实现真正的“开箱即用”。
- **极致检索性能**：在规则库规模较小时，优先使用原生 `grep` & `list_dir` 检索，无需安装向量数据库即可享受秒级响应。
- **冲突自动平滑**：内置“冲突协议”，当新偏好与旧规则冲突时，AI 会自动进行规则演进或场景标注，不再反复纠结。

## 工作流 (Workflows)

系统内置两个核心自动化工作流，强制在每次任务收尾时串行执行：

- **`auto-memory-sync`**：
  在每个任务完成后执行。AI 会将有价值的纠错记录到 `.logs/`。
- **`memory-consolidation`**：
  **紧随同步执行**。AI 将 `.logs/` 中的零散碎片按意图识别协议进行蒸馏，更新 `.memory/` 中的权威规则库。

## 记忆检索策略

- **传统匹配**：项目默认使用关键词匹配（`grep` & `list_dir`）。在记忆库较小时（<50条），这种方式速度最快且无需额外依赖。
- **按需加载**：系统在任务启动时会自动扫描 `.memory/` 目录，召回相关的规则片段。

## 目录结构

```text
.
├── .kiro/
│   ├── steering/              # 核心规则配置 (Kiro Steering 文件)
│   │   └── memory-integration.md
│   └── skills/
│       └── auto-memory-rules/ # 技能包存储路径
│           ├── SKILL.md       # 核心逻辑与规则模板
│           ├── scripts/       # 自动化脚本
│           │   ├── generate-checklist.sh  # 生成自检清单
│           │   └── generate-index.sh      # 生成规则索引
│           └── memory/        # 记忆存储库 (自动生成)
│               ├── rules/     # 规则文件
│               ├── index.md   # 规则索引 (自动生成)
│               └── CHECKLIST.md  # 自检清单 (自动生成)
└── .frieren/                  # Frieren 兼容目录 (可选)
```

## 规则分类与命名

系统采用标准化的分类体系，确保规则的可检索性：

### 规则分类 (Category)
- `api` - API 相关
- `types` - 类型定义
- `component` - 组件开发
- `hook` - Hook 开发
- `state` - 状态管理
- `pattern` - 设计模式
- `convention` - 编码规范
- `quality` - 代码质量
- `workflow` - 工作流程

### 优先级标记
- 🔴 `high` - 高优先级（严重影响代码质量或功能）
- 🟡 `medium` - 中优先级（影响代码可维护性）
- 🟢 `low` - 低优先级（优化建议）

### 规则文件结构
每个规则文件包含 frontmatter 元数据：
```yaml
---
category: hook
priority: high
tags: [react, hooks, state]
description: Hook 不应暴露内部 setter
---
```

## 如何使用

1. 将 `.kiro/` 或 `.frieren/` 文件夹拷贝到你的项目根目录
2. 使用 Kiro AI 编程助手，它将自动识别并应用 steering 规则
3. 生成索引和清单：
   ```bash
   # 生成规则索引
   bash .kiro/skills/auto-memory-rules/scripts/generate-index.sh
   
   # 生成自检清单
   bash .kiro/skills/auto-memory-rules/scripts/generate-checklist.sh
   ```
4. 查看生成的文件：
   - `memory/index.md` - 按分类浏览所有规则
   - `memory/CHECKLIST.md` - 代码审查自检清单

## 未来升级：语义化搜索 (QMD)

当你的规则库增长到一定规模时，可以考虑引入 QMD 以获得更精准的语义检索能力：

- [QMD 技术指南](./qmd-guide.md)
- [QMD 语义化检索升级待办](./todo-qmd-integration.md)

---

> 由 Distillation Logic 驱动的自我进化系统。
