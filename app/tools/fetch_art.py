#!/usr/bin/env python3
"""Download public-domain Rider-Waite-Smith card scans from Wikimedia Commons.

Run on your own machine (the cloud sandbox cannot reach Commons):
    python3 tools/fetch_art.py            # fetch missing cards
    python3 tools/fetch_art.py --check    # only report licence info, no download

For each card it asks the Commons API for the licence, author and source, saves
the image to assets/cards/art/<card_id>.jpg (resized to 480px wide to keep the
app small) and appends a line to assets/cards/art/CREDITS.md.

The Commons file titles below are best guesses and are NOT verified. The script
prints every title it cannot find or whose licence is not public domain. YOU
must review the list, look at each file page, and confirm the scan is of the
1909 Pamela Colman Smith printing (not a 1971+ US Games recolouring).
"""
import json
import pathlib
import sys
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
ART = ROOT / "assets" / "cards" / "art"
API = "https://commons.wikimedia.org/w/api.php"
UA = "ShenTarotArtFetcher/0.1 (student project; contact: shenyunlongbusiness@gmail.com)"
MAJOR = ["Fool", "Magician", "High_Priestess", "Empress", "Emperor", "Hierophant",
         "Lovers", "Chariot", "Strength", "Hermit", "Wheel_of_Fortune", "Justice",
         "Hanged_Man", "Death", "Temperance", "Devil", "Tower", "Star", "Moon",
         "Sun", "Judgement", "World"]
SUIT_PREFIX = {"wands": "Wands", "cups": "Cups", "swords": "Swords", "pentacles": "Pents"}
RANKS = ["ace", "two", "three", "four", "five", "six", "seven", "eight", "nine",
         "ten", "page", "knight", "queen", "king"]


def titles():
    cards = json.loads((ROOT / "assets/cards/cards.json").read_text())["cards"]
    for c in cards:
        if c["arcana"] == "major":
            n = c["number"]
            yield c["id"], f"File:RWS_Tarot_{n:02d}_{MAJOR[n]}.jpg"
        else:
            rank = c["id"].split("_", 1)[1]
            yield c["id"], f"File:{SUIT_PREFIX[c['suit']]}{RANKS.index(rank) + 1:02d}.jpg"


def api(params):
    url = API + "?" + urllib.parse.urlencode({**params, "format": "json"})
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def info(title):
    d = api({"action": "query", "prop": "imageinfo", "titles": title,
             "iiprop": "url|extmetadata", "iiurlwidth": 480})
    page = next(iter(d["query"]["pages"].values()))
    if "imageinfo" not in page:
        return None
    ii = page["imageinfo"][0]
    meta = ii.get("extmetadata", {})
    return {
        "thumb": ii.get("thumburl") or ii["url"],
        "license": meta.get("LicenseShortName", {}).get("value", "unknown"),
        "artist": meta.get("Artist", {}).get("value", "unknown"),
        "page": "https://commons.wikimedia.org/wiki/" + urllib.parse.quote(title.replace(" ", "_")),
    }


def main():
    check_only = "--check" in sys.argv
    ART.mkdir(parents=True, exist_ok=True)
    credits, problems = [], []
    for card_id, title in titles():
        dest = ART / f"{card_id}.jpg"
        meta = info(title)
        if meta is None:
            problems.append(f"NOT FOUND   {card_id}: {title}")
            continue
        lic = meta["license"]
        if "public domain" not in lic.lower() and lic.lower() not in ("pd", "cc0"):
            problems.append(f"LICENCE?    {card_id}: {lic} ({meta['page']})")
            continue
        credits.append(f"- {card_id}: {meta['page']} ({lic})")
        if not check_only and not dest.exists():
            req = urllib.request.Request(meta["thumb"], headers={"User-Agent": UA})
            dest.write_bytes(urllib.request.urlopen(req, timeout=60).read())
            print("saved", dest.name)
    if not check_only:
        (ART / "CREDITS.md").write_text(
            "# Card art credits\n\nSources are public-domain per Wikimedia Commons "
            "at download time. Re-verify before release.\n\n" + "\n".join(credits) + "\n")
    print(f"\n{len(credits)} ok, {len(problems)} need attention")
    print("\n".join(problems))


if __name__ == "__main__":
    main()
