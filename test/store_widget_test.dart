import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marcador_truco/data/match_store.dart';
import 'package:marcador_truco/domain/match.dart';
import 'package:marcador_truco/views/home_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('save resumes names, points and victories', () async {
    final store = MatchStore(await SharedPreferences.getInstance());
    var g = Match.initial().rename(0, 'Amigos');
    for (var i = 0; i < 12; i++) {
      g = g.point(0, 1);
    }
    await store.save(g);
    expect(store.load().winner, 0);
    await store.save(g.confirmWin().point(1, 1));
    expect(store.load().wins, [1, 0]);
    expect(store.load().scores, [0, 1]);
    expect(store.load().names.first, 'Amigos');
  });
  test('corrupt data is reported without replacement', () async {
    SharedPreferences.setMockInitialValues({MatchStore.key: 'bad'});
    final p = await SharedPreferences.getInstance();
    expect(() => MatchStore(p).load(), throwsFormatException);
    expect(p.getString(MatchStore.key), 'bad');
  });
  testWidgets('score controls, restart cancellation and name validation', (
    tester,
  ) async {
    final store = MatchStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(MaterialApp(home: HomePage(store: store)));
    await tester.tap(find.text('+1').first);
    await tester.pumpAndSettle();
    expect(store.load().scores, [1, 0]);
    await tester.ensureVisible(find.text('Nova partida'));
    await tester.tap(find.text('Nova partida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(store.load().scores, [1, 0]);
    await tester.ensureVisible(find.text('Nós'));
    await tester.tap(find.text('Nós'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), ' ');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Use de 1 a 24 caracteres.'), findsOneWidget);
  });
  testWidgets('narrow screen and enlarged text remain usable', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MatchStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.5)),
          child: child!,
        ),
        home: HomePage(store: store),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('+1').last);
    await tester.tap(find.text('+1').last);
    await tester.pumpAndSettle();
    expect(store.load().scores, [0, 1]);
    expect(tester.takeException(), isNull);
  });
}
