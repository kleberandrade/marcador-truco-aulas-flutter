import 'package:material_ui/material_ui.dart';

import '../domain/match.dart';

class TeamBoard extends StatelessWidget {
  final Match game;
  final int team;
  final bool saving;
  final VoidCallback onRename;
  final ValueChanged<int> onPoint;
  const TeamBoard({
    super.key,
    required this.game,
    required this.team,
    required this.saving,
    required this.onRename,
    required this.onPoint,
  });
  @override
  Widget build(BuildContext context) {
    final color = team == 0 ? const Color(0xff176b58) : const Color(0xff8b442c);
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'EQUIPE ${team + 1}',
              style: TextStyle(
                color: color,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: saving ? null : onRename,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(
                game.names[team],
                style: const TextStyle(fontSize: 25),
              ),
            ),
            Semantics(
              label: '${game.names[team]}: ${game.scores[team]} de 12 pontos',
              child: ExcludeSemantics(
                child: Text(
                  '${game.scores[team]}',
                  style: TextStyle(
                    fontSize: 104,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            Text(
              '${game.wins[team]} vitórias',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ExcludeSemantics(
              child: LinearProgressIndicator(
                value: game.scores[team] / 12,
                color: color,
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        saving || game.winner != null || game.scores[team] == 0
                        ? null
                        : () => onPoint(-1),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('−1'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: saving || game.winner != null
                        ? null
                        : () => onPoint(1),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('+1'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
