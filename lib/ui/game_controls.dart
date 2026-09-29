import 'package:flutter/material.dart';

import '../app/arcade_hall_of_fame_page.dart';
import '../core/arcade_achievements.dart';
import '../core/arcade_leaderboard.dart';
import '../core/game_feedback.dart';
import '../core/level_campaign.dart';



class TouchStick extends StatefulWidget {
  const TouchStick({super.key, required this.onChanged, this.size = 104});

  final ValueChanged<Offset> onChanged;
  final double size;

  @override
  State<TouchStick> createState() => _TouchStickState();
}

class _TouchStickState extends State<TouchStick> {
  int? _pointer;
  Offset _knob = Offset.zero;

  void _update(PointerEvent event) {
    final box = context.findRenderObject()! as RenderBox;
    final local = box.globalToLocal(event.position);
    final maxOffset = widget.size * .355;
    final raw = local - Offset(widget.size / 2, widget.size / 2);
    final knob = raw.distance > maxOffset
        ? raw / raw.distance * maxOffset
        : raw;
    setState(() => _knob = knob);
    widget.onChanged(knob / maxOffset);
  }

  void _release(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    setState(() => _knob = Offset.zero);
    widget.onChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Movement control',
      value: _knob == Offset.zero ? 'idle' : 'active',
      child: Listener(
        onPointerDown: (event) {
          if (_pointer != null) return;
          _pointer = event.pointer;
          _update(event);
        },
        onPointerMove: (event) {
          if (_pointer == event.pointer) _update(event);
        },
        onPointerUp: _release,
        onPointerCancel: _release,
        child: SizedBox(
          height: widget.size,
          width: widget.size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x7707111D),
              border: Border.all(
                color: _knob != Offset.zero
                    ? const Color(0xFF48F2C1).withValues(alpha: .75)
                    : const Color(0xFF4A6B8F).withValues(alpha: .55),
                width: _knob != Offset.zero ? 2.0 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _knob != Offset.zero
                      ? const Color(0xFF48F2C1).withValues(alpha: .28)
                      : const Color(0xFF1E3A5F).withValues(alpha: .15),
                  blurRadius: _knob != Offset.zero ? 18 : 8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner reticle circle
                Container(
                  height: widget.size * .65,
                  width: widget.size * .65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF38587A).withValues(alpha: .4),
                      width: 1,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: _knob,
                  child: Container(
                    height: widget.size * .44,
                    width: widget.size * .44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: _knob != Offset.zero
                            ? [const Color(0xFF48F2C1), const Color(0xFF165C58)]
                            : [const Color(0xFF3A587B), const Color(0xFF162537)],
                      ),
                      border: Border.all(
                        color: _knob != Offset.zero
                            ? const Color(0xFFE6FFF9)
                            : const Color(0xFF90BBE8),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _knob != Offset.zero
                              ? const Color(0xFF48F2C1).withValues(alpha: .6)
                              : const Color(0xFF000000).withValues(alpha: .4),
                          blurRadius: _knob != Offset.zero ? 14 : 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.control_camera_rounded,
                      color: _knob != Offset.zero ? Colors.black87 : Colors.white,
                      size: 20,
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

class HoldGameButton extends StatefulWidget {
  const HoldGameButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onChanged,
    this.size = 74,
    this.iconSize,
  });

  final String label;
  final IconData icon;
  final Color color;
  final ValueChanged<bool> onChanged;
  final double size;
  final double? iconSize;

  @override
  State<HoldGameButton> createState() => _HoldGameButtonState();
}

class _HoldGameButtonState extends State<HoldGameButton> {
  int? _pointer;
  bool _held = false;

  void _release(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    setState(() => _held = false);
    widget.onChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label.replaceAll('\n', ' '),
      toggled: _held,
      child: Listener(
        onPointerDown: (event) {
          if (_pointer != null) return;
          _pointer = event.pointer;
          setState(() => _held = true);
          GameFeedback.selection();
          widget.onChanged(true);
        },
        onPointerUp: _release,
        onPointerCancel: _release,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _held
                ? widget.color.withValues(alpha: .85)
                : const Color(0xEE0B1220),
            border: Border.all(
              color: widget.color.withValues(alpha: _held ? 1 : .72),
              width: _held ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _held ? .55 : .18),
                blurRadius: _held ? 22 : 8,
                spreadRadius: _held ? 1.5 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: widget.iconSize ?? (widget.size * .36),
                color: Colors.white,
              ),
              const SizedBox(height: 1),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.size >= 80 ? 10.5 : (widget.size >= 70 ? 9.5 : 8.5),
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A larger fire control that continuously reports both its hold state and
/// the direction selected by the player's thumb.
class AimGameButton extends StatefulWidget {
  const AimGameButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onFiringChanged,
    required this.onAimChanged,
    this.size = 96,
  });

  final String label;
  final IconData icon;
  final Color color;
  final ValueChanged<bool> onFiringChanged;
  final ValueChanged<Offset> onAimChanged;
  final double size;

  @override
  State<AimGameButton> createState() => _AimGameButtonState();
}

class _AimGameButtonState extends State<AimGameButton> {
  int? _pointer;
  Offset _knob = Offset.zero;
  bool _firing = false;

  void _update(PointerEvent event) {
    final box = context.findRenderObject()! as RenderBox;
    final local = box.globalToLocal(event.position);
    final maxOffset = widget.size * .26;
    final raw = local - Offset(widget.size / 2, widget.size / 2);
    final knob = raw.distance > maxOffset
        ? raw / raw.distance * maxOffset
        : raw;
    setState(() => _knob = knob);
    if (knob.distance > 2) widget.onAimChanged(knob / maxOffset);
  }

  void _release(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    setState(() {
      _knob = Offset.zero;
      _firing = false;
    });
    widget.onFiringChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    final firingColor = widget.color.withValues(alpha: .72);
    return Semantics(
      button: true,
      label: '${widget.label} aim control',
      toggled: _firing,
      child: Listener(
        onPointerDown: (event) {
          if (_pointer != null) return;
          _pointer = event.pointer;
          setState(() => _firing = true);
          GameFeedback.selection();
          _update(event);
          widget.onFiringChanged(true);
        },
        onPointerMove: (event) {
          if (_pointer == event.pointer) _update(event);
        },
        onPointerUp: _release,
        onPointerCancel: _release,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _firing ? firingColor : const Color(0xEE0B1220),
            border: Border.all(
              color: widget.color.withValues(alpha: _firing ? 1 : .72),
              width: _firing ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _firing ? .55 : .18),
                blurRadius: _firing ? 22 : 8,
                spreadRadius: _firing ? 1.5 : 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: widget.size * .48,
                width: widget.size * .48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x5530445F),
                  border: Border.all(color: widget.color.withValues(alpha: .6)),
                ),
              ),
              Transform.translate(
                offset: _knob,
                child: Icon(
                  widget.icon,
                  size: widget.size * .3,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: widget.size * .13,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: widget.size * .1,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TapGameButton extends StatelessWidget {
  const TapGameButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.width = 74,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            GameFeedback.selection();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            width: width,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xEE0B1220),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: .82),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .22),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 19, color: color),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
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

class GameExitButton extends StatelessWidget {
  const GameExitButton({super.key, required this.onExit});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Exit game',
      child: Material(
        color: const Color(0xEE0B1220),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            GameFeedback.selection();
            onExit();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B5B84).withValues(alpha: .6),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: Color(0xFFE3ECFF),
            ),
          ),
        ),
      ),
    );
  }
}

