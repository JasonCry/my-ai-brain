# 产品能力大地图 (Capability Matrix · Single Source of Truth)

> 💡 **定位与使命**：本文件是本项目的**业务能力与代码入口单一事实源 (SSOT)**。  
> AI Agent 与开发者在定位需求或排查问题时，优先查阅此表锁定模块与关键代码路径，严禁盲目全库 `grep`。

---

## 🏛️ 核心业务能力矩阵

| 能力项 | 状态 | 交付版本 | 核心特性说明 | 关键代码与架构路径 (Code Anchors) | 冒烟验证路径 (Smoke Path) |
| :--- | :---: | :---: | :--- | :--- | :--- |
| **示例模块** | 🟢 已交付 | `v0.1.0` | 核心业务流程示例 | `backend/src/routes/mod.rs`, `flutter_app/lib/main.dart` | 启动服务 -> 访问首页验证 |
