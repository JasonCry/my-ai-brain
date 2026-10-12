---
name: grill-with-docs
description: >-
  Deep requirement boundary interview and active domain modeling (CONTEXT.md & ADRs).
  Self-contained deep skill combining Design-Tree Frontier Grilling, Index-First codebase
  fact-checking, and Domain Glossary/ADR maintenance without secondary skill hops.
  TRIGGER AUTOMATICALLY in SOP-2 Stage 1-2 when requirements or boundaries are underspecified.
---

# Grill with Docs (Boundary Interview & Active Domain Modeling)

通过「设计决策树前沿盘问 (Frontier Grilling)」与「领域词汇表/ADR 实时沉淀 (Domain Modeling)」在动手写代码前彻底廓清需求边界、消除隐性假设。本技能为**自包含深模块（Deep Skill）**，无需二次跳转调用其他技能。

---

## 1. 核心铁律：事实自查，决策归用户 (Facts are Yours, Decisions are the User's)

1. **严禁把代码库里能查到的事实抛给用户回答**：
   - 在向用户提问前，先用 Index-First 三层探针（读取 `llms.txt` → `./scripts/code_query.sh feature/trace/outline`）查清现有表结构、路由签名与前端组件状态。
   - 若发现用户表述与现有代码不一致，直接指出冲突并请用户拍板：“现有代码在 `routes/tasks.rs` 中将状态定义为 X，但刚才提到 Y，本次是否需要迁移契约？”
2. **明确 Goals 与 Non-Goals (YAGNI)**：
   - 主动帮用户砍掉过度设计与单次实现的投机抽象，锁定本次最小闭环边界。

---

## 2. 盘问方法：决策树前沿轮次推进 (Design-Tree Frontier Rounds)

将待定问题映射为一棵**设计决策树（Design Tree）**：
- **前沿问题 (The Frontier)**：所有前置依赖已明确、当前可以立即提问而不必靠猜的独立决策点。
- **单轮集中提问**：每轮一次性列出当前所有 Frontier 问题（通常不超过 3~4 个核心问题），每个问题**必须附带你的推荐方案（Recommended Answer）与关键取舍**：

```markdown
❓ **Q1 - [决策主题]**: [简明说明背景、边界冲突或可选路径]
➡️ **推荐方案**: [给出明确推荐项及理由，用户只需回复“按推荐”即可快速推进]

---

❓ **Q2 - [决策主题]**: [简明说明异常流/多端兼容/状态并发边界]
➡️ **推荐方案**: [给出明确推荐项及理由]
```

---

## 3. 领域建模与架构决策实时同步 (Active Domain & ADR Discipline)

在盘问与对齐过程中，实时维护项目的领域一致性：
1. **术语对齐 (`CONTEXT.md`)**：
   - 当确立了新的核心业务概念或消除了同义词混淆时，立即增量更新项目根目录 `CONTEXT.md`（仅记录纯领域词汇与不变量定义，不塞入具体实现细节）。
2. **架构决策记录 (`docs/adr/`)**：
   - 仅当某个决策同时满足以下 3 个条件时，在 `docs/adr/NNNN-<slug>.md` 创建 ADR：
     1. **难以逆转 (Hard to reverse)**：日后推翻重来的代价高昂；
     2. **缺乏背景则令人困惑 (Surprising without context)**：后人看代码会疑惑“当初为什么要这样做”；
     3. **真实权衡的产物 (Result of a real trade-off)**：存在多个可行备选方案且因特定约束做出了取舍。

---

## 4. 退出条件与下一步交接

当决策树前沿为空（所有关键边界、异常流、Non-goals 均已与用户达成共识）时，结束盘问，直接进入 **SOP-2 阶段 3**：基于 `docs/agents/SPEC.template.md` 在 `docs/<category>/<feature_name>_solution.md` 生成结构化技术实施契约。
