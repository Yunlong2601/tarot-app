import 'dart:math';

/// A New or Full Moon moment.
typedef MoonPhase = ({DateTime at, bool full});

double _rad(double deg) => deg * pi / 180;

/// The moment (UTC) of lunation [k] (k = 0 is the New Moon of 6 Jan 2000;
/// k + 0.5 is the Full Moon after it). Meeus, Astronomical Algorithms,
/// ch. 49, main terms only: accurate to a few minutes, plenty for "tonight".
DateTime _phaseUtc(double k) {
  final full = (k - k.floorToDouble()) > 0.25;
  final t = k / 1236.85;
  var jde =
      2451550.09766 +
      29.530588861 * k +
      0.00015437 * t * t -
      0.000000150 * t * t * t +
      0.00000000073 * t * t * t * t;
  final e = 1 - 0.002516 * t - 0.0000074 * t * t;
  final m = _rad(2.5534 + 29.10535670 * k - 0.0000014 * t * t);
  final mp = _rad(201.5643 + 385.81693528 * k + 0.0107582 * t * t);
  final f = _rad(160.7108 + 390.67050284 * k - 0.0016118 * t * t);
  final om = _rad(124.7746 - 1.56375588 * k + 0.0020672 * t * t);
  jde +=
      (full ? -0.40614 : -0.40720) * sin(mp) +
      (full ? 0.17302 : 0.17241) * e * sin(m) +
      (full ? 0.01614 : 0.01608) * sin(2 * mp) +
      (full ? 0.01043 : 0.01039) * sin(2 * f) +
      (full ? 0.00734 : 0.00739) * e * sin(mp - m) -
      (full ? 0.00515 : 0.00514) * e * sin(mp + m) +
      (full ? 0.00209 : 0.00208) * e * e * sin(2 * m) -
      0.00111 * sin(mp - 2 * f) -
      0.00057 * sin(mp + 2 * f) +
      0.00056 * e * sin(2 * mp + m) -
      0.00042 * sin(3 * mp) +
      0.00042 * e * sin(m + 2 * f) +
      0.00038 * e * sin(m - 2 * f) -
      0.00024 * e * sin(2 * mp - m) -
      0.00017 * sin(om);
  final ms = ((jde - 2440587.5) * 86400000).round();
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

/// The next New and Full Moons after [from], in order.
List<MoonPhase> moonPhasesAfter(DateTime from, {int count = 2}) {
  final years =
      from.toUtc().difference(DateTime.utc(2000, 1, 6)).inDays / 365.25;
  var k = (years * 12.3685).floorToDouble() - 1;
  final out = <MoonPhase>[];
  while (out.length < count) {
    for (final step in [0.0, 0.5]) {
      final at = _phaseUtc(k + step);
      if (at.isAfter(from.toUtc()) && out.length < count) {
        out.add((at: at, full: step == 0.5));
      }
    }
    k += 1;
  }
  return out;
}

/// The New or Full Moon falling on [day] (local calendar day), if any.
MoonPhase? moonPhaseOn(DateTime day) {
  final start = DateTime(day.year, day.month, day.day);
  final end = DateTime(day.year, day.month, day.day + 1);
  for (final p in moonPhasesAfter(start.subtract(const Duration(seconds: 1)))) {
    final local = p.at.toLocal();
    if (!local.isBefore(start) && local.isBefore(end)) return p;
  }
  return null;
}
