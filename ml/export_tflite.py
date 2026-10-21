"""Convert out/model.keras to TFLite (dynamic-range quantisation, float I/O),
check it against the Keras model, and copy it into the app's assets."""
import pathlib
import random
import shutil

import keras
import numpy as np
import tensorflow as tf

from augment import OUT_H, OUT_W, augment, to_tensor
from data import class_ids, load_anchors

HERE = pathlib.Path(__file__).resolve().parent
MODEL = HERE / "out" / "model.keras"
TFLITE = HERE / "out" / "tarot_classifier.tflite"
APP_ASSET = HERE.parent / "app" / "assets" / "models" / "tarot_classifier.tflite"


def main():
    model = keras.saving.load_model(MODEL)
    conv = tf.lite.TFLiteConverter.from_keras_model(model)
    conv.optimizations = [tf.lite.Optimize.DEFAULT]  # dynamic range: weights int8, I/O float32
    TFLITE.write_bytes(conv.convert())
    print(f"wrote {TFLITE} ({TFLITE.stat().st_size / 1e6:.1f} MB)")

    it = tf.lite.Interpreter(model_path=str(TFLITE))
    it.allocate_tensors()
    inp, out = it.get_input_details()[0], it.get_output_details()[0]
    n = 2 * len(class_ids())  # 78 upright + 78 reversed
    assert list(inp["shape"]) == [1, OUT_H, OUT_W, 3] and inp["dtype"] == np.float32, inp
    assert list(out["shape"]) == [1, n] and out["dtype"] == np.float32, out

    anchors = load_anchors(include_photos=False)
    rng, ids, agree = random.Random(7), class_ids(), 0
    trials = 40
    for _ in range(trials):
        cid = rng.choice(ids)
        x = to_tensor(augment(rng.choice(anchors[cid]), rng))[None]
        it.set_tensor(inp["index"], x)
        it.invoke()
        a = it.get_tensor(out["index"])[0]
        b = model.predict(x, verbose=0)[0]
        agree += int(a.argmax() == b.argmax())
        assert abs(a.sum() - 1) < 1e-2, "output is not a softmax"
    print(f"tflite vs keras top-1 agreement: {agree}/{trials}")

    APP_ASSET.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(TFLITE, APP_ASSET)
    print("copied to", APP_ASSET)


if __name__ == "__main__":
    main()
