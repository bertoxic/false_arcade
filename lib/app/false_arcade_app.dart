import 'package:flutter/material.dart';

import 'arcade_catalog.dart';
import 'arcade_game_art.dart';
import 'game_level_select_page.dart';
import '../ui/game_controls.dart';

class FalseArcadeApp extends StatelessWidget {
  const FalseArcadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'False Arcade',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFF02060B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF48F2C1),
          secondary: Color(0xFF75DFFF),
          surface: Color(0xFF0A111B),
        ),
        splashColor: const Color(0xFF48F2C1).withValues(alpha: .12),
        highlightColor: Colors.transparent,
      ),
      home: const ArcadeHomePage(),
    );
  }
}

/// A game-cabinet selection screen, rather than a web-style list of links.
class ArcadeHomePage extends StatefulWidget {
  const ArcadeHomePage({super.key});

  @override
  State<ArcadeHomePage> createState() => _ArcadeHomePageState();
}

class _ArcadeHomePageState extends State<ArcadeHomePage> {
  var _selectedIndex = 0;

  ArcadeGameDefinition get _selected => arcadeCatalog[_selectedIndex];

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  void _launch(ArcadeGameDefinition game) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GameLevelSelectPage(game: game)),
    );
  }

  void _cycle(int direction) {
    final next = (_selectedIndex + direction) % arcadeCatalog.length;
    setState(() => _selectedIndex = next < 0 ? arcadeCatalog.length - 1 : next);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -.92),
          radius: 1.2,
          colors: [Color(0xFF0C2430), Color(0xFF040912), Color(0xFF010308)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: ArcadeGridField()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1050
                    ? 3
                    : constraints.maxWidth >= 620
                    ? 2
                    : 1;
                final horizontalPadding = constraints.maxWidth >= 700
                    ? 28.0
                    : 16.0;
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _ArcadeHeader(
                          active: _selectedIndex + 1,
                          total: arcadeCatalog.length,
                          onFeedbackSettings: () =>
                              showGameFeedbackSettings(context),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _FeaturedGamePanel(
                          game: _selected,
                          index: _selectedIndex,
                          total: arcadeCatalog.length,
                          compact: constraints.maxWidth < 540,
                          onPlay: () => _launch(_selected),
                          onPrevious: () => _cycle(-1),
                          onNext: () => _cycle(1),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        10,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            const Text(
                              'CHOOSE A SIGNAL',
                              style: TextStyle(
                                color: Color(0xFF90A7B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.1,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(
                                  0xFF385260,
                                ).withValues(alpha: .65),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'TAP TO PLAY',
                              style: TextStyle(
                                color: Color(0xFF48F2C1),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: crossAxisCount == 1 ? 154 : 166,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _GameCartridge(
                            game: arcadeCatalog[index],
                            index: index,
                            selected: index == _selectedIndex,
                            onHover: () => _select(index),
                            onPlay: () => _launch(arcadeCatalog[index]),
                          ),
                          childCount: arcadeCatalog.length,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        22,
                        horizontalPadding,
                        18,
                      ),
                      sliver: const SliverToBoxAdapter(child: _ArcadeFooter()),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _ArcadeHeader extends StatelessWidget {
  const _ArcadeHeader({
    required this.active,
    required this.total,
    required this.onFeedbackSettings,
  });

  final int active;
  final int total;
  final VoidCallback onFeedbackSettings;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Container(
        width: 31,
        height: 31,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF48F2C1),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF48F2C1).withValues(alpha: .35),
              blurRadius: 16,
            ),
          ],
        ),
        child: const Icon(
          Icons.videogame_asset_rounded,
          color: Color(0xFF031016),
          size: 19,
        ),
      ),
      const SizedBox(width: 10),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FALSE ARCADE',
            style: TextStyle(
              color: Color(0xFFF0FAFF),
              fontSize: 22,
              height: .9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'SYSTEM SELECT // SIX IMPOSSIBLE GAMES',
            style: TextStyle(
              color: Color(0xFF89A3B5),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.16,
            ),
          ),
        ],
      ),
      const Spacer(),
      IconButton(
        onPressed: onFeedbackSettings,
        tooltip: 'Feedback settings',
        icon: const Icon(Icons.tune_rounded, color: Color(0xFF8FEAFF)),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'SIGNAL ${active.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Color(0xFF48F2C1),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PLAYER ONE READY',
            style: TextStyle(
              color: Color(0xFF677D90),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: .85,
            ),
          ),
        ],
      ),
    ],
  );
}

class _FeaturedGamePanel extends StatelessWidget {
  const _FeaturedGamePanel({
    required this.game,
    required this.index,
    required this.total,
    required this.compact,
    required this.onPlay,
    required this.onPrevious,
    required this.onNext,
  });

