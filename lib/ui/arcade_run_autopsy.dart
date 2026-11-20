import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/game_feedback.dart';

/// Structured telemetry and pedagogical post-mortem diagnostic for a run.
@immutable
class RunAutopsyData {
  const RunAutopsyData({
    required this.gameTitle,
    required this.causeOfDeath,
    required this.mistakeAnalysis,
    required this.tacticalTip,
    required this.grade,
    required this.finalScore,
    required this.challengeCode,
    this.parAchieved = false,
  });

  final String gameTitle;
  final String causeOfDeath;
  final String mistakeAnalysis;
  final String tacticalTip;
  final String grade; // 'S+', 'A', 'B', 'C', 'D'
  final int finalScore;
  final String challengeCode;
  final bool parAchieved;

  /// Formatted shareable ASCII receipt.
  String toShareReceipt() {
    return '''
====================================
  FALSE ARCADE // RUN AUTOPSY
  MISSION: $gameTitle
====================================
  RANK:    $grade ${parAchieved ? '(PAR CLEARED)' : ''}
  SCORE:   $finalScore PTS
  SEED:    $challengeCode
  CAUSE:   $causeOfDeath
------------------------------------
  TIP:     $tacticalTip
====================================
Challenge my seed: $challengeCode
''';
  }
}

/// Actionable post-mortem modal replacing the uninformative generic game over.
class ArcadeRunAutopsyDialog extends StatelessWidget {
  const ArcadeRunAutopsyDialog({
    super.key,
    required this.data,
    required this.onRetry,
    required this.onExit,
  });

  final RunAutopsyData data;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  Color get _gradeColor => switch (data.grade) {
        'S+' => const Color(0xFFFFD700),
        'A' => const Color(0xFF48F2C1),
        'B' => const Color(0xFF75DFFF),
        'C' => const Color(0xFFFF8A48),
        _ => const Color(0xFFFF557D),
      };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF060D18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _gradeColor.withValues(alpha: 0.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _gradeColor.withValues(alpha: 0.2),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header bar
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gradeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _gradeColor, width: 1),
                  ),
                  child: Text(
                    'AUTOPSY // ${data.gameTitle.toUpperCase()}',
                    style: TextStyle(
                      color: _gradeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'PressStart2P',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'SEED: ${data.challengeCode}',
                  style: const TextStyle(
                    color: Color(0xFF6B8399),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Score and Rank Grade Banner
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FINAL SCORE',
                        style: TextStyle(
                          color: Color(0xFF7A93A6),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data.finalScore}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gradeColor.withValues(alpha: 0.12),
                    border: Border.all(color: _gradeColor, width: 2),
                  ),
                  child: Text(
                    data.grade,
                    style: TextStyle(
                      color: _gradeColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cause of failure
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF130910),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFFF557D).withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FATAL COMPLICATION',
                    style: TextStyle(
                      color: Color(0xFFFF557D),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.causeOfDeath,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.mistakeAnalysis,
                    style: const TextStyle(
                      color: Color(0xFFB0BAC7),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tactical Pro-Tip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF081C1B),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF48F2C1).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFF48F2C1),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TACTICAL COUNTERPLAY',
                          style: TextStyle(
                            color: Color(0xFF48F2C1),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.tacticalTip,
                          style: const TextStyle(
                            color: Color(0xFFD6F5EC),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Share Challenge Code Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8FEAFF),
                side: const BorderSide(color: Color(0xFF2C4A60)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                GameFeedback.selection();
                Clipboard.setData(ClipboardData(text: data.toShareReceipt()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challenge receipt copied to clipboard!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF0F2C3B),
                  ),
                );
              },
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text(
                'COPY CHALLENGE RECEIPT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Retry and Exit Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF869DAF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      GameFeedback.selection();
                      onExit();
                    },
                    child: const Text(
                      'CABINET',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48F2C1),
                      foregroundColor: const Color(0xFF030D12),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      GameFeedback.selection();
                      onRetry();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.replay_rounded, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'INSTANT RETRY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
