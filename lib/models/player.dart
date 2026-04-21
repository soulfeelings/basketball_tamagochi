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
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.league = 'Street',
  }) : lastEnergyUpdate = lastEnergyUpdate ?? DateTime.now();

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
      energy = (energy + minutes).clamp(0, maxEnergy);
      lastEnergyUpdate = now;
    }
  }

  String get leagueEmoji {
    switch (league) {
      case 'Street': return '🏀';
      case 'High School': return '🏫';
      case 'College': return '🎓';
      case 'Pro': return '🏆';
      default: return '🏀';
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
    matchesPlayed: json['matchesPlayed'],
    matchesWon: json['matchesWon'],
    league: json['league'],
  );

  String serialize() => jsonEncode(toJson());

  factory Player.deserialize(String data) =>
      Player.fromJson(jsonDecode(data));
}
