import 'dart:convert';

class Player {
  String name;
  String position;
  int level;
  int xp;
  int coins;
  int energy;
  int maxEnergy;
  DateTime lastEnergyUpdate;

  // Skills (0-100)
  int shooting;
  int dribbling;
  int defense;
  int speed;
  int stamina;

  // Nutrition
  int hunger; // 0-100, higher = hungrier
  int fatigue; // 0-100, higher = more tired
  DateTime lastHungerUpdate;

  // Career
  int matchesPlayed;
  int matchesWon;
  String league; // Street, High School, College, Pro

  Player({
    required this.name,
    required this.position,
    this.level = 1,
    this.xp = 0,
    this.coins = 100,
    this.energy = 100,
    this.maxEnergy = 100,
    DateTime? lastEnergyUpdate,
    this.shooting = 10,
    this.dribbling = 10,
    this.defense = 10,
    this.speed = 10,
    this.stamina = 10,
    this.hunger = 50,
    this.fatigue = 0,
    DateTime? lastHungerUpdate,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.league = 'Street',
  })  : lastEnergyUpdate = lastEnergyUpdate ?? DateTime.now(),
        lastHungerUpdate = lastHungerUpdate ?? DateTime.now();

  int get overall => ((shooting + dribbling + defense + speed + stamina) / 5).round();

  int get xpForNextLevel => level * 100;

  bool get canLevelUp => xp >= xpForNextLevel;

  void addXp(int amount) {
    xp += amount;
    while (canLevelUp) {
      xp -= xpForNextLevel;
      level++;
      maxEnergy += 5;
      energy = maxEnergy;
    }
  }

  void regenerateEnergy() {
    final now = DateTime.now();
    final minutes = now.difference(lastEnergyUpdate).inMinutes;
    if (minutes > 0) {
      // Hunger 51-75: energy regen halved
      int regenAmount = minutes;
      if (hunger > 50 && hunger <= 75) {
        regenAmount = (regenAmount / 2).floor();
      } else if (hunger > 75) {
        regenAmount = (regenAmount / 2).floor();
      }
      energy = (energy + regenAmount).clamp(0, maxEnergy);
      lastEnergyUpdate = now;
    }
  }

  // Hunger: increases by 3 per hour since last update
  void updateHunger() {
    final now = DateTime.now();
    final hours = now.difference(lastHungerUpdate).inMinutes / 60.0;
    if (hours > 0) {
      int increase = (hours * 3).floor();
      if (increase > 0) {
        hunger = (hunger + increase).clamp(0, 100);
        lastHungerUpdate = now;
      }
    }
  }

  // Fatigue: passive decay of -2 per hour
  void updateFatigue() {
    final now = DateTime.now();
    final hours = now.difference(lastHungerUpdate).inMinutes / 60.0;
    if (hours > 0) {
      int decrease = (hours * 2).floor();
      if (decrease > 0) {
        fatigue = (fatigue - decrease).clamp(0, 100);
      }
    }
  }

  String get hungerStatus {
    if (hunger <= 25) return 'Full';
    if (hunger <= 50) return 'Satisfied';
    if (hunger <= 75) return 'Hungry';
    return 'Starving';
  }

  String get fatigueStatus {
    if (fatigue <= 30) return 'Fresh';
    if (fatigue <= 60) return 'Tired';
    if (fatigue <= 85) return 'Exhausted';
    return 'Burned Out';
  }

  // Combined training multiplier from hunger + fatigue
  double get trainingMultiplier {
    double multiplier = 1.0;

    // Hunger effects on training
    if (hunger <= 25) {
      multiplier *= 1.10; // Full: +10%
    } else if (hunger > 75) {
      multiplier *= 0.75; // Starving: -25%
    }

    // Fatigue effects on training
    if (fatigue > 30 && fatigue <= 60) {
      multiplier *= 0.75; // Tired: -25%
    } else if (fatigue > 60) {
      multiplier *= 0.75; // Exhausted+: also -25%
    }

    return multiplier;
  }

  // Match performance multiplier (fatigue-based)
  double get matchPerformanceMultiplier {
    double multiplier = 1.0;
    if (fatigue > 60 && fatigue <= 85) {
      multiplier *= 0.90; // Exhausted: -10%
    } else if (fatigue > 85) {
      multiplier *= 0.90;
    }
    return multiplier;
  }

  bool get canEnterMatch {
    if (hunger > 75) return false; // Starving
    if (fatigue > 85) return false; // Burned Out
    return true;
  }

  String get leagueEmoji {
    switch (league) {
      case 'Street': return '\u{1F3C0}';
      case 'High School': return '\u{1F3EB}';
      case 'College': return '\u{1F393}';
      case 'Pro': return '\u{1F3C6}';
      default: return '\u{1F3C0}';
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'position': position,
    'level': level,
    'xp': xp,
    'coins': coins,
    'energy': energy,
    'maxEnergy': maxEnergy,
    'lastEnergyUpdate': lastEnergyUpdate.toIso8601String(),
    'shooting': shooting,
    'dribbling': dribbling,
    'defense': defense,
    'speed': speed,
    'stamina': stamina,
    'hunger': hunger,
    'fatigue': fatigue,
    'lastHungerUpdate': lastHungerUpdate.toIso8601String(),
    'matchesPlayed': matchesPlayed,
    'matchesWon': matchesWon,
    'league': league,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    name: json['name'],
    position: json['position'],
    level: json['level'],
    xp: json['xp'],
    coins: json['coins'],
    energy: json['energy'],
    maxEnergy: json['maxEnergy'],
    lastEnergyUpdate: DateTime.parse(json['lastEnergyUpdate']),
    shooting: json['shooting'],
    dribbling: json['dribbling'],
    defense: json['defense'],
    speed: json['speed'],
    stamina: json['stamina'],
    hunger: json['hunger'] ?? 50,
    fatigue: json['fatigue'] ?? 0,
    lastHungerUpdate: json['lastHungerUpdate'] != null
        ? DateTime.parse(json['lastHungerUpdate'])
        : null,
    matchesPlayed: json['matchesPlayed'],
    matchesWon: json['matchesWon'],
    league: json['league'],
  );

  String serialize() => jsonEncode(toJson());

  factory Player.deserialize(String data) =>
      Player.fromJson(jsonDecode(data));
}
