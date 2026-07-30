/// Flutter Settings Framework
/// Scroll-to and highlight helpers for settings tiles.
library;

import 'package:flutter/material.dart';

/// Registry of [GlobalKey]s for setting tiles, used to scroll and highlight.
class SettingAnchorRegistry {
  final Map<String, GlobalKey> _keys = {};

  /// Currently highlighted setting key (null when none).
  final ValueNotifier<String?> highlightedKey = ValueNotifier<String?>(null);

  Duration highlightDuration;

  SettingAnchorRegistry({
    this.highlightDuration = const Duration(milliseconds: 1500),
  });

  /// Returns a stable [GlobalKey] for [settingKey].
  GlobalKey keyFor(String settingKey) {
    return _keys.putIfAbsent(settingKey, GlobalKey.new);
  }

  /// Wraps [child] so it can be scrolled to and highlighted by [settingKey].
  Widget wrap(String settingKey, Widget child) {
    return SettingAnchor(
      registry: this,
      settingKey: settingKey,
      child: child,
    );
  }

  /// Scrolls to [settingKey] and briefly highlights the tile.
  ///
  /// Prefer [knownOffset] when the target may be disposed (collapsed section).
  Future<void> scrollTo(
    String settingKey, {
    ScrollController? controller,
    double? knownOffset,
    double alignment = 0.1,
  }) async {
    highlightedKey.value = settingKey;

    if (knownOffset != null && controller != null && controller.hasClients) {
      final max = controller.position.maxScrollExtent;
      await controller.animateTo(
        knownOffset.clamp(0.0, max),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      final ctx = keyFor(settingKey).currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: alignment,
        );
      } else if (controller != null &&
          controller.hasClients &&
          knownOffset == null) {
        // No context yet; caller should expand section and retry.
      }
    }

    final token = settingKey;
    Future<void>.delayed(highlightDuration, () {
      if (highlightedKey.value == token) {
        highlightedKey.value = null;
      }
    });
  }

  void dispose() {
    highlightedKey.dispose();
  }
}

/// Wraps a setting tile with a [GlobalKey] and optional highlight decoration.
class SettingAnchor extends StatelessWidget {
  const SettingAnchor({
    super.key,
    required this.registry,
    required this.settingKey,
    required this.child,
  });

  final SettingAnchorRegistry registry;
  final String settingKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: registry.keyFor(settingKey),
      child: ValueListenableBuilder<String?>(
        valueListenable: registry.highlightedKey,
        builder: (context, highlighted, _) {
          final active = highlighted == settingKey;
          final theme = Theme.of(context);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.55)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: active
                  ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    )
                  : null,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Convenience: scroll using a [SettingAnchorRegistry].
Future<void> scrollToSetting(
  SettingAnchorRegistry registry,
  String settingKey, {
  ScrollController? controller,
  double? knownOffset,
  double alignment = 0.1,
}) {
  return registry.scrollTo(
    settingKey,
    controller: controller,
    knownOffset: knownOffset,
    alignment: alignment,
  );
}
