import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class GameProvider extends ChangeNotifier {
  Player? _player;
  final Random _random = Random();
  List<String> _matchLog = [];

  Player? get player => _player;
  List<String> get matchLog => _matchLog;

  bool get hasPlayer => _player != null;

  Future<void> loadPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('player');
    if (data != null) {
      _player = Player.deserialize(data);
      _player!.regenerateEnergy();
      notifyListeners();
    }
  }

  Future<void> savePlayer() async {
    if (_player == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player', _player!.serialize());
  }

  Future<void> createPlayer(String name, String position) async {
    _player = Player(name: name, position: position);
    await savePlayer();
    notifyListeners();
  }

  Future<void> deletePlayer() async {
    _player = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player');
    notifyListeners();
  }

  // Training costs 20 energy, improves a skill by 1-3 points
  Future<String> train(String skill) async {
    if (_player == null) return '';
    if (_player!.energy < 20) return 'Not enough energy! Wait for it to recover.';

    _player!.energy -= 20;
    int gain = _random.nextInt(3) + 1;
    String result;

    switch (skill) {
      case 'shooting':
        _player!.shooting = (_player!.shooting + gain).clamp(0, 99);
        result = 'Shooting +$gain (now ${_player!.shooting})';
        break;
      case 'dribbling':
        _player!.dribbling = (_player!.dribbling + gain).clamp(0, 99);
        result = 'Dribbling +$gain (now ${_player!.dribbling})';
        break;
      case 'defense':
        _player!.defense = (_player!.defense + gain).clamp(0, 99);
        result = 'Defense +$gain (now ${_player!.defense})';
        break;
      case 'speed':
        _player!.speed = (_player!.speed + gain).clamp(0, 99);
        result = 'Speed +$gain (now ${_player!.speed})';
        break;
      case 'stamina':
        _player!.stamina = (_player!.stamina + gain).clamp(0, 99);
        result = 'Stamina +$gain (now ${_player!.stamina})';
        break;
      default:
        return 'Unknown skill';
    }

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

    int playerScore = 0;
    int opponentScore = 0;

    // Simulate 4 quarters
    for (int q = 1; q <= 4; q++) {
      _matchLog.add('--- Quarter $q ---');

      for (int play = 0; play < 3; play++) {
        // Player attack
        int chance = _player!.shooting + _player!.dribbling + _random.nextInt(30);
        if (chance > opponentOverall + _random.nextInt(40)) {
          int pts = _random.nextInt(3) == 0 ? 3 : 2;
          playerScore += pts;
          _matchLog.add('${_player!.name} scores $pts pts!');
        } else {
          _matchLog.add('${_player!.name} misses...');
        }

        // Opponent attack
        chance = opponentOverall + _random.nextInt(30);
        if (chance > _player!.defense + _random.nextInt(40)) {
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
    notifyListeners();
  }
}
