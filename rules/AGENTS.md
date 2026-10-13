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

### 🚨 Automated Engineering SOP Interception Protocol

遇到跨模块 Bug、新特性开发或全仓架构治理时，首轮回复须附带紧凑阶段卡；**纯技术咨询、方案探讨或 Lite Mode 局部修改豁免阶段卡与 GitHub Issue**：

```markdown
> 📌 **[SOP 名称]** `[■■□□□] 阶段 X/Y: 阶段名称` | **关联工单**: `#ID` (若有)
> **当前目标**: [一句话描述当前目标] | **下一步驱动**: [主动引导用户进入下一步动作]
```

### 四级弹性 SOP 路由与豁免边界（详见 `docs/agents/engineering_sop.md`）
- **Lite Mode (极简极速通道 · 零流程包袱)**：
  - **适用范围**：纯文案/样式微调、静态配置修正、**单文件内明确局部修复（无跨接缝 `UI->Route->Storage->Table` 及 Schema 变更）**。
  - **豁免机制**：**显式豁免 `gh issue create`**；免多轮机械阶段卡，直奔最小修改并运行 `./scripts/verify_fast.sh`，严禁流程内耗。
- **SOP-1 (Bug 缺陷攻坚 - 5步)**：跨模块或根因不明 Bug $\to$ 登记 `gh issue create` 与 `changelog.md` $\to$ 必红复现闭环（`diagnosing-bugs`）$\to$ 假设验证 $\to$ TDD 修复 $\to$ `./scripts/verify_fast.sh` 与预发验证四维回执。
- **SOP-2 (特性演进 Idea → Ship - 4步)**：大模糊需求先走 `/wayfinder` $\to$ `/grill-with-docs` 盘问边界 $\to$ `/to-spec` 合成 Spec $\to$ 单会话直接实施 / 多会话走 `/to-tickets` 切片 $\to$ 逐单 TDD $\to$ `/code-review`。
- **SOP-3A / SOP-3B (审查与治理)**：日常 PR 走 **SOP-3A (2步)**（`/code-review` 双轴快审 + `/ponytail-review` 净删减）；架构加深走 **SOP-3B (4步)**（`/improve-codebase-architecture` + `/grill-with-docs` + `Expand-Contract` 重构 + 双轴验收）。

### 双层技能架构与触发契约（0 Token 常驻编排器）
- **L1 常驻模型自触发原语**：`diagnosing-bugs`（必红复现）、`tdd`（公共接缝红绿切片）、`codebase-design`（深模块隐藏实现）、`domain-modeling`（实时内联 `GLOSSARY.md` 与 ADR）、`ponytail`（YAGNI 极简）、`code-review`（Standards+Spec 双轴审查）。
- **L2 人类显式编排器（`disable-model-invocation: true` · 0 常驻 Token）**：主干编排器（`/grill-with-docs`, `/to-spec`, `/to-tickets`, `/implement`, `/retro`）及治理路由（`/wayfinder`, `/triage`, `/improve-codebase-architecture`, `/ask-matt`）不占常驻 `<skills>`，由用户 `/<name>` 或阶段卡推进时按需加载 `~/.gemini/config/skills/<name>/SKILL.md`。

## 🗺️ Index-First 穿透式代码定位与左移验证协议 (严禁全仓盲目 Grep)

排查 Bug 或开发新功能时，严禁无范围全局 `grep` 或整篇读取大文件，执行高效定位闭环：
1. **Step 0 · 复合穿透 (首选, ~150 Tokens)**：优先调用 `./scripts/code_query.sh locate <关键词>`，单步穿透 Seam 接缝并直接内联输出核心文件 Outline 与精确起止行号 `[LStart-LEnd]`（**单次交互节省 2 轮 Tool 往返**）。
2. **Step 1 · 宏观与中观拆解 (备用)**：如需分步排查，执行 `./scripts/code_query.sh feature <关键词>`（读业务文档）或 `trace <模块>`（检索 `docs/ARCHITECTURE_SEAMS.json`）。
3. **Step 2 · 微观定行与切片读写**：针对目标文件执行 `./scripts/code_query.sh outline <文件>` 或 `symbol <符号>` 获取精确 `[LStart-LEnd]`，调用 `view_file` 按行切片读写。
4. **Step 3 · Shift-Left 秒级快检**：提交前运行 `./scripts/verify_fast.sh` 完成增量编译/静态类型检查，由 Git Hook 自动保障质量。

## 📄 异构文档零感知高保真精读门禁 (Zero-Prompt Docling Gate · Mandatory)

凡遇到用户要求读取、分析、对比、总结或入库 `.pdf`、`.docx`、`.pptx`、`.xlsx` 文件：
1. **零提醒自动拦截**：**严禁等待用户提醒“用 docling”**，且**严禁**直接使用 `pypdf`、`pdfplumber`、`pdftotext` 提取残缺文本；必须无条件自动调用 `~/.local/bin/p12-docling --input "<file_path>"`。
2. **原件原位保护与缓存直读**：严禁移动或重命名用户的原始文档；直接读取命令 JSON 回执中的 `parsed_md_path`（指向 `.docling_cache/<sha256>/parsed.md`，二次读取 0ms 秒回）。
