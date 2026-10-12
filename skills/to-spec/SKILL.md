---
name: to-spec
description: Synthesize requirement alignment into a verifiable technical spec based on docs/agents/SPEC.template.md.
---

# To Spec (Structured Spec-Driven Contract Generator)

将已达成共识的需求与架构决策转化为结构化、可被 `/code-review` 双轴核验的技术实施契约文档。

## 执行流程

1. **三层渐进式接缝锁域 (Index-First Seam Mapping)**：
   - 若尚未定位代码接缝，先读取 `llms.txt` 并执行 `./scripts/code_query.sh feature <kw>` 与 `./scripts/code_query.sh trace <api>`，精确锁定本次变更涉及的 `UI -> Route -> Storage -> Table` 文件路径。
   - 遵循 [`codebase-design`](../codebase-design/SKILL.md) 原则：优先复用既有公共接缝（Seam），保持深模块小接口，避免新增透传浅层。

2. **按分类子目录生成结构化 Spec (`docs/<category>/<feature_name>_solution.md`)**：
   - **严禁直接将方案文件堆放在 `docs/` 根目录**（应放入 `docs/architecture/`、`docs/frontend/`、`docs/ai_secretary/` 等对应分类子目录）。
   - 严格采用 `docs/agents/SPEC.template.md` 契约格式（包含机器可读的 YAML Frontmatter 与可勾选的 Acceptance Criteria 清单）：

```markdown
---
issue_id: "#<Issue_ID>"
status: "approved"
owner_sop: "SOP-2"
affected_seams:
  - ui: "<前端视图/组件路径>"
  - route: "<后端路由与 Handler 路径>"
  - storage: "<存储层路径>"
  - table: "<SQLite/数据库表名>"
verify_commands:
  - "./scripts/verify_fast.sh"
  - "./scripts/deploy_staging.sh"
---

# [Feature Name] 技术实施契约

## 1. 目标与非目标 (Goals & Non-Goals)
- **Goals (做什么)**: ...
- **Non-Goals (明确不做什么 · YAGNI)**: ...

## 2. 深模块接口与接缝设计 (Deep Module Interface & Seams)
- **公共接缝签名 (Public Seam Interface)**: ...
- **数据流与存储契约 (`UI -> Route -> Storage -> Table`)**: ...

## 3. 垂直示踪弹切片与 TDD 计划 (Vertical Tracer-Bullet Slices)
1. **Slice 1 (Red -> Green)**: ...
2. **Slice 2 (Red -> Green)**: ...

## 4. 验收清单 (Acceptance Criteria · 供 `/code-review` Spec 轴逐项核验)
- [ ] AC-1: ...
- [ ] AC-2: `./scripts/verify_fast.sh` 静态与增量编译检查通过
- [ ] AC-3: Staging (`localhost:3020`) 真实接口与浏览器控制台 0 报错验证通过
```

3. **关联 GitHub Issue**：
   - 将生成的 Spec 路径与核心验收条件同步关联至对应的 GitHub Issue（`#<Issue_ID>`），并在 `changelog.md` 当前版本下登记。
