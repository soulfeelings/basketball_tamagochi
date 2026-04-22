import 'dart:io';
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
  testWidgets('Full game flow', (WidgetTester tester) async {
    final game = GameProvider();

    // 1. Create Player screen
    await tester.pumpWidget(app(game, const CreatePlayerScreen()));
    await tester.pump();
    expect(find.text('START CAREER'), findsOneWidget);

    // 2. Enter name
    await tester.enterText(find.byType(TextField).first, 'LeBron Jr');
    await tester.pump();

    // 3. Select position
    await tester.tap(find.text('Shooting Guard'));
    await tester.pump();

    // 4. Start career
    await tester.tap(find.text('START CAREER'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(game.hasPlayer, isTrue);
    expect(game.player!.name, 'LeBron Jr');
    debugPrint('Player created: ${game.player!.name}, ${game.player!.position}');

    // 5. Home Screen
    await tester.pumpWidget(app(game, const HomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('LeBron Jr'), findsOneWidget);
    expect(find.text('TRAIN'), findsOneWidget);
    debugPrint('Home screen verified');

    // 6. Training
    await tester.pumpWidget(app(game, const TrainingScreen()));
    await tester.pump();
    final oldShooting = game.player!.shooting;
    await tester.tap(find.text('Shooting'));
    await tester.pump();
    expect(game.player!.shooting, greaterThan(oldShooting));
    debugPrint('Shooting trained: ${game.player!.shooting}');

    final oldDribbling = game.player!.dribbling;
    await tester.tap(find.text('Dribbling'));
    await tester.pump();
    expect(game.player!.dribbling, greaterThan(oldDribbling));
    debugPrint('Dribbling trained: ${game.player!.dribbling}');

    await tester.tap(find.text('Defense'));
    await tester.pump();
    debugPrint('Defense trained: ${game.player!.defense}');
    debugPrint('Overall: ${game.player!.overall}, Level: ${game.player!.level}');

    // 7. Match
    await tester.pumpWidget(app(game, const MatchScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('START MATCH'), findsOneWidget);

    await tester.tap(find.text('START MATCH'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(game.player!.matchesPlayed, 1);
    final won = game.player!.matchesWon > 0;
    debugPrint('Match played! ${won ? "WON" : "LOST"}');
    debugPrint('Coins: ${game.player!.coins}, XP: ${game.player!.xp}');
    debugPrint('Record: ${game.player!.matchesWon}/${game.player!.matchesPlayed}');

    expect(find.text('BACK TO HOME'), findsOneWidget);
    debugPrint('All tests passed!');
  });
}
