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

### 双层技能架构（对齐 `mattpocock/skills` 官方 `SKILL-MECHANICS.md`）与三级弹性 SOP
采用 **「常驻模型自触发原语（Model-invoked Primitives）+ 零常驻人类显式编排器（User-invoked `/slash` Orchestrators）」** 双层正交机制：
- **第 1 层 · 常驻模型自触发原语（L1 内联 + 按需读取 `SKILL.md`）**：
  - **`diagnosing-bugs`**：先构建必红最小复现闭环（单测/curl/探针）→ 提出可证伪假设并排查全部调用方根因 → 严禁无复现盲改代码。
  - **`tdd`**：在公共接缝（Seam）处按 `Red -> Green -> Refactor` 垂直示踪弹切片推进，禁止测试内部私有实现细节。
  - **`codebase-design`**：设计深模块（小接口隐藏复杂实现，置于清晰 Seam 处），严禁透传浅模块（Pass-through）。
  - **`domain-modeling`**：主动打磨领域模型与统一语言（实时内联维护项目根 `GLOSSARY.md` / `GLOSSARY-MAP.md`，兼容存量 `CONTEXT.md`，并在 `docs/adr/` 记录不可逆权衡决策）。
  - **`ponytail`**：YAGNI 极简优先，优先复用仓内既有实现/标准库/平台原生能力，拒绝单一实现的抽象层与防御性冗余代码。
  - **`code-review`**：交付前执行 Standards（编码规范与 Fowler 坏味道基线）+ Spec（需求契约一致性）双轴并行子 Agent 审查。
- **第 2 层 · 人类显式编排器（`disable-model-invocation: true`，0 常驻 Token，按需直读 `~/.gemini/config/skills/<name>/SKILL.md`）**：
  - **触发与寻址契约**：第 2 层技能不占用 `<skills>` 常驻列表；当用户输入 `/<name>` 或 SOP 推进至对应阶段时，Agent **必须直接调用 `view_file("/Users/jasonshawn/.gemini/config/skills/<name>/SKILL.md")` 加载并执行**。
  - **主干流（Idea → Ship）**：`/grill-with-docs`（设计树边界盘问 + 实时沉淀 `GLOSSARY.md`/ADR，必要时转 `/prototype` 验证）→ `/to-spec`（合成为结构化 Spec）→ 单会话特性直接 `/implement`；多会话特性走 `/to-tickets`（拆解带阻塞边的垂直切片工单）→ `/implement`（逐单 TDD + `/clear`）或 `/implement-spec`（全图并发子 Agent 实施）→ `/retro`（复盘并加固 Linter/Hook/导航环境）。
  - **支线与治理入口**：`/triage`（外部/存量工单分诊状态机）、`/wayfinder`（跨多会话大型模糊战役 `wayfinder:map` 决策地图，迷雾散去后汇入 `/to-spec`）、`/improve-codebase-architecture`（扫描 Git 热点与浅模块并生成加深重构 HTML 报告）、`/setup-matt-pocock-skills`（单仓首次初始化 `docs/agents/*`）、`/ask-matt`（总路由表）。
- **日常对话四级弹性 SOP 路由（详见 `docs/agents/engineering_sop.md`）**：
  - **Lite Mode (2步极简通道)**：纯文案/样式微调、静态配置修正，或**单文件内明确局部修复（无跨接缝 `UI->Route->Storage->Table` 及 Schema 变更）**，按 `[■□] 阶段 1/2: 极简建单与定位` -> `[■■] 阶段 2/2: 最小修改与快速验证` 闭环。
  - **SOP-1 (Bug 缺陷攻坚 - 5步)**：跨模块或根因不明 Bug → `gh issue create` 登记 `changelog.md` → 必红复现闭环（`diagnosing-bugs`）→ 假设验证 → TDD 修复 → `./scripts/verify_fast.sh` + 预发验证并输出 `[代码已改] -> [单测已过] -> [真实接口/Staging已测] -> [生产待授权]` 四维回执（复杂排障后可选 `/retro`）。
  - **SOP-2 (特性演进 Idea → Ship - 4步)**：（超大模糊需求先走 `/wayfinder`）→ `[■□□□] 1/4: /grill-with-docs 需求深挖与 GLOSSARY/ADR 沉淀` → `[■■□□] 2/4: /to-spec 结构化 Spec 与单/多会话工单分流` → `[■■■□] 3/4: 垂直切片 TDD 实施 (/implement)` → `[■■■■] 4/4: /code-review 双轴审查与预发闭环`。
  - **SOP-3A / SOP-3B (代码审查与架构治理)**：日常分支/PR 审查走 **SOP-3A (2步)**（`/code-review` 双轴并行 + `/ponytail-review` 净删减评估）；模块加深与重构走 **SOP-3B (4步)**（`/improve-codebase-architecture` HTML 报告 + `/grill-with-docs` + 局部垂直切片或全仓 `Expand-Contract` 迁移 + 双轴验收）。

## 🗺️ Index-First 三层渐进式代码定位与左移验证协议 (Mandatory · 严禁盲目全局 Grep)

在包含代码索引脚本的代码仓库中排查 Bug 或开发新功能时，**严禁一上来就执行无范围的全局 `grep` 或整篇读取上千行的大文件**，必须严格执行以下渐进式协议：
1. **Step 1 · 宏观锁域 (L0, ~300 Tokens)**：优先读取 `llms.txt` 或执行 `./scripts/code_query.sh feature <关键词>` 检索 `docs/CAPABILITIES.md`，锁定目标功能所属的前端视图与后端路由文件名。
2. **Step 2 · 中观溯源 (L1, ~150 Tokens)**：调用 `./scripts/code_query.sh trace <API或模块名>`（检索 `docs/ARCHITECTURE_SEAMS.json`），一步获取 `UI -> Route -> Storage -> Table` 端到端文件接缝。
3. **Step 3 · 微观定行 (L2, ~100 Tokens)**：针对目标文件执行 `./scripts/code_query.sh outline <文件路径>`（或 `./scripts/code_query.sh symbol <函数名/类名>`），毫秒级获取文件内函数签名与**精确起止行号 (`LStart-LEnd`)**。
4. **Step 4 · 切片读写与秒级左移验证 (Minimal Context & Shift-Left Gate)**：调用 `view_file(StartLine, EndLine)` 按行号切片读取并局部修改；在执行重型构建前，优先运行 `./scripts/verify_fast.sh` 秒级完成增量编译/类型检查，提交时由 `.git/hooks/pre-commit` 自动增量刷新接缝索引。

## 📄 异构文档零感知高保真精读门禁 (Zero-Prompt Docling Gate · Mandatory)

凡遇到用户要求读取、分析、对比、总结或入库 `.pdf`、`.docx`、`.pptx`、`.xlsx` 文件：
1. **零提醒自动拦截**：**严禁等待用户提醒“用 docling”**，且**严禁**直接使用 `pypdf`、`pdfplumber`、`pdftotext` 提取残缺文本；必须无条件自动调用 `~/.local/bin/p12-docling --input "<file_path>"`。
2. **原件原位保护与缓存直读**：严禁移动或重命名用户的原始文档；直接读取命令 JSON 回执中的 `parsed_md_path`（指向 `.docling_cache/<sha256>/parsed.md`，二次读取 0ms 秒回）。
