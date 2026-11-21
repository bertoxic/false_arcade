part of 'fall_due_game.dart';

class FallDueTrainingPage extends StatefulWidget {
  const FallDueTrainingPage({super.key});

  @override
  State<FallDueTrainingPage> createState() => _FallDueTrainingPageState();
}

class _FallDueTrainingPageState extends State<FallDueTrainingPage> {
  late Future<SharedPreferences> _storage = SharedPreferences.getInstance();
  var _selection = 0;
  var _contractsSelected = false;
  var _ledger = false;

  List<_Chapter> get _list => _contractsSelected ? _contracts : _chapters;
  String get _mode =>
      _contractsSelected ? (_ledger ? 'ledger' : 'contract') : 'story';

  int _unlocked(SharedPreferences store) {
    var last = 0;
    while (last < _chapters.length - 1 &&
        _StoryStore.finished(store, 'story', last)) {
      last++;
    }
    return last;
  }

  Future<void> _play(SharedPreferences store, {required bool resume}) async {
    final index = _selection;
    final mode = _mode;
    final chapter = _list[index];
    final next = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _StoryPage(
          chapter: chapter,
          index: index,
          mode: mode,
          store: store,
          resume: resume,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      if (next == true && !_contractsSelected && index < _chapters.length - 1) {
        _selection = index + 1;
      }
    });
    if (next == true && !_contractsSelected && index + 1 < _chapters.length) {
      await _play(
        store,
        resume: _StoryStore.resume(store, 'story', index + 1).isNotEmpty,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _storage,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Fall Due')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Saved chapter records could not load.'),
                  TextButton(
                    onPressed: () => setState(
                      () => _storage = SharedPreferences.getInstance(),
                    ),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        final store = snapshot.data;
        if (store == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final chapter = _list[_selection];
        final record = _StoryStore.record(store, _mode, _selection);
        final resume = _StoryStore.resume(store, _mode, _selection);
        final unlocked = _contractsSelected
            ? _list.length - 1
            : _unlocked(store);
        return Scaffold(
          backgroundColor: const Color(0xFF100E15),
          body: Stack(
            fit: StackFit.expand,
            children: [
              _DueBackdrop(chapter.landscape),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xF113121B),
                      Color(0xE01A1722),
                      Color(0xAB17131C),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 740;
                    final main = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < _list.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _ChapterButton(
                              chapter: _list[i],
                              number: i + 1,
                              selected: i == _selection,
                              locked: i > unlocked,
                              completed: _StoryStore.finished(store, _mode, i),
                              onTap: () => setState(() => _selection = i),
                            ),
                          ),
                      ],
                    );
                    final details = Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xEB211B28),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _dueGold.withValues(alpha: .37),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chapter.act,
                            style: const TextStyle(
                              color: _dueGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            chapter.title,
                            style: const TextStyle(
                              color: _dueCream,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            chapter.summary,
                            style: const TextStyle(color: Color(0xFFDAD0D7)),
                          ),
                          if (chapter.rule.label.isNotEmpty)
                            Text(
                              chapter.rule.label,
                              style: const TextStyle(
                                color: _dueGold,
                                fontSize: 12,
                              ),
                            ),
                          if (record['time'] case final num best) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Best ${_storyTime(best.toDouble())}${record['clean'] == true ? ' · Clean clear' : ''}${record['stamp'] == true ? ' · Mastery stamp' : ''}',
                              style: const TextStyle(color: _dueMint),
                            ),
                          ],
                          if (record['archive'] == true) ...[
                            const SizedBox(height: 6),
                            Text(
                              chapter.archive,
                              style: const TextStyle(color: _dueBlue),
                            ),
                          ],
                          if (record['clear'] == true &&
                              record['stamp'] != true) ...[
                            const SizedBox(height: 6),
                            Text(
                              chapter.mastery,
                              style: const TextStyle(
                                color: _dueGold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: () =>
                                    _play(store, resume: resume.isNotEmpty),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: Text(resume.isEmpty ? 'Play' : 'Resume'),
                              ),
                              if (resume.isNotEmpty)
                                OutlinedButton(
                                  onPressed: () => _play(store, resume: false),
                                  child: const Text('Start fresh'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: wide ? 34 : 14,
                            vertical: 8,
                          ),
                          sliver: SliverList.list(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    color: _dueCream,
                                    tooltip: 'Back to games',
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(Icons.arrow_back_rounded),
                                  ),
                                  const SizedBox(width: 7),
                                  const Expanded(
                                    child: Text(
                                      'GRAVITY TRAINING',
                                      style: TextStyle(
                                        color: _dueCream,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 23,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Lessons'),
                                    selected: !_contractsSelected,
                                    onSelected: (_) => setState(() {
                                      _contractsSelected = false;
                                      _selection = 0;
                                    }),
                                  ),
                                  ChoiceChip(
                                    label: const Text('Practice drills'),
                                    selected: _contractsSelected,
                                    onSelected: (_) => setState(() {
                                      _contractsSelected = true;
                                      _selection = 0;
                                    }),
                                  ),
                                  if (_contractsSelected)
                                    FilterChip(
                                      label: const Text('Gravity Ledger'),
                                      selected: _ledger,
                                      onSelected: (value) =>
                                          setState(() => _ledger = value),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (wide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: main),
                                    const SizedBox(width: 18),
                                    Expanded(child: details),
                                  ],
                                )
                              else ...[
                                details,
                                const SizedBox(height: 10),
                                main,
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChapterButton extends StatelessWidget {
  const _ChapterButton({
    required this.chapter,
    required this.number,
    required this.selected,
    required this.locked,
    required this.completed,
    required this.onTap,
  });
  final _Chapter chapter;
  final int number;
  final bool selected, locked, completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xE446352D) : const Color(0xE6221D28),
    borderRadius: BorderRadius.circular(10),
    child: ListTile(
      dense: true,
      enabled: !locked,
      selected: selected,
      onTap: locked ? null : onTap,
      leading: Text(
        '$number',
        style: TextStyle(
          color: locked ? Colors.white38 : _dueGold,
          fontWeight: FontWeight.w900,
        ),
      ),
      title: Text(
        chapter.title,
        style: TextStyle(
          color: locked ? Colors.white54 : _dueCream,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        chapter.landscape.title,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: Icon(
        locked
            ? Icons.lock_outline
            : (completed ? Icons.check_circle_outline : Icons.chevron_right),
        color: locked ? Colors.white38 : _dueGold,
        size: 19,
      ),
    ),
  );
}

abstract final class _StoryStore {
  static String _key(String type, String mode, int index) =>
      'fall_due.v2.$type.$mode.$index';
  static Map<String, dynamic> _map(SharedPreferences store, String key) {
    final data = store.getString(key);
    try {
      final decoded = data == null ? null : jsonDecode(data);
      return decoded is Map<String, dynamic> ? decoded : {};
    } on FormatException {
      return {};
    }
  }

  static Map<String, dynamic> record(
    SharedPreferences store,
    String mode,
    int index,
  ) => _map(store, _key('record', mode, index));
  static Map<String, dynamic> resume(
    SharedPreferences store,
    String mode,
    int index,
  ) => _map(store, _key('resume', mode, index));
  static bool finished(SharedPreferences store, String mode, int index) =>
      record(store, mode, index)['clear'] == true;

  static Future<void> save(
    SharedPreferences store,
    String mode,
    int index,
    _StoryRun run,
  ) async {
    await store.setString(
      _key('resume', mode, index),
      jsonEncode({
        'checkpoint': run.checkpoint,
        'time': run.elapsed,
        'hits': run.hits,
        'found': run.found.toList(),
        'charge': run.charge,
        'gained': run.gained.toList(),
        'defeated': run.defeated.toList(),
        'routes': run.routes.map((id, route) => MapEntry('$id', route)),
        'assist': run.assistedRun,
      }),
    );
  }

  static void restore(
    SharedPreferences store,
    String mode,
    int index,
    _StoryRun run,
  ) {
    final data = resume(store, mode, index);
    if (data['checkpoint'] case final int checkpoint
        when checkpoint >= 0 &&
            checkpoint < run.rooms.length &&
            run.rooms[checkpoint].checkpoint) {
      run.load(checkpoint);
      run.elapsed = (data['time'] as num?)?.toDouble() ?? 0;
      run.hits = (data['hits'] as int?) ?? 0;
      run.charge = ((data['charge'] as int?) ?? 1).clamp(0, 3);
      run.found.addAll((data['found'] as List? ?? const []).whereType<int>());
      run.gained.addAll(
        (data['gained'] as List? ?? const []).whereType<String>(),
      );
      run.defeated.addAll(
        (data['defeated'] as List? ?? const []).whereType<String>(),
      );
      run.assistedRun = data['assist'] == true || run.longTells;
      final routes = data['routes'];
      if (routes is Map) {
        for (final entry in routes.entries) {
          final room = int.tryParse(entry.key.toString());
          if (room != null && entry.value is String) {
            run.routes[room] = entry.value as String;
          }
        }
      }
    }
  }

  static Future<void> complete(
    SharedPreferences store,
    String mode,
    int index,
    _StoryRun run,
    _Chapter chapter,
  ) async {
    final previous = record(store, mode, index);
    final old = (previous['time'] as num?)?.toDouble();
    final best = run.assistedRun
        ? old
        : math.min(old ?? double.infinity, run.elapsed);
    final clean = run.hits == 0;
    await store.setString(
      _key('record', mode, index),
      jsonEncode({
        'clear': true,
        'time': ?best,
        'clean': clean || previous['clean'] == true,
        'archive': run.found.isNotEmpty || previous['archive'] == true,
        'stamp': chapter.mastered(run) || previous['stamp'] == true,
        'par':
            (!run.assistedRun && run.elapsed <= chapter.par) ||
            previous['par'] == true,
      }),
    );
    await store.remove(_key('resume', mode, index));
  }
}

String _storyTime(double elapsed) {
  final seconds = elapsed.floor();
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _StoryPage extends StatefulWidget {
  const _StoryPage({
    required this.chapter,
    required this.index,
    required this.mode,
    required this.store,
    required this.resume,
  });
  final _Chapter chapter;
  final int index;
  final String mode;
  final SharedPreferences store;
  final bool resume;

  @override
  State<_StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<_StoryPage>
    with SingleTickerProviderStateMixin {
  static const _settings = 'fall_due.v2.settings';
  final _focus = FocusNode(debugLabel: 'Fall Due story controls');
  final _keys = <LogicalKeyboardKey>{};
  late final _StoryRun _run;
  late final GameLoopController _loop;
  late bool _contrast;
  late bool _reducedMotion;
  late bool _swapCasts;
  bool _paused = false;
  bool _reported = false;
  bool _bindings = false;
  bool _left = false, _right = false, _jump = false;
  Future<void> _lastSave = Future.value();

  @override
  void initState() {
    super.initState();
    GamePresentation.enterLandscape();
    GameFeedback.playMusic(widget.chapter.landscape.music);
    final store = widget.store;
    _contrast = store.getBool('$_settings.contrast') ?? false;
    _reducedMotion = store.getBool('$_settings.motion') ?? false;
    _swapCasts = store.getBool('$_settings.swap') ?? false;
    _run = _StoryRun(
      widget.chapter.rooms,
      rule: widget.chapter.rule,
      ledger: widget.mode == 'ledger',
      longTells: store.getBool('$_settings.tells') ?? false,
    );
    _run.assistedRun = _run.longTells;
    if (widget.resume) {
      _StoryStore.restore(store, widget.mode, widget.index, _run);
    }
    _focus.addListener(() {
      if (!_focus.hasFocus) _release();
    });
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) {
        final before = _run.checkpoint;
        final hits = _run.hits;
        final discoveries = _run.found.length;
        _run.step(dt);
        if (_run.checkpoint != before ||
            _run.found.length != discoveries ||
            _run.hits != hits) {
          _save();
        }
        if (_run.finished && !_reported) {
          _reported = true;
          _lastSave = _lastSave.then(
            (_) => _StoryStore.complete(
              store,
              widget.mode,
              widget.index,
              _run,
              widget.chapter,
            ),
          );
          unawaited(_lastSave);
          GameFeedback.selection();
          scheduleMicrotask(() {
            if (mounted) _loop.setPaused(true);
          });
        }
      },
      onFrame: () {
        if (mounted) setState(() {});
      },
      onLifecyclePause: () {
        _release();
        if (_run.started && !_run.finished) {
          _save();
          if (mounted) setState(() => _paused = true);
          _loop.setPaused(true);
        }
      },
    );
  }

  void _save() {
    if (!_run.started || _run.finished) return;
    _lastSave = _lastSave.then((_) {
      if (!_run.finished) {
        return _StoryStore.save(widget.store, widget.mode, widget.index, _run);
      }
    });
    unawaited(_lastSave);
  }

  void _release() {
    _keys.clear();
    _left = _right = _jump = false;
    _run.clearInput();
  }

  void _syncInput() {
    _run.left =
        _left ||
        _keys.contains(LogicalKeyboardKey.keyA) ||
        _keys.contains(LogicalKeyboardKey.arrowLeft);
    _run.right =
        _right ||
        _keys.contains(LogicalKeyboardKey.keyD) ||
        _keys.contains(LogicalKeyboardKey.arrowRight);
    _run.jump(
      _jump ||
          _keys.contains(LogicalKeyboardKey.space) ||
          _keys.contains(LogicalKeyboardKey.arrowUp),
    );
  }

  void _cast(_Gravity verb) {
    if (!_paused) _run.cast(verb);
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      if (event is KeyDownEvent && _run.started && !_run.finished) {
        _pause(!_paused);
      }
      return KeyEventResult.handled;
    }
    if (!_run.started || _paused || _run.finished) {
      return KeyEventResult.ignored;
    }
    final give = _swapCasts ? LogicalKeyboardKey.keyE : LogicalKeyboardKey.keyQ;
    final take = _swapCasts ? LogicalKeyboardKey.keyQ : LogicalKeyboardKey.keyE;
    final recognized = [
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.space,
      give,
      take,
      LogicalKeyboardKey.keyF,
      LogicalKeyboardKey.keyR,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyB,
    ].contains(key);
    if (!recognized) return KeyEventResult.ignored;
    if (event is KeyDownEvent && _keys.add(key)) {
      if (key == give) _cast(_Gravity.give);
      if (key == take) _cast(_Gravity.take);
      if (key == LogicalKeyboardKey.keyF) _run.cycle();
      if (key == LogicalKeyboardKey.keyS) _run.self = !_run.self;
      if (key == LogicalKeyboardKey.keyR) _recall();
      if (key == LogicalKeyboardKey.keyB && _run.ledger) {
        _run.overdrive = !_run.overdrive;
      }
    }
    if (event is KeyUpEvent) _keys.remove(key);
    _syncInput();
    setState(() {});
    return KeyEventResult.handled;
  }

  void _recall() {
    final prop = _run.target;
    if (prop == null || !prop.spec.recall || prop.caught) {
      _run.say('Select a recoverable prop');
      return;
    }
    if ((_run.player - _run.safe).distance > 40 || !_run.grounded) {
      _run.say('Recall a prop from safe ground');
      return;
    }
    prop.lost = true;
    prop.recover = 1.5;
    _run.say('Returning to the marked cradle');
  }

  void _pause(bool value) {
    _release();
    _loop.setPaused(value);
    setState(() {
      _paused = value;
      if (value) _bindings = false;
    });
    if (value) {
      _save();
      GameFeedback.pauseMusic();
    } else {
      _focus.requestFocus();
      GameFeedback.resumeMusic();
    }
  }

  void _start() {
    setState(() => _run.started = true);
    _loop.start();
    _focus.requestFocus();
    _save();
  }

  void _preference(String key, bool value) {
    unawaited(widget.store.setBool('$_settings.$key', value));
  }

  Future<void> _close({bool next = false}) async {
    _save();
    await _lastSave;
    if (mounted) Navigator.of(context).pop(next);
  }

  @override
  void dispose() {
    _release();
    _loop.dispose();
    _focus.dispose();
    GameFeedback.playMusic('arcade_theme');
    GamePresentation.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shade = widget.chapter.landscape;
    return PopScope(
      canPop: _reported || !_run.started,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pause(true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF14121A),
        body: Focus(
          focusNode: _focus,
          autofocus: true,
          onKeyEvent: _key,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, bounds) {
                final compact = bounds.maxHeight < 420;
                final controlSize = compact ? 41.0 : 51.0;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Column(
                      children: [
                        _header(),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, area) {
                              final viewport = LogicalViewport.fit(
                                Size(area.maxWidth, area.maxHeight),
                                _duePlayfieldSize,
                              );
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned.fromRect(
                                    rect: viewport.screenWorldRect,
                                    child: _DueBackdrop(
                                      shade,
                                      camera: _run.index * 350,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapDown: (tap) {
                                        if (!_run.started ||
                                            _paused ||
                                            !viewport.screenWorldRect.contains(
                                              tap.localPosition,
                                            )) {
                                          return;
                                        }
                                        _run.point(
                                          viewport.screenToWorld(
                                            tap.localPosition,
                                          ),
                                        );
                                        _focus.requestFocus();
                                      },
                                      child: CustomPaint(
                                        key: const ValueKey(
                                          'fall-due-story-playfield',
                                        ),
                                        painter: _StoryPainter(
                                          run: _run,
                                          theme: shade,
                                          contrast: _contrast,
                                          reduced: _reducedMotion,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        _controls(controlSize),
                      ],
                    ),
                    if (!_run.started || _paused || _run.finished)
                      _overlay(compact),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final name = _run.room.boss ?? _run.room.title;
    final source = _run.noticeTime > 0 ? _run.notice : _run.room.hint;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 3, 5, 3),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Pause',
            color: _dueCream,
            onPressed: !_run.started || _run.finished
                ? null
                : () => _pause(true),
            icon: const Icon(Icons.pause_rounded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name   ${_run.index + 1}/${_run.rooms.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _dueCream,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  source,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _run.noticeTime > 0 ? _dueMint : Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Semantics(
            label: '${_run.hearts} hearts',
            child: Row(
              children: List.generate(
                _StoryRun.maxHearts,
                (i) => Icon(
                  i < _run.hearts
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _dueCoral,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls(double size) {
    final available = _run.started && !_paused && !_run.finished;
    return LayoutBuilder(
      builder: (context, bounds) {
        final narrow = bounds.maxWidth < 420;
        final buttonSize = narrow ? math.min(size, 43.0) : size;
        Widget hold(String label, IconData icon, ValueChanged<bool> action) =>
            HoldGameButton(
              label: label,
              icon: icon,
              color: _dueCream,
              backgroundColor: const Color(0xFF29232F),
              size: narrow ? buttonSize - 4 : buttonSize,
              labelSize: 8,
              onChanged: (value) {
                if (available) {
                  action(value);
                  _syncInput();
                }
              },
            );
        Widget cast(String label, _Gravity verb, Color color) => Semantics(
          button: true,
          label: label,
          child: SizedBox(
            width: narrow ? buttonSize + 4 : buttonSize + 18,
            height: buttonSize,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: color,
                backgroundColor: const Color(0xFF29232F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: available ? () => _cast(verb) : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    verb == _Gravity.give
                        ? Icons.south_rounded
                        : Icons.north_rounded,
                    size: 17,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            children: [
              hold('LEFT', Icons.chevron_left_rounded, (held) => _left = held),
              const SizedBox(width: 4),
              hold(
                'RIGHT',
                Icons.chevron_right_rounded,
                (held) => _right = held,
              ),
              const Spacer(),
              if (_run.ledger)
                IconButton(
                  tooltip: 'Overcharge GIVE · ${_run.charge}/3',
                  visualDensity: VisualDensity.compact,
                  color: _run.overdrive ? _dueGold : _dueCream,
                  onPressed: available && _run.charge > 0
                      ? () => setState(() => _run.overdrive = !_run.overdrive)
                      : null,
                  icon: Badge(
                    label: Text('${_run.charge}'),
                    child: const Icon(Icons.bolt_rounded),
                  ),
                ),
              IconButton(
                tooltip: 'Target self',
                visualDensity: VisualDensity.compact,
                color: _run.self ? _dueMint : _dueCream,
                onPressed: available
                    ? () => setState(() => _run.self = !_run.self)
                    : null,
                icon: const Icon(Icons.accessibility_new_rounded, size: 20),
              ),
              cast('GIVE', _Gravity.give, _dueGold),
              const SizedBox(width: 4),
              cast('TAKE', _Gravity.take, _dueBlue),
              const SizedBox(width: 5),
              hold('JUMP', Icons.arrow_upward_rounded, (held) => _jump = held),
            ],
          ),
        );
      },
    );
  }

  Widget _overlay(bool compact) {
    final done = _run.finished;
    final heading = done
        ? (widget.index == 5 && widget.mode == 'story'
              ? 'The Grove is whole'
              : 'Chapter clear')
        : (_paused ? 'Paused' : widget.chapter.title);
    return ColoredBox(
      color: const Color(0xDA100E16),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 12 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 510),
            child: Material(
              color: const Color(0xFF231D2B),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(compact ? 14 : 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: TextStyle(
                        color: _dueCream,
                        fontSize: compact ? 22 : 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (done) ...[
                      Text(
                        '${_storyTime(_run.elapsed)} · ${_run.hits == 0 ? 'Clean clear' : '${_run.hits} recoveries'}${_run.found.isEmpty ? '' : ' · Archive recovered'}',
                        style: const TextStyle(color: _dueMint),
                      ),
                      if (_run.found.isNotEmpty)
                        Text(
                          widget.chapter.archive,
                          style: const TextStyle(color: _dueCream),
                        ),
                      if (widget.chapter.mastered(_run))
                        const Text(
                          'Mastery stamp earned',
                          style: TextStyle(color: _dueGold),
                        ),
                      if (_run.routes.isNotEmpty)
                        Text(
                          _run.routes.values.toSet().join(' · '),
                          style: const TextStyle(color: _dueBlue, fontSize: 12),
                        ),
                    ] else if (!_paused) ...[
                      Text(
                        widget.chapter.summary,
                        style: const TextStyle(color: _dueCream),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Move and jump. Tap or cycle a marked target, then GIVE weight or TAKE it away. Select yourself in the air to lift or slam.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ] else if (_bindings) ...[
                      _toggle(
                        'Longer attack tells',
                        _run.longTells,
                        (value) => setState(() {
                          _run.longTells = value;
                          _run.assistedRun |= value;
                          _preference('tells', value);
                        }),
                      ),
                      _toggle(
                        'High-contrast targeting',
                        _contrast,
                        (value) => setState(() {
                          _contrast = value;
                          _preference('contrast', value);
                        }),
                      ),
                      _toggle(
                        'Reduce movement effects',
                        _reducedMotion,
                        (value) => setState(() {
                          _reducedMotion = value;
                          _preference('motion', value);
                        }),
                      ),
                      _toggle(
                        'Swap Q and E',
                        _swapCasts,
                        (value) => setState(() {
                          _swapCasts = value;
                          _preference('swap', value);
                        }),
                      ),
                      _toggle(
                        'Haptics',
                        GameFeedback.settings.value.hapticsEnabled,
                        (value) => setState(() {
                          unawaited(GameFeedback.setHapticsEnabled(value));
                        }),
                      ),
                      Text(
                        'Arrows or A/D · Space jump · ${_swapCasts ? 'E GIVE · Q TAKE' : 'Q GIVE · E TAKE'} · F target · S self · R recall · B overcharge',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      children: [
                        if (done &&
                            widget.index < _chapters.length - 1 &&
                            widget.mode == 'story')
                          FilledButton(
                            onPressed: () => _close(next: true),
                            child: const Text('Next lesson'),
                          ),
                        if (!done)
                          FilledButton(
                            onPressed: _paused ? () => _pause(false) : _start,
                            child: Text(_paused ? 'Resume' : 'Begin'),
                          ),
                        if (_paused) ...[
                          OutlinedButton(
                            onPressed: () =>
                                setState(() => _bindings = !_bindings),
                            child: Text(
                              _bindings
                                  ? 'Hide settings'
                                  : 'Controls & assists',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              _run.reset();
                              _save();
                              _pause(false);
                            },
                            child: const Text('Reset room'),
                          ),
                          OutlinedButton(
                            onPressed: _recall,
                            child: const Text('Recall prop'),
                          ),
                        ],
                        OutlinedButton(
                          onPressed: () => _close(),
                          child: const Text('Training menu'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> callback) =>
      SwitchListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(color: _dueCream)),
        value: value,
        onChanged: callback,
      );
}
