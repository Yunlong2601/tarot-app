# Card recognition model (`ml/`)

Trains the on-device classifier used by the app's camera scan (`app/lib/features/scan/recognition/`).

**Contract.** Input float32 `[1, 320, 224, 3]`, RGB, values 0..255 (the same crop the app cuts out with `guideCrop`). Output softmax over **156** classes: `0..77` card i upright, `78..155` card i reversed, card order = `app/assets/cards/cards.json`. Model: MobileNetV3-Small (ImageNet weights), dynamic-range quantised TFLite, about 1.2 MB.

## Run
```bash
cd ml
python3.12 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/python -m unittest test_augment -v           # pipeline smoke tests
.venv/bin/python train.py --no-photos --epochs-head 3 --epochs-ft 12 --steps 100   # about 10 min on an Apple-silicon Mac
.venv/bin/python export_tflite.py     # writes out/tarot_classifier.tflite and copies it to app/assets/models/
.venv/bin/python evaluate.py          # synthetic check only
```
(The first model here was trained with the venv at `~/development/ml-venv`; any venv works.)

## What is and is not proven
- Trained **only** on the 78 public-domain scans plus synthetic phone-photo augmentation (perspective, rotation, lighting, glare, blur, noise, JPEG, random backgrounds). The synthetic evaluation scores 100% for card and orientation, but it tests the same artwork it trained on, so **it says almost nothing about real phones and real printed decks.** Do not treat it as the 95% target.
- Real accuracy needs real photos. Add them as `ml/data/photos/<deck>/<card_id>/*.jpg` (about 10 per card, full phone photos with the card centred in the guide frame; `<card_id>` as in `cards.json`), retrain without `--no-photos`, and measure on a deck the model never saw: `train.py --photo-decks deckA`, then `evaluate.py --deck deckB`. Target: >= 95% top-1 and >= 99% top-3. Tune the confidence thresholds from those results.
- `data/` and `out/` are git-ignored (photos stay private; do not commit them).
- Not yet tested inside the app on a device: the app checks the model's tensor shapes at load and falls back to the manual picker if they do not match.
