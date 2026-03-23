#!/usr/bin/env python3
"""Deterministically parse the raw argument string that follows ---audit."""

from __future__ import annotations

import json
import shlex
import sys


def main() -> int:
    if len(sys.argv) == 2:
        raw = sys.argv[1]
    elif len(sys.argv) == 1:
        raw = sys.stdin.read().strip()
        if not raw:
            print(
                json.dumps(
                    {
                        "ok": False,
                        "error": "usage: parse-audit-args.py \"[raw args after ---audit]\" or pipe raw args on stdin",
                    },
                    ensure_ascii=False,
                )
            )
            return 2
    else:
        print(
            json.dumps(
                {
                    "ok": False,
                    "error": "usage: parse-audit-args.py \"[raw args after ---audit]\" or pipe raw args on stdin",
                },
                ensure_ascii=False,
            )
        )
        return 2

    raw = raw.lstrip("\ufeff")
    try:
        args = shlex.split(raw, posix=True)
    except ValueError as exc:
        print(json.dumps({"ok": False, "raw": raw, "error": str(exc)}, ensure_ascii=False))
        return 1

    print(json.dumps({"ok": True, "raw": raw, "args": args}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
