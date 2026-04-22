import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../providers/game_provider.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final player = game.player!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Nutrition'),
        backgroundColor: const Color(0xFF0F3460),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Condition status
            _buildConditionCard(player),
            const SizedBox(height: 16),

            // Hunger bar
            _buildStatusBar(
              label: 'Hunger',
              value: player.hunger,
              maxValue: 100,
              status: player.hungerStatus,
              icon: Icons.restaurant,
              color: _hungerColor(player.hunger),
            ),
            const SizedBox(height: 10),

            // Fatigue bar
            _buildStatusBar(
              label: 'Fatigue',
              value: player.fatigue,
              maxValue: 100,
              status: player.fatigueStatus,
              icon: Icons.bedtime,
              color: _fatigueColor(player.fatigue),
            ),
            const SizedBox(height: 8),

            // Training bonus indicator
            if (game.remainingBonusSessions > 0)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Training bonus active: ${game.remainingBonusSessions} sessions left',
                      style: const TextStyle(color: Colors.green, fontSize: 13),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Coins display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${player.coins} coins',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'FOOD MENU',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Food items
            ...Food.allFoods.map((food) => _buildFoodCard(context, food, player.coins)),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionCard(player) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F3460),
            const Color(0xFF16213E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildConditionItem(
            player.hungerStatus,
            _hungerColor(player.hunger),
            _hungerEmoji(player.hunger),
          ),
          Container(width: 1, height: 40, color: Colors.grey[700]),
          _buildConditionItem(
            player.fatigueStatus,
            _fatigueColor(player.fatigue),
            _fatigueEmoji(player.fatigue),
          ),
          Container(width: 1, height: 40, color: Colors.grey[700]),
          _buildConditionItem(
            'Training',
            Colors.white70,
            '${(player.trainingMultiplier * 100).round()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(String label, Color color, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusBar({
    required String label,
    required int value,
    required int maxValue,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
              const Spacer(),
              Text(
                status,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / maxValue,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$value/$maxValue',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, Food food, int playerCoins) {
    final canAfford = playerCoins >= food.cost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canAfford ? Colors.green.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Text(food.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: canAfford
                  ? () async {
                      final result = await context.read<GameProvider>().eat(food);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result),
                            backgroundColor: result.contains('Not enough') ? Colors.red[700] : Colors.green[700],
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: canAfford
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canAfford
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                    const SizedBox(height: 2),
                    Text(
                      '${food.cost}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hungerColor(int hunger) {
    if (hunger <= 25) return Colors.green;
    if (hunger <= 50) return Colors.lightGreen;
    if (hunger <= 75) return Colors.orange;
    return Colors.red;
  }

  Color _fatigueColor(int fatigue) {
    if (fatigue <= 30) return Colors.green;
    if (fatigue <= 60) return Colors.yellow;
    if (fatigue <= 85) return Colors.orange;
    return Colors.red;
  }

  String _hungerEmoji(int hunger) {
    if (hunger <= 25) return '\u{1F60B}';
    if (hunger <= 50) return '\u{1F642}';
    if (hunger <= 75) return '\u{1F615}';
    return '\u{1F635}';
  }

  String _fatigueEmoji(int fatigue) {
    if (fatigue <= 30) return '\u{1F4AA}';
    if (fatigue <= 60) return '\u{1F612}';
    if (fatigue <= 85) return '\u{1F62B}';
    return '\u{1F634}';
  }
}