class GamePauseButton extends StatelessWidget {
  const GamePauseButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Pause game',
    child: Material(
      color: const Color(0xEE0B1220),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          GameFeedback.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3B5B84).withValues(alpha: .6),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.pause_rounded, size: 20, color: Color(0xFFE3ECFF)),
        ),
      ),
    ),
  );
}

class GamePauseOverlay extends StatelessWidget {
  const GamePauseOverlay({
    super.key,
    required this.gameName,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  final String gameName;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xD9080B13),
      child: Center(
        child: Container(
          width: 370,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF121A2B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF58749A)),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 26),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RUN PAUSED',
                style: TextStyle(
                  color: Color(0xFF8FEAFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                gameName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The arena and timer are frozen. Resume when you are ready.',
                style: TextStyle(
                  color: Color(0xFFC3D0E7),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onResume,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF68DFF0),
                    foregroundColor: const Color(0xFF07111A),
                  ),
                  child: const Text(
                    'RESUME',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showGameFeedbackSettings(context),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text(
                    'FEEDBACK SETTINGS',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRestart,
                      child: const Text('RESTART'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onExit,
                      child: const Text('EXIT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Opens the same persisted music, sound, and haptic preferences from the
/// arcade cabinet and every pause screen.
Future<void> showGameFeedbackSettings(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const _FeedbackSettingsSheet(),
);

class _FeedbackSettingsSheet extends StatelessWidget {
  const _FeedbackSettingsSheet();

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(16),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 460,
        maxHeight: MediaQuery.sizeOf(context).height * .88,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF101827),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF58749A)),
            boxShadow: const [
              BoxShadow(color: Color(0x99000000), blurRadius: 24),
            ],
          ),
          child: ValueListenableBuilder<GameFeedbackSettings>(
            valueListenable: GameFeedback.settings,
            builder: (context, settings, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FEEDBACK',
                  style: TextStyle(
                    color: Color(0xFF8FEAFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Arcade preferences',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'These settings apply immediately and are remembered across games.',
                  style: TextStyle(color: Color(0xFFC3D0E7), fontSize: 12),
                ),
                const SizedBox(height: 8),
                _FeedbackToggle(
                  icon: Icons.music_note_rounded,
                  title: 'Music',
                  subtitle: 'Background soundtrack',
                  value: settings.musicEnabled,
                  onChanged: GameFeedback.setMusicEnabled,
                ),
                _FeedbackToggle(
                  icon: Icons.volume_up_rounded,
                  title: 'Sound effects',
                  subtitle: 'Shots, pickups, and game cues',
                  value: settings.soundEnabled,
                  onChanged: GameFeedback.setSoundEnabled,
                ),
                _FeedbackToggle(
                  icon: Icons.vibration_rounded,
                  title: 'Haptics',
                  subtitle: 'Hits, pickups, and major actions',
                  value: settings.hapticsEnabled,
                  onChanged: GameFeedback.setHapticsEnabled,
                ),
                _FeedbackToggle(
                  icon: Icons.tv_rounded,
                  title: 'CRT Arcade Screen FX',
                  subtitle: 'Retro scanlines & phosphor vignette',
                  value: settings.crtEnabled,
                  onChanged: GameFeedback.setCrtEnabled,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _FeedbackToggle extends StatelessWidget {
  const _FeedbackToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    secondary: Icon(icon, color: const Color(0xFF8FEAFF)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    value: value,
    onChanged: onChanged,
  );
}

/// Shared end-of-mission flow for every campaign title. Internal game stages
/// may still use their own transitions, but a selected campaign level always
/// ends here so players can deliberately continue to the newly unlocked level.
class CampaignMissionClearOverlay extends StatefulWidget {
  const CampaignMissionClearOverlay({
    super.key,
    required this.level,
    required this.score,
    required this.elapsedSeconds,
    required this.accent,
    required this.onExit,
    this.onNextLevel,
  });

  final GeneratedGameLevel level;
  final int score;
  final double elapsedSeconds;
  final Color accent;
  final VoidCallback onExit;
  final VoidCallback? onNextLevel;

  @override
  State<CampaignMissionClearOverlay> createState() =>
      _CampaignMissionClearOverlayState();
}

class _CampaignMissionClearOverlayState
    extends State<CampaignMissionClearOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GameFeedback.victory();
      final result = LevelRunResult(
        level: widget.level,
        score: widget.score,
        elapsedSeconds: widget.elapsedSeconds,
      );
      if (result.stars == 3) {
        ArcadeAchievements.unlock('first_contract');
      }
      if (widget.score >= 5000) {
        ArcadeAchievements.unlock('arcade_centurion');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = LevelRunResult(
      level: widget.level,
      score: widget.score,
      elapsedSeconds: widget.elapsedSeconds,
    );
    final isFinalMission = widget.level.number >= gameCampaignLevelCount;
    final isTopScore = ArcadeLeaderboard.isTopScore(
      widget.level.gameId,
      widget.score,
    );

    final String grade;
    final Color gradeColor;
    if (result.stars == 3 &&
        widget.elapsedSeconds <= widget.level.parSeconds * 0.85) {
      grade = 'S+';
      gradeColor = const Color(0xFFFF557D);
    } else if (result.stars == 3) {
      grade = 'S';
      gradeColor = const Color(0xFFFFD36A);
    } else if (result.stars == 2) {
      grade = 'A';
      gradeColor = const Color(0xFF48F2C1);
    } else if (result.stars == 1) {
      grade = 'B';
      gradeColor = const Color(0xFF72D6FF);
    } else {
      grade = 'C';
      gradeColor = const Color(0xFF8B9FB0);
    }

    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xE8080C16),
        child: Center(
          child: Container(
            width: 480,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF111A2A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.accent.withValues(alpha: .75),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withValues(alpha: .24),
                  blurRadius: 36,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFinalMission ? 'CAMPAIGN COMPLETE' : 'MISSION COMPLETE',
                      style: TextStyle(
                        color: widget.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'PressStart2P',
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 1; i <= 3; i++)
                          Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Icon(
                              i <= result.stars
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 18,
                              color: i <= result.stars
                                  ? const Color(0xFFFFD36A)
                                  : const Color(0xFF485A72),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'LEVEL ${widget.level.number.toString().padLeft(2, '0')} · ${widget.level.chapterTitle}',
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.level.storyBeat,
                  style: const TextStyle(
                    color: Color(0xFFC6D2E6),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CampaignResultChip(
                      icon: Icons.grade_rounded,
                      label: 'RANK $grade',
                      color: gradeColor,
                    ),
                    _CampaignResultChip(
                      icon: Icons.star_rounded,
                      label: '${result.stars}/3 STARS',
                      color: const Color(0xFFFFD36A),
                    ),
                    _CampaignResultChip(
                      icon: Icons.stars_rounded,
                      label: '${widget.score} SCORE',
                      color: widget.accent,
                    ),
                    _CampaignResultChip(
                      icon: Icons.timer_outlined,
                      label: '${widget.elapsedSeconds.round()}s',
                      color: const Color(0xFF9EB4D1),
                    ),
                  ],
                ),
                if (isTopScore) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => showArcadeInitialsEntryDialog(
                        context,
                        gameId: widget.level.gameId,
                        score: widget.score,
                        level: widget.level.number,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFFFD36A),
                          width: 1.5,
                        ),
                        foregroundColor: const Color(0xFFFFD36A),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.emoji_events_rounded, size: 18),
                      label: const Text(
                        '★ NEW TOP SCORE! LOG INITIALS',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (!isFinalMission)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.onNextLevel ?? widget.onExit,
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.accent,
                        foregroundColor: const Color(0xFF04101A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        'NEXT LEVEL · ${widget.level.number + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                if (!isFinalMission) const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: widget.onExit,
                    child: Text(
                      isFinalMission ? 'RETURN TO LEVELS' : 'CHOOSE A LEVEL',
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


class _CampaignResultChip extends StatelessWidget {
  const _CampaignResultChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF0A111E),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: .48)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .45,
          ),
        ),
      ],
    ),
  );
}

/// A compact campaign readout intended for the top edge of an arena.
///
/// The strip deliberately stays display-only so it never intercepts a tap
/// meant for the game beneath it. Completed stages are dimly marked, the
/// active stage is lit, and an optional endless run is represented after the
/// authored path instead of pretending it is another fixed level.
class GameStageProgressMenu extends StatelessWidget {
  const GameStageProgressMenu({
    super.key,
    required this.title,
    required this.stageLabel,
    required this.currentStage,
    required this.stageCount,
    required this.accentColor,
    this.compact = false,
    this.endless = false,
  });

  /// Short game title, such as `FUTURE DEBT`.
  final String title;

  /// The game-specific campaign term, such as `SECTOR` or `DISTRICT`.
  final String stageLabel;

  /// One-based current stage number.
  final int currentStage;

  /// Number of authored campaign stages. The visual path is kept deliberately
  /// small so it remains readable across phones in landscape.
  final int stageCount;

  final Color accentColor;
  final bool compact;

  /// Adds a live run marker after the authored path.
  final bool endless;

  @override
  Widget build(BuildContext context) {
    final authoredStages = stageCount.clamp(1, 6);
    final inEndlessRun = endless || currentStage > stageCount;
    final activeStage = currentStage.clamp(1, authoredStages);
    final runNumber = (currentStage - stageCount).clamp(1, 999);
    final panelColor = const Color(0xE80B101B);
    final mutedColor = const Color(0xFF536077);
    final lineColor = accentColor.withValues(alpha: .35);

    return Semantics(
      label: inEndlessRun
          ? '$title, endless run $runNumber after $stageCount $stageLabel stages'
          : '$title, $stageLabel $activeStage of $stageCount',
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: compact ? 232 : 292),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(compact ? 9 : 11),
            border: Border.all(color: accentColor.withValues(alpha: .5)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: .12),
                blurRadius: 12,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 8 : 10,
              compact ? 4 : 5,
              compact ? 8 : 10,
              compact ? 5 : 6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFEAF2FF),
                          fontSize: compact ? 8 : 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: compact ? 1 : 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      inEndlessRun
                          ? '∞ RUN $runNumber'
                          : '$stageLabel $activeStage/$stageCount',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: compact ? 8 : 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: compact ? .75 : 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 4 : 5),
                Row(
                  children: [
                    for (var index = 0; index < authoredStages; index++) ...[
                      _StageNode(
                        label: '${index + 1}',
                        active: !inEndlessRun && index + 1 == activeStage,
                        complete: inEndlessRun || index + 1 < activeStage,
                        accentColor: accentColor,
                        compact: compact,
                      ),
                      if (index + 1 < authoredStages || inEndlessRun)
                        Expanded(
                          child: Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            color: index + 1 < activeStage || inEndlessRun
                                ? lineColor
                                : mutedColor.withValues(alpha: .65),
                          ),
                        ),
                    ],
                    if (inEndlessRun)
                      _StageNode(
                        label: '∞',
                        active: true,
                        complete: false,
                        accentColor: accentColor,
                        compact: compact,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.label,
    required this.active,
    required this.complete,
    required this.accentColor,
    required this.compact,
  });

  final String label;
  final bool active;
  final bool complete;
  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 14.0 : 16.0;
    final color = active || complete ? accentColor : const Color(0xFF526078);
    return Container(
      alignment: Alignment.center,
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: active
            ? accentColor.withValues(alpha: .25)
            : complete
            ? accentColor.withValues(alpha: .13)
            : const Color(0xFF161D2C),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: active ? 1.5 : 1),
        boxShadow: active
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: .45),
                  blurRadius: 8,
                ),
              ]
            : const [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active || complete ? accentColor : const Color(0xFF8693AA),
          fontSize: compact ? 7 : 8,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
