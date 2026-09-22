#!/usr/bin/env python3
"""
distill_doc.py - Helper script to validate, create, or index documents in SoftwareDevKnowledgeBase.
"""

import os
import sys

KB_ROOT = os.environ.get("SOFTWARE_DEV_KB_ROOT", os.path.expanduser("~/Projects/SoftwareDevKnowledgeBase"))

CATEGORIES = {
    "1": ("01-Architecture-And-Design", "系统架构与设计"),
    "2": ("02-DevOps-And-Deployment", "运维部署与网络穿透"),
    "3": ("03-Backend-Engineering", "后端工程与高并发"),
    "4": ("04-Frontend-And-CrossPlatform", "前端与跨平台开发"),
    "5": ("05-Security-And-Compliance", "安全合规与证书管理"),
    "6": ("06-Troubleshooting-And-SOP", "故障排查与 SOP"),
}

def main():
    if not os.path.exists(KB_ROOT):
        print(f"Error: Knowledge base root not found at {KB_ROOT}")
        sys.exit(1)
    
    print("==================================================")
    print("📚 软件工程知识库沉淀助手 (Knowledge Distillation)")
    print("==================================================")
    for k, (folder, name) in CATEGORIES.items():
        print(f"[{k}] {folder} - {name}")
    print("==================================================")

if __name__ == "__main__":
    main()
