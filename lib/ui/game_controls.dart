import 'package:flutter/material.dart';

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
              color: const Color(0x66121A2A),
              border: Border.all(color: const Color(0x997B92B7), width: 1.4),
            ),
            child: Center(
              child: Transform.translate(
                offset: _knob,
                child: Container(
                  height: widget.size * .42,
                  width: widget.size * .42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF30445F),
                    border: Border.all(color: const Color(0xFFC1D4F0)),
                  ),
                  child: const Icon(
                    Icons.control_camera_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
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
  });

  final String label;
  final IconData icon;
  final Color color;
  final ValueChanged<bool> onChanged;
  final double size;

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
                ? widget.color.withValues(alpha: .72)
                : const Color(0xDD101829),
            border: Border.all(
              color: widget.color.withValues(alpha: _held ? 1 : .65),
              width: 2,
            ),
            boxShadow: _held
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: .42),
                      blurRadius: 18,
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: widget.size * .28, color: Colors.white),
              const SizedBox(height: 1),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
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
            color: _firing ? firingColor : const Color(0xDD101829),
            border: Border.all(
              color: widget.color.withValues(alpha: _firing ? 1 : .65),
              width: 2,
            ),
            boxShadow: _firing
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: .42),
                      blurRadius: 18,
                    ),
                  ]
                : const [],
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            width: width,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xDD101829),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: .72),
                width: 1.5,
              ),
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
        color: const Color(0xD9111828),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onExit,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
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
      color: const Color(0xD9111828),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.pause_rounded, size: 20, color: Color(0xFFE3ECFF)),
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
