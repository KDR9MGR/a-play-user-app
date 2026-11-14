#!/usr/bin/env python3

import argparse
import json
import os
import sys
from pathlib import Path


def _strip_quotes(value: str) -> str:
    v = value.strip()
    if len(v) >= 2 and ((v[0] == v[-1] == '"') or (v[0] == v[-1] == "'")):
        return v[1:-1].strip()
    return v


def read_dotenv(env_path: Path) -> dict[str, str]:
    if not env_path.exists():
        return {}

    values: dict[str, str] = {}
    for raw in env_path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = _strip_quotes(value)
        if not key:
            continue
        values[key] = value
    return values


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--env-file",
        default=".env",
        help="Path to .env file (default: .env)",
    )
    parser.add_argument(
        "--out",
        default=".dart-defines.json",
        help="Output JSON file path (default: .dart-defines.json)",
    )
    args = parser.parse_args()

    repo_root = Path(os.getcwd())
    env_path = repo_root / args.env_file
    out_path = repo_root / args.out

    env = read_dotenv(env_path)

    # `.env` is declared as a Flutter asset in pubspec.yaml, so everything in
    # it ships inside the IPA/APK in plain text. Secrets belong in Supabase
    # secrets (used by edge functions only), never here.
    server_only = [
        "RESEND_API_KEY",
        "SUPABASE_SERVICE_ROLE_KEY",
        "PAYSTACK_SECRET_KEY",
        "PAYSTACK_TEST_SECRET_KEY",
        "APPLE_SHARED_SECRET",
        "IOS_SHARED_SECRET",
    ]
    leaked = [k for k in server_only if env.get(k)]
    if leaked:
        print(
            f"ERROR: {env_path.name} contains server-side secrets that would be "
            f"bundled into the app: {', '.join(leaked)}.\n"
            "Remove them from .env and keep them in Supabase secrets "
            "(`supabase secrets set ...`).",
            file=sys.stderr,
        )
        return 1

    keys = [
        "SUPABASE_URL",
        "SUPABASE_ANON_KEY",
        "PAYSTACK_PUBLIC_KEY",
        "GOOGLE_MAPS_API_KEY",
        "MAPS_API_KEY",
        "APP_ENV",
    ]
    defines = {k: env[k] for k in keys if env.get(k)}

    out_path.write_text(json.dumps(defines, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

