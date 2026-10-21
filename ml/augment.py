"""Synthetic "phone photo of a card" generator for training.

Takes a clean card image (public-domain scan or a real photo) and produces a
224x320 RGB crop like the one the app cuts out of the camera frame: the card
roughly fills the guide frame, with perspective, rotation, lighting, glare,
blur, noise, JPEG artefacts and a random background showing at the edges.

Orientation: the model is trained UPRIGHT only (rotation limited to +-15
degrees). The app handles reversed cards by also classifying the crop turned
180 degrees.
"""
import io
import math
import random

import numpy as np
from PIL import Image, ImageEnhance, ImageFilter

OUT_W, OUT_H = 224, 320


def _coeffs(src, dst):
    """Perspective coefficients mapping dst points to src points."""
    a = []
    for (x, y), (u, v) in zip(dst, src):
        a.append([x, y, 1, 0, 0, 0, -u * x, -u * y])
        a.append([0, 0, 0, x, y, 1, -v * x, -v * y])
    b = [c for p in src for c in p]
    return np.linalg.solve(np.array(a, dtype=np.float64), np.array(b, dtype=np.float64))


def _background(rng, w, h):
    kind = rng.choice(["flat", "gradient", "noise", "wood"])
    base = np.array([rng.randint(20, 235) for _ in range(3)], dtype=np.float32)
    if kind == "flat":
        arr = np.tile(base, (h, w, 1))
    elif kind == "gradient":
        other = np.array([rng.randint(20, 235) for _ in range(3)], dtype=np.float32)
        t = np.linspace(0, 1, h, dtype=np.float32)[:, None, None]
        arr = base * (1 - t) + other * t
        arr = np.tile(arr, (1, w, 1))
    elif kind == "noise":
        arr = base + np.random.default_rng(rng.randint(0, 2**31)).normal(0, 18, (h, w, 3))
    else:  # streaky "wood/cloth" texture
        stripes = np.random.default_rng(rng.randint(0, 2**31)).normal(0, 14, (1, w, 1))
        arr = base + np.tile(stripes, (h, 1, 3))
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))


def _glare(img, rng):
    w, h = img.size
    cx, cy = rng.uniform(0.1, 0.9) * w, rng.uniform(0.1, 0.9) * h
    rx, ry = rng.uniform(0.15, 0.5) * w, rng.uniform(0.1, 0.4) * h
    yy, xx = np.mgrid[0:h, 0:w]
    blob = np.exp(-(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2))
    arr = np.asarray(img, dtype=np.float32)
    arr = arr + blob[..., None] * rng.uniform(40, 170)
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))


def augment(card: Image.Image, rng: random.Random, strength: float = 1.0) -> Image.Image:
    """Return a 224x320 RGB training crop. strength 0..1 scales how rough it is."""
    card = card.convert("RGB")
    # Scale the card so it fills most of the crop, with jitter.
    fill = rng.uniform(0.80, 0.99) if strength else 0.95
    cw, ch = OUT_W * fill, OUT_H * fill
    card = card.resize((max(8, int(cw)), max(8, int(ch))), Image.BILINEAR)

    # Slightly oversized canvas so rotation/perspective corners stay inside.
    pad = 0.35
    cw_i, ch_i = card.size
    W, H = int(OUT_W * (1 + pad)), int(OUT_H * (1 + pad))
    bg = _background(rng, W, H)
    ox, oy = (W - cw_i) // 2, (H - ch_i) // 2
    # Soft white border/edge like a real card sitting on a surface.
    bg.paste(card, (ox, oy))

    # Perspective: jitter the four corners of the whole canvas.
    j = 0.06 * strength
    dst = [(0, 0), (W, 0), (W, H), (0, H)]
    src = [(x + rng.uniform(-j, j) * W, y + rng.uniform(-j, j) * H) for x, y in dst]
    img = bg.transform((W, H), Image.PERSPECTIVE, _coeffs(src, dst), Image.BICUBIC)

    # Rotation +-15 degrees.
    img = img.rotate(rng.uniform(-15, 15) * strength, resample=Image.BICUBIC, fillcolor=(128, 128, 128))

    # Crop the guide-frame window with jitter, then resize to model size.
    jx = rng.uniform(-0.04, 0.04) * strength * OUT_W
    jy = rng.uniform(-0.04, 0.04) * strength * OUT_H
    left = (W - OUT_W) / 2 + jx
    top = (H - OUT_H) / 2 + jy
    img = img.crop((int(left), int(top), int(left) + OUT_W, int(top) + OUT_H))

    # Lighting and colour.
    img = ImageEnhance.Brightness(img).enhance(rng.uniform(1 - 0.5 * strength, 1 + 0.35 * strength))
    img = ImageEnhance.Contrast(img).enhance(rng.uniform(1 - 0.4 * strength, 1 + 0.3 * strength))
    img = ImageEnhance.Color(img).enhance(rng.uniform(1 - 0.5 * strength, 1 + 0.3 * strength))
    if rng.random() < 0.4 * strength:
        img = _glare(img, rng)
    if rng.random() < 0.5 * strength:
        img = img.filter(ImageFilter.GaussianBlur(rng.uniform(0.3, 1.8)))
    arr = np.asarray(img, dtype=np.float32)
    if rng.random() < 0.6 * strength:
        arr = arr + np.random.default_rng(rng.randint(0, 2**31)).normal(0, rng.uniform(2, 9), arr.shape)
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    if rng.random() < 0.5 * strength:  # JPEG artefacts
        buf = io.BytesIO()
        img.save(buf, "JPEG", quality=rng.randint(35, 85))
        img = Image.open(io.BytesIO(buf.getvalue())).convert("RGB")
    return img


def to_tensor(img: Image.Image) -> np.ndarray:
    """Model input: float32 RGB 0..255, shape (320, 224, 3)."""
    arr = np.asarray(img.convert("RGB").resize((OUT_W, OUT_H), Image.BILINEAR), dtype=np.float32)
    assert arr.shape == (OUT_H, OUT_W, 3)
    return arr


def center_crop_like_app(photo: Image.Image) -> Image.Image:
    """Cut the guide frame out of a full photo, as the app does (see
    app/lib/features/scan/recognition/scan_logic.dart guideCrop)."""
    w, h = photo.size
    ch = h * 0.78
    cw = ch * 0.6
    if cw > w * 0.9:
        cw = w * 0.9
        ch = cw / 0.6
    cw, ch = round(cw), round(ch)
    left, top = (w - cw) // 2, (h - ch) // 2
    return photo.crop((left, top, left + cw, top + ch)).resize((OUT_W, OUT_H), Image.BILINEAR)
