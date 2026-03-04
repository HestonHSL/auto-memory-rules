---
name: memory-distill
description: 两层记忆架构指南。区分对话碎片（.logs/）与提纯规则（.memory/），驱动 AI 持续自我迭代。
keywords: memory, logs, correction, preference, distillation, rules
---

# Memory-Distill 核心导航

> 本技能定义了 AI 如何从日常纠错中「蒸馏」出长期规则。它由 `rules.md` 强制驱动，确保 AI 越用越懂你。

---

## 工作流导航 (Workflow Navigation)

根据当前任务阶段，直接调用以下工作流：

### 1. 任务结束：同步记录

- **指令**：[`/auto-memory-sync`](./workflows/auto-memory-sync.md)
- **时机**：当用户手动修改代码、否定 AI 方案或提供关键偏好后。
- **目标**：将「具象碎片」快速记入 `.logs/`。

### 2. 定期整理：提纯规则

- **指令**：[`/memory-consolidation`](./workflows/memory-consolidation.md)
- **时机**：`.logs/` 积累较多、规则出现冲突或用户明确要求整理时。
- **目标**：将碎片升华为可执行的规则，存入 `.memory/`。

---

## 执行与逻辑参考 (Rules & Logic)

AI 在执行任务和分析记忆时必须参考以下标准：

### 1. 行为准则与集成 (Integration Rules)

- **内容**：任务启动加载、对话内缓存、任务结束触发。
- [**`references/rules-reference.md`**](./references/rules-reference.md)

### 2. 提纯与意图分析 (Distillation Logic)

- **内容**：意图识别表、Layer 1/2 写入规范、质量门控、冲突协议。
- [**`references/distillation-logic.md`**](./references/distillation-logic.md)

---

## 核心架构预览 (Architecture Preview)

### 1. 两层架构

| 存储层            | 路径       | 核心特征                             |
| :---------------- | :--------- | :----------------------------------- |
| **Layer 1：碎片** | `.logs/`   | 原始记录、记录快速、低抽象、忠实。   |
| **Layer 2：规则** | `.memory/` | 抽象指令、加载迅速、高抽象、可执行。 |

### 2. 提纯四步法

从 `.logs/` 升华到 `.memory/` 的标准路径：

1.  **意图识别**：判定是偏好、规范、功能还是业务补充。
2.  **价值判定**：应用[质量标准](#质量标准)进行筛选。
3.  **抽象规则**：将具象变化转化为「指令式语言」。
4.  **去重合并**：解决规则冲突，保持精简。

---

## 质量标准与模板

### 质量标准

- **应记**：高成本错误、风格模板、多次尝试后的解法、强制规范。
- **不记**：一次性处理、纯概念解释、包含具体变量名/行号的具象描述。

### Layer 2 记录模板

```markdown
### [技术关键词标题]

- **场景描述**: [触发场景]
- **规则 (可执行)**: [指令式规则]
- **原因 / 强制性**: [原因及豁免条件]
```

---

> 维护提示：本目录下的规则与工作流紧密关联。修改逻辑时，请同步更新 [规则镜像](./references/rules-reference.md)。
