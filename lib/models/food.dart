class Food {
  final String name;
  final String emoji;
  final int cost;
  final int hungerReduction; // reduces hunger by this amount
  final int energyBoost;
  final int fatigueEffect; // positive = adds fatigue, negative = reduces
  final int? permanentStatBoost; // +1 to a specific stat
  final String? boostStat; // which stat to boost permanently
  final double? trainingBonus; // multiplier for next 2 training sessions
  final String description;

  const Food({
    required this.name,
    required this.emoji,
    required this.cost,
    required this.hungerReduction,
    this.energyBoost = 0,
    this.fatigueEffect = 0,
    this.permanentStatBoost,
    this.boostStat,
    this.trainingBonus,
    required this.description,
  });

  static const List<Food> allFoods = [
    Food(
      name: 'Water',
      emoji: '\u{1F4A7}',
      cost: 5,
      hungerReduction: 20,
      energyBoost: 5,
      description: 'Basic hydration. -20 hunger, +5 energy.',
    ),
    Food(
      name: 'Fast Food',
      emoji: '\u{1F354}',
      cost: 12,
      hungerReduction: 40,
      fatigueEffect: 20,
      description: 'Filling but heavy. -40 hunger, +20 fatigue.',
    ),
    Food(
      name: 'Energy Bar',
      emoji: '\u{1F36B}',
      cost: 25,
      hungerReduction: 30,
      energyBoost: 25,
      description: 'Quick boost. -30 hunger, +25 energy.',
    ),
    Food(
      name: 'Chicken & Rice',
      emoji: '\u{1F357}',
      cost: 60,
      hungerReduction: 60,
      trainingBonus: 0.15,
      description: 'Clean meal. -60 hunger, +15% training bonus (2 sessions).',
    ),
    Food(
      name: 'Protein Shake',
      emoji: '\u{1F964}',
      cost: 80,
      hungerReduction: 20,
      permanentStatBoost: 1,
      boostStat: 'stamina',
      description: 'Premium nutrition. -20 hunger, +1 permanent stamina.',
    ),
  ];
}
