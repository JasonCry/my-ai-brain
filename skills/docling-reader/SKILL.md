---
name: docling-reader
description: >-
  Zero-prompt, non-destructive structured document reader powered by IBM Docling.
  Automatically intercepts .pdf, .docx, .pptx, and .xlsx files to extract high-fidelity
  Markdown, complex tables (TableFormer), multi-column layouts (DocLayNet), and hierarchical
  RAG chunks into a hidden .docling_cache/<sha256>/ shadow directory without moving original files.
  Trigger AUTOMATICALLY whenever reading, analyzing, comparing, summarizing, or ingesting any
  .pdf, .docx, .pptx, or .xlsx file across Antigravity, ChatGPT/Codex, DSH, Claude, or P12 Smart Secretary.
---

# Docling 异构文档零感知高保真精读技能 (Docling Reader Skill)

本技能将 IBM **Docling**（`DocLayNet` 多栏版面重构 + `TableFormer` 复杂表格无损还原 + `HybridChunker` 语义切片）下沉为本机所有 AI 客户端（**Antigravity、ChatGPT/Codex、DSH、Claude Code、P12 智能秘书**）的隐形基础设施。

---

## 🚨 核心铁律：零提醒自动拦截与原件原位保护 (Zero-Prompt & Non-Destructive)

1. **无需用户提醒（Zero-Prompt Interception）**：
   - 凡遇到用户要求读取、分析、对比、总结或入库 `.pdf`、`.docx`、`.pptx`、`.xlsx` 文件，**严禁等待用户提醒“用 docling”**，必须由 Agent 根据文件扩展名**无条件自动触发本技能**。
   - **严禁**退回使用 `pypdf`、`pdfplumber`、`pdftotext`、`python-docx` 等粗糙文本提取工具（会导致双栏串行与表格错位）。
2. **原件 100% 原位不动（Zero File Movement）**：
   - **严禁移动、重命名或修改用户的原始文档**，完全尊重用户在各业务目录（如 `xserver`、`health`、`product`、`wudang`、`hermes`）中的原有归档规则。
3. **SHA-256 隐藏影子缓存（Shadow Cache）**：
   - 解析生成的 `parsed.md` 与 `chunks.json` 自动存放在项目根目录的 `.docling_cache/<sha256_prefix>/`（若为项目外独立文件如 `~/Downloads/a.pdf`，则存入 `~/.docling_cache/<sha256_prefix>/`），不污染工作区文件树。
   - 已解析过的文件（即使后续被移动或重命名）再次读取时 **0 秒直接命中缓存返回**，绝不重复消耗算力。

---

## ⚡ 标准执行工作流 (Standard Execution Workflow)

当需要读取任何 `.pdf` / `.docx` / `.pptx` / `.xlsx` 文件时，直接按以下步骤执行：

### 步骤 1：调用全局 CLI `p12-docling` 获取净水缓存路径

在终端运行（无需激活任何虚拟环境，`uv` 自动管理）：

```bash
~/.local/bin/p12-docling --input "/path/to/document.pdf"
```

可选参数：
- `--realm <auto|xserver|product|health|wudang|hermes>`：默认 `auto`（根据文件路径自动识别领域；如 `health` 自动启用最高精度表格 `TableFormerMode.ACCURATE` + 中文 OCR）。
- `--force`：忽略已有 SHA-256 缓存，强制重新解析。

### 步骤 2：解析 JSON 回执并按需精读

命令在标准输出返回单行 JSON 回执：

```json
{
  "status": "ok",
  "cache_hit": true,
  "realm_id": "xserver",
  "original_path": "/Users/.../02_架构评审/存储方案.pdf",
  "parsed_md_path": "/Users/.../.docling_cache/e3b0c44298fc1c14/parsed.md",
  "chunks_json_path": "/Users/.../.docling_cache/e3b0c44298fc1c14/chunks.json",
  "source_hash": "sha256:e3b0c44298fc1c14...",
  "page_count": 14,
  "chunk_count": 38
}
```

拿到回执后：
- **短文档（`page_count <= 10`）**：直接使用 `view_file`（或文件读取工具）读取 `parsed_md_path` 指向的 `parsed.md`。
- **长文档（`page_count > 10`）**：先用 `grep` 在 `parsed_md_path` 或 `chunks_json_path` 中定位目标章节与页码（`page_numbers`），再用 `view_file(StartLine, EndLine)` 切片精读，避免撑爆上下文窗口。

---

## 🤝 跨客户端协同姿势（Antigravity / ChatGPT / DSH / P12 随身秘书）

| 客户端环境 | 触发与协同方式 |
| :--- | :--- |
| **Antigravity / Claude Code / Codex** | 通过全局技能软链与 `AGENTS.md` / `CLAUDE.md` 后缀门禁自动触发 `~/.local/bin/p12-docling`，直接读取返回的 `parsed_md_path`。 |
| **DSH (DeepSeek Harness)** | 挂载于 `~/.dsh/skills/docling-reader`；面对纯文本推理模型（DeepSeek-V3/R1），先执行 `p12-docling` 将复杂 PDF/表格转为结构化 Markdown 再喂入模型。 |
| **ChatGPT macOS 桌面端** | 1. **Codex / Terminal 联动**：直接调用 `~/.local/bin/p12-docling`；<br>2. **Work with Apps 窗口模式**：执行 `~/.local/bin/p12-docling --input <file>` 后在 IDE 打开 `parsed_md_path`，ChatGPT 直接读取当前编辑器中的高清 Markdown 表格。 |
| **P12 智能秘书 (白诗雅)** | 后端 `ai_secretary.rs` 与 `knowledge.rs` 通过 `Semaphore(1)` 受控调用同一脚本，共享 `.docling_cache/` 缓存与 `source_hash` 证据溯源。 |
