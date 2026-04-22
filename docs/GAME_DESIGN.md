# Basketball Tamagochi — Game Design Document

**Version:** 1.0
**Date:** 2026-04-22
**Platform:** Flutter (Android + iOS)
**Status:** Active Development

---

## Table of Contents

1. [Game Overview](#1-game-overview)
2. [Core Loop](#2-core-loop)
3. [Player Creation](#3-player-creation)
4. [Progression System](#4-progression-system)
5. [Energy System](#5-energy-system)
6. [Nutrition System](#6-nutrition-system)
7. [Match System](#7-match-system)
8. [Economy](#8-economy)
9. [Screens & UI Flow](#9-screens--ui-flow)
10. [Future Features](#10-future-features)

---

## 1. Game Overview

### Elevator Pitch

**Basketball Tamagochi** is a mobile RPG where you raise a basketball player from dusty street courts all the way to the professional leagues. Like a Tamagochi, your player needs constant care — feed them, rest them, train them — or their performance suffers. Unlike a Tamagochi, the end goal is glory: a championship ring in the Pro League.

### Target Audience

| Segment | Description |
|---|---|
| Primary | Casual mobile gamers aged 16–35 who follow basketball |
| Secondary | RPG fans who enjoy stat-building and progression systems |
| Tertiary | Users nostalgic for Tamagochi-style nurturing games |

The game respects the player's time. Sessions can be 2 minutes (check hunger, eat, train one skill) or 20 minutes (multiple matches, full nutrition management). There is no mandatory real-time obligation — the player degrades slowly and recovers slowly, so missing a day is recoverable.

### Platform

- **Flutter** cross-platform: targets Android and iOS from a single codebase
- **State management:** Provider pattern (`GameProvider` as the single source of truth)
- **Persistence:** `SharedPreferences` for local save data — no account or server required
- **Remote:** `git@github.com:soulfeelings/basketball_tamagochi.git`, branch `main`

---

## 2. Core Loop

The game operates on a nested loop structure: a fast inner loop (seconds), a medium loop (minutes/hours), and a long arc (days/weeks).

### Loop Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        LONG ARC (days–weeks)                    │
│  Accumulate enough Level + Overall rating → League Promotion    │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  MEDIUM LOOP (minutes–hours)              │  │
│  │  Energy regenerates → Hunger rises → Fatigue decays       │  │
│  │                                                            │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │                 FAST LOOP (per session)             │  │  │
│  │  │                                                      │  │  │
│  │  │   CHECK STATUS                                       │  │  │
│  │  │       │                                              │  │  │
│  │  │       ▼                                              │  │  │
│  │  │   MANAGE NUTRITION ──► Buy food ──► Eat              │  │  │
│  │  │   (hunger/fatigue)      (coins)     (reduces hunger, │  │  │
│  │  │       │                              may boost stats) │  │  │
│  │  │       ▼                                              │  │  │
│  │  │   TRAIN SKILLS ──────► -20 energy, +1–3 skill,      │  │  │
│  │  │   (if energy ≥ 20)      +15 XP, +5 fatigue          │  │  │
│  │  │       │                                              │  │  │
│  │  │       ▼                                              │  │  │
│  │  │   PLAY MATCH ────────► -40 energy, +15 fatigue,     │  │  │
│  │  │   (if energy ≥ 40)      +10 hunger                  │  │  │
│  │  │       │                    │                         │  │  │
│  │  │       │              WIN ──┤── LOSS                  │  │  │
│  │  │       │              +XP   │   +10 XP                │  │  │
│  │  │       │              +coins│                         │  │  │
│  │  │       ▼                    ▼                         │  │  │
│  │  │   LEVEL UP? ──────────► max energy +5, energy refill │  │  │
│  │  │                                                      │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Tensions

- **Energy vs. Progress:** Training and matches consume energy, but energy recovers at only 1 point per minute. Players must decide when to act and when to wait.
- **Hunger vs. Economy:** Ignoring hunger penalizes training and eventually blocks matches, but premium food costs coins that could be saved. Cheap food (Water, 5 coins) only partially solves the problem.
- **Fatigue vs. Activity:** Every training session and every match increases fatigue. High fatigue reduces training gains and match performance. Players must balance activity with recovery time.
- **Coins vs. Progression:** Food costs coins. The only way to earn coins is by winning matches. Losing streaks create a resource squeeze.

---

## 3. Player Creation

Players are created on the **Create Player Screen** before any gameplay begins. No player data exists until creation is confirmed.

### Inputs

| Field | Type | Options |
|---|---|---|
| Name | Free text | Any non-empty string |
| Position | Single select | Point Guard, Shooting Guard, Small Forward, Power Forward, Center |

### Starting Stats

All players begin with identical base stats regardless of position. Position is a label only — it has no mechanical effect in the current implementation. This is intentional for v1; position-specific stat biases are a planned future feature.

| Stat | Starting Value |
|---|---|
| Level | 1 |
| XP | 0 |
| Coins | 100 |
| Energy | 100 |
| Max Energy | 100 |
| Shooting | 10 |
| Dribbling | 10 |
| Defense | 10 |
| Speed | 10 |
| Stamina | 10 |
| Hunger | 50 (Satisfied) |
| Fatigue | 0 (Fresh) |
| League | Street |
| Matches Played | 0 |
| Matches Won | 0 |

### Overall Rating

The **Overall** (OVR) is a single number displayed prominently in the player header. It is the arithmetic mean of all five skills, rounded to the nearest integer:

```
Overall = round((Shooting + Dribbling + Defense + Speed + Stamina) / 5)
```

At creation, Overall = 10. The theoretical maximum is 99 (all skills capped at 99).

---

## 4. Progression System

### 4.1 XP and Leveling

XP is earned from training and matches. The XP threshold to reach the next level scales linearly with current level:

```
XP required for next level = current_level × 100
```

**Examples:**

| Current Level | XP Needed to Level Up |
|---|---|
| 1 | 100 |
| 5 | 500 |
| 10 | 1,000 |
| 15 | 1,500 |
| 30 | 3,000 |

**On Level Up:**
- Excess XP carries over: `xp = xp - xpForNextLevel` (loops until `xp < threshold`)
- `maxEnergy += 5`
- `energy = maxEnergy` (full energy refill)

This means leveling up is also an energy refill mechanic — a meaningful reward beyond the stat gate.

**XP Sources:**

| Action | XP Earned |
|---|---|
| Training (any skill) | 15 XP |
| Match — Loss | 10 XP |
| Match — Win | `30 + (level × 5)` XP |

A level 1 win yields 35 XP. A level 10 win yields 80 XP. This makes winning increasingly valuable and sustains the grind at higher levels.

### 4.2 League Progression

There are four leagues, representing the career arc from nobody to professional. Promotion is checked automatically after every match win. It is never possible to be demoted.

| League | Emoji | Promotion Requirements |
|---|---|---|
| Street | Basketball | Starting league |
| High School | School building | Level ≥ 5 AND Overall ≥ 25 |
| College | Graduation cap | Level ≥ 15 AND Overall ≥ 45 |
| Pro | Trophy | Level ≥ 30 AND Overall ≥ 65 |

Both conditions (Level AND Overall) must be met simultaneously. Overall is skill-gated, not level-gated, so a player who grinds XP without training skills will not promote even at the right level.

**Estimated time to Pro League:** With consistent play (training and winning), a player starting at all-10 skills needs to raise their Overall to 65, which requires gaining approximately 275 skill points total across five attributes. At 1–3 skill points per training session (average ~2), that is roughly 137+ training sessions. With 20 energy per training session and a base 100 energy pool, a dedicated session might include 4–5 training actions. This puts the Pro journey at dozens of real-world play sessions — comfortably a multi-week progression.

### 4.3 Skill Growth Through Training

Skills are trained individually. Each training action on a chosen skill:

1. Costs **20 energy**
2. Generates a **base gain** of 1, 2, or 3 (uniform random)
3. Applies the **training multiplier** (see Nutrition System)
4. Adds **+5 fatigue** to the player
5. Awards **+15 XP**

```
final_gain = clamp(round(base_gain × training_multiplier), 1, 10)
```

The `clamp(1, 10)` means even with heavy penalties the player always gains at least 1 point, and with stacked bonuses the ceiling is 10 per session. All skill values are hard-capped at **99**.

---

## 5. Energy System

Energy is the primary action resource. It gates both training and matches.

### Energy Parameters

| Parameter | Value |
|---|---|
| Starting energy | 100 |
| Starting max energy | 100 |
| Max energy increase per level-up | +5 |
| Energy cost: Training | 20 |
| Energy cost: Match | 40 |
| Passive regen rate (base) | 1 point per minute |

### Energy Regeneration

Energy regenerates passively over real time. The app calculates elapsed minutes since the last energy update whenever the player state is loaded or refreshed. The home screen timer fires every 60 seconds to trigger `refreshEnergy()`.

**Hunger modifier on regen:**

| Hunger State | Regen Rate |
|---|---|
| Full (0–25) | 1 per minute (normal) |
| Satisfied (26–50) | 1 per minute (normal) |
| Hungry (51–75) | 0.5 per minute (halved, `floor`) |
| Starving (76–100) | 0.5 per minute (halved, `floor`) |

Note: The code applies the same halved regen for both Hungry and Starving states. This is an area for future differentiation — Starving could realistically have zero regen.

### Energy Capacity Growth

At level 1, max energy is 100. Each level-up adds 5. By level 10, max energy is 145. By level 30 (Pro threshold), max energy is 195. This means higher-level players can batch more actions per session without waiting.

---

## 6. Nutrition System

The Nutrition System is the Tamagochi heart of the game. Two meters — **Hunger** and **Fatigue** — passively change over real time and directly affect training efficiency, match eligibility, and energy regeneration.

### 6.1 Hunger Meter

**Direction:** Higher value = worse. 0 is perfectly full; 100 is starving.
**Passive change:** +3 per real-world hour (calculated in fractional hours, applied in whole-number increments)
**Starting value:** 50

| Range | Status Label | UI Color | Effect |
|---|---|---|---|
| 0–25 | Full | Green | Training multiplier ×1.10 (+10%) |
| 26–50 | Satisfied | Light Green | No bonus or penalty |
| 51–75 | Hungry | Orange | Energy regen halved |
| 76–100 | Starving | Red | Training multiplier ×0.75 (−25%), energy regen halved, **cannot enter matches** |

A neglected player left for ~17 hours from starting hunger of 50 will reach Starving (100). At that point they cannot play matches at all, and training is severely penalized.

### 6.2 Fatigue Meter

**Direction:** Higher value = worse. 0 is fully rested; 100 is burned out.
**Passive change:** −2 per real-world hour (naturally recovers over time)
**Starting value:** 0
**Activity effects:** +5 per training session, +15 per match played

| Range | Status Label | UI Color | Effect |
|---|---|---|---|
| 0–30 | Fresh | Green | No penalty |
| 31–60 | Tired | Yellow | Training multiplier ×0.75 (−25%) |
| 61–85 | Exhausted | Orange | Training multiplier ×0.75 (−25%), match performance multiplier ×0.90 (−10%) |
| 86–100 | Burned Out | Red | Training multiplier ×0.75 (−25%), match performance multiplier ×0.90 (−10%), **cannot enter matches** |

Fatigue from activity: playing 3 matches in one session (120 energy cost — feasible at higher levels) raises fatigue by 45. A player at Exhausted who plays a match will push into Burned Out and be locked out. Natural recovery at −2/hr means recovering from 100 to 30 (Fresh threshold) takes 35 real-world hours without any food intervention.

### 6.3 Combined Training Multiplier

The `trainingMultiplier` is a product of the hunger modifier and the fatigue modifier:

```
multiplier = hunger_mod × fatigue_mod

hunger_mod:
  hunger 0–25   → 1.10
  hunger 26–75  → 1.00
  hunger 76–100 → 0.75

fatigue_mod:
  fatigue 0–30  → 1.00
  fatigue 31+   → 0.75
```

**Combined multiplier lookup:**

| Hunger State | Fatigue State | Training Multiplier |
|---|---|---|
| Full | Fresh | 1.10 (best case) |
| Full | Tired/Exhausted/Burned Out | 0.825 |
| Satisfied | Fresh | 1.00 |
| Satisfied | Tired+ | 0.75 |
| Hungry | Fresh | 1.00 |
| Hungry | Tired+ | 0.75 |
| Starving | Fresh | 0.75 |
| Starving | Tired+ | 0.5625 (worst case) |

The optimal state for training is **Full + Fresh**, which yields a 10% bonus. Stacked penalties at Starving + Tired reduce effective training to 56.25% of base — nearly halving the gain.

### 6.4 Food Items

All food is available at all times from the Nutrition Screen at a flat coin cost. There is no cooldown on eating.

| Item | Emoji | Cost | Hunger | Energy | Fatigue | Special |
|---|---|---|---|---|---|---|
| Water | Droplet | 5 | −20 | +5 | 0 | — |
| Fast Food | Burger | 12 | −40 | 0 | +20 | — |
| Energy Bar | Chocolate | 25 | −30 | +25 | 0 | — |
| Chicken & Rice | Chicken leg | 60 | −60 | 0 | 0 | +15% training bonus, next 2 sessions |
| Protein Shake | Cup | 80 | −20 | 0 | 0 | +1 permanent Stamina (capped at +5 total) |

**Design notes on each item:**

- **Water (5c):** The budget option. Won't solve serious hunger but costs almost nothing and provides a small energy top-up. Useful early game when coins are scarce.
- **Fast Food (12c):** A trap for inattentive players. It solves hunger well but adds 20 fatigue — which at a low base could push the player into Tired, negating training efficiency. Better to spend more.
- **Energy Bar (25c):** Best value for energy recovery. Useful before a match when energy is low.
- **Chicken & Rice (60c):** The training optimizer's choice. Maximal hunger reduction plus a 15% training bonus on the next two sessions. Most efficient for players actively grinding skills.
- **Protein Shake (80c):** The premium long-term investment. +1 permanent Stamina per purchase, up to a total of +5 stat points through nutrition. At 80 coins each, maxing the bonus costs 400 coins — a significant investment that pays off over the full game.

**Protein Shake cap mechanics:** The `_nutritionStatBoosts` map in `GameProvider` tracks cumulative permanent boosts per stat. Once a stat has received 5 total boosts from nutrition, the purchase still costs coins but yields no additional stat gain. The game notifies the player: "(stamina boost maxed at +5)". This is a coin-waste risk players should be aware of.

### 6.5 How Nutrition Affects Matches

Two nutrition conditions **block match entry entirely:**
- Hunger > 75 (Starving)
- Fatigue > 85 (Burned Out)

If either condition is met, calling `playMatch()` will add a log entry ("Cannot play - too hungry or fatigued!") and return false without consuming energy. This is a hard gate, not a soft penalty.

When the player is allowed to play but is Exhausted (fatigue 61–85) or Burned Out (86+), a `matchPerformanceMultiplier` of 0.90 is applied:
- Player attack chance: `(shooting + dribbling) × 0.90`
- Player defense: `defense × 0.90`

This represents the player physically dragging through the game.

---

## 7. Match System

### 7.1 Entering a Match

Requirements:
- Energy ≥ 40
- Hunger ≤ 75 (not Starving)
- Fatigue ≤ 85 (not Burned Out)

On entry, 40 energy is immediately deducted whether the player wins or loses.

### 7.2 Opponent Strength

Opponents are generated with a random Overall rating based on the player's current league:

| League | Opponent Overall Range |
|---|---|
| Street | 15–34 (base 15 + rand 0–19) |
| High School | 30–54 (base 30 + rand 0–24) |
| College | 50–74 (base 50 + rand 0–24) |
| Pro | 70–94 (base 70 + rand 0–24) |

League ranges overlap — a Street opponent at their ceiling (34) is stronger than a High School opponent at their floor (30). This creates natural variance and occasional upset scenarios.

### 7.3 Match Simulation

Matches are simulated as **4 quarters × 3 plays** = 12 attack/defense rounds per side. Each play:

**Player attack:**
```
attack_chance = round((shooting + dribbling) × performanceMultiplier) + rand(0–29)
if attack_chance > (opponentOverall + rand(0–39)):
    score += rand(0,1) == 0 ? 3 : 2    // 1-in-3 chance of 3-pointer, else 2-pointer
```

**Opponent attack:**
```
opponent_chance = opponentOverall + rand(0–29)
if opponent_chance > round(defense × performanceMultiplier) + rand(0–39):
    score += rand(0,1) == 0 ? 3 : 2
```

`performanceMultiplier` = 1.0 normally, 0.90 when Exhausted or Burned Out.

### 7.4 Result Calculation

The match is won if `playerScore > opponentScore`. Ties go to the opponent (no overtime mechanic in v1).

**Win rewards:**
```
xpReward = 30 + (level × 5)
coinReward = 20 + (level × 10)
```

**Example rewards by level:**

| Level | XP on Win | Coins on Win |
|---|---|---|
| 1 | 35 | 30 |
| 5 | 55 | 70 |
| 10 | 80 | 120 |
| 15 | 105 | 170 |
| 30 | 180 | 320 |

**Loss rewards:** Flat 10 XP, no coins.

### 7.5 Post-Match State Changes

Regardless of win or loss:
- Fatigue +15
- Hunger +10
- `matchesPlayed` increments

On win:
- `matchesWon` increments
- XP and coins added
- `_checkPromotion()` runs

### 7.6 Match Log

A scrollable log records every play event: quarter headers, scoring plays, defensive stops, running score, and the final result including XP/coin rewards and any promotion notification. This log is cleared at the start of each new match.

---

## 8. Economy

### Coin Sources

| Source | Amount | Notes |
|---|---|---|
| Player creation | 100 | One-time starting bonus |
| Match win (level 1) | 30 | `20 + (1 × 10)` |
| Match win (level 10) | 120 | `20 + (10 × 10)` |
| Match win (level 30) | 320 | `20 + (30 × 10)` |

Coins are **only earned by winning matches**. Losses yield nothing. This creates a direct link between player skill level and economic throughput.

### Coin Sinks

| Sink | Cost | Notes |
|---|---|---|
| Water | 5 | Minimal hunger fix |
| Fast Food | 12 | Hunger fix with fatigue drawback |
| Energy Bar | 25 | Energy recovery |
| Chicken & Rice | 60 | Best training optimizer |
| Protein Shake | 80 | Permanent +1 Stamina (×5 max) |

### Economic Balance Notes

**Early game (Street league, level 1–4):**
Starting coins: 100. A win earns ~30 coins. The cheapest meaningful food (Fast Food) costs 12. Players can sustain themselves on cheap food while losing, but the 20 fatigue penalty from Fast Food can create a trap. A losing player with dwindling coins may over-rely on Fast Food, increasing fatigue, reducing training efficiency, and perpetuating the losing streak. This is intentional tension.

**Mid game (High School, level 5–14):**
Win rewards scale to 70–150 coins. Chicken & Rice (60 coins) becomes affordable as a regular purchase. Players can now meaningfully invest in nutrition as a training multiplier.

**Late game (College/Pro, level 15–30+):**
Win rewards exceed 150–320 coins per match. Protein Shake (80 coins) is a routine purchase. The 400-coin cost to max out the nutrition Stamina bonus is achievable in a few sessions.

**Coin floor:** There is no coin floor protection. A player who spends all coins and cannot win a match faces a progression pause. In practice, starting with 100 coins and cheap food options (Water at 5 coins) means a complete coin drain is recoverable with one or two wins.

---

## 9. Screens & UI Flow

### Screen Inventory

| Screen | File | Purpose |
|---|---|---|
| Create Player | `create_player_screen.dart` | One-time player setup |
| Home | `home_screen.dart` | Dashboard and navigation hub |
| Training | `training_screen.dart` | Skill training actions |
| Match | `match_screen.dart` | Match initiation and log |
| Nutrition | `nutrition_screen.dart` | Food purchase and meter display |

### Navigation Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                       App Launch                                │
│                           │                                     │
│              loadPlayer() from SharedPreferences                │
│                           │                                     │
│              ┌────────────┴────────────┐                        │
│              │                         │                        │
│         No save data              Save data found               │
│              │                         │                        │
│              ▼                         ▼                        │
│   ┌─────────────────────┐   ┌─────────────────────────────┐    │
│   │  CREATE PLAYER      │   │         HOME SCREEN         │    │
│   │                     │   │                             │    │
│   │  • Enter name       │   │  Player header (OVR badge,  │    │
│   │  • Choose position  │   │  name, position, level,     │    │
│   │  • START CAREER     │   │  hunger status, XP bar,     │    │
│   │        │            │   │  coins)                     │    │
│   └────────┼────────────┘   │                             │    │
│            │                │  Skills card (5 stat bars)  │    │
│            └───────────────►│                             │    │
│                             │  Energy bar                 │    │
│                             │  Hunger bar                 │    │
│                             │  Fatigue bar                │    │
│                             │                             │    │
│                             │  Career card (league,       │    │
│                             │  played, won, win %)        │    │
│                             │                             │    │
│                             │  [TRAIN] [EAT] [MATCH]      │    │
│                             └──────────┬──────────────────┘    │
│                                        │                        │
│                    ┌───────────────────┼───────────────────┐   │
│                    │                   │                   │   │
│                    ▼                   ▼                   ▼   │
│          ┌──────────────┐   ┌──────────────────┐  ┌────────────┐│
│          │  TRAINING    │   │   NUTRITION      │  │   MATCH   ││
│          │              │   │                  │  │           ││
│          │ Energy info  │   │ Condition card   │  │ Energy    ││
│          │ (cost: 20)   │   │ (hunger status,  │  │ info      ││
│          │              │   │  fatigue status, │  │ (cost:40) ││
│          │ Condition    │   │  training %)     │  │           ││
│          │ row (hunger, │   │                  │  │ Pre-match ││
│          │  fatigue,    │   │ Hunger bar       │  │ ready     ││
│          │  multiplier, │   │ Fatigue bar      │  │ screen    ││
│          │  bonus badge)│   │                  │  │           ││
│          │              │   │ Training bonus   │  │ START     ││
│          │ 5 skill      │   │ indicator        │  │ MATCH     ││
│          │ buttons with │   │                  │  │ button    ││
│          │ current value│   │ Coins display    │  │    │      ││
│          │              │   │                  │  │    ▼      ││
│          │ Tap → train  │   │ Food menu        │  │ Match log ││
│          │ → snackbar   │   │ (5 items, buy    │  │ (4 qtrs, ││
│          │              │   │  button per item)│  │  plays,   ││
│          │              │   │                  │  │  score,   ││
│          │              │   │ Tap → eat        │  │  result)  ││
│          │              │   │ → snackbar       │  │           ││
│          └──────┬───────┘   └────────┬─────────┘  └─────┬──────┘│
│                 │                    │                   │       │
│                 └────────────────────┴───────────────────┘       │
│                              Back → HOME                         │
└─────────────────────────────────────────────────────────────────┘
```

### Home Screen Auto-Refresh

The Home Screen runs a `Timer.periodic` at 1-minute intervals that calls `GameProvider.refreshEnergy()`. This triggers `regenerateEnergy()`, `updateHunger()`, and `updateFatigue()` on every tick, keeping the displayed meters live without requiring user interaction.

### Data Persistence

All player state is serialized to JSON and stored under the `"player"` key in `SharedPreferences`. Additional nutrition state (bonus sessions, bonus multiplier, per-stat boost counts) is stored as separate `SharedPreferences` keys. The save fires after every meaningful action (eating, training, playing a match, creating/deleting a player).

---

## 10. Future Features

Features are listed in priority order. High-priority items have the most direct impact on retention and the core loop. Lower-priority items expand the game's surface area.

---

### Priority 1 — Daily Login Rewards

**Why first:** The single highest-impact retention mechanic for any mobile game. Gives players a reason to open the app every day independent of active session length.

**Design sketch:**
- Day 1: 50 coins
- Day 2: 1 Energy Bar (free)
- Day 3: 100 coins
- Day 4: 1 Chicken & Rice (free)
- Day 5: 200 coins
- Day 6: 1 Protein Shake (free)
- Day 7: 500 coins + full energy refill

Streaks reset if a day is missed. A 7-day cycle repeats with escalating rewards after the first cycle.

**Implementation notes:** Requires storing last login date in `SharedPreferences`. Can be added to `GameProvider` as a `checkDailyReward()` method called in `loadPlayer()`.

---

### Priority 2 — Position-Based Stat Biases

**Why second:** Position is already in the data model and UI but has zero mechanical effect. Adding biases closes a design gap and improves player identity.

**Design sketch:**

| Position | Primary Stat Bonus | Secondary Stat Bonus |
|---|---|---|
| Point Guard | Speed +5 | Dribbling +3 |
| Shooting Guard | Shooting +5 | Speed +3 |
| Small Forward | Shooting +3 | Defense +3 |
| Power Forward | Defense +5 | Stamina +3 |
| Center | Stamina +5 | Defense +3 |

Applied at player creation as starting stat adjustments. All players still start Overall = 10 (adjusted average). Biases are in starting composition, not in growth rate.

---

### Priority 3 — Equipment Shop

**Why third:** Adds a second major coin sink and a new progression axis. Prevents coins from becoming valueless at high levels.

**Design sketch:**
- Equipment items (shoes, jersey, training gear) provide permanent passive bonuses
- Shoes: +X speed
- Wristband: +X% training efficiency
- Performance jersey: +X% match performance
- Each item has 3–5 upgrade tiers
- Costs scale from 200 to 2,000 coins

**Implementation notes:** Requires a new `Equipment` model, a new `ShopScreen`, and additional stat-modifier logic in `GameProvider`. The training and match multiplier chains should be refactored to accommodate equipment bonuses cleanly.

---

### Priority 4 — Skill-Specific Training Mini-Games

**Why fourth:** Transforms training from a single tap into an engaging skill-based moment. Increases session length and sense of agency.

**Design sketch:**
- Each skill unlocks a short mini-game (10–20 seconds)
- Shooting: tap moving targets (free-throw timing bar)
- Dribbling: tap in rhythm (beat-based)
- Defense: swipe to block incoming shots
- Speed: rapid taps (sprint sequence)
- Stamina: endurance hold (long press)

Performance on the mini-game determines the gain bracket:
- Perfect: base gain ×1.5
- Good: base gain ×1.0 (current behavior)
- Missed: base gain ×0.5 (minimum 1)

The current random 1–3 gain becomes the baseline for the Good outcome.

---

### Priority 5 — Multiplayer League Challenges

**Why fifth:** High complexity, high reward for long-term retention. Requires backend infrastructure absent from v1.

**Design sketch:**
- Asynchronous PvP: players submit a "challenge" with their current stats; opponents play against a simulated version
- Weekly league tables: top players per league bracket earn bonus coins and special cosmetic rewards
- No real-time requirement — all matches remain simulated on-device against uploaded opponent snapshots

**Implementation notes:** Requires a server (Firebase or similar), account system, and significant new UI. Should not block the v1 launch. Estimated scope: 3–4× the current codebase size.

---

### Priority 6 — 3D Player Model

**Why last:** Highest visual impact but no gameplay change. Appropriate after core mechanics are proven and stable.

**Design sketch:**
- Animated 3D character displayed on the Home Screen
- Idle, training, and match-ready animation states
- Visual indicators: slumped posture when fatigued, energetic stance when Fresh + Full
- Position-specific uniform based on player's chosen position

**Implementation notes:** Requires Flutter 3D rendering (via `flutter_3d_controller` or similar package), or pre-rendered sprite sheets as a lower-cost alternative. The sprite-sheet approach is recommended for v1.5; full 3D for v2.0.

---

## Appendix: Key Formulas Quick Reference

| Formula | Expression |
|---|---|
| XP for next level | `level × 100` |
| Overall rating | `round((shooting + dribbling + defense + speed + stamina) / 5)` |
| Win XP reward | `30 + (level × 5)` |
| Win coin reward | `20 + (level × 10)` |
| Energy regen rate (base) | 1 per minute |
| Energy regen rate (hungry/starving) | 0.5 per minute |
| Hunger increase rate | 3 per hour |
| Fatigue decay rate | 2 per hour |
| Training fatigue cost | +5 per session |
| Match fatigue cost | +15 per match |
| Match hunger cost | +10 per match |
| Training gain range | 1–3 (base) × multiplier, clamped 1–10 |
| Max energy at level N | `100 + (N - 1) × 5` |

---

*This document reflects the state of the codebase as of 2026-04-22. All numbers are sourced directly from `player.dart`, `food.dart`, and `game_provider.dart`.*
