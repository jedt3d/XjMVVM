#!/usr/bin/env python3
"""Lightweight CI checks for Xojo text projects.

This script is intentionally repo-local so GitHub Actions can validate the
project without relying on a developer machine's Codex skill installation or
the Xojo IDE. It is not a compiler. It checks for mistakes that are cheap and
useful on Linux CI: conflict markers, tag-balance errors, and missing local
manifest references.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


TEXT_EXTENSIONS = {
    ".xojo_code",
    ".xojo_project",
    ".xojo_script",
    ".xojo_window",
    ".xojo_webpage",
    ".xojo_screen",
    ".xojo_menu",
    ".xojo_toolbar",
    ".xojo_report",
    ".xojo_database_connection",
    ".xojo_filetypeset",
    ".xojo_color",
    ".xojo_image",
}

OPAQUE_EXTENSIONS = {
    ".xojo_binary_project",
    ".xojo_resources",
    ".xojo_uistate",
}

OPEN_TAGS = {
    "Attributes",
    "Class",
    "ComputedProperty",
    "Constant",
    "DelegateDeclaration",
    "Enum",
    "EnumValues",
    "Event",
    "EventHandler",
    "Events",
    "ExternalMethod",
    "Getter",
    "Hook",
    "Interface",
    "BuildAutomation",
    "MenuHandler",
    "Method",
    "Module",
    "Note",
    "Property",
    "Session",
    "Setter",
    "Structure",
    "ViewBehavior",
    "ViewProperty",
    "WebPage",
    "WindowCode",
}

MANIFEST_ITEMS = {
    "BuildSteps",
    "Class",
    "Constant",
    "Folder",
    "Interface",
    "MenuBar",
    "Module",
    "Report",
    "Toolbar",
    "WebPage",
    "WebSession",
    "WebView",
    "Window",
}

SKIP_PARTS = {
    ".git",
    ".github",
    ".idea",
    ".vscode",
    ".venv",
    "__pycache__",
    "Builds",
    "node_modules",
    "venv",
}

TAG_RE = re.compile(r"^\s*#tag\s+(.+?)\s*$", re.IGNORECASE)
MANIFEST_RE = re.compile(r"^([A-Za-z]+)=([^;]*);([^;]+);")
CONFLICT_RE = re.compile(r"^(<<<<<<<|=======|>>>>>>>)")


def should_skip(path: Path, root: Path) -> bool:
    rel = path.relative_to(root)
    if any(part in SKIP_PARTS for part in rel.parts):
        return True
    if any(part.startswith("pb_data") for part in rel.parts):
        return True
    return False


def xojo_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*"):
        if path.is_file() and not should_skip(path, root):
            if path.suffix in TEXT_EXTENSIONS or path.suffix in OPAQUE_EXTENSIONS:
                files.append(path)
    return sorted(files)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def tag_name(payload: str) -> str:
    first = payload.split(",", 1)[0].strip()
    return first.split()[0] if first else ""


def scan_tag_balance(path: Path, text: str) -> list[str]:
    issues: list[str] = []
    stack: list[tuple[str, int]] = []

    for line_no, line in enumerate(text.splitlines(), start=1):
        match = TAG_RE.match(line)
        if not match:
            continue

        name = tag_name(match.group(1))
        if name.startswith("End") and len(name) > 3:
            expected = name[3:]
            if not stack:
                issues.append(f"{path}:{line_no}: closing #tag {name} without opener")
                continue
            actual, actual_line = stack.pop()
            if actual.lower() != expected.lower():
                issues.append(
                    f"{path}:{line_no}: closing #tag {name} does not match "
                    f"#tag {actual} from line {actual_line}"
                )
        elif name in OPEN_TAGS:
            stack.append((name, line_no))

    for name, line_no in stack:
        issues.append(f"{path}:{line_no}: unclosed #tag {name}")

    return issues


def scan_manifest(path: Path, root: Path, text: str) -> list[str]:
    issues: list[str] = []
    base = path.parent

    for line_no, line in enumerate(text.splitlines(), start=1):
        match = MANIFEST_RE.match(line)
        if not match:
            continue

        item_type, _name, item_path = match.groups()
        if item_type not in MANIFEST_ITEMS:
            continue
        if item_path.startswith(".."):
            continue

        target = (base / item_path).resolve()
        if not str(target).startswith(str(root.resolve())):
            continue
        if not target.exists():
            issues.append(f"{path}:{line_no}: manifest path does not exist: {item_path}")

    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="Repository root to scan")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    issues: list[str] = []
    counts = {
        "files": 0,
        "text": 0,
        "opaque": 0,
        "tag_balance_issues": 0,
        "manifest_issues": 0,
        "conflict_marker_issues": 0,
    }

    for path in xojo_files(root):
        counts["files"] += 1
        rel = path.relative_to(root)
        if path.suffix in OPAQUE_EXTENSIONS:
            counts["opaque"] += 1
            continue

        counts["text"] += 1
        text = read_text(path)

        for line_no, line in enumerate(text.splitlines(), start=1):
            if CONFLICT_RE.match(line):
                issues.append(f"{rel}:{line_no}: conflict marker found")
                counts["conflict_marker_issues"] += 1

        tag_issues = scan_tag_balance(rel, text)
        counts["tag_balance_issues"] += len(tag_issues)
        issues.extend(tag_issues)

        if path.suffix == ".xojo_project":
            manifest_issues = scan_manifest(rel, root, text)
            counts["manifest_issues"] += len(manifest_issues)
            issues.extend(manifest_issues)

    result = {"status": "ok" if not issues else "failed", "counts": counts, "issues": issues}
    print(json.dumps(result, indent=2))
    return 0 if not issues else 1


if __name__ == "__main__":
    raise SystemExit(main())
