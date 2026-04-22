import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hooprise/providers/game_provider.dart';
import 'package:hooprise/screens/create_player_screen.dart';
import 'package:hooprise/screens/home_screen.dart';
import 'package:hooprise/screens/training_screen.dart';
import 'package:hooprise/screens/match_screen.dart';

Widget app(GameProvider game, Widget screen) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
      useMaterial3: true,
    ),
    home: ChangeNotifierProvider<GameProvider>.value(value: game, child: screen),
  );
}

void main() {
  testWidgets('01 Create Player', (tester) async {
    await tester.pumpWidget(app(GameProvider(), const CreatePlayerScreen()));
    await tester.pump();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/01_create_player.png'));
  });

  testWidgets('04 Home Screen', (tester) async {
    final game = GameProvider();
    await game.createPlayer('LeBron Jr', 'Shooting Guard');
    await tester.pumpWidget(app(game, const HomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/04_home_screen.png'));
  });

  testWidgets('05 Training', (tester) async {
    final game = GameProvider();
    await game.createPlayer('LeBron Jr', 'Shooting Guard');
    await tester.pumpWidget(app(game, const TrainingScreen()));
    await tester.pump();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/05_training.png'));
  });

  testWidgets('10 Match Ready', (tester) async {
    final game = GameProvider();
    await game.createPlayer('LeBron Jr', 'Shooting Guard');
    await tester.pumpWidget(app(game, const MatchScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/10_match_ready.png'));
  });

  testWidgets('11 Match Result', (tester) async {
    final game = GameProvider();
    await game.createPlayer('LeBron Jr', 'Shooting Guard');
    await tester.pumpWidget(app(game, const MatchScreen()));
    await tester.pump();
    await tester.tap(find.text('START MATCH'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/11_match_result.png'));
  });
}
