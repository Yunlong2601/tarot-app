#!/usr/bin/env python3
"""Count the characters of each store-listing field in docs/store-listing.md."""
import pathlib, re, sys

text = (pathlib.Path(__file__).resolve().parent.parent / "docs" / "store-listing.md").read_text()
limits = {"Name": 30, "Subtitle": 30, "Keywords (comma-separated, no spaces)": 100, "Title": 30, "Short description": 80}
bad = 0
for label, limit in limits.items():
    for m in re.finditer(rf"^- \*\*{re.escape(label)}:\*\* (.+)$", text, flags=re.M):
        n = len(m.group(1).strip())
        ok = n <= limit
        bad += not ok
        print(f"{'ok  ' if ok else 'OVER'} {label}: {n}/{limit}  {m.group(1).strip()[:60]}")
m = re.search(r"- \*\*Description:\*\*\n\n(.*?)\n\n- \*\*Support", text, flags=re.S)
if m:
    n = len(m.group(1))
    print(f"{'ok  ' if n <= 4000 else 'OVER'} Description: {n}/4000")
    bad += n > 4000
sys.exit(1 if bad else 0)
