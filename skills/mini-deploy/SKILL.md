---
name: mini-deploy
description: >-
  Standardized zero-compilation production deployment skill for Mac Mini with ultra-lean token usage (<500 tokens).
  Seamlessly auto-detects between WuDangShuYuan (字疏·书院) and P12_Personal_Work_Assistant (AI 智能随身秘书) based
  on git remote, triggers local release hot-reload without touching .env, enforces macOS ARM64 code signing,
  and verifies health status in a single step. Trigger whenever the user asks to "上线", "部署", "热更", "生产部署",
  "mini-deploy", or mentions deploying on Mac Mini.
---

# Mac Mini 跨项目免编译极简部署技能 (Mini Deploy Skill)

本技能确立了在 **Mac Mini（纯净生产机）** 上对 **「字疏·书院」** 与 **「AI 智能随身秘书」** 进行免编译、零 Token 浪费、单步收敛的标准上线规范。

---

## 🧭 核心哲学与安全刚性红线 (The Taboos)

1. **单步收敛门禁 (Single-Turn Gate · 严格节省 Token)**：
   - 严禁进行任何发散式文件查找、全局 Grep、查看历史提交或反复翻查系统日志；
   - 严禁通过多轮对话询问用户“你想部署哪个端口”或“请提供 .env”；
   - 必须直接单步调用封装好的全局分发工具 `mini-deploy`，捕获结构化状态后一次性汇报闭环。
2. **生产数据孤岛铁律 (Absolute Data Safety)**：
   - Mac Mini 本地的生产真实数据库（`backend/wudang.db`、`p12.db`）与核心凭证（`.env`）拥有最高安全级别；
   - 严禁任何发布包覆盖本地数据库与用户上传资产。
3. **macOS ARM64 内核安全签名合规**：
   - 所有从 GitHub Releases 拉取的 ARM64 原生二进制文件必须由脚本自动执行 `xattr -cr` 与 `codesign --force --deep -s -`，彻底杜绝 `OS_REASON_CODESIGNING` 异常终止。

---

## 📋 触发场景与意图匹配

当用户表达如下意图时，自动激活本技能：
- “把最新版本上线”、“在 macmini 上部署一下”、“生产热更”
- “部署最新版”、“上线”、“/deploy”、“mini-deploy”
- “检查生产服务状态”、“看看两个服务是否正常”

---

## ⚡ 标准执行流程 (Single-Step Workflow)

### 步骤 1：单步调用分发器
根据用户意图直接执行对应的 `mini-deploy` 命令（**严禁添加前置探测命令**）：

- **常规部署（自动感知当前项目）**：
  ```bash
  mini-deploy
  ```
- **显式指定项目部署**：
  ```bash
  mini-deploy wudang   # 部署字疏·书院 (端口 3002, 守护 com.jason.wudang)
  mini-deploy p12      # 部署随身秘书 (端口 3000, 守护 com.jason.p12gtd)
  ```
- **仅巡检当前服务状态**：
  ```bash
  mini-deploy status
  ```
- **演练自检模式（不触碰生产实物）**：
  ```bash
  mini-deploy --dry-run
  ```

### 步骤 2：捕获结果并结构化汇报
脚本执行完毕后，直接提取关键指标向用户汇报：
- **项目名称与版本号**；
- **进程状态与监听端口**；
- **健康探活 HTTP 返回码**。

---

## 💡 终端 0 Token 独立运行姿态

如果用户在 Mac Mini 终端前，无需打开 Antigravity，直接在终端输入即可秒级完成：
```bash
# 自动感知当前目录项目并部署
mini-deploy

# 查看所有服务状态
mini-deploy status
```
