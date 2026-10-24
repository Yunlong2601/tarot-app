import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/brand.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';
import 'reading_sections.dart';

/// Opens a preview of the reading as a story-sized image and shares it. The
/// question stays off the image unless the user turns it on: it is personal.
Future<void> shareReading(BuildContext context, Reading reading) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ShareCardScreen(reading: reading),
      ),
    );

class ShareCardScreen extends StatefulWidget {
  const ShareCardScreen({super.key, required this.reading});
  final Reading reading;

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final _key = GlobalKey();
  bool _withQuestion = false;
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final boundary =
          _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes.buffer.asUint8List(),
              name: 'shentarot-reading.png',
              mimeType: 'image/png',
            ),
          ],
          text: tr('My tarot reading from ShenTarot · shentarot.com'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasQuestion = (widget.reading.question ?? '').trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Share your reading'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: FittedBox(
              child: RepaintBoundary(
                key: _key,
                child: ShareCard(
                  reading: widget.reading,
                  withQuestion: _withQuestion,
                ),
              ),
            ),
          ),
          if (hasQuestion)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Show my question')),
              subtitle: Text(
                tr('Off by default, because your question may be private.'),
              ),
              value: _withQuestion,
              onChanged: (v) => setState(() => _withQuestion = v),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: _busy ? null : _share,
            icon: const Icon(Icons.ios_share),
            label: Text(tr('Share image')),
          ),
        ],
      ),
    );
  }
}

/// The image itself: 360 x 640, sized for phone stories.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.reading,
    this.withQuestion = false,
  });
  final Reading reading;
  final bool withQuestion;

  @override
  Widget build(BuildContext context) {
    final sections = parseReading(reading.interpretation);
    final overview = sections
        ?.where((s) => s.kind == SectionKind.overview)
        .firstOrNull
        ?.body;
    final reflect = sections
        ?.where((s) => s.kind == SectionKind.reflect)
        .firstOrNull
        ?.body;
    final text = overview ?? reading.interpretation;
    final shown = reading.cards.take(3).toList();
    final more = reading.cards.length - shown.length;
    return Container(
      width: 360,
      height: 640,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceHigh, AppColors.background],
        ),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFFF2EEE3),
          fontSize: 14,
          height: 1.4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BrandMark(size: 26),
                const SizedBox(width: 8),
                Text(
                  'ShenTarot',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              reading.spread.label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            if (withQuestion && (reading.question ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '“${reading.question!.trim()}”',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final d in shown)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CardArt(
                      card: d.card,
                      reversed: d.reversed,
                      width: 86,
                    ),
                  ),
                if (more > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      '+$more',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                [for (final d in shown) cardLabel(d.card.name, d.reversed)]
                    .join(' · '),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Text(
                text,
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            if (reflect != null) ...[
              Text(
                reflect,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'shentarot.com',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
