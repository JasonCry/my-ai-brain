# Claude Code Guidelines & Engineering SOPs

This repository follows strict standardized automated engineering SOPs and workflows. All AI agents (including Claude Code) MUST strictly adhere to the following protocols.

## Two-Layer Skill Architecture (`mattpocock/skills` Alignment) & Elastic SOPs

Whenever the user mentions a bug/problem, a new feature/idea, or an architectural concern, lead your response with the compact Phase Card:

```markdown
> 📌 **[SOP 名称]** `[■■□□□] 阶段 X/Y: 阶段名称` | **关联工单**: `#ID` (若有)
> **当前目标**: [一句话描述] | **下一步驱动**: [主动引导下一步动作]
```

- **Layer 1 · Model-Invoked Primitives (Always active in `<skills>`, core discipline inlined)**:
  - `diagnosing-bugs`: Reproducible failing loop first -> falsifiable hypotheses -> minimal root-cause fix.
  - `tdd`: Red-Green-Refactor vertical tracer-bullet slices at public seams.
  - `codebase-design`: Deep modules (small interface hiding complex implementation at clean seams), no pass-through layers.
  - `domain-modeling`: Challenge fuzzy terms and maintain `GLOSSARY.md` / `CONTEXT.md` and `docs/adr/` inline.
  - `ponytail`: YAGNI, stdlib/native first, zero single-implementation abstractions.
  - `code-review`: Two-axis review (Standards + Spec) via parallel subagents before delivery.
- **Layer 2 · User-Invoked `/slash` Orchestrators (`disable-model-invocation: true`, 0 System Prompt tokens)**:
  - Main flow: `/grill-with-docs` -> `/to-spec` -> `/to-tickets` -> `/implement` (or `/implement-spec`) -> `/retro`.
  - On-ramps & upkeep: `/triage`, `/wayfinder`, `/improve-codebase-architecture`, `/setup-matt-pocock-skills`, `/ask-matt`.
- **Elastic Daily SOPs**:
  - **Lite Mode (2-Step Fast Track)**: Text/style tweaks, static config updates, or **single-file localized fixes without cross-seam (`UI->Route->Storage->Table`) or DB schema changes** (`[■□] 1/2` -> `[■■] 2/2`).
  - **SOP-1 (Bug Fix - 5 Steps)**: Create GitHub Issue -> failing feedback loop (`diagnosing-bugs`) -> hypothesis test -> TDD fix -> `./scripts/verify_fast.sh` + `./scripts/deploy_staging.sh` -> 4-state receipt.
  - **SOP-2 / SOP-3 (Feature & Architecture)**: Guide or follow `/grill-with-docs` -> `/to-spec` -> `/to-tickets` -> `/implement` (or `/improve-codebase-architecture`).

## Index-First 3-Tier Progressive Code Navigation & Shift-Left Verification (Mandatory)

NEVER start by running blind repo-wide `grep` or reading entire large files. Always follow the 3-tier funnel:
1. **L0 Macro**: Read `llms.txt` or run `./scripts/code_query.sh feature <keyword>` (`docs/CAPABILITIES.md`).
2. **L1 Meso**: Run `./scripts/code_query.sh trace <api_or_module>` to inspect end-to-end seams (`docs/ARCHITECTURE_SEAMS.json`).
3. **L2 Micro & Fast Check**: Run `./scripts/code_query.sh outline <file_path>` or `./scripts/code_query.sh symbol <name>` to get exact `[LStart-LEnd]` line numbers, slice-read/edit only those lines, and run `./scripts/verify_fast.sh` for instant compile/lint feedback before full staging builds.

## Zero-Prompt Docling Document Reading Gate (Mandatory)

Whenever asked to read, analyze, compare, summarize, or ingest any `.pdf`, `.docx`, `.pptx`, or `.xlsx` file:
1. **Automatic Interception**: NEVER wait for the user to say "use docling", and NEVER use lossy extractors (`pypdf`, `pdfplumber`, `pdftotext`). Always run `~/.local/bin/p12-docling --input "<file_path>"` automatically.
2. **Non-Destructive Shadow Cache**: Never move or rename the user's original file. Read the high-fidelity Markdown from `parsed_md_path` returned in the JSON receipt (`.docling_cache/<sha256>/parsed.md`).
