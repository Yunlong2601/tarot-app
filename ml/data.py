"""Class list and anchor-image loading. Class order = cards.json order, which
is the order the app expects from the model output."""
import json
import pathlib
import random

from PIL import Image

from augment import center_crop_like_app

ROOT = pathlib.Path(__file__).resolve().parent.parent
CARDS_JSON = ROOT / "app" / "assets" / "cards" / "cards.json"
ART_DIR = ROOT / "app" / "assets" / "cards" / "art"
PHOTOS_DIR = ROOT / "ml" / "data" / "photos"  # <deck>/<card_id>/*.jpg (not committed)


def class_ids():
    return [c["id"] for c in json.loads(CARDS_JSON.read_text())["cards"]]


def load_anchors(include_photos=True, photo_decks=None):
    """Returns {card_id: [PIL images]}. Public-domain art for every card, plus
    optional real photos from ml/data/photos/<deck>/<card_id>/*.jpg.
    photo_decks limits which decks are used (the rest can be held out)."""
    ids = class_ids()
    anchors = {i: [] for i in ids}
    for i in ids:
        p = ART_DIR / f"{i}.jpg"
        if p.exists():
            anchors[i].append(Image.open(p).convert("RGB"))
    if include_photos and PHOTOS_DIR.exists():
        for deck in sorted(d for d in PHOTOS_DIR.iterdir() if d.is_dir()):
            if photo_decks is not None and deck.name not in photo_decks:
                continue
            for i in ids:
                for f in sorted((deck / i).glob("*.jpg")) if (deck / i).exists() else []:
                    anchors[i].append(center_crop_like_app(Image.open(f).convert("RGB")))
    missing = [i for i, v in anchors.items() if not v]
    if missing:
        raise SystemExit(f"No anchor image for: {missing[:5]}... Run app/tools/fetch_art.py first.")
    return anchors


def sample(anchors, rng: random.Random):
    cid = rng.choice(list(anchors))
    return cid, rng.choice(anchors[cid])
