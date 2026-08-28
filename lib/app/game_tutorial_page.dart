import 'package:flutter/material.dart';

import '../core/level_campaign.dart';
import 'arcade_catalog.dart';

/// The short first-run briefing shown before a title is launched for the first
/// time. It deliberately covers one objective, one control scheme, and one
/// signature risk so players can begin without leaving the game flow.
class GameTutorialPage extends StatefulWidget {
  const GameTutorialPage({super.key, required this.game, required this.level});

  final ArcadeGameDefinition game;
  final GeneratedGameLevel level;

  @override
  State<GameTutorialPage> createState() => _GameTutorialPageState();
}

class _GameTutorialPageState extends State<GameTutorialPage> {
  var _step = 0;

  List<_TutorialStep> get _steps => _tutorials[widget.game.id]!;

  void _advance() {
    if (_step == _steps.length - 1) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.game.colors.first;
    final step = _steps[_step];
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -.8),
            radius: 1.2,
            colors: [
              accent.withValues(alpha: .26),
              const Color(0xFF08111C),
              const Color(0xFF02050A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRAINING SIMULATION',
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.7,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.game.title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: .9,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LEVEL ${widget.level.number.toString().padLeft(2, '0')} · ${widget.level.mutator}',
                  style: const TextStyle(
                    color: Color(0xFFA9B7CA),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
                const Spacer(),
                Center(child: Icon(step.icon, size: 84, color: accent)),
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    step.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Text(
                      step.body,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFCFD9E8),
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    for (var index = 0; index < _steps.length; index++)
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index == _steps.length - 1 ? 0 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: index <= _step
                                ? accent
                                : const Color(0xFF344154),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _advance,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: const Color(0xFF031018),
                    ),
                    icon: Icon(
                      _step == _steps.length - 1
                          ? Icons.play_arrow_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      _step == _steps.length - 1 ? 'BEGIN LEVEL' : 'NEXT',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _TutorialStep {
  const _TutorialStep(this.title, this.body, this.icon);

  final String title;
  final String body;
  final IconData icon;
}

const _tutorials = <String, List<_TutorialStep>>{
  'not_yet': [
    _TutorialStep(
      'CLEAR THE DEBT SECTOR',
      'Survive each breach, clear the threats, and make it through the settlement alive.',
      Icons.shield_outlined,
    ),
    _TutorialStep(
      'MOVE, AIM, THEN FIRE',
      'Use the movement control to reposition. Choose a direction before firing so your shots cover the lane you need.',
      Icons.control_camera_rounded,
    ),
    _TutorialStep(
      'DELAY HAS A COST',
      'Your actions create consequences. Build momentum, but leave room to survive when the debt comes due.',
      Icons.hourglass_bottom_rounded,
    ),
  ],
  'edge_load': [
    _TutorialStep(
      'STEAL AND EXTRACT',
      'Find the diamond, take it, and reach the exit with your haul before the mansion closes around you.',
      Icons.diamond_outlined,
    ),
    _TutorialStep(
      'STAY OUT OF SIGHT',
      'Move carefully, sprint only when needed, and use coins or disguises to create safe openings.',
      Icons.visibility_off_rounded,
    ),
    _TutorialStep(
      'LOOT CHANGES THE RUN',
      'More loot is worth more, but carrying it makes every route and guard encounter more dangerous.',
      Icons.account_balance_wallet_outlined,
    ),
  ],
  'false_habit': [
    _TutorialStep(
      'BREAK THE WARDEN\'S PATTERN',
      'Reach the objective, take the valuables, and escape the district before the Warden pins you down.',
      Icons.psychology_alt_outlined,
    ),
    _TutorialStep(
      'LEAD WITH AN ECHO',
      'Move through the space and place Echoes to teach the Warden the wrong route. Save ESCAPE for a clean exit.',
      Icons.waves_rounded,
    ),
    _TutorialStep(
      'USE PREDICTION AGAINST IT',
      'The Warden learns from repeated habits. Change your route and timing after each successful feint.',
      Icons.route_rounded,
    ),
  ],
  'numberfall': [
    _TutorialStep(
      'STABILIZE THE NUMBER',
      'Collect the fragments and make it through the living display without falling out of the sequence.',
      Icons.looks_one_outlined,
    ),
    _TutorialStep(
      'RUN AND JUMP CLEANLY',
      'Use left and right to line up your landing. Jump from stable ground, then steer in the air when needed.',
      Icons.north_rounded,
    ),
    _TutorialStep(
      'EVERY +1 REWRITES THE WORLD',
      'Collecting a value can redraw the platforms. Look ahead before you take it and plan the next landing.',
      Icons.auto_graph_rounded,
    ),
  ],
  'fall_due': [
    _TutorialStep(
      'REACH THE LEDGER EXIT',
      'Cross the stage, gather seals, and reach the exit before your gravity debt overwhelms the run.',
      Icons.exit_to_app_rounded,
    ),
    _TutorialStep(
      'JUMP AND BORROW SEPARATELY',
      'JUMP gives a normal leap. BORROW changes gravity for extra air time—use it deliberately, not by accident.',
      Icons.south_rounded,
    ),
    _TutorialStep(
      'TRANSFER THE DEBT',
      'Give (Q) makes crates heavy enough to build bridges; Take (E) makes them rise into locks or launches collectors. Pick the target with F.',
      Icons.swap_horiz_rounded,
    ),
    _TutorialStep(
      'PAY THE LANDING BACK',
      'Borrowed gravity has to be repaid. Use safe debt pads between sections, or turn the heavier landing into a rust-floor dive.',
      Icons.balance_rounded,
    ),
  ],
  'future_debt': [
    _TutorialStep(
      'SURVIVE THE DEBT SECTOR',
      'Eliminate threats and reach the level score target while protecting your remaining lives.',
      Icons.safety_check_outlined,
    ),
    _TutorialStep(
      'MOVE, AIM, AND FIRE TOGETHER',
      'Use navigation to set your direction. The gun follows that direction, while auto-targeting helps acquire nearby enemies.',
      Icons.gps_fixed_rounded,
    ),
    _TutorialStep(
      'POWER NOW, CONSEQUENCES LATER',
      'Borrowed powers are strong, but their future bills change the fight. Ghost Wage phases through walls; Reverse Payment turns danger back on enemies.',
      Icons.currency_exchange_rounded,
    ),
  ],
};
