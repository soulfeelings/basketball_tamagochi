# Basketball Tamagochi

## Overview
A mobile RPG-style basketball career game built with Flutter. You create and grow your basketball player from street courts to professional leagues.

## Tech Stack
- Flutter (cross-platform: Android + iOS)
- Dart
- Provider for state management

## Game Concept
- Create your player (name, position)
- Train skills: shooting, dribbling, defense, speed, stamina
- Play simulated matches against AI opponents
- Earn XP and coins from matches
- Level up and progress through leagues (Street → High School → College → Pro)
- Manage energy — training and matches cost energy, which recovers over time

## Project Structure
```
lib/
  main.dart              — App entry point
  models/                — Data models (Player, Match, etc.)
  screens/               — UI screens (Home, Training, Match, etc.)
  providers/             — State management
  widgets/               — Reusable UI components
```

## Build & Run
```bash
flutter pub get
flutter run
```

## Git
- Remote: git@github.com:soulfeelings/basketball_tamagochi.git
- Branch: main
