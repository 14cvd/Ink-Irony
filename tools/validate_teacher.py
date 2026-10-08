#!/usr/bin/env python3
"""Validate Ms. Irony teacher line files (Ink/Resources/teacher_<lang>.json).

Usage: python3 tools/validate_teacher.py
Exits non-zero if any file has an error.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RESOURCES = ROOT / "Ink" / "Resources"

LANGUAGES = ["en", "tr", "az", "ru", "es"]
TONES = ["strict", "gentle"]
TRIGGERS = [
    "wordStart", "finalExamStart", "correct", "combo", "firstMistake",
    "mistake", "lowLives", "won", "wonFlawless", "wonNarrow", "lost",
    "eraser", "reveal", "hint", "desk", "deskReturning", "dailyDone",
    "gradeAPlus", "gradeA", "gradeAMinus", "gradeB", "gradeC", "gradeD",
    "gradeF",
]
MIN_LINES = {"en": 6}
DEFAULT_MIN_LINES = 4
MAX_LEN = 64
PLACEHOLDER = "{word}"
FANCY_QUOTES = "‘’“”«»„"

# Failure words the gentle tone must never use (case-insensitive word prefixes).
GENTLE_BANNED = {
    "en": ["fail", "wrong", "stupid"],
    "tr": ["yanlış", "başarısız", "aptal"],
    "az": ["yanlış", "səhv", "uğursuz", "axmaq"],
    "ru": ["неправильн", "неверн", "ошибк", "провал", "глуп"],
    "es": ["error", "incorrect", "fracas", "fallo", "estúpid"],
}


def validate(lang):
    errors = []
    path = RESOURCES / f"teacher_{lang}.json"
    if not path.exists():
        return [f"missing file {path}"], 0, {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError) as exc:
        return [f"invalid JSON: {exc}"], 0, {}

    if not isinstance(data, dict):
        return ["top level must be an object"], 0, {}
    extra_keys = set(data) - {"language", *TONES}
    if extra_keys:
        errors.append(f"unexpected top-level keys: {sorted(extra_keys)}")
    if data.get("language") != lang:
        errors.append(f'"language" is {data.get("language")!r}, expected {lang!r}')

    minimum = MIN_LINES.get(lang, DEFAULT_MIN_LINES)
    total = 0
    per_tone = {}
    for tone in TONES:
        block = data.get(tone)
        if not isinstance(block, dict):
            errors.append(f"missing or invalid tone {tone!r}")
            continue
        unknown = set(block) - set(TRIGGERS)
        if unknown:
            errors.append(f"{tone}: unknown triggers {sorted(unknown)}")
        tone_total = 0
        for trigger in TRIGGERS:
            where = f"{tone}.{trigger}"
            lines = block.get(trigger)
            if not isinstance(lines, list):
                errors.append(f"{where}: missing or not a list")
                continue
            if len(lines) < minimum:
                errors.append(f"{where}: {len(lines)} lines, need at least {minimum}")
            seen = set()
            for i, line in enumerate(lines):
                at = f"{where}[{i}]"
                if not isinstance(line, str) or not line.strip():
                    errors.append(f"{at}: empty or not a string")
                    continue
                if line != line.strip():
                    errors.append(f"{at}: leading/trailing whitespace")
                if len(line) > MAX_LEN:
                    errors.append(f"{at}: {len(line)} chars > {MAX_LEN}: {line!r}")
                key = line.strip().casefold()
                if key in seen:
                    errors.append(f"{at}: duplicate line {line!r}")
                seen.add(key)
                if any(q in line for q in FANCY_QUOTES):
                    errors.append(f"{at}: fancy quote character: {line!r}")
                if trigger == "lost":
                    if line.count(PLACEHOLDER) != 1:
                        errors.append(f"{at}: must contain {PLACEHOLDER} exactly once: {line!r}")
                    if line.replace(PLACEHOLDER, "").count("{") or line.replace(PLACEHOLDER, "").count("}"):
                        errors.append(f"{at}: stray brace: {line!r}")
                elif "{" in line or "}" in line:
                    errors.append(f"{at}: braces only allowed in 'lost': {line!r}")
                if tone == "gentle":
                    low = line.casefold()
                    for word in GENTLE_BANNED.get(lang, []):
                        if re.search(r"\b" + re.escape(word), low):
                            errors.append(f"{at}: gentle line uses banned word {word!r}: {line!r}")
            tone_total += len(lines)
        per_tone[tone] = tone_total
        total += tone_total
    return errors, total, per_tone


def main():
    failed = False
    grand_total = 0
    print(f"{'lang':<5} {'strict':>7} {'gentle':>7} {'total':>7}  status")
    for lang in LANGUAGES:
        errors, total, per_tone = validate(lang)
        grand_total += total
        status = "OK" if not errors else f"{len(errors)} error(s)"
        print(f"{lang:<5} {per_tone.get('strict', 0):>7} {per_tone.get('gentle', 0):>7} {total:>7}  {status}")
        for err in errors:
            print(f"      - {err}")
        failed = failed or bool(errors)
    print(f"all   {'':>7} {'':>7} {grand_total:>7}")
    if failed:
        print("FAILED")
        return 1
    print("PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
