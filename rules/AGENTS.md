# Agent Guidelines & Skills Configuration

## 🚨 Automated Engineering SOP Interception Protocol (Mandatory for ALL turns)

Whenever the user mentions a bug/problem, a new feature/idea, or an architectural review, you MUST lead your VERY FIRST response with the compact Phase Card:

```markdown
> 📌 **[SOP 名称]** `[■■□□□] 阶段 X/Y: 阶段名称` | **关联工单**: `#ID` (若有)
> **当前目标**: [一句话描述当前目标] | **下一步驱动**: [主动引导用户进入下一步动作]
```

### SOP Routing Matrix:
- **SOP-1 (Bug 缺陷攻坚流 - 5步)**: 遇到 "bug", "报错", "异常", "问题", "不工作", "崩溃", "失败", "数据不对" 等。立刻输出 `[■□□□□] 阶段 1/5: 捕获与工单建立`，执行 `gh issue create`，记录在 `changelog.md`，并主动驱动阶段 2 最小复现环。
- **Lite Mode (轻量极简通道 - 2步)**: 仅当为纯文本勘误、单一简单样式调整等极简修改时，自动降级为 2 步（`[■□] 阶段 1/2: 极简登记与确认` -> `[■■] 阶段 2/2: 修改与部署`）。
- **SOP-2 (特性演进流 - 5步)**: 遇到 "新需求", "新功能", "增加", "想做", "支持", "优化交互" 等。立刻输出 `[■□□□□] 阶段 1/5: 需求倾听与边界盘问`，调用 `/grill-me` 盘问边界，更新 `CONTEXT.md`，在 `docs/` 撰写 Spec，TDD 实施与部署。
- **SOP-3 (架构治理流 - 4步)**: 遇到 "架构", "重构", "code review", "走查", "代码膨胀" 等。立刻输出 `[■□□□] 阶段 1/4: 明确审计范围与焦点`，查冗余与深浅，写方案 Spec，并做双轴审查。

## Agent skills

### Issue tracker
GitHub Issues via `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels
Canonical five-role vocabulary. See `docs/agents/triage-labels.md`.

### Domain docs
Single-context (`CONTEXT.md` + `docs/adr/` at repo root). See `docs/agents/domain.md`.

### Automated Engineering SOPs Reference
Full specification: see `docs/agents/engineering_sop.md`.
