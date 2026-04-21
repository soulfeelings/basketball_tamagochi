import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/create_player_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider()..loadPlayer(),
      child: const HoopRiseApp(),
    ),
  );
}

class HoopRiseApp extends StatelessWidget {
  const HoopRiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basketball Tamagochi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Consumer<GameProvider>(
        builder: (context, game, _) {
          if (game.hasPlayer) {
            return const HomeScreen();
          }
          return const CreatePlayerScreen();
        },
      ),
    );
  }
}
