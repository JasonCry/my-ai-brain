#!/usr/bin/env -S /Users/jasonshawn/.local/bin/uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "docling>=2.15.0",
#   "docling-core>=2.10.0",
#   "pyyaml>=6.0",
# ]
# [[tool.uv.index]]
# url = "https://pypi.tuna.tsinghua.edu.cn/simple"
# default = true
# ///
"""
p12-docling: Universal Non-Destructive Document Reader & Shadow Cache Engine
Shared across Antigravity, ChatGPT/Codex, DSH (DeepSeek Harness), Claude Code, and P12 Smart Secretary.

Design Principles:
  1. Zero File Movement: Never moves, renames, or modifies the user's original document.
  2. SHA-256 Shadow Cache: Stores parsed.md and chunks.json in `<project_root>/.docling_cache/<sha256[:16]>/`
     (or `~/.docling_cache/<sha256[:16]>/` for standalone files outside a git/project workspace).
  3. Instant Cache Hit (5ms): Cache hits only use Python stdlib (lazy-loading PyTorch/Docling only on cache miss).
"""
import argparse
import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path


REALM_PROFILES = {
    "health": {"table_mode": "accurate", "ocr": True, "sensitivity": "restricted"},
    "xserver": {"table_mode": "fast", "ocr": False, "sensitivity": "ordinary"},
    "product": {"table_mode": "accurate", "ocr": False, "sensitivity": "ordinary"},
    "wudang": {"table_mode": "fast", "ocr": True, "sensitivity": "ordinary"},
    "hermes": {"table_mode": "accurate", "ocr": True, "sensitivity": "private"},
}


def compute_sha256(file_path: Path) -> str:
    h = hashlib.sha256()
    with file_path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def detect_realm(input_path: Path, requested_realm: str) -> str:
    if requested_realm != "auto" and requested_realm in REALM_PROFILES:
        return requested_realm
    path_lower = str(input_path).lower()
    if any(k in path_lower for k in ("health", "体检", "病历", "化验", "医疗", "医院")):
        return "health"
    if any(k in path_lower for k in ("wudang", "字疏", "书院", "国学", "古籍")):
        return "wudang"
    if any(k in path_lower for k in ("product", "产品", "商业", "竞品")):
        return "product"
    if any(k in path_lower for k in ("hermes", "合同", "发票", "账单", "保单", "行程")):
        return "hermes"
    return "xserver"


def resolve_cache_root(input_path: Path, explicit_vault_dir: str | None) -> tuple[Path, str]:
    """
    Determines where `.docling_cache` should live:
    1. If `--vault-dir` is passed, use `<vault_dir>/.docling_cache`.
    2. If `input_path` is inside a Git repo or Obsidian Vault (`.obsidian` or `.git`), use that root's `.docling_cache`.
    3. Otherwise (e.g., ~/Downloads or ~/Desktop), use `~/.docling_cache` so user Desktop/Downloads stays clean.
    """
    if explicit_vault_dir:
        base = Path(explicit_vault_dir).expanduser().resolve()
        try:
            rel = str(input_path.relative_to(base))
        except ValueError:
            rel = str(input_path)
        return base / ".docling_cache", rel

    curr = input_path.parent
    home = Path.home().resolve()
    while curr != curr.parent and curr != home:
        if (curr / ".git").exists() or (curr / ".obsidian").exists() or (curr / "AGENTS.md").exists():
            try:
                rel = str(input_path.relative_to(curr))
            except ValueError:
                rel = input_path.name
            return curr / ".docling_cache", rel
        curr = curr.parent

    return home / ".docling_cache", str(input_path)


def ensure_gitignore_has_cache(cache_root: Path) -> None:
    """Ensure .docling_cache/.gitignore ignores '*' so git status stays clean."""
    gitignore_inside = cache_root / ".gitignore"
    if not gitignore_inside.exists():
        cache_root.mkdir(parents=True, exist_ok=True)
        gitignore_inside.write_text("# Automatically created by p12-docling\n*\n", encoding="utf-8")


