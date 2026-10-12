# Agent Guidelines & Skills Configuration

<!-- communication-contract:begin -->
## 协作沟通：极简、精确、结构化

来源：`~/Projects/my-ai-brain/rules/COMMUNICATION_CONTRACT.md`（2026-09-28，用户已确认）。本段为默认直接执行的摘要，无需每轮重新读取原文。

- 先结论，后必要依据和下一步；不铺垫、不复述需求。默认不超过3个核心要点，步骤用编号，对比用表格，不机械凑格式。
- 复杂内容先给精简总览，完整细节放交付文档；用户要求“展开”或明确要求完整内容时再详述。
- 明确区分建议、已确认、已完成、未验证；简短不省略关键风险、限制、依据与剩余事项。
- 需要选择时给推荐方案、关键取舍和一个明确问题；已有授权直接执行，不重复确认。
- 常用顺序：问题=结论→解释；方案=推荐→结构→下一步；完成=结果→验证→剩余；审查=问题→影响→建议。
- 保留适用工程流程、权限与验证要求；确需阶段卡时保持精简。用户本轮明确篇幅/格式优先，本规则不缩减实际工作与交付物完整性。
<!-- communication-contract:end -->

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

## 🗺️ Index-First 三层渐进式代码定位协议 (Mandatory · 严禁盲目全局 Grep)

在排查 Bug 或开发新功能时，**严禁一上来就执行无范围的全局 `grep` 或整篇读取上千行的大文件**，必须严格执行以下 4 步渐进式披露协议：
1. **Step 1 · 宏观锁域 (L0, ~300 Tokens)**：优先读取 `llms.txt` 或执行 `./scripts/code_query.sh feature <关键词>` 检索 `docs/CAPABILITIES.md`，锁定目标功能所属的前端视图与后端路由文件名。
2. **Step 2 · 中观溯源 (L1, ~150 Tokens)**：调用 `./scripts/code_query.sh trace <API或模块名>`（检索 `docs/ARCHITECTURE_SEAMS.json`），一步获取 `UI -> Route -> Storage -> Table` 端到端文件接缝。
3. **Step 3 · 微观定行 (L2, ~100 Tokens)**：针对目标文件执行 `./scripts/code_query.sh outline <文件路径>`（或 `./scripts/code_query.sh symbol <函数名/类名>`），毫秒级获取文件内函数签名与**精确起止行号 (`LStart-LEnd`)**。
4. **Step 4 · 切片读写 (Minimal Context)**：直接调用 `view_file(StartLine, EndLine)` 按行号切片读取目标函数并修改，提交时由 `.git/hooks/pre-commit` 自动增量刷新接缝索引。

## 📄 异构文档零感知高保真精读门禁 (Zero-Prompt Docling Gate · Mandatory)

凡遇到用户要求读取、分析、对比、总结或入库 `.pdf`、`.docx`、`.pptx`、`.xlsx` 文件：
1. **零提醒自动拦截**：**严禁等待用户提醒“用 docling”**，且**严禁**直接使用 `pypdf`、`pdfplumber`、`pdftotext` 提取残缺文本；必须无条件自动调用 `~/.local/bin/p12-docling --input "<file_path>"`。
2. **原件原位保护与缓存直读**：严禁移动或重命名用户的原始文档；直接读取命令 JSON 回执中的 `parsed_md_path`（指向 `.docling_cache/<sha256>/parsed.md`，二次读取 0ms 秒回）。

## Agent skills

### Issue tracker
GitHub Issues via `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels
Canonical five-role vocabulary. See `docs/agents/triage-labels.md`.

### Domain docs
Single-context (`CONTEXT.md` + `docs/adr/` at repo root). See `docs/agents/domain.md`.

### Automated Engineering SOPs Reference
Full specification: see `docs/agents/engineering_sop.md`.
