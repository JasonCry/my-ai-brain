# 全局多项目基础设施与端口注册表 (Port Allocation Registry)

> 💡 **单一事实源**：本注册表是所有独立软件项目在开发机（MacBook Air / Mac Mini）与生产部署时的**权威端口分配图**。  
> 任何新项目、新服务严禁随意占用既有端口段，杜绝本地冲突与服务踩踏。

---

## 🏛️ 权威端口占用与拓扑分配总表

| 端口 | 监听进程 / 服务 | 项目归属 | 环境类型 | 详细用途说明 |
| :---: | :--- | :--- | :---: | :--- |
| **`3000`** | `gtd-backend` | **P12 (AI 随身秘书)** | 🟢 生产 (Prod) | GTD 主应用 Web 访问与核心 API 接口 (`https://gtdcalendar.xyz`) |
| **`3001`** | `gtd-backend` | **P12 (AI 随身秘书)** | 🟢 生产 (Prod) | 国学独立门户 Web 访问 (`https://guoxue.gtdcalendar.xyz`) |
| **`3002`** | `wudang-backend` | **字疏·书院** | 🟢 生产 (Prod) | 「字疏·书院」对外正式服务端口，Rust Axum 托管 Flutter Web + API，通过 FRP 穿透至 ECS / `wudang.gtdcalendar.xyz` |
| **`3010`** | `wudang-staging` | **字疏·书院** | 🧪 预发 (Staging) | 「字疏·书院」本地测试与验收环境（Staging Gate 规范备用），本地验收通过后方可上发 3002 |
| **`3020`** | `gtd-backend` | **P12 (AI 随身秘书)** | 🧪 预发 (Staging) | GTD 主应用本地 Staging 测试与验收入口 (`http://localhost:3020`) |
| **`3021`** | `gtd-backend` | **P12 (AI 随身秘书)** | 🧪 预发 (Staging) | 国学独立门户本地 Staging 测试与验收入口 (`http://localhost:3021`) |
| **`3080`** | `node` | **公共基础设施** | 🛠️ 开发与管理 | Node.js 前端开发 / Web 管理界面及脚手架辅助服务 |
| **`8445`** | `wudang-proxy` | **字疏·书院** | 🌐 移动网络放行 | 适配阿里云未备案拦截的移动端 API 高位放行端口 |

---

## 🔮 新项目预留与接入规约 (Reserved Allocation)

未来新增第三、第四款软件时，端口分配遵循以下梯次规划，严禁抢占 3000~3021 与 3080：

1. **项目 3 预留段**：
   - 生产对外服务 (Prod)：`3003`
   - 本地预发验收 (Staging Gate)：`3023`
   - 伴生服务/后台：`3013`
2. **项目 4 预留段**：
   - 生产对外服务 (Prod)：`3004`
   - 本地预发验收 (Staging Gate)：`3024`
   - 伴生服务/后台：`3014`

---

## 🛡️ 数据与运行态隔离铁律

1. **数据库物理隔离**：
   - P12 数据库严格存放于自身仓库 `backend/data/` 或 `p12.db`；
   - 字疏书院数据库严格存放于自身仓库 `backend/wudang.db`；
   - 严禁任何跨项目共享或软链数据库文件。
2. **Staging First 铁律**：
   - P12 代码改动必须先在 `localhost:3020/3021` 验收；
   - 字疏书院改动必须先在 `localhost:3010` 验收；
   - 未经用户在 Staging 显式通过前，绝对禁止重启、杀死或覆盖生产服务进程（3000/3001/3002）。
