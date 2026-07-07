#!/usr/bin/env python3
"""Run the production PocketBase auth/rules smoke for XjMVVM.

This uses the checked-in pocketbase/pb_migrations directory, creates temporary
runtime data, provisions a superuser and two auth users, and proves that
Customer records are only visible and mutable by their owner.
"""

from __future__ import annotations

import argparse
import json
import shutil
import signal
import subprocess
import tempfile
import time
from pathlib import Path

from pocketbase_smoke import (
    DEFAULT_HOST,
    DEFAULT_VERSION,
    pocketbase_binary,
    request_json,
    stop_process,
)


DEFAULT_PORT = 8100
SUPER_EMAIL = "xjmvvm-superuser@example.com"
SUPER_PASSWORD = "correct-horse-battery-123"
OWNER_EMAIL = "owner@example.com"
OWNER_PASSWORD = "owner-password-123"
OTHER_EMAIL = "other@example.com"
OTHER_PASSWORD = "other-password-123"


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def run_checked(cmd: list[str], cwd: Path) -> None:
    result = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True)
    if result.returncode != 0:
        raise SystemExit(
            "Command failed:\n"
            + " ".join(cmd)
            + "\nSTDOUT:\n"
            + result.stdout
            + "\nSTDERR:\n"
            + result.stderr
        )


def wait_for_auth(base_url: str, timeout: int, proc: subprocess.Popen[str]) -> None:
    deadline = time.time() + timeout
    last_status = 0
    last_error = ""
    while time.time() < deadline:
        if proc.poll() is not None:
            output = proc.stdout.read() if proc.stdout is not None else ""
            raise SystemExit(f"PocketBase exited before auth was ready.\n{output}")
        try:
            status, _ = request_json("POST", f"{base_url}/api/collections/_superusers/auth-with-password", {
                "identity": SUPER_EMAIL,
                "password": SUPER_PASSWORD,
            })
            last_status = status
            if status == 200:
                return
        except Exception as exc:
            last_error = str(exc)
        time.sleep(0.25)
    raise SystemExit(f"PocketBase auth did not become ready within {timeout}s; last status={last_status}; last error={last_error}")


def auth_token(base_url: str, collection: str, identity: str, password: str) -> tuple[str, dict]:
    status, payload = request_json("POST", f"{base_url}/api/collections/{collection}/auth-with-password", {
        "identity": identity,
        "password": password,
    })
    if status != 200 or not payload.get("token"):
        raise SystemExit(f"Auth failed for {collection}/{identity}: HTTP {status} {payload}")
    return payload["token"], payload["record"]


def create_user(base_url: str, super_token: str, email: str, password: str, name: str) -> dict:
    status, payload = request_json("POST", f"{base_url}/api/collections/users/records", {
        "email": email,
        "password": password,
        "passwordConfirm": password,
        "verified": True,
        "name": name,
    }, token=super_token)
    if status not in {200, 201}:
        raise SystemExit(f"User create failed for {email}: HTTP {status} {payload}")
    return payload


def require_denied(status: int, payload: dict, label: str) -> None:
    if 200 <= status < 300:
        raise SystemExit(f"{label} unexpectedly succeeded: HTTP {status} {payload}")


def run_smoke(base_url: str) -> dict:
    super_token, _ = auth_token(base_url, "_superusers", SUPER_EMAIL, SUPER_PASSWORD)
    owner = create_user(base_url, super_token, OWNER_EMAIL, OWNER_PASSWORD, "Owner User")
    other = create_user(base_url, super_token, OTHER_EMAIL, OTHER_PASSWORD, "Other User")
    owner_token, owner_auth = auth_token(base_url, "users", OWNER_EMAIL, OWNER_PASSWORD)
    other_token, other_auth = auth_token(base_url, "users", OTHER_EMAIL, OTHER_PASSWORD)

    create_body = {
        "owner": owner_auth["id"],
        "first_name": "Ada",
        "last_name": "Lovelace",
        "email": "ada@example.com",
        "date_of_birth": "1815-12-10",
        "gender": "female",
    }

    status, denied_create = request_json("POST", f"{base_url}/api/collections/customers/records", create_body)
    require_denied(status, denied_create, "unauthenticated create")

    status, created = request_json("POST", f"{base_url}/api/collections/customers/records", create_body, token=owner_token)
    if status not in {200, 201}:
        raise SystemExit(f"Owner create failed: HTTP {status} {created}")
    record_id = created.get("id")
    if not record_id:
        raise SystemExit(f"Owner create response did not include id: {created}")

    status, owner_list = request_json("GET", f"{base_url}/api/collections/customers/records?page=1&perPage=10", token=owner_token)
    if status != 200 or owner_list.get("totalItems") != 1:
        raise SystemExit(f"Owner list failed: HTTP {status} {owner_list}")

    status, guest_list = request_json("GET", f"{base_url}/api/collections/customers/records?page=1&perPage=10")
    if status != 200 or guest_list.get("totalItems") != 0:
        raise SystemExit(f"Guest list should be filtered empty: HTTP {status} {guest_list}")

    status, other_list = request_json("GET", f"{base_url}/api/collections/customers/records?page=1&perPage=10", token=other_token)
    if status != 200 or other_list.get("totalItems") != 0:
        raise SystemExit(f"Other user list should be filtered empty: HTTP {status} {other_list}")

    status, denied_view = request_json("GET", f"{base_url}/api/collections/customers/records/{record_id}", token=other_token)
    require_denied(status, denied_view, "cross-user view")

    status, updated = request_json("PATCH", f"{base_url}/api/collections/customers/records/{record_id}", {
        "last_name": "Byron",
    }, token=owner_token)
    if status != 200 or updated.get("last_name") != "Byron":
        raise SystemExit(f"Owner update failed: HTTP {status} {updated}")

    status, denied_update = request_json("PATCH", f"{base_url}/api/collections/customers/records/{record_id}", {
        "last_name": "Wrong",
    }, token=other_token)
    require_denied(status, denied_update, "cross-user update")

    status, deleted = request_json("DELETE", f"{base_url}/api/collections/customers/records/{record_id}", token=owner_token)
    if status not in {200, 204}:
        raise SystemExit(f"Owner delete failed: HTTP {status} {deleted}")

    return {
        "base_url": base_url,
        "owner_user_id": owner["id"],
        "other_user_id": other["id"],
        "auth_owner_id": owner_auth["id"],
        "auth_other_id": other_auth["id"],
        "record_id": record_id,
        "owner_list_total": owner_list.get("totalItems"),
        "guest_list_total": guest_list.get("totalItems"),
        "other_list_total": other_list.get("totalItems"),
        "updated_last_name": updated.get("last_name"),
    }


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
    temp_root = Path(tempfile.mkdtemp(prefix="xjmvvm-pocketbase-production-"))
    pb_data = temp_root / "pb_data"
    migrations_src = repo_root() / "pocketbase" / "pb_migrations"
    migrations_dst = temp_root / "pb_migrations"
    shutil.copytree(migrations_src, migrations_dst)

    run_checked([
        str(binary),
        "superuser",
        "create",
        SUPER_EMAIL,
        SUPER_PASSWORD,
        f"--dir={pb_data}",
    ], temp_root)

    cmd = [
        str(binary),
        "serve",
        f"--http={args.host}:{args.port}",
        f"--dir={pb_data}",
        f"--migrationsDir={migrations_dst}",
    ]

    proc = subprocess.Popen(
        cmd,
        cwd=temp_root,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        start_new_session=True,
    )

    try:
        wait_for_auth(base_url, args.startup_timeout, proc)
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
