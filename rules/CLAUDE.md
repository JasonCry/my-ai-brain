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

- **SOP-1 (Bug 缺陷攻坚流)**: Triggered by "bug", "报错", "异常", "问题", "不工作", "崩溃". Automatically load and follow `diagnosing-bugs` + `tdd` + `ponytail` (read their `SKILL.md` first). Immediately show `[■□□□□] 阶段 1/5: 捕获与工单建立`, track the issue, build a failing feedback loop before editing code, test hypotheses, fix via TDD at public seams, and verify. (Trivial style/text fixes auto-downgrade to Lite Mode 2 steps).
- **SOP-2 (特性演进与编码流)**: Triggered by "新需求", "新功能", "写代码", "实现", "增加", "想做", "支持". Automatically load `grill-with-docs` (`grilling` + `domain-modeling`) when requirements are underspecified, and **ALWAYS automatically load `codebase-design` + `tdd` + `ponytail` before writing code**. Design deep modules at clean seams, implement via vertical TDD slices, and run `code-review` before delivery.
- **SOP-3 (架构治理流)**: Triggered by "架构", "重构", "code review", "走查", "膨胀". Automatically load `codebase-design` + `ponytail-review` + `code-review`. Display `[■□□□] 阶段 1/4: 明确审计范围与焦点`, audit bloat/depth, generate refactor spec, and perform dual-axis review.

## Index-First 3-Tier Progressive Code Navigation (Mandatory)

NEVER start by running blind repo-wide `grep` or reading entire large files. Always follow the 3-tier funnel:
1. **L0 Macro**: Read `llms.txt` or run `./scripts/code_query.sh feature <keyword>` (`docs/CAPABILITIES.md`).
2. **L1 Meso**: Run `./scripts/code_query.sh trace <api_or_module>` to inspect end-to-end seams (`docs/ARCHITECTURE_SEAMS.json`).
3. **L2 Micro**: Run `./scripts/code_query.sh outline <file_path>` or `./scripts/code_query.sh symbol <name>` to get exact `[LStart-LEnd]` line numbers, then slice-read only those lines.

## Zero-Prompt Docling Document Reading Gate (Mandatory)

Whenever asked to read, analyze, compare, summarize, or ingest any `.pdf`, `.docx`, `.pptx`, or `.xlsx` file:
1. **Automatic Interception**: NEVER wait for the user to say "use docling", and NEVER use lossy extractors (`pypdf`, `pdfplumber`, `pdftotext`). Always run `~/.local/bin/p12-docling --input "<file_path>"` automatically.
2. **Non-Destructive Shadow Cache**: Never move or rename the user's original file. Read the high-fidelity Markdown from `parsed_md_path` returned in the JSON receipt (`.docling_cache/<sha256>/parsed.md`).
