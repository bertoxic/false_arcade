part of 'future_debt_game.dart';

/// A mission plan turns the shared campaign blueprint into rules the run can
/// actually enforce. I keep it immutable so a replay has one source of truth.
enum _FutureObjectiveKind {
  clearClaims,
  recoverRecords,
  breachLien,
  reflectAudit,
  surviveMaturities,
  settleCollector,
  closeLedger,
}

@immutable
class _FutureDebtCasePlan {
  const _FutureDebtCasePlan({
    required this.levelNumber,
    required this.act,
    required this.objective,
    required this.objectiveTarget,
    required this.scoreTarget,
    required this.maximumAlive,
    required this.encounterBudget,
    required this.spawnInterval,
    required this.rewardMultiplier,
    required this.contractLimit,
    required this.exitAnchor,
    required this.title,
    required this.instruction,
    required this.mutator,
  });

  factory _FutureDebtCasePlan.fromCampaign(GeneratedGameLevel? campaign) {
    final level = campaign?.number ?? 1;
    final act = (level - 1) ~/ 7;
    final mission = (level - 1) % 7;
    final objective = _FutureObjectiveKind.values[mission];
    final pressure = campaign?.enemyPressure ?? 1;
    final rewardRate = campaign?.rewardRate ?? 1;
    final difficulty = campaign?.difficulty ?? 1;
    final length = campaign?.lengthMultiplier ?? 1.18;
    final rawTarget = campaign?.targetScore ?? 2600;
    final anchors = const [
      Offset(470, 480),
      Offset(1340, 390),
      Offset(2420, 470),
      Offset(720, 1110),
      Offset(1620, 1120),
      Offset(2420, 1110),
      Offset(930, 1600),
      Offset(2150, 1590),
    ];
    final objectiveTarget = switch (objective) {
      _FutureObjectiveKind.clearClaims => 9 + act * 3,
      _FutureObjectiveKind.recoverRecords => 3 + act,
      _FutureObjectiveKind.breachLien => 2 + act,
      _FutureObjectiveKind.reflectAudit => 2 + act,
      _FutureObjectiveKind.surviveMaturities => 1 + act,
      _FutureObjectiveKind.settleCollector => 1,
      _FutureObjectiveKind.closeLedger => 1,
    };
    final title = switch (objective) {
      _FutureObjectiveKind.clearClaims => 'CLEAR THE CLAIMS',
      _FutureObjectiveKind.recoverRecords => 'RECOVER THE CASE FILES',
      _FutureObjectiveKind.breachLien => 'BREACH THE LIEN',
      _FutureObjectiveKind.reflectAudit => 'RETURN AUDIT FIRE',
      _FutureObjectiveKind.surviveMaturities => 'SURVIVE MATURITY',
      _FutureObjectiveKind.settleCollector => 'SETTLE WITH THE COLLECTOR',
      _FutureObjectiveKind.closeLedger => 'CLOSE THE LEDGER CLEANLY',
    };
    final instruction = switch (objective) {
      _FutureObjectiveKind.clearClaims =>
        'Clear enough claimants to expose the extraction account.',
      _FutureObjectiveKind.recoverRecords =>
        'Recover sealed case files from the far rooms before extracting.',
      _FutureObjectiveKind.breachLien =>
        'Break marked lien walls to open the bank\'s hidden route.',
      _FutureObjectiveKind.reflectAudit =>
        'Borrow Reverse Payment and turn audit fire back on its issuer.',
      _FutureObjectiveKind.surviveMaturities =>
        'Take credit, let it mature, then survive the Echo it creates.',
      _FutureObjectiveKind.settleCollector =>
        'Declare bankruptcy only when you are ready to defeat the Collector.',
      _FutureObjectiveKind.closeLedger =>
        'Reach the target with no bill, Echo, lock, or Collector outstanding.',
    };

    return _FutureDebtCasePlan(
      levelNumber: level,
      act: act,
      objective: objective,
      objectiveTarget: objectiveTarget,
      // I cap the late targets so the final act increases pressure and choices,
      // not just the length of the same score grind.
      scoreTarget: (rawTarget * .5).round().clamp(1100, 4600).toInt(),
      maximumAlive: (6 + act * 2 + pressure * 2).round().clamp(7, 12).toInt(),
      encounterBudget: (18 + level * 2 + difficulty * 3 + length * 2)
          .round()
          .clamp(20, 66)
          .toInt(),
      spawnInterval: (1.08 / pressure).clamp(.44, 1.05).toDouble(),
      rewardMultiplier: rewardRate.clamp(.82, 1.25).toDouble(),
      contractLimit: (1 + act).clamp(1, 3).toInt(),
      exitAnchor: anchors[(level - 1) % anchors.length],
      title: title,
      instruction: instruction,
      mutator: campaign?.mutator ?? 'OPEN CREDIT',
    );
  }

  final int levelNumber;
  final int act;
  final _FutureObjectiveKind objective;
  final int objectiveTarget;
  final int scoreTarget;
  final int maximumAlive;
  final int encounterBudget;
  final double spawnInterval;
  final double rewardMultiplier;
  final int contractLimit;
  final Offset exitAnchor;
  final String title;
  final String instruction;
  final String mutator;
}
