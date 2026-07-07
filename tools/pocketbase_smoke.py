#!/usr/bin/env python3
"""Run a disposable stock PocketBase Customer API smoke test.

The script starts a real PocketBase executable with temporary pb_data and
pb_migrations directories, creates a public test-only customers collection, and
exercises create/list/view/update/delete through the Records API.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
import zipfile
from pathlib import Path


DEFAULT_VERSION = "0.39.5"
DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 8099


def asset_name(version: str) -> str:
    system = platform.system().lower()
    machine = platform.machine().lower()

    if system == "darwin":
        os_name = "darwin"
    elif system == "linux":
        os_name = "linux"
    elif system == "windows":
        os_name = "windows"
    else:
        raise SystemExit(f"Unsupported OS for auto-download: {platform.system()}")

    if machine in {"arm64", "aarch64"}:
        arch = "arm64"
    elif machine in {"x86_64", "amd64"}:
        arch = "amd64"
    elif machine.startswith("armv7"):
        arch = "armv7"
    else:
        raise SystemExit(f"Unsupported CPU for auto-download: {platform.machine()}")

    return f"pocketbase_{version}_{os_name}_{arch}.zip"


def download_pocketbase(version: str, cache_dir: Path) -> Path:
    asset = asset_name(version)
    target_dir = cache_dir / f"v{version}" / asset.removesuffix(".zip")
    exe_name = "pocketbase.exe" if platform.system().lower() == "windows" else "pocketbase"
    binary = target_dir / exe_name
    if binary.exists():
        return binary

    target_dir.mkdir(parents=True, exist_ok=True)
    url = f"https://github.com/pocketbase/pocketbase/releases/download/v{version}/{asset}"
    zip_path = target_dir / asset
    print(f"Downloading PocketBase {version}: {url}")
    urllib.request.urlretrieve(url, zip_path)
    with zipfile.ZipFile(zip_path) as zf:
        zf.extractall(target_dir)
    binary.chmod(0o755)
    return binary


def pocketbase_binary(args: argparse.Namespace) -> Path:
    explicit = args.pocketbase_bin or os.environ.get("POCKETBASE_BIN")
    if explicit:
        binary = Path(explicit).expanduser()
        if not binary.exists():
            raise SystemExit(f"POCKETBASE_BIN does not exist: {binary}")
        return binary

    found = shutil.which("pocketbase")
    if found:
        return Path(found)

    cache_dir = Path(args.cache_dir).expanduser()
    cached = cache_dir / f"v{args.version}" / asset_name(args.version).removesuffix(".zip")
    cached = cached / ("pocketbase.exe" if platform.system().lower() == "windows" else "pocketbase")
    if cached.exists():
        return cached

    if args.no_download:
        raise SystemExit("No pocketbase binary found. Set POCKETBASE_BIN or omit --no-download.")

    return download_pocketbase(args.version, cache_dir)


def write_migration(migrations_dir: Path) -> None:
    migrations_dir.mkdir(parents=True, exist_ok=True)
    (migrations_dir / "1700000000_create_customers.js").write_text(
        """migrate((app) => {
  let collection = new Collection({
    type: "base",
    name: "customers",
    listRule: "",
    viewRule: "",
    createRule: "",
    updateRule: "",
    deleteRule: "",
    fields: [
      { name: "first_name", type: "text", required: true },
      { name: "last_name", type: "text", required: true },
      { name: "email", type: "email", required: false },
      { name: "date_of_birth", type: "text", required: false },
      { name: "gender", type: "text", required: false },
    ],
  })
  app.save(collection)
}, (app) => {
  let collection = app.findCollectionByNameOrId("customers")
  app.delete(collection)
})
""",
        encoding="utf-8",
    )


def request_json(method: str, url: str, data: dict | None = None, timeout: int = 10) -> tuple[int, dict]:
    body = None if data is None else json.dumps(data).encode("utf-8")
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Accept", "application/json")
    if data is not None:
        req.add_header("Content-Type", "application/json")

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            payload = resp.read().decode("utf-8")
            parsed = json.loads(payload) if payload else {}
            return resp.status, parsed
    except urllib.error.HTTPError as exc:
        payload = exc.read().decode("utf-8")
        parsed = json.loads(payload) if payload else {}
        return exc.code, parsed


def wait_for_collection(base_url: str, timeout: int) -> None:
    deadline = time.time() + timeout
    last_error: Exception | None = None
    while time.time() < deadline:
        try:
            status, _ = request_json("GET", f"{base_url}/api/collections/customers/records?page=1&perPage=1")
            if status == 200:
                return
        except Exception as exc:  # network startup window
            last_error = exc
        time.sleep(0.25)
    raise SystemExit(f"PocketBase did not expose customers collection within {timeout}s: {last_error}")


def run_smoke(base_url: str) -> dict:
    create_body = {
        "first_name": "Ada",
        "last_name": "Lovelace",
        "email": "ada@example.com",
        "date_of_birth": "1815-12-10",
        "gender": "female",
    }

    status, created = request_json("POST", f"{base_url}/api/collections/customers/records", create_body)
    if status not in {200, 201}:
        raise SystemExit(f"Create failed: HTTP {status} {created}")
    record_id = created.get("id")
    if not record_id:
        raise SystemExit(f"Create response did not include id: {created}")

    status, listed = request_json("GET", f"{base_url}/api/collections/customers/records?page=1&perPage=10")
    if status != 200 or listed.get("totalItems", 0) < 1:
        raise SystemExit(f"List failed: HTTP {status} {listed}")

    status, viewed = request_json("GET", f"{base_url}/api/collections/customers/records/{record_id}")
    if status != 200 or viewed.get("id") != record_id:
        raise SystemExit(f"View failed: HTTP {status} {viewed}")

    status, updated = request_json(
        "PATCH",
        f"{base_url}/api/collections/customers/records/{record_id}",
        {"last_name": "Byron"},
    )
    if status != 200 or updated.get("last_name") != "Byron":
        raise SystemExit(f"Update failed: HTTP {status} {updated}")

    status, deleted = request_json("DELETE", f"{base_url}/api/collections/customers/records/{record_id}")
    if status not in {200, 204}:
        raise SystemExit(f"Delete failed: HTTP {status} {deleted}")

    return {
        "base_url": base_url,
        "record_id": record_id,
        "listed_total": listed.get("totalItems"),
        "updated_last_name": updated.get("last_name"),
    }


def stop_process(proc: subprocess.Popen[str]) -> None:
    if proc.poll() is not None:
        return
    proc.send_signal(signal.SIGTERM)
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait(timeout=5)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", default=DEFAULT_VERSION)
    parser.add_argument("--pocketbase-bin")
    parser.add_argument("--cache-dir", default="~/.cache/xjmvvm-pocketbase")
    parser.add_argument("--host", default=DEFAULT_HOST)
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    parser.add_argument("--startup-timeout", type=int, default=20)
    parser.add_argument("--no-download", action="store_true")
    parser.add_argument("--keep-temp", action="store_true")
    args = parser.parse_args()

    binary = pocketbase_binary(args)
    base_url = f"http://{args.host}:{args.port}"
    temp_root = Path(tempfile.mkdtemp(prefix="xjmvvm-pocketbase-"))
    pb_data = temp_root / "pb_data"
    pb_migrations = temp_root / "pb_migrations"
    write_migration(pb_migrations)

    cmd = [
        str(binary),
        "serve",
        f"--http={args.host}:{args.port}",
        f"--dir={pb_data}",
        f"--migrationsDir={pb_migrations}",
    ]

    proc = subprocess.Popen(
        cmd,
        cwd=temp_root,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    try:
        wait_for_collection(base_url, args.startup_timeout)
        result = run_smoke(base_url)
        print(json.dumps({"status": "ok", "pocketbase": str(binary), **result}, indent=2))
        return 0
    finally:
        stop_process(proc)
        if args.keep_temp:
            print(f"Kept temp dir: {temp_root}")
        else:
            shutil.rmtree(temp_root, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())
