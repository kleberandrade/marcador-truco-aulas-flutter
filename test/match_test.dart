import 'package:flutter_test/flutter_test.dart';
import 'package:marcador_truco/domain/match.dart';

void main() {
  test('bounds, winner lock, cancel, confirm and restart', () {
    var g = Match.initial();
    expect(g.point(0, -1).scores, [0, 0]);
    for (var i = 0; i < 15; i++) {
      g = g.point(0, 1);
    }
    expect(g.scores, [12, 0]);
    expect(g.point(1, 1).scores, [12, 0]);
    expect(g.cancelWin().scores, [11, 0]);
    expect(g.confirmWin().wins, [1, 0]);
    expect(g.confirmWin().restart().wins, [1, 0]);
    expect(g.confirmWin().restart(clearWins: true).wins, [0, 0]);
  });
  test('validates external data and round trips', () {
    expect(() => Match.initial().rename(0, ' '), throwsFormatException);
    expect(() => Match.decode('{"version":99}'), throwsFormatException);
    final g = Match.initial().rename(0, ' Mesa ').point(1, 1);
    expect(Match.decode(g.encode()).names, ['Mesa', 'Eles']);
    expect(Match.decode(g.encode()).scores, [0, 1]);
  });
  test('rejects negative, oversized and conflicting saved scores', () {
    for (final scores in ['[-1,0]', '[13,0]', '[12,12]', '[1.5,0]']) {
      expect(
        () => Match.decode(
          '{"version":1,"names":["A","B"],"scores":$scores,"wins":[0,0]}',
        ),
        throwsFormatException,
      );
    }
    expect(() => Match.initial().point(0, 3), throwsArgumentError);
    expect(() => Match.initial().rename(0, 'a' * 25), throwsFormatException);
  });
}
