import 'package:flutter/material.dart';

import '../app/false_arcade_app.dart';

/// A retro arcade-themed recovery screen rendered when an unexpected widget
/// or layout error occurs in production builds, replacing Flutter's default
/// grey or red crash screen.
class ArcadeCrashRecoveryView extends StatefulWidget {
  const ArcadeCrashRecoveryView({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  State<ArcadeCrashRecoveryView> createState() =>
      _ArcadeCrashRecoveryViewState();
}

class _ArcadeCrashRecoveryViewState extends State<ArcadeCrashRecoveryView> {
  bool _showDetails = false;

  void _reboot() {
    runApp(const FalseArcadeApp());
  }

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xFFFF5252);
    const accentAmber = Color(0xFFFFD36A);
    const bgDark = Color(0xFF040810);

    final summary = widget.details.exceptionAsString();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgDark,
      ),
      home: Scaffold(
        backgroundColor: bgDark,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 580),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A101C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: errorColor.withValues(alpha: 0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: errorColor.withValues(alpha: 0.25),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: errorColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: errorColor),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: errorColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'CABINET FAULT DETECTED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 14,
                        color: errorColor,
                        letterSpacing: 1.2,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'An unexpected system interrupt occurred. Arcade memory is preserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _reboot,
                      icon: const Icon(Icons.restart_alt_rounded, color: Colors.black),
                      label: const Text(
                        'REBOOT CABINET',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentAmber,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => setState(() => _showDetails = !_showDetails),
                      icon: Icon(
                        _showDetails
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 18,
                        color: Colors.white38,
                      ),
                      label: Text(
                        _showDetails ? 'HIDE DIAGNOSTICS' : 'VIEW DIAGNOSTICS',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    if (_showDetails) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: SelectableText(
                          summary,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white60,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
