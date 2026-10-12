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

- **L1 Inline Core Disciplines (Always active without extra file reads)**:
  - `diagnosing-bugs`: Reproducible failing loop first -> falsifiable hypotheses -> minimal root-cause fix.
  - `tdd`: Red-Green-Refactor vertical tracer-bullet slices at public seams.
  - `ponytail`: YAGNI, stdlib/native first, zero single-implementation abstractions.
  - `codebase-design`: Deep modules (small interface hiding complex implementation), no pass-through layers.
- **SOP-1 (Bug 缺陷攻坚流)**: Triggered by cross-module or non-trivial bugs. Show `[■□□□□] 阶段 1/5: 捕获与工单建立`, create GitHub Issue, build a failing feedback loop before editing code, verify hypotheses, fix via TDD, run `./scripts/verify_fast.sh` + `./scripts/deploy_staging.sh`, and output the 4-state receipt.
- **Lite Mode (2-Step Fast Track)**: Triggered by text/style tweaks, static config updates, or **single-file localized fixes without cross-seam (`UI->Route->Storage->Table`) or DB schema changes**. Run in 2 compact steps (`[■□] 1/2` -> `[■■] 2/2`).
- **SOP-2 (特性演进与编码流)**: Triggered by new features. Load L2 `SKILL.md` on-demand (`grill-with-docs` when requirements are underspecified, `codebase-design` when designing new module seams, `code-review` before delivery). Author structured spec from `docs/agents/SPEC.template.md` before implementation.
- **SOP-3 (架构治理流)**: Triggered by architecture/refactor/review requests. Load `codebase-design` + `ponytail-review` + `code-review` on-demand.

## Index-First 3-Tier Progressive Code Navigation & Shift-Left Verification (Mandatory)

NEVER start by running blind repo-wide `grep` or reading entire large files. Always follow the 3-tier funnel:
1. **L0 Macro**: Read `llms.txt` or run `./scripts/code_query.sh feature <keyword>` (`docs/CAPABILITIES.md`).
2. **L1 Meso**: Run `./scripts/code_query.sh trace <api_or_module>` to inspect end-to-end seams (`docs/ARCHITECTURE_SEAMS.json`).
3. **L2 Micro & Fast Check**: Run `./scripts/code_query.sh outline <file_path>` or `./scripts/code_query.sh symbol <name>` to get exact `[LStart-LEnd]` line numbers, slice-read/edit only those lines, and run `./scripts/verify_fast.sh` for instant compile/lint feedback before full staging builds.

## Zero-Prompt Docling Document Reading Gate (Mandatory)

Whenever asked to read, analyze, compare, summarize, or ingest any `.pdf`, `.docx`, `.pptx`, or `.xlsx` file:
1. **Automatic Interception**: NEVER wait for the user to say "use docling", and NEVER use lossy extractors (`pypdf`, `pdfplumber`, `pdftotext`). Always run `~/.local/bin/p12-docling --input "<file_path>"` automatically.
2. **Non-Destructive Shadow Cache**: Never move or rename the user's original file. Read the high-fidelity Markdown from `parsed_md_path` returned in the JSON receipt (`.docling_cache/<sha256>/parsed.md`).
