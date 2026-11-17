import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marcador_truco/main.dart' as app;
import 'package:marcador_truco/data/match_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native scoring, victory, rename, restart and storage recovery', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    // This test owns only the dedicated scoreboard key on its test simulator.
    await preferences.remove(MatchStore.key);
    app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nós'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Amigos');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Amigos'), findsOneWidget);
    for (var i = 0; i < 12; i++) {
      await tester.ensureVisible(find.text('+1').first);
      await tester.tap(find.text('+1').first);
      await tester.pumpAndSettle();
    }
    expect(find.text('Fim da partida'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(MatchStore(preferences).load().scores, [11, 0]);
    await tester.tap(find.text('+1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar vitória'));
    await tester.pumpAndSettle();
    expect(MatchStore(preferences).load().wins, [1, 0]);
    await tester.tap(find.text('+1').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Nova partida'));
    await tester.tap(find.text('Nova partida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();
    expect(MatchStore(preferences).load().scores, [0, 0]);
    expect(MatchStore(preferences).load().wins, [1, 0]);
    await preferences.reload();
    expect(MatchStore(preferences).load().names.first, 'Amigos');
    expect(MatchStore(preferences).load().wins, [1, 0]);
    await tester.pumpWidget(const SizedBox.shrink());
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Amigos'), findsOneWidget);
    expect(find.text('1 vitórias'), findsOneWidget);
  });
}
