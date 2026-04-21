import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  bool _playing = false;
  bool? _won;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final player = game.player!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('${player.leagueEmoji} ${player.league} Match'),
        backgroundColor: const Color(0xFF0F3460),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Energy warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Energy: ${player.energy}/${player.maxEnergy}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(Cost: 40)',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (!_playing && _won == null) ...[
              const Spacer(),
              Icon(
                Icons.sports_basketball,
                size: 80,
                color: Colors.orange.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 20),
              Text(
                'Ready to play?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll face a ${player.league} level opponent',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: player.energy >= 40 ? _startMatch : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  player.energy >= 40 ? 'START MATCH' : 'NOT ENOUGH ENERGY',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
            ] else ...[
              // Result banner
              if (_won != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _won! ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _won! ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _won! ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                        color: _won! ? Colors.amber : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _won! ? 'VICTORY!' : 'DEFEAT',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _won! ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Match log
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: game.matchLog.length,
                    itemBuilder: (context, index) {
                      final line = game.matchLog[index];
                      final isHeader = line.startsWith('---');
                      final isResult = line.startsWith('WIN') || line.startsWith('LOSS') || line.startsWith('PROMOTED');
                      final isScore = line.startsWith('Score:');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          line,
                          style: TextStyle(
                            fontSize: isHeader || isResult ? 14 : 13,
                            fontWeight: isHeader || isResult || isScore ? FontWeight.bold : FontWeight.normal,
                            color: isResult
                                ? (line.startsWith('WIN') || line.startsWith('PROMOTED') ? Colors.green : Colors.red)
                                : isHeader
                                    ? Colors.orange
                                    : isScore
                                        ? Colors.white
                                        : Colors.grey[400],
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16213E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('BACK TO HOME', style: TextStyle(fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startMatch() async {
    setState(() => _playing = true);
    final won = await context.read<GameProvider>().playMatch();
    setState(() {
      _won = won;
      _playing = false;
    });
  }
}
