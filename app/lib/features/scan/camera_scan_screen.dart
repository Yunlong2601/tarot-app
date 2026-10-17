import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import 'orientation_dialog.dart';
import 'recognition/preprocess.dart';
import 'recognition/recognizer.dart';
import 'recognition/scan_logic.dart';
import '../../app/i18n.dart';

/// Scans [count] cards one at a time with the camera. Pops the list of
/// [DrawnCard] when complete, or null if the user leaves.
///
/// A still photo is taken on tap, recognised on device, and its temp file is
/// deleted straight away. Nothing is stored or uploaded.
class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key, required this.count});

  final int count;

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  late final ScanSession _session = ScanSession(widget.count);
  CameraController? _camera;
  CardRecognizer? _recognizer;
  String? _cameraError;
  bool _busy = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _init();
  }

  Future<void> _init() async {
    final deck = AppScope.of(context).deck;
    final recognizer = await TfliteRecognizer.load(
      classCount: deck.cards.length,
    );
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('No camera found');
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        recognizer?.close();
        return;
      }
      setState(() {
        _camera = controller;
        _recognizer = recognizer;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _recognizer = recognizer;
        _cameraError = e.code.contains('Denied')
            ? tr(
                'Camera access is off. You can allow it in Settings, or pick cards manually.',
              )
            : tr('The camera could not start. You can pick cards manually.');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recognizer = recognizer;
        _cameraError = tr(
          'The camera could not start. You can pick cards manually.',
        );
      });
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    _recognizer?.close();
    super.dispose();
  }

  Future<void> _capture() async {
    final camera = _camera;
    if (camera == null || _busy) return;
    setState(() => _busy = true);
    final deck = AppScope.of(context).deck;
    String? path;
    try {
      final shot = await camera.takePicture();
      path = shot.path;
      final recognizer = _recognizer;
      if (recognizer == null) {
        _toast(tr('Recognition is not available yet. Pick the card manually.'));
        return;
      }
      final bytes = await shot.readAsBytes();
      final input = await preprocessOffUi(bytes);
      final scores = await recognizer.recognize(input);
      final decision = decideScan(
        [for (final c in deck.cards) c.id],
        scores.upright,
        scores.reversed,
      );
      if (!mounted) return;
      await _handleDecision(decision);
    } catch (_) {
      _toast(
        tr('That scan did not work. Try again or pick the card manually.'),
      );
    } finally {
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleDecision(ScanDecision decision) async {
    switch (decision) {
      case ConfidentScan(:final guess):
        final ok = await _confirm(guess);
        if (ok == true) _accept(guess.cardId, guess.reversed);
      case UncertainScan(:final topGuesses):
        await _chooseAmong(topGuesses);
    }
  }

  Future<bool?> _confirm(CardGuess guess) {
    final card = AppScope.of(context).deck.byId(guess.cardId)!;
    var reversed = guess.reversed;
    return showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('Is this {0}?', [card.name]),
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(tr('Upright'))),
                    ButtonSegment(value: true, label: Text(tr('Reversed'))),
                  ],
                  selected: {reversed},
                  onSelectionChanged: (s) => setSheet(() => reversed = s.first),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    _accept(card.id, reversed);
                    Navigator.of(ctx).pop(false);
                  },
                  child: Text(tr('Yes, use this card')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(tr('Not this card')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _chooseAmong(List<CardGuess> guesses) async {
    final deck = AppScope.of(context).deck;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr('I\'m not sure. Is it one of these?'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final g in guesses)
                ListTile(
                  title: Text(deck.byId(g.cardId)!.name),
                  subtitle: Text(g.reversed ? tr('Reversed?') : tr('Upright?')),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _accept(g.cardId, g.reversed);
                  },
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _pickManually();
                },
                child: Text(tr('Pick manually')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickManually() async {
    final id = await context.push<String>('/pick');
    if (id == null || !mounted) return;
    final reversed = await askOrientation(context);
    if (reversed == null) return;
    _accept(id, reversed);
  }

  void _accept(String cardId, bool reversed) {
    if (!_session.add(cardId, reversed: reversed)) {
      _toast(tr('That card is already in this reading.'));
      return;
    }
    if (_session.isComplete) {
      final deck = AppScope.of(context).deck;
      context.pop([
        for (final c in _session.cards)
          DrawnCard(card: deck.byId(c.cardId)!, reversed: c.reversed),
      ]);
    } else {
      setState(() {});
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.count == 1
              ? tr('Scan your card')
              : tr('Card {0} of {1}', [_session.nextIndex, widget.count]),
        ),
        actions: [
          if (_session.cards.isNotEmpty)
            TextButton(
              onPressed: () => setState(_session.undo),
              child: Text(tr('Undo last')),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: camera != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(child: CameraPreview(camera)),
                      const _GuideOverlay(),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _cameraError != null
                          ? Text(
                              _cameraError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr(
                      tr(
                        'Line the card up inside the frame. The photo is read on your phone and never saved or uploaded.',
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  if (camera != null)
                    FilledButton.icon(
                      onPressed: _busy ? null : _capture,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        _busy ? tr('Reading card...') : tr('Scan card'),
                      ),
                    ),
                  OutlinedButton(
                    onPressed: _busy ? null : _pickManually,
                    child: Text(tr('Pick a card manually')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the guide frame as a fraction of the preview, using the same
/// geometry as [guideCrop] so the user lines up what the model sees.
class _GuideOverlay extends StatelessWidget {
  const _GuideOverlay();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) {
      final box = guideCrop(c.maxWidth.round(), c.maxHeight.round());
      return Stack(
        children: [
          Positioned(
            left: box.left.toDouble(),
            top: box.top.toDouble(),
            width: box.width.toDouble(),
            height: box.height.toDouble(),
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
