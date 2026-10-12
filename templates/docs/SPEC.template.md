---
issue_id: "#000"
status: "draft" # draft | approved | implemented | verified
owner_sop: "SOP-2"
affected_seams:
  - ui: ""
  - route: ""
  - storage: ""
  - table: ""
verify_commands:
  - "./scripts/verify_fast.sh"
  - "./scripts/deploy_staging.sh"
---

# [Feature / Refactor Name] 技术实施契约 (Spec-Driven Development)

## 1. 目标与非目标 (Goals & Non-Goals)
- **Goals (做什么)**:
  - 
- **Non-Goals (明确不做什么 · YAGNI)**:
  - 

## 2. 深模块接口与接缝设计 (Deep Module Interface & Seams)
- **公共接缝签名 (Public Seam Interface)**:
  - 
- **数据流与存储契约 (`UI -> Route -> Storage -> Table`)**:
  - 

## 3. 垂直示踪弹切片与 TDD 计划 (Vertical Tracer-Bullet Slices)
1. **Slice 1 (Red -> Green)**: 
2. **Slice 2 (Red -> Green)**: 

## 4. 验收清单 (Acceptance Criteria · 供 `/code-review` Spec 轴逐项核验)
- [ ] AC-1: 
- [ ] AC-2: 
- [ ] AC-3: Staging (`localhost:3020`) 真实接口与控制台 0 报错验证通过
