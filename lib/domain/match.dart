import 'dart:convert';

class Match {
  final List<String> names;
  final List<int> scores, wins;
  Match._(List<String> n, List<int> s, List<int> w)
    : names = List.unmodifiable(n),
      scores = List.unmodifiable(s),
      wins = List.unmodifiable(w);
  factory Match.initial() => Match._(['Nós', 'Eles'], [0, 0], [0, 0]);
  int? get winner => scores.contains(12) ? scores.indexOf(12) : null;
  Match point(int team, int delta) {
    RangeError.checkValidIndex(team, scores);
    if (delta != 1 && delta != -1) throw ArgumentError('Use +1 or -1');
    if (winner != null) return this;
    final s = [...scores];
    s[team] = (s[team] + delta).clamp(0, 12);
    return Match._(names, s, wins);
  }

  static String validName(String value) {
    final n = value.trim();
    if (n.isEmpty || n.length > 24) {
      throw const FormatException('Use de 1 a 24 caracteres.');
    }
    return n;
  }

  Match rename(int team, String value) {
    final n = [...names];
    n[team] = validName(value);
    return Match._(n, scores, wins);
  }

  Match restart({bool clearWins = false}) =>
      Match._(names, [0, 0], clearWins ? [0, 0] : wins);
  Match confirmWin() {
    if (winner == null) return this;
    final w = [...wins];
    w[winner!]++;
    return Match._(names, [0, 0], w);
  }

  Match cancelWin() {
    if (winner == null) return this;
    final s = [...scores];
    s[winner!] = 11;
    return Match._(names, s, wins);
  }

  String encode() => jsonEncode({
    'version': 1,
    'names': names,
    'scores': scores,
    'wins': wins,
  });
  factory Match.decode(String source) {
    final d = jsonDecode(source);
    if (d is! Map || d['version'] != 1) {
      throw const FormatException('Unknown save version');
    }
    List<int> numbers(String key, int max) {
      final v = d[key];
      if (v is! List ||
          v.length != 2 ||
          v.any((e) => e is! int || e < 0 || e > max)) {
        throw const FormatException('Invalid scores');
      }
      return v.cast<int>();
    }

    final n = d['names'];
    if (n is! List || n.length != 2 || n.any((e) => e is! String)) {
      throw const FormatException('Invalid names');
    }
    final s = numbers('scores', 12);
    if (s.where((v) => v == 12).length > 1) {
      throw const FormatException('Two winners');
    }
    return Match._(
      n.cast<String>().map(validName).toList(),
      s,
      numbers('wins', 1000000000),
    );
  }
}
