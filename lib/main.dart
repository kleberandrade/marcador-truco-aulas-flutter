import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/match_store.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrucoApp());
}

class TrucoApp extends StatelessWidget {
  const TrucoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mesa de Truco',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff176b58)),
      scaffoldBackgroundColor: const Color(0xfff3f4ef),
    ),
    home: FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Não foi possível abrir o armazenamento. Recarregue o app.',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return HomePage(store: MatchStore(snapshot.data!));
      },
    ),
  );
}