def ingest_document(
    input_path: Path,
    requested_realm: str = "auto",
    vault_dir: str | None = None,
    title: str | None = None,
    force: bool = False,
) -> dict:
    input_path = input_path.expanduser().resolve()
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    realm = detect_realm(input_path, requested_realm)
    profile = REALM_PROFILES.get(realm, REALM_PROFILES["xserver"])

    raw_sha256 = compute_sha256(input_path)
    source_hash = f"sha256:{raw_sha256}"
    hash_prefix = raw_sha256[:16]

    cache_root, orig_rel_path = resolve_cache_root(input_path, vault_dir)
    cache_dir = cache_root / hash_prefix
    md_path = cache_dir / "parsed.md"
    chunks_path = cache_dir / "chunks.json"

    # 1. Fast-path: SHA-256 Cache Hit (5ms, zero heavy imports!)
    if not force and md_path.exists() and chunks_path.exists():
        try:
            cached_meta = json.loads(chunks_path.read_text(encoding="utf-8"))
        except Exception:
            cached_meta = {}
        return {
            "status": "ok",
            "cache_hit": True,
            "realm_id": realm,
            "original_path": str(input_path),
            "original_rel_path": orig_rel_path,
            "parsed_md_path": str(md_path),
            "chunks_json_path": str(chunks_path),
            "source_hash": source_hash,
            "page_count": cached_meta.get("page_count", 1),
            "chunk_count": len(cached_meta.get("chunks", [])),
        }

    # 2. Cache Miss: Lazy import Docling & PyTorch (with HF Mirror acceleration)
    os.environ.setdefault("HF_ENDPOINT", "https://hf-mirror.com")
    import yaml
    from docling.chunking import HybridChunker
    from docling.datamodel.base_models import InputFormat
    from docling.datamodel.pipeline_options import (
        PdfPipelineOptions,
        TableFormerMode,
    )
    from docling.document_converter import DocumentConverter, PdfFormatOption

    pipeline_options = PdfPipelineOptions()
    pipeline_options.do_table_structure = True
    pipeline_options.table_structure_options.mode = (
        TableFormerMode.ACCURATE if profile["table_mode"] == "accurate" else TableFormerMode.FAST
    )
    pipeline_options.do_ocr = profile["ocr"]

    converter = DocumentConverter(
        format_options={
            InputFormat.PDF: PdfFormatOption(pipeline_options=pipeline_options)
        }
    )

    conv_result = converter.convert(str(input_path))
    doc = conv_result.document
    md_body = doc.export_to_markdown()
    page_count = len(doc.pages) if hasattr(doc, "pages") else 1

    # 3. Structural Hybrid Chunking
    chunker = HybridChunker()
    chunks_data = []
    for idx, chunk in enumerate(chunker.chunk(dl_doc=doc)):
        pages = sorted({
            prov.page_no
            for item in chunk.meta.doc_items
            for prov in getattr(item, "prov", [])
            if hasattr(prov, "page_no")
        })
        chunks_data.append({
            "chunk_index": idx,
            "headings": list(chunk.meta.headings or []),
            "page_numbers": pages,
            "text": chunker.contextualize(chunk=chunk),
        })

    # 4. Write to Shadow Cache (.docling_cache/<hash_prefix>/)
    ensure_gitignore_has_cache(cache_root)
    cache_dir.mkdir(parents=True, exist_ok=True)

    doc_title = title or input_path.stem
    frontmatter = {
        "docling_schema_version": 1,
        "title": doc_title,
        "realm_id": realm,
        "scope": "realm",
        "subject_id": "self",
        "verification": "candidate",
        "lifecycle": "active",
        "sensitivity": profile["sensitivity"],
        "source_ref": {
            "source_id": f"raw:{realm}:{hash_prefix}",
            "original_rel_path": orig_rel_path,
            "source_hash": source_hash,
            "page_count": page_count,
            "parser_version": "docling-v2",
            "ingested_at": int(time.time()),
        },
    }

    yaml_header = yaml.safe_dump(frontmatter, allow_unicode=True, sort_keys=False)
    md_path.write_text(f"---\n{yaml_header}---\n\n{md_body}\n", encoding="utf-8")

    chunks_path.write_text(
        json.dumps(
            {
                "doc_id": f"{realm}:{orig_rel_path}",
                "original_rel_path": orig_rel_path,
                "source_hash": source_hash,
                "page_count": page_count,
                "chunks": chunks_data,
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )

    return {
        "status": "ok",
        "cache_hit": False,
        "realm_id": realm,
        "original_path": str(input_path),
        "original_rel_path": orig_rel_path,
        "parsed_md_path": str(md_path),
        "chunks_json_path": str(chunks_path),
        "source_hash": source_hash,
        "page_count": page_count,
        "chunk_count": len(chunks_data),
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="p12-docling: Non-Destructive Structured Document Reader & Shadow Cache"
    )
    parser.add_argument("--input", "-i", required=True, help="Path to input document (.pdf, .docx, .pptx, .xlsx)")
    parser.add_argument(
        "--realm",
        "-r",
        default="auto",
        choices=["auto", *REALM_PROFILES.keys()],
        help="Target realm profile (default: auto-detect from path)",
    )
    parser.add_argument("--vault-dir", "-v", default=None, help="Optional project/vault root directory")
    parser.add_argument("--title", "-t", default=None, help="Optional document title")
    parser.add_argument("--force", "-f", action="store_true", help="Force re-parse ignoring SHA-256 cache")
    parser.add_argument("--open", action="store_true", help="Open parsed.md in macOS default editor/IDE after parsing")
    args = parser.parse_args()

    try:
        receipt = ingest_document(
            input_path=Path(args.input),
            requested_realm=args.realm,
            vault_dir=args.vault_dir,
            title=args.title,
            force=args.force,
        )
        if args.open and receipt.get("parsed_md_path"):
            subprocess.run(["open", receipt["parsed_md_path"]], check=False)
        print(json.dumps(receipt, ensure_ascii=False))
    except Exception as exc:
        print(json.dumps({"status": "error", "message": str(exc)}, ensure_ascii=False), file=sys.stderr)
        sys.exit(1)