  final ArcadeGameDefinition game;
  final int index;
  final int total;
  final bool compact;
  final VoidCallback onPlay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: compact ? 1.12 : 2.12,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF06101A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: game.colors.first.withValues(alpha: .77)),
        boxShadow: [
          BoxShadow(
            color: game.colors.first.withValues(alpha: .16),
            blurRadius: 26,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ArcadeGameArtwork(gameId: game.id, colors: game.colors),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF040912).withValues(alpha: .98),
                    const Color(0xFF040912).withValues(alpha: .70),
                    const Color(0xFF040912).withValues(alpha: .05),
                  ],
                  stops: const [0, .42, 1],
                ),
              ),
            ),
            Positioned(
              top: 13,
              left: 15,
              child: _SignalTag(
                text:
                    'SIGNAL ${(index + 1).toString().padLeft(2, '0')} // $total',
                color: game.colors.first,
              ),
            ),
            Positioned(
              top: 9,
              right: 9,
              child: Row(
                children: [
                  _CycleButton(
                    icon: Icons.chevron_left_rounded,
                    label: 'Previous game',
                    onTap: onPrevious,
                  ),
                  const SizedBox(width: 5),
                  _CycleButton(
                    icon: Icons.chevron_right_rounded,
                    label: 'Next game',
                    onTap: onNext,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 15,
              right: compact ? 15 : null,
              bottom: 14,
              width: compact ? null : 390,
              child: _FeaturedCopy(
                game: game,
                onPlay: onPlay,
                compact: compact,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SignalTag extends StatelessWidget {
  const _SignalTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xDD05101A),
      border: Border.all(color: color.withValues(alpha: .68)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 8,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _CycleButton extends StatelessWidget {
  const _CycleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: const Color(0xCC06111C),
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          height: 29,
          width: 29,
          child: Icon(icon, color: const Color(0xFFCFEAFF), size: 20),
        ),
      ),
    ),
  );
}

class _FeaturedCopy extends StatelessWidget {
  const _FeaturedCopy({
    required this.game,
    required this.onPlay,
    required this.compact,
  });

  final ArcadeGameDefinition game;
  final VoidCallback onPlay;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        game.subtitle.toUpperCase(),
        style: TextStyle(
          color: game.colors.first,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.16,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        game.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFFF4FBFF),
          fontSize: compact ? 28 : 35,
          height: .92,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.25,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        game.detail,
        maxLines: compact ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFA9BCCB),
          fontSize: 12,
          height: 1.25,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          FilledButton.icon(
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow_rounded, size: 17),
            label: const Text(
              'PLAY MISSION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 37),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              backgroundColor: game.colors.first,
              foregroundColor: const Color(0xFF021016),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '${game.missionLabel}\n${game.campaignStages.toString().padLeft(2, '0')} STAGES ONLINE',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9BB1BF),
                fontSize: 8,
                height: 1.25,
                fontWeight: FontWeight.w800,
                letterSpacing: .6,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _GameCartridge extends StatelessWidget {
  const _GameCartridge({
    required this.game,
    required this.index,
    required this.selected,
    required this.onHover,
    required this.onPlay,
  });

  final ArcadeGameDefinition game;
  final int index;
  final bool selected;
  final VoidCallback onHover;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Play ${game.title}',
    child: MouseRegion(
      onEnter: (_) => onHover(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onFocusChange: (focused) {
            if (focused) onHover();
          },
          onTap: onPlay,
          borderRadius: BorderRadius.circular(9),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF07101A),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: game.colors.first.withValues(
                  alpha: selected ? .92 : .38,
                ),
                width: selected ? 1.7 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: game.colors.first.withValues(alpha: .13),
                        blurRadius: 14,
                      ),
                    ]
                  : const [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: ArcadeGameArtwork(
                      gameId: game.id,
                      colors: game.colors,
                      muted: !selected,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF02070D).withValues(alpha: .10),
                          const Color(0xFF02070D).withValues(alpha: .92),
                        ],
                        stops: const [.2, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    left: 10,
                    child: Text(
                      '${(index + 1).toString().padLeft(2, '0')} // ${game.campaignStages.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: game.colors.first,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 9,
                    top: 8,
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xD9051019),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: game.colors.first.withValues(alpha: .65),
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: game.colors.first,
                        size: 17,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF4FBFF),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.05,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          game.missionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF9CB3C1),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .7,
                          ),
                        ),
                      ],
                    ),
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

class _ArcadeFooter extends StatelessWidget {
  const _ArcadeFooter();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Text(
          'V 1.1  //  TOUCH + KEYBOARD READY',
          style: TextStyle(
            color: Color(0xFF607889),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.15,
          ),
        ),
      ),
      const Icon(Icons.gamepad_rounded, color: Color(0xFF48F2C1), size: 14),
      const SizedBox(width: 5),
      const Text(
        'SELECT // PLAY',
        style: TextStyle(
          color: Color(0xFF91A9B8),
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    ],
  );
}

class NotYetApp extends FalseArcadeApp {
  const NotYetApp({super.key});
}
