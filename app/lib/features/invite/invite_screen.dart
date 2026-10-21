import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/referral_service.dart';

/// Invite friends: your code, tier, credits, an anonymous list of friends who
/// joined, the tier ladder and the small print. Also where a friend's code is
/// entered. Behind `referralsEnabled`.
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  ReferralInfo? _info;
  String? _error;
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_info == null && _error == null) _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final info = await AppScope.of(context).referralApi.me();
      if (mounted) setState(() => _info = info);
    } on ReferralException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Invites are not available right now.');
      }
    }
  }

  Future<void> _redeem() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await AppScope.of(context)
          .redeemReferral(_code.text, ios: Platform.isIOS);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Friend\'s offer unlocked: 50% off your first year.'),
        ),
      );
      context.push('/paywall');
    } on ReferralException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final info = _info;
    final t = Theme.of(context).textTheme;
    const muted = TextStyle(color: AppColors.textMuted);
    return Scaffold(
      appBar: AppBar(title: const Text('Invite friends')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (info == null && _error == null)
            const Center(child: CircularProgressIndicator())
          else if (info == null)
            Text(_error!, style: muted)
          else ...[
            _TierHeader(info),
            const SizedBox(height: 20),
            Text('Your code', style: t.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    info.code,
                    style: t.headlineSmall?.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  icon: const Icon(Icons.copy),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: info.code)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.ios_share),
              label: const Text('Share my code'),
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      'Try ShenTarot, the tarot card scanner and reader. Use my '
                      'code ${info.code} and we both get ${info.creditsPerFriend} '
                      'free credits after your first reading.',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Your free credits and months', style: t.titleMedium),
            const SizedBox(height: 6),
            Text(
              '${info.monthsEarned} earned · ${info.monthsPending} pending · '
              '${info.friendsJoined} friends joined',
            ),
            const SizedBox(height: 4),
            Text(
              '${info.creditsEarned} credits earned: you and your friend each '
              'get ${info.creditsPerFriend} credits when they finish their '
              'first reading (up to 20 friends a year).',
              style: muted,
            ),
            const SizedBox(height: 4),
            const Text(
              'A month is added 14 days after a friend\'s first payment.',
              style: muted,
            ),
            if (info.friends.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Friends', style: t.titleMedium),
              for (final f in info.friends)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    f.status == 'credited'
                        ? Icons.check_circle
                        : f.status == 'pending'
                        ? Icons.hourglass_bottom
                        : Icons.person_outline,
                    color: f.status == 'credited' ? AppColors.gold : null,
                  ),
                  title: Text('A friend joined on ${f.joined}'),
                  subtitle: Text(switch (f.status) {
                    'credited' => 'Free month added',
                    'pending' => 'Subscribed; month coming soon',
                    _ => 'Not subscribed yet',
                  }),
                ),
            ],
            const SizedBox(height: 20),
            Text('Tiers', style: t.titleMedium),
            for (final tier in referralTiers)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  info.friendsPaid >= tier.friends
                      ? Icons.star
                      : Icons.star_border,
                  color: AppColors.gold,
                ),
                title: Text(
                  '${tier.name} · ${tier.friends} '
                  '${tier.friends == 1 ? 'friend' : 'friends'}',
                ),
                subtitle: Text(tier.perk),
              ),
          ],
          const Divider(height: 40),
          Text('Have a friend\'s code?', style: t.titleMedium),
          const SizedBox(height: 8),
          if (state.referralOffer != null)
            const Text(
              'Your friend\'s offer is active: 50% off your first year of '
              'the annual plan. It appears on the Premium screen.',
            )
          else ...[
            TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'Friend\'s code'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : _redeem,
              child: const Text('Use code'),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Small print: you and your friend each get 10 credits when your '
            'friend finishes their first reading (you for up to 20 friends a '
            'year). Your friend also gets 50% off their first year of the '
            'annual plan if they subscribe; nothing is given for installing. '
            'You get 1 free month of Premium for each friend who pays, added '
            '14 days after their payment, up to 6 a year. If you already '
            'subscribe in the store, earned months are kept until your '
            'subscription ends. Without an account, codes and months belong '
            'to this phone and are lost if the app is deleted; sign in to keep '
            'them. Cosmetic tier rewards are coming soon. Terms apply.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  const _TierHeader(this.info);
  final ReferralInfo info;

  @override
  Widget build(BuildContext context) {
    final tier = tierFor(info.friendsPaid);
    final next = nextTier(info.friendsPaid);
    final from = tier?.friends ?? 0;
    final progress = next == null
        ? 1.0
        : (info.friendsPaid - from) / (next.friends - from);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tier?.name ?? 'No tier yet',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0, 1).toDouble(),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 6),
        Text(
          next == null
              ? 'Top tier reached. Thank you!'
              : '${info.friendsPaid} of ${next.friends} friends who subscribed '
                    'to reach ${next.name}',
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
