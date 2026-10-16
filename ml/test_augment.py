"""Smoke tests for the augmentation and data pipeline (no TensorFlow needed).
Run: .venv/bin/python -m unittest test_augment -v"""
import random
import unittest

import numpy as np
from PIL import Image

from augment import OUT_H, OUT_W, augment, center_crop_like_app, to_tensor
from data import class_ids, load_anchors


class AugmentTests(unittest.TestCase):
    def test_output_shape_and_range(self):
        img = Image.new("RGB", (500, 840), (200, 30, 30))
        x = to_tensor(augment(img, random.Random(1)))
        self.assertEqual(x.shape, (OUT_H, OUT_W, 3))
        self.assertEqual(x.dtype, np.float32)
        self.assertTrue(0 <= x.min() and x.max() <= 255)

    def test_deterministic_for_a_seed(self):
        img = Image.new("RGB", (500, 840), (10, 120, 200))
        a = to_tensor(augment(img, random.Random(5)))
        b = to_tensor(augment(img, random.Random(5)))
        self.assertTrue(np.array_equal(a, b))

    def test_guide_crop_matches_the_app(self):
        # app: guideCrop(1000, 1000) -> 468 x 780 centred (scan_logic_test / scan_test.dart)
        photo = Image.new("RGB", (1000, 1000))
        self.assertEqual(center_crop_like_app(photo).size, (OUT_W, OUT_H))

    def test_classes_match_cards_json_and_have_art(self):
        ids = class_ids()
        self.assertEqual(len(ids), 78)
        self.assertEqual(ids[0], "major_00_fool")
        anchors = load_anchors(include_photos=False)
        self.assertTrue(all(len(v) >= 1 for v in anchors.values()))


if __name__ == "__main__":
    unittest.main()
