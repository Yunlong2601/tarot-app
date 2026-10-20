"""Train the 78-class card classifier (MobileNetV3-Small, ImageNet weights).

    .venv/bin/python train.py --epochs-head 3 --epochs-ft 8

Input contract (must match app/lib/features/scan/recognition): float32
[1, 320, 224, 3], RGB, values 0..255; output softmax over 156 classes:
indices 0..77 = card i upright, 78..155 = card i reversed (card order =
cards.json). Reversed training samples are the card turned 180 degrees. A
first version with 78 upright-only outputs could NOT tell reversed cards
(it scored a turned card just as confidently), hence the 156 outputs.
"""
import argparse
import pathlib
import random

import keras
import numpy as np
from keras import layers

from augment import OUT_H, OUT_W, augment, to_tensor
from data import class_ids, load_anchors

OUT = pathlib.Path(__file__).resolve().parent / "out"


class SyntheticCards(keras.utils.PyDataset):
    def __init__(self, anchors, batch_size, steps, seed, strength=1.0, **kw):
        super().__init__(**kw)
        self.anchors, self.bs, self.steps, self.seed, self.strength = anchors, batch_size, steps, seed, strength
        self.ids = class_ids()
        self.index = {c: i for i, c in enumerate(self.ids)}
        self.n = len(self.ids)
        self.epoch = 0

    def __len__(self):
        return self.steps

    def on_epoch_end(self):
        self.epoch += 1

    def __getitem__(self, idx):
        rng = random.Random(self.seed * 1_000_003 + self.epoch * 10_007 + idx)
        x = np.empty((self.bs, OUT_H, OUT_W, 3), dtype=np.float32)
        y = np.empty((self.bs,), dtype=np.int32)
        for n in range(self.bs):
            cid = rng.choice(self.ids)
            reversed_ = rng.random() < 0.5
            img = rng.choice(self.anchors[cid])
            if reversed_:
                img = img.rotate(180)
            x[n] = to_tensor(augment(img, rng, self.strength))
            y[n] = self.index[cid] + (self.n if reversed_ else 0)
        return x, y


def build_model(num_classes):
    base = keras.applications.MobileNetV3Small(
        input_shape=(OUT_H, OUT_W, 3), include_top=False, weights="imagenet",
        include_preprocessing=True,  # expects 0..255 RGB
    )
    inp = keras.Input((OUT_H, OUT_W, 3), dtype="float32")
    x = base(inp, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.3)(x)
    out = layers.Dense(num_classes, activation="softmax", name="cards")(x)
    return keras.Model(inp, out), base


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--epochs-head", type=int, default=3)
    ap.add_argument("--epochs-ft", type=int, default=8)
    ap.add_argument("--steps", type=int, default=120)
    ap.add_argument("--batch", type=int, default=32)
    ap.add_argument("--workers", type=int, default=6)
    ap.add_argument("--no-photos", action="store_true", help="train on public-domain art only")
    ap.add_argument("--photo-decks", nargs="*", help="only use these photo decks (hold out the others)")
    a = ap.parse_args()

    anchors = load_anchors(include_photos=not a.no_photos, photo_decks=a.photo_decks)
    n_anchor = sum(len(v) for v in anchors.values())
    print(f"{len(anchors)} classes, {n_anchor} anchor images")
    train = SyntheticCards(anchors, a.batch, a.steps, seed=1, workers=a.workers, use_multiprocessing=True, max_queue_size=8)
    val = SyntheticCards(anchors, a.batch, 20, seed=999, strength=1.0, workers=a.workers, use_multiprocessing=True)

    model, base = build_model(2 * len(class_ids()))
    base.trainable = False
    model.compile(optimizer=keras.optimizers.Adam(1e-3),
                  loss="sparse_categorical_crossentropy",
                  metrics=["accuracy", keras.metrics.SparseTopKCategoricalAccuracy(3, name="top3")])
    model.fit(train, validation_data=val, epochs=a.epochs_head)

    base.trainable = True
    for layer in base.layers:  # keep BatchNorm statistics fixed while fine-tuning
        if isinstance(layer, layers.BatchNormalization):
            layer.trainable = False
    model.compile(optimizer=keras.optimizers.Adam(1e-4),
                  loss="sparse_categorical_crossentropy",
                  metrics=["accuracy", keras.metrics.SparseTopKCategoricalAccuracy(3, name="top3")])
    model.fit(train, validation_data=val, epochs=a.epochs_ft)

    OUT.mkdir(exist_ok=True)
    model.save(OUT / "model.keras")
    print("saved", OUT / "model.keras")


if __name__ == "__main__":
    main()
