import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/food.dart';

class GameProvider extends ChangeNotifier {
  Player? _player;
  final Random _random = Random();
  List<String> _matchLog = [];

  // Nutrition tracking
  int trainingBonusSessions = 0;
  double _trainingBonusMultiplier = 1.0;
  Map<String, int> _nutritionStatBoosts = {}; // tracks permanent boosts per stat, cap at +5

  Player? get player => _player;
  List<String> get matchLog => _matchLog;
  int get remainingBonusSessions => trainingBonusSessions;

  bool get hasPlayer => _player != null;

  Future<void> loadPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('player');
    if (data != null) {
      _player = Player.deserialize(data);
      _player!.regenerateEnergy();
      _player!.updateHunger();
      _player!.updateFatigue();

      // Load nutrition extras
      trainingBonusSessions = prefs.getInt('trainingBonusSessions') ?? 0;
      _trainingBonusMultiplier = prefs.getDouble('trainingBonusMultiplier') ?? 1.0;
      for (final stat in ['shooting', 'dribbling', 'defense', 'speed', 'stamina']) {
        _nutritionStatBoosts[stat] = prefs.getInt('nutritionBoost_$stat') ?? 0;
      }

      notifyListeners();
    }
  }

  Future<void> savePlayer() async {
    if (_player == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player', _player!.serialize());
    await prefs.setInt('trainingBonusSessions', trainingBonusSessions);
    await prefs.setDouble('trainingBonusMultiplier', _trainingBonusMultiplier);
    for (final entry in _nutritionStatBoosts.entries) {
      await prefs.setInt('nutritionBoost_${entry.key}', entry.value);
    }
  }

  Future<void> createPlayer(String name, String position) async {
    _player = Player(name: name, position: position);
    trainingBonusSessions = 0;
    _trainingBonusMultiplier = 1.0;
    _nutritionStatBoosts = {};
    await savePlayer();
    notifyListeners();
  }

  Future<void> deletePlayer() async {
    _player = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player');
    await prefs.remove('trainingBonusSessions');
    await prefs.remove('trainingBonusMultiplier');
    for (final stat in ['shooting', 'dribbling', 'defense', 'speed', 'stamina']) {
      await prefs.remove('nutritionBoost_$stat');
    }
    notifyListeners();
  }

  // Eat food
  Future<String> eat(Food food) async {
    if (_player == null) return '';
    if (_player!.coins < food.cost) return 'Not enough coins!';

    _player!.coins -= food.cost;
    _player!.hunger = (_player!.hunger - food.hungerReduction).clamp(0, 100);
    _player!.energy = (_player!.energy + food.energyBoost).clamp(0, _player!.maxEnergy);
    _player!.fatigue = (_player!.fatigue + food.fatigueEffect).clamp(0, 100);

    String result = '${food.emoji} Ate ${food.name}!';

    // Training bonus
    if (food.trainingBonus != null) {
      trainingBonusSessions = 2;
      _trainingBonusMultiplier = 1.0 + food.trainingBonus!;
      result += ' Training bonus active for 2 sessions!';
    }

    // Permanent stat boost
    if (food.permanentStatBoost != null && food.boostStat != null) {
      final stat = food.boostStat!;
      final currentBoost = _nutritionStatBoosts[stat] ?? 0;
      if (currentBoost < 5) {
        _nutritionStatBoosts[stat] = currentBoost + food.permanentStatBoost!;
        switch (stat) {
          case 'shooting':
            _player!.shooting = (_player!.shooting + food.permanentStatBoost!).clamp(0, 99);
            break;
          case 'dribbling':
            _player!.dribbling = (_player!.dribbling + food.permanentStatBoost!).clamp(0, 99);
            break;
          case 'defense':
            _player!.defense = (_player!.defense + food.permanentStatBoost!).clamp(0, 99);
            break;
          case 'speed':
            _player!.speed = (_player!.speed + food.permanentStatBoost!).clamp(0, 99);
            break;
          case 'stamina':
            _player!.stamina = (_player!.stamina + food.permanentStatBoost!).clamp(0, 99);
            break;
        }
        result += ' +${food.permanentStatBoost} $stat!';
      } else {
        result += ' ($stat boost maxed at +5)';
      }
    }

    await savePlayer();
    notifyListeners();
    return result;
  }

  // Training costs 20 energy, improves a skill by 1-3 points
  Future<String> train(String skill) async {
    if (_player == null) return '';
    if (_player!.energy < 20) return 'Not enough energy! Wait for it to recover.';

    _player!.energy -= 20;
    int baseGain = _random.nextInt(3) + 1;

    // Apply training multiplier from hunger/fatigue
    double multiplier = _player!.trainingMultiplier;

    // Apply food training bonus
    if (trainingBonusSessions > 0) {
      multiplier *= _trainingBonusMultiplier;
      trainingBonusSessions--;
    }

    int gain = (baseGain * multiplier).round().clamp(1, 10);
    String result;
    String bonusText = multiplier != 1.0 ? ' (${multiplier > 1.0 ? "+" : ""}${((multiplier - 1.0) * 100).round()}%)' : '';

    switch (skill) {
      case 'shooting':
        _player!.shooting = (_player!.shooting + gain).clamp(0, 99);
        result = 'Shooting +$gain$bonusText (now ${_player!.shooting})';
        break;
      case 'dribbling':
        _player!.dribbling = (_player!.dribbling + gain).clamp(0, 99);
        result = 'Dribbling +$gain$bonusText (now ${_player!.dribbling})';
        break;
      case 'defense':
        _player!.defense = (_player!.defense + gain).clamp(0, 99);
        result = 'Defense +$gain$bonusText (now ${_player!.defense})';
        break;
      case 'speed':
        _player!.speed = (_player!.speed + gain).clamp(0, 99);
        result = 'Speed +$gain$bonusText (now ${_player!.speed})';
        break;
      case 'stamina':
        _player!.stamina = (_player!.stamina + gain).clamp(0, 99);
        result = 'Stamina +$gain$bonusText (now ${_player!.stamina})';
        break;
      default:
        return 'Unknown skill';
    }

    // Training adds a bit of fatigue
    _player!.fatigue = (_player!.fatigue + 5).clamp(0, 100);

    _player!.addXp(15);
    await savePlayer();
    notifyListeners();
    return result;
  }

  // Match simulation
  Future<bool> playMatch() async {
    if (_player == null) return false;
    if (_player!.energy < 40) return false;

    _player!.energy -= 40;
    _matchLog.clear();

    // Check nutrition restrictions
    if (!_player!.canEnterMatch) {
      _matchLog.add('Cannot play - too hungry or fatigued!');
      notifyListeners();
      return false;
    }

    // Opponent strength based on league
    int opponentOverall;
    switch (_player!.league) {
      case 'Street':
        opponentOverall = 15 + _random.nextInt(20);
        break;
      case 'High School':
        opponentOverall = 30 + _random.nextInt(25);
        break;
      case 'College':
        opponentOverall = 50 + _random.nextInt(25);
        break;
      case 'Pro':
        opponentOverall = 70 + _random.nextInt(25);
        break;
      default:
        opponentOverall = 15;
    }

    double performanceMultiplier = _player!.matchPerformanceMultiplier;

    int playerScore = 0;
    int opponentScore = 0;

    // Simulate 4 quarters
    for (int q = 1; q <= 4; q++) {
      _matchLog.add('--- Quarter $q ---');

      for (int play = 0; play < 3; play++) {
        // Player attack (apply performance multiplier)
        int chance = ((_player!.shooting + _player!.dribbling) * performanceMultiplier).round() + _random.nextInt(30);
        if (chance > opponentOverall + _random.nextInt(40)) {
          int pts = _random.nextInt(3) == 0 ? 3 : 2;
          playerScore += pts;
          _matchLog.add('${_player!.name} scores $pts pts!');
        } else {
          _matchLog.add('${_player!.name} misses...');
        }

        // Opponent attack
        chance = opponentOverall + _random.nextInt(30);
        if (chance > (_player!.defense * performanceMultiplier).round() + _random.nextInt(40)) {
          int pts = _random.nextInt(3) == 0 ? 3 : 2;
          opponentScore += pts;
          _matchLog.add('Opponent scores $pts pts.');
        } else {
          _matchLog.add('Great defense by ${_player!.name}!');
        }
      }

      _matchLog.add('Score: $playerScore - $opponentScore');
    }

    bool won = playerScore > opponentScore;
    _player!.matchesPlayed++;

    // Match adds fatigue
    _player!.fatigue = (_player!.fatigue + 15).clamp(0, 100);
    // Match increases hunger
    _player!.hunger = (_player!.hunger + 10).clamp(0, 100);

    if (won) {
      _player!.matchesWon++;
      int xpReward = 30 + (_player!.level * 5);
      int coinReward = 20 + (_player!.level * 10);
      _player!.addXp(xpReward);
      _player!.coins += coinReward;
      _matchLog.add('');
      _matchLog.add('WIN! +$xpReward XP, +$coinReward coins');

      // Check league promotion
      _checkPromotion();
    } else {
      int xpReward = 10;
      _player!.addXp(xpReward);
      _matchLog.add('');
      _matchLog.add('LOSS. +$xpReward XP. Keep training!');
    }

    await savePlayer();
    notifyListeners();
    return won;
  }

  void _checkPromotion() {
    if (_player == null) return;
    switch (_player!.league) {
      case 'Street':
        if (_player!.level >= 5 && _player!.overall >= 25) {
          _player!.league = 'High School';
          _matchLog.add('PROMOTED to High School!');
        }
        break;
      case 'High School':
        if (_player!.level >= 15 && _player!.overall >= 45) {
          _player!.league = 'College';
          _matchLog.add('PROMOTED to College!');
        }
        break;
      case 'College':
        if (_player!.level >= 30 && _player!.overall >= 65) {
          _player!.league = 'Pro';
          _matchLog.add('PROMOTED to Pro League!');
        }
        break;
    }
  }

  void refreshEnergy() {
    _player?.regenerateEnergy();
    _player?.updateHunger();
    _player?.updateFatigue();
    notifyListeners();
  }
}
