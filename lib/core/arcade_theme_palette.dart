import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Representation of an authentic retro hardware display palette.
@immutable
class ArcadePalette {
  const ArcadePalette({
    required this.id,
    required this.name,
    required this.tagline,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    this.colorMatrix,
  });

  final String id;
  final String name;
  final String tagline;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final List<double>? colorMatrix;

  /// Default baseline Cyber Neon palette.
  static const cyberNeon = ArcadePalette(
    id: 'cyber_neon',
    name: 'CYBER NEON',
    tagline: 'Default 80s arcade monitor glow',
    primary: Color(0xFF48F2C1),
    secondary: Color(0xFF75DFFF),
    accent: Color(0xFFFF557D),
    background: Color(0xFF02060B),
    surface: Color(0xFF0A111B),
  );

  /// Authentic 4-shade Game Boy 1989 monochrome olive matrix.
  static const gameBoy1989 = ArcadePalette(
    id: 'gameboy_1989',
    name: 'POCKET 1989',
    tagline: 'Classic 4-shade olive LCD matrix',
    primary: Color(0xFF8BAC0F),
    secondary: Color(0xFF9BBC0F),
    accent: Color(0xFF306230),
    background: Color(0xFF0F380F),
    surface: Color(0xFF1E4C1E),
    colorMatrix: [
      0.35, 0.45, 0.10, 0, 0,
      0.30, 0.55, 0.10, 0, 0,
      0.10, 0.30, 0.10, 0, 0,
      0.00, 0.00, 0.00, 1, 0,
    ],
  );

  /// 1995 Virtual Boy high-contrast deep black and laser crimson.
  static const virtualBoy1995 = ArcadePalette(
    id: 'virtual_boy',
    name: 'LASER CRIMSON',
    tagline: '1995 dual-mirror red LED aesthetic',
    primary: Color(0xFFFF0033),
    secondary: Color(0xFFFF5577),
    accent: Color(0xFFFF8899),
    background: Color(0xFF0A0002),
    surface: Color(0xFF1A0005),
    colorMatrix: [
      0.90, 0.10, 0.00, 0, 0,
      0.10, 0.00, 0.00, 0, 0,
      0.10, 0.00, 0.00, 0, 0,
      0.00, 0.00, 0.00, 1, 0,
    ],
  );

  /// Warm amber phosphor from classic DEC VT220 terminals.
  static const amberPhosphor = ArcadePalette(
    id: 'amber_phosphor',
    name: 'VT220 AMBER',
    tagline: 'Warm amber phosphor on charcoal black',
    primary: Color(0xFFFFB000),
    secondary: Color(0xFFFFCC33),
    accent: Color(0xFFFFE066),
    background: Color(0xFF0D0A02),
    surface: Color(0xFF1F1705),
    colorMatrix: [
      0.80, 0.45, 0.00, 0, 0,
      0.55, 0.35, 0.00, 0, 0,
      0.05, 0.05, 0.00, 0, 0,
      0.00, 0.00, 0.00, 1, 0,
    ],
  );

  /// Synthwave pastel teal, hot pink, and dusk purple.
  static const vaporwaveSunset = ArcadePalette(
    id: 'vaporwave',
    name: 'VAPOR SUNSET',
    tagline: 'Pastel teal and hyper-saturated magenta',
    primary: Color(0xFF24E5DF),
    secondary: Color(0xFFFF71CE),
    accent: Color(0xFFFFB86C),
    background: Color(0xFF0D0221),
    surface: Color(0xFF1D0938),
  );

  /// Pitch black AMOLED for maximum battery life and blinding electric accents.
  static const amoledMidnight = ArcadePalette(
    id: 'amoled_dark',
    name: 'AMOLED DEEP',
    tagline: 'Pure zero-power black with hyper-electric neon',
    primary: Color(0xFF00FFCC),
    secondary: Color(0xFF39FF14),
    accent: Color(0xFFFF007F),
    background: Color(0xFF000000),
    surface: Color(0xFF080808),
  );

  static const List<ArcadePalette> all = [
    cyberNeon,
    gameBoy1989,
    virtualBoy1995,
    amberPhosphor,
    vaporwaveSunset,
    amoledMidnight,
  ];
}

/// Central manager for active and unlocked hardware display palettes.
abstract final class ArcadeThemeManager {
  static const _storageKey = 'false_arcade.palette.active_v1';
  static const _unlockedStorageKey = 'false_arcade.palette.unlocked_v1';

  static final ValueNotifier<ArcadePalette> current =
      ValueNotifier<ArcadePalette>(ArcadePalette.cyberNeon);

  static final ValueNotifier<Set<String>> unlockedIds =
      ValueNotifier<Set<String>>({
    ArcadePalette.cyberNeon.id,
    ArcadePalette.gameBoy1989.id,
  });

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeId = prefs.getString(_storageKey);
      if (activeId != null) {
        final match = ArcadePalette.all.firstWhere(
          (p) => p.id == activeId,
          orElse: () => ArcadePalette.cyberNeon,
        );
        current.value = match;
      }
      final unlockedList = prefs.getStringList(_unlockedStorageKey);
      if (unlockedList != null) {
        unlockedIds.value = {
          ArcadePalette.cyberNeon.id,
          ...unlockedList,
        };
      }
      _loaded = true;
    } catch (_) {}
  }

  static Future<void> selectPalette(String paletteId) async {
    final palette = ArcadePalette.all.firstWhere(
      (p) => p.id == paletteId,
      orElse: () => ArcadePalette.cyberNeon,
    );
    current.value = palette;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, palette.id);
    } catch (_) {}
  }

  static Future<void> unlockPalette(String paletteId) async {
    if (unlockedIds.value.contains(paletteId)) return;
    final next = Set<String>.from(unlockedIds.value)..add(paletteId);
    unlockedIds.value = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_unlockedStorageKey, next.toList());
    } catch (_) {}
  }
}
