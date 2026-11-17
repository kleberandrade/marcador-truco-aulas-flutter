import 'package:flutter/material.dart';
import '../domain/match.dart';
import '../data/match_store.dart';
import '../widgets/team_board.dart';

class HomePage extends StatefulWidget {
  final MatchStore store;
  const HomePage({super.key, required this.store});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Match game = Match.initial();
  String? error;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    try {
      game = widget.store.load();
    } catch (_) {
      error =
          'O placar salvo está inválido. Nada foi sobrescrito. Inicie uma nova partida para continuar.';
    }
    if (game.winner != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => finish());
    }
  }

  Future<void> update(Match next) async {
    setState(() {
      game = next;
      saving = true;
      error = null;
    });
    try {
      await widget.store.save(next);
    } catch (_) {
      error =
          'Falha ao salvar. O placar está apenas nesta sessão. Tente salvar novamente.';
    }
    if (mounted) setState(() => saving = false);
  }

  Future<bool> confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ),
      ) ??
      false;
  Future<void> finish() async {
    final won = await confirm(
      'Fim da partida',
      '${game.names[game.winner!]} chegou a 12. Confirmar vitória e abrir a próxima partida?',
      'Confirmar vitória',
    );
    if (mounted) await update(won ? game.confirmWin() : game.cancelWin());
  }

  Future<void> point(int team, int delta) async {
    await update(game.point(team, delta));
    if (mounted && game.winner != null) await finish();
  }

  Future<void> rename(int team) async {
    final controller = TextEditingController(text: game.names[team]);
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nome da equipe'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 24,
            decoration: const InputDecoration(labelText: 'Equipe'),
            validator: (value) {
              try {
                Match.validName(value ?? '');
                return null;
              } on FormatException catch (e) {
                return e.message;
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (result != null && mounted) await update(game.rename(team, result));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
  }

  Widget board(int team) => TeamBoard(
    game: game,
    team: team,
    saving: saving,
    onRename: () => rename(team),
    onPoint: (delta) => point(team, delta),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NA MESA • SEM COMPLICAÇÃO',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff176b58),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mesa de Truco',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Duas equipes. Uma partida até 12 pontos.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                if (error != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(error!),
                          TextButton(
                            onPressed: saving ? null : () => update(game),
                            child: const Text('Salvar placar atual'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (saving) const LinearProgressIndicator(),
                LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth >= 650
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: board(0)),
                            Expanded(child: board(1)),
                          ],
                        )
                      : Column(children: [board(0), board(1)]),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Nova partida'),
                      onPressed: saving
                          ? null
                          : () async {
                              if (await confirm(
                                    'Nova partida?',
                                    'Os pontos serão zerados. Os nomes e as vitórias serão mantidos.',
                                    'Reiniciar',
                                  ) &&
                                  mounted) {
                                await update(game.restart());
                              }
                            },
                    ),
                    TextButton(
                      onPressed: saving
                          ? null
                          : () async {
                              if (await confirm(
                                    'Zerar vitórias também?',
                                    'Todos os pontos e as vitórias serão apagados.',
                                    'Zerar tudo',
                                  ) &&
                                  mounted) {
                                await update(game.restart(clearWins: true));
                              }
                            },
                      child: const Text('Zerar sessão'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  game.scores.every((s) => s == 11)
                      ? '11 × 11 • Combinem as regras da mão de ferro na mesa.'
                      : 'Marcação manual • Use +1 e −1 conforme o resultado de cada mão.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'O placar é salvo neste dispositivo. As regras regionais ficam por conta da mesa.',
                  style: TextStyle(color: Color(0xff515952)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
