import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../app/brand.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../core/analytics.dart';
import '../../data/models.dart';
import 'reading_sections.dart';

/// One titled block of a keepsake page.
typedef KeepsakePart = ({String? heading, String text});

/// The parts of a reading for its keepsake: the overview, each card with its
/// position, the question to reflect on and the small step.
List<KeepsakePart> readingParts(Reading r) {
  final sections = parseReading(r.interpretation);
  if (sections == null) return [(heading: null, text: r.interpretation)];
  final positions = r.spread.positionsFrom(r.createdAt);
  return [
    for (final s in sections)
      if (s.kind == SectionKind.card && s.cardIndex! < r.cards.length)
        (
          heading:
              '${positions[s.cardIndex!]} · ${cardLabel(r.cards[s.cardIndex!].card.name, r.cards[s.cardIndex!].reversed)}',
          text: s.body.replaceAll(RegExp(r'[*_#`]'), ''),
        )
      else if (s.kind != SectionKind.other)
        (heading: tr(s.title), text: s.body.replaceAll(RegExp(r'[*_#`]'), '')),
  ];
}

/// Save a reading or the monthly letter as a PDF or a picture (Premium).
Future<void> openKeepsake(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? question,
  required List<KeepsakePart> parts,
  required String fileName,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => KeepsakeScreen(
      title: title,
      subtitle: subtitle,
      question: question,
      parts: parts,
      fileName: fileName,
    ),
  ),
);

class KeepsakeScreen extends StatefulWidget {
  const KeepsakeScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.question,
    required this.parts,
    required this.fileName,
  });
  final String title;
  final String subtitle;
  final String? question;
  final List<KeepsakePart> parts;
  final String fileName;

  @override
  State<KeepsakeScreen> createState() => _KeepsakeScreenState();
}

class _KeepsakeScreenState extends State<KeepsakeScreen> {
  final _key = GlobalKey();
  late bool _withQuestion = (widget.question ?? '').trim().isNotEmpty;
  bool _busy = false;

  /// The page as drawn on screen, so every language prints as it reads.
  Future<ui.Image> _capture() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio: 2.5);
  }

  Future<void> _save({required bool pdf}) async {
    setState(() => _busy = true);
    logEvent('keepsake', {'pdf': pdf});
    try {
      final image = await _capture();
      final XFile file;
      if (pdf) {
        file = XFile.fromData(
          await keepsakePdf(image),
          name: '${widget.fileName}.pdf',
          mimeType: 'application/pdf',
        );
      } else {
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        file = XFile.fromData(
          png!.buffer.asUint8List(),
          name: '${widget.fileName}.png',
          mimeType: 'image/png',
        );
      }
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Could not save this. Please try again.'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasQuestion = (widget.question ?? '').trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Save a keepsake'))),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _key,
                    child: KeepsakePage(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      question: _withQuestion ? widget.question : null,
                      parts: widget.parts,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  if (hasQuestion)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(tr('Show my question')),
                      value: _withQuestion,
                      onChanged: (v) => setState(() => _withQuestion = v),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: _busy ? null : () => _save(pdf: false),
                          icon: const Icon(Icons.image_outlined),
                          label: Text(tr('Image')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: _busy ? null : () => _save(pdf: true),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(tr('PDF')),
                        ),
                      ),
                    ],
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

/// A page on warm paper, ready to print or keep: 420 points wide.
class KeepsakePage extends StatelessWidget {
  const KeepsakePage({
    super.key,
    required this.title,
    required this.subtitle,
    this.question,
    required this.parts,
  });
  final String title;
  final String subtitle;
  final String? question;
  final List<KeepsakePart> parts;

  static const _paper = Color(0xFFFBF7EE);
  static const _ink = Color(0xFF2A241B);
  static const _muted = Color(0xFF7A6F5E);
  static const _accent = Color(0xFF9C7A3C);

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(
    child: Container(
      width: 420,
      color: _paper,
      padding: const EdgeInsets.fromLTRB(36, 36, 36, 28),
      child: DefaultTextStyle(
        style: const TextStyle(color: _ink, fontSize: 13, height: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BrandMark(size: 20),
                const SizedBox(width: 6),
                Text(
                  'ShenTarot',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontFamily: displayFont,
                fontFamilyFallback: displayFallback,
                fontSize: 24,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: _muted)),
            if (question != null && question!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '“${question!.trim()}”',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            Container(height: 0.8, color: _accent.withValues(alpha: 0.5)),
            for (final p in parts) ...[
              const SizedBox(height: 14),
              if (p.heading != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    p.heading!,
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(p.text),
            ],
            const SizedBox(height: 24),
            Text(
              tr('For entertainment and self-reflection only.'),
              style: const TextStyle(color: _muted, fontSize: 10),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Cuts the page image into A4 pages, so a long reading prints whole. Each
/// cut falls on a blank line of paper, never through a line of text.
Future<Uint8List> keepsakePdf(ui.Image image) async {
  final doc = pw.Document(title: 'ShenTarot');
  final w = image.width;
  final pageH = (w * PdfPageFormat.a4.height / PdfPageFormat.a4.width).floor();
  final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  bool blank(int y) {
    final paper = KeepsakePage._paper;
    for (var x = 0; x < w; x += 3) {
      final i = (y * w + x) * 4;
      if ((rgba.getUint8(i) - (paper.r * 255).round()).abs() > 6 ||
          (rgba.getUint8(i + 1) - (paper.g * 255).round()).abs() > 6 ||
          (rgba.getUint8(i + 2) - (paper.b * 255).round()).abs() > 6) {
        return false;
      }
    }
    return true;
  }

  for (final (top, bottom) in keepsakeCuts(image.height, pageH, blank)) {
    final h = bottom - top;
    final rec = ui.PictureRecorder();
    Canvas(rec)
      ..drawColor(KeepsakePage._paper, BlendMode.src)
      ..drawImageRect(
        image,
        Rect.fromLTWH(0, top.toDouble(), w.toDouble(), h.toDouble()),
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        Paint(),
      );
    final slice = await rec.endRecording().toImage(w, pageH);
    final png = await slice.toByteData(format: ui.ImageByteFormat.png);
    final img = pw.MemoryImage(png!.buffer.asUint8List());
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Image(img, fit: pw.BoxFit.fill),
      ),
    );
  }
  return doc.save();
}

/// Page slices (top, bottom) of an image [height] tall, each at most [pageH],
/// ending on a row where [blank] is true when one is in the last quarter.
List<(int, int)> keepsakeCuts(int height, int pageH, bool Function(int) blank) {
  final out = <(int, int)>[];
  var top = 0;
  while (top < height) {
    var bottom = top + pageH;
    if (bottom >= height) {
      bottom = height;
    } else {
      for (var y = bottom; y > top + pageH * 3 ~/ 4; y--) {
        if (blank(y)) {
          bottom = y;
          break;
        }
      }
    }
    out.add((top, bottom));
    top = bottom;
  }
  return out;
}
