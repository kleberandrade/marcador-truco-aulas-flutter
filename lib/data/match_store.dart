import 'package:shared_preferences/shared_preferences.dart';

import '../domain/match.dart';

class MatchStore {
  static const key = 'truco.match.v1';
  final SharedPreferences preferences;
  MatchStore(this.preferences);
  Match load() {
    final value = preferences.getString(key);
    return value == null ? Match.initial() : Match.decode(value);
  }

  Future<void> save(Match game) async {
    if (!await preferences.setString(key, game.encode())) {
      throw StateError('Save failed');
    }
  }
}
