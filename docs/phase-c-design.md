# Phase C design: camera scan and recognition

Status: designed, not built in this repo. (A partial draft written in a cloud session was never verified or pushed; build from this design.) The product plan is in `step1-plan.md` section 3.

## Goal
Scan one physical Rider-Waite-Smith card with the camera and identify it and its orientation on device. If unsure, offer guesses and the manual picker. Never store or upload the photo.

## Packages to add (check versions on pub.dev)
`camera`, `tflite_flutter`, `image`. Use the camera plugin's own permission prompt (no extra permission package).

## Native config
- iOS `ios/Runner/Info.plist`: `NSCameraUsageDescription` = "Used to recognise the tarot card you hold up. Photos are never saved or uploaded."
- Android `android/app/src/main/AndroidManifest.xml`: `<uses-permission android:name="android.permission.CAMERA"/>`.
- Verify `tflite_flutter` runs on real iOS and Android devices; this was not checked.

## Design decisions
1. **Guide frame instead of corner detection (v1).** A centred card-shaped box (aspect 0.6, up to 78% of image height, 90% of width) is drawn over the preview. The crop used for recognition is the same rectangle as fractions of the photo, so what the user lines up is what the model sees. Add corner detection later only if accuracy needs it. Train with crop/perspective jitter so slight misalignment is tolerated.
2. **Take a still photo on tap** (`takePicture`, medium resolution, JPEG) rather than analysing a live stream. Read the bytes, run recognition, and **delete the temp file in a `finally`**. Decode, crop and resize off the UI isolate (`Isolate.run`).
3. **Model contract** (must match `ml/`): input float32 `[1, 320, 224, 3]`, RGB, values 0..255; output softmax over 78 classes in `cards.json` order. File: `app/assets/models/tarot_classifier.tflite` (declare the `assets/models/` directory in pubspec with a placeholder file so builds work before the model exists). If the model is missing or has the wrong shape, show "recognition unavailable" and use the manual picker.
4. **Orientation by two passes.** The model is trained on upright cards only. Classify the crop and the crop rotated 180 degrees; per card keep the better score and mark reversed if the rotated pass won.
5. **Decision policy** (starting values, tune on held-out photos): confident only if best score >= 0.80, lead over the best other card >= 0.25, and the best card's upright vs rotated scores differ by >= 0.20. Otherwise show the top 3 guesses plus "Pick manually". Always ask the user to confirm, even when confident.
6. **Spreads:** scan cards one at a time ("Card 2 of 3"), reject duplicates (a physical deck has none), allow "not this card" to undo. Manual picking asks upright/reversed after choosing the card.
7. Debug builds keep a "Simulate scan" button for working without a camera.

## Suggested units (pure Dart, easy to test)
- `decideScan(cardIds, uprightScores, rotatedScores, policy)` returns confident or uncertain-with-top-3.
- `guideCrop(width, height)` returns the crop box.
- `preprocessForModel(jpegBytes)` returns the two tensors; test that rotated is an exact 180 degree turn of upright.
- `ScanSession(count)` collects cards, rejects duplicates.

## ML pipeline (`ml/`, not yet written)
1. Anchor images: the 78 public-domain scans (`app/tools/fetch_art.py`) plus your own phone photos of 2-3 physical decks, about 10 per card, stored as `data/photos/<deck>/<card_id>/*.jpg`.
2. Augment to about 300 images per card at 224x320: perspective, rotation +-15 degrees, brightness/contrast, glare, blur, random backgrounds, crop jitter.
3. Train MobileNetV3-Small (ImageNet weights) with a 78-class head, then fine-tune. Export TFLite with dynamic-range quantisation (keeps float input/output).
4. Evaluate on a held-out set of real photos from a deck the model never saw. Target >= 95% top-1 and >= 99% top-3. Report the most confused pairs.
5. Cheap decks vary in colour and borders; non-RWS decks will fail and fall back to manual, which is acceptable for the MVP.

## Done when
Scanning a real card on a real iPhone and Android phone identifies it and its orientation, low-confidence cases fall back cleanly, no photo file remains on disk, and tests for the pure units above pass.
