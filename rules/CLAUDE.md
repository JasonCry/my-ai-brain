# Claude Code Guidelines & Engineering SOPs

This repository follows strict standardized automated engineering SOPs and workflows. All AI agents (including Claude Code) MUST strictly adhere to the following protocols.

## Core Reference (Single Source of Truth)

- **Automated SOPs**: See `docs/agents/engineering_sop.md`
- **Issue Tracker**: See `docs/agents/issue-tracker.md`
- **Triage Labels**: See `docs/agents/triage-labels.md`
- **Domain Modeling & ADRs**: See `docs/agents/domain.md`

## Automated SOP Interception Protocol (Mandatory for ALL interactions)

Whenever the user mentions a bug/problem, a new feature/idea, or an architectural concern, you MUST automatically enter the corresponding SOP defined in `docs/agents/engineering_sop.md`, leading each response with the compact Phase Card:

```markdown
> 📌 **[SOP 名称]** `[■■□□□] 阶段 X/Y: 阶段名称` | **关联工单**: `#ID` (若有)
> **当前目标**: [一句话描述] | **下一步驱动**: [主动引导下一步动作]
```

- **SOP-1 (Bug 缺陷攻坚流)**: Triggered by "bug", "报错", "异常", "问题", "不工作", "崩溃". Immediately show `[■□□□□] 阶段 1/5: 捕获与工单建立`, track the issue, build a feedback loop, test hypotheses, fix via TDD, and verify. (Trivial style/text fixes auto-downgrade to Lite Mode 2 steps).
- **SOP-2 (特性演进流)**: Triggered by "新需求", "新功能", "增加", "想做", "支持". Display `[■□□□□] 阶段 1/5: 需求倾听与边界盘问`, grill boundaries, model domain concepts into `CONTEXT.md`/ADRs, create spec in `docs/`, and implement.
- **SOP-3 (架构治理流)**: Triggered by "架构", "重构", "code review", "走查", "膨胀". Display `[■□□□] 阶段 1/4: 明确审计范围与焦点`, audit bloat/depth, generate refactor spec, and perform dual-axis review.
