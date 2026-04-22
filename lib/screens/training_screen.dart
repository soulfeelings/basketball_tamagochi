import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final player = game.player!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Training'),
        backgroundColor: const Color(0xFF0F3460),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    '(Cost: 20)',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Condition info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    player.hungerStatus,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.bedtime, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    player.fatigueStatus,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Training: ${(player.trainingMultiplier * 100).round()}%',
                    style: TextStyle(
                      color: player.trainingMultiplier >= 1.0 ? Colors.green : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (game.remainingBonusSessions > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+BONUS (${game.remainingBonusSessions})',
                        style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose a skill to train:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrainButton(context, 'shooting', 'Shooting', Icons.gps_fixed, Colors.red, player.shooting),
            _buildTrainButton(context, 'dribbling', 'Dribbling', Icons.sports_basketball, Colors.blue, player.dribbling),
            _buildTrainButton(context, 'defense', 'Defense', Icons.shield, Colors.green, player.defense),
            _buildTrainButton(context, 'speed', 'Speed', Icons.speed, Colors.purple, player.speed),
            _buildTrainButton(context, 'stamina', 'Stamina', Icons.favorite, Colors.orange, player.stamina),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainButton(BuildContext context, String skill, String label, IconData icon, Color color, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final result = await context.read<GameProvider>().train(skill);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result),
                backgroundColor: result.contains('Not enough') ? Colors.red[700] : Colors.green[700],
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
