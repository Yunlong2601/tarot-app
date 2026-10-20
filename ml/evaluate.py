"""Evaluate the TFLite model the way the app uses it: one pass, 156 outputs
(card x upright/reversed); per card keep the better of its two scores and call
it reversed if the reversed output won.

    .venv/bin/python evaluate.py                       # synthetic stress test
    .venv/bin/python evaluate.py --deck mydeck2        # REAL photos from data/photos/mydeck2
                                                       # (a deck the model was NOT trained on)

Targets (docs/phase-c-design.md): >= 95% top-1 and >= 99% top-3 on real photos.
Synthetic numbers are only a pipeline check: they say little about real phones.
"""
import argparse
import collections
import pathlib
import random

import numpy as np
import tensorflow as tf
from PIL import Image

from augment import augment, center_crop_like_app, to_tensor
from data import PHOTOS_DIR, class_ids, load_anchors

HERE = pathlib.Path(__file__).resolve().parent
TFLITE = HERE / "out" / "tarot_classifier.tflite"

# Same starting policy as app/lib/features/scan/recognition/scan_logic.dart
MIN_SCORE, MIN_LEAD, MIN_GAP = 0.80, 0.25, 0.20


class Model:
    def __init__(self):
        self.it = tf.lite.Interpreter(model_path=str(TFLITE))
        self.it.allocate_tensors()
        self.i = self.it.get_input_details()[0]["index"]
        self.o = self.it.get_output_details()[0]["index"]

    def scores(self, x):
        self.it.set_tensor(self.i, x[None].astype(np.float32))
        self.it.invoke()
        return self.it.get_tensor(self.o)[0]


def scan(model, x):
    """Returns (best_index, reversed, confident, top3)."""
    out = model.scores(x)
    n = len(out) // 2
    up, rev = out[:n], out[n:]
    best = np.maximum(up, rev)
    order = np.argsort(-best)
    b = order[0]
    lead = best[b] - best[order[1]]
    confident = best[b] >= MIN_SCORE and lead >= MIN_LEAD and abs(up[b] - rev[b]) >= MIN_GAP
    return int(b), bool(rev[b] > up[b]), bool(confident), [int(i) for i in order[:3]]


def run(model, samples):
    ids = class_ids()
    top1 = top3 = orient = conf = conf_right = 0
    confused = collections.Counter()
    for true_i, x, is_reversed in samples:
        b, rev, confident, top = scan(model, x)
        top1 += b == true_i
        top3 += true_i in top
        orient += (b == true_i) and (rev == is_reversed)
        conf += confident
        conf_right += confident and b == true_i
        if b != true_i:
            confused[(ids[true_i], ids[b])] += 1
    n = len(samples)
    print(f"samples: {n}")
    print(f"top-1: {top1 / n:.1%}   top-3: {top3 / n:.1%}   card+orientation right: {orient / n:.1%}")
    print(f"auto-accepted (confident): {conf / n:.1%}; of those correct: {conf_right / max(conf, 1):.1%}")
    for (t, p), c in confused.most_common(8):
        print(f"  confused {t} -> {p}: {c}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--deck", help="evaluate on real photos in data/photos/<deck>/<card_id>/*.jpg")
    ap.add_argument("--n", type=int, default=400, help="synthetic samples")
    a = ap.parse_args()
    model = Model()
    ids = class_ids()
    index = {c: i for i, c in enumerate(ids)}
    samples = []
    if a.deck:
        for d in sorted((PHOTOS_DIR / a.deck).iterdir()):
            for f in sorted(d.glob("*.jpg")):
                x = to_tensor(center_crop_like_app(Image.open(f).convert("RGB")))
                samples.append((index[d.name], x, False))
                samples.append((index[d.name], x[::-1, ::-1].copy(), True))  # reversed = 180 degree turn
        print(f"REAL photos from deck '{a.deck}'")
    else:
        anchors = load_anchors(include_photos=False)
        rng = random.Random(4242)
        for _ in range(a.n):
            cid = rng.choice(ids)
            x = to_tensor(augment(rng.choice(anchors[cid]), rng))
            rev = rng.random() < 0.5
            samples.append((index[cid], x[::-1, ::-1].copy() if rev else x, rev))
        print("SYNTHETIC stress test (not a measure of real-phone accuracy)")
    run(model, samples)


if __name__ == "__main__":
    main()
