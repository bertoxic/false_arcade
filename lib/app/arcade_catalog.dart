import 'package:flutter/material.dart';

import '../core/level_campaign.dart';

import '../games/edge_load/edge_load_game.dart';
import '../games/fall_due/fall_due_game.dart';
import '../games/false_habit/echo_heist_game.dart';
import '../games/future_debt/future_debt_game.dart';
import '../games/not_yet/not_yet_game.dart';
import '../games/numberfall/numberfall_game.dart';

@immutable
class ArcadeGameDefinition {
  const ArcadeGameDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.missionLabel,
    required this.campaignStages,
    required this.icon,
    required this.colors,
    required this.levelPageBuilder,
  });

  final String id;
  final String title;
  final String subtitle;
  final String detail;
  final String missionLabel;
  final int campaignStages;
  final IconData icon;
  final List<Color> colors;
  final Widget Function(
    GeneratedGameLevel,
    LevelCompleteCallback,
    VoidCallback?,
  )
  levelPageBuilder;
}

final arcadeCatalog = <ArcadeGameDefinition>[
  const ArcadeGameDefinition(
    id: 'not_yet',
    title: 'NOT YET',
    subtitle: 'Reality-debt arena roguelite',
    detail: 'Stack consequences, then survive the settlement.',
    missionLabel: 'DEBT SECTORS',
    campaignStages: gameCampaignLevelCount,
    icon: Icons.hourglass_top_rounded,
    colors: [Color(0xFFFF557D), Color(0xFF906BFF)],
    levelPageBuilder: _notYetLevelPage,
  ),
  const ArcadeGameDefinition(
    id: 'edge_load',
    title: 'EDGELOAD',
    subtitle: 'Mansion stealth extraction',
    detail:
        'Steal the diamond, misdirect the guards, and escape with the haul.',
    missionLabel: 'MANSION RUNS',
    campaignStages: gameCampaignLevelCount,
    icon: Icons.diamond_rounded,
    colors: [Color(0xFFF7C948), Color(0xFF72D6FF)],
    levelPageBuilder: _edgeLoadLevelPage,
  ),
  const ArcadeGameDefinition(
    id: 'false_habit',
    title: 'FALSE HABIT',
    subtitle: 'Predictive stealth heist',
    detail: 'Teach the Warden a lie, deploy Echoes, and escape rich.',
    missionLabel: 'HEIST DISTRICTS',
    campaignStages: gameCampaignLevelCount,
    icon: Icons.visibility_rounded,
    colors: [Color(0xFFFF7B88), Color(0xFFC29CFF)],
    levelPageBuilder: _falseHabitLevelPage,
  ),
  const ArcadeGameDefinition(
    id: 'numberfall',
    title: 'NUMBERFALL',
    subtitle: 'Living-number platformer',
    detail: 'Every +1 redraws the platforms under your feet.',
    missionLabel: 'NUMBER DISPLAYS',
    campaignStages: gameCampaignLevelCount,
    icon: Icons.looks_one_rounded,
    colors: [Color(0xFF55F2D7), Color(0xFF2BAFEF)],
    levelPageBuilder: _numberfallLevelPage,
  ),
  const ArcadeGameDefinition(
    id: 'fall_due',
    title: 'FALL DUE',
    subtitle: 'Gravity-debt platformer',
    detail: 'Borrow gravity for air time—then pay the landing back.',
    missionLabel: 'LEDGER STAGES',
    campaignStages: gameCampaignLevelCount,
    icon: Icons.south_rounded,
    colors: [Color(0xFF8DE1FF), Color(0xFFFFD86E)],
    levelPageBuilder: _fallDueLevelPage,
  ),
  const ArcadeGameDefinition(
    id: 'future_debt',
    title: 'FUTURE DEBT',
    subtitle: 'Time-credit survival shooter',
    detail: 'Borrow powers now; take the lockouts when the future bills you.',
    missionLabel: 'DEBT SECTORS',
    campaignStages: gameCampaignLevelCount,
    icon: Icons.schedule_rounded,
    colors: [Color(0xFF4BE4FF), Color(0xFFFF4F7F)],
    levelPageBuilder: _futureDebtLevelPage,
  ),
];

Widget _notYetLevelPage(
  GeneratedGameLevel level,
  LevelCompleteCallback onComplete,
  VoidCallback? onNextLevel,
) => RealityGamePage(
  level: level,
  onLevelComplete: onComplete,
  onNextLevel: onNextLevel,
);

Widget _edgeLoadLevelPage(
  GeneratedGameLevel level,
  LevelCompleteCallback onComplete,
  VoidCallback? onNextLevel,
) => EdgeLoadPage(
  level: level,
  onLevelComplete: onComplete,
  onNextLevel: onNextLevel,
);

Widget _falseHabitLevelPage(
  GeneratedGameLevel level,
  LevelCompleteCallback onComplete,
  VoidCallback? onNextLevel,
) => EchoHeistPage(
  level: level,
  onLevelComplete: onComplete,
  onNextLevel: onNextLevel,
);

Widget _numberfallLevelPage(
  GeneratedGameLevel level,
  LevelCompleteCallback onComplete,
  VoidCallback? onNextLevel,
) => NumberfallPage(
  level: level,
  onLevelComplete: onComplete,
  onNextLevel: onNextLevel,
);

Widget _fallDueLevelPage(
  GeneratedGameLevel level,
  LevelCompleteCallback onComplete,
  VoidCallback? onNextLevel,
) => FallDuePage(
  level: level,
  onLevelComplete: onComplete,
  onNextLevel: onNextLevel,
);

Widget _futureDebtLevelPage(
  GeneratedGameLevel level,
  LevelCompleteCallback onComplete,
  VoidCallback? onNextLevel,
) => FutureDebtPage(
  level: level,
  onLevelComplete: onComplete,
  onNextLevel: onNextLevel,
);
