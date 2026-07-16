import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:liquid_glass_bar/liquid_glass_bar.dart";
import "package:liquid_glass_renderer/liquid_glass_renderer.dart";

import "../features/vocabulary/presentation/daily_plan_setup_sheet.dart";
import "../l10n/app_localizations.dart";

const _kBarContentHeight = 57.0;
const _kBarTopPadding = 8.0;
const _kBarBottomSpacing = 12.0;
const _kBarHorizontalPadding = 16.0;
const _kBarInnerPadding = 12.0;
const _kBarRowSpacing = 8.0;

const _kBarStyle = LiquidGlassBarStyle(
  borderRadius: 28,
  height: _kBarContentHeight,
  padding: EdgeInsets.zero,
);

/// Chiều cao ước lượng bottom chrome (nav + safe area) để padding nội dung.
double mainShellBottomInset(BuildContext context) {
  return _kBarTopPadding +
      _kBarInnerPadding +
      _kBarContentHeight +
      _kBarBottomSpacing +
      MediaQuery.paddingOf(context).bottom;
}

LiquidGlassSettings _glassSettingsFor(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return LiquidGlassSettings(
    thickness: isDark ? 18 : 22,
    blur: isDark ? 14 : 18,
    glassColor: isDark
        ? cs.surface.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.30),
    lightIntensity: isDark ? 0.75 : 1.15,
    ambientStrength: isDark ? 0.18 : 0.28,
    saturation: isDark ? 1.25 : 1.45,
    refractiveIndex: 1.35,
  );
}

LiquidGlassBarStyle _barStyleFor(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  return _kBarStyle.copyWith(
    activeColor: cs.primary,
    inactiveColor: cs.onSurface.withValues(alpha: 0.55),
    liquidGlassSettings: _glassSettingsFor(context),
  );
}

/// Tab config cho [LiquidGlassBar].
class AppNavDestination {
  const AppNavDestination({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  LiquidGlassBarItem get barItem =>
      LiquidGlassBarItem(iconData: icon, label: label);
}

/// Liquid glass bottom nav bar (liquid_glass_bar package).
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBar(
      items: destinations.map((d) => d.barItem).toList(),
      currentIndex: selectedIndex,
      onTap: onDestinationSelected,
      style: _barStyleFor(context),
    );
  }
}

/// Separate liquid-glass button for opening today's daily plan setup sheet.
class DailyPlanSetupGlassButton extends StatelessWidget {
  const DailyPlanSetupGlassButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onPressed,
          child: LiquidGlass.withOwnLayer(
            shape: const LiquidRoundedRectangle(borderRadius: 28),
            settings: _glassSettingsFor(context),
            child: SizedBox(
              width: _kBarContentHeight,
              height: _kBarContentHeight,
              child: Icon(
                Icons.edit_calendar_rounded,
                color: cs.primary,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini player + bottom nav của [MainShell].
class MainShellBottomChrome extends ConsumerWidget {
  const MainShellBottomChrome({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.miniPlayer,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavDestination> destinations;
  final Widget miniPlayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          miniPlayer,
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _kBarHorizontalPadding,
              _kBarTopPadding,
              _kBarHorizontalPadding,
              _kBarBottomSpacing,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppNavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    destinations: destinations,
                  ),
                ),
                const SizedBox(width: _kBarRowSpacing),
                DailyPlanSetupGlassButton(
                  tooltip: l10n.setupTodoTooltip,
                  onPressed: () => showDailyPlanSetupSheet(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on LiquidGlassBarStyle {
  LiquidGlassBarStyle copyWith({
    Color? activeColor,
    Color? inactiveColor,
    LiquidGlassSettings? liquidGlassSettings,
  }) {
    return LiquidGlassBarStyle(
      liquidGlassSettings: liquidGlassSettings ?? this.liquidGlassSettings,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      borderRadius: borderRadius,
      height: height,
      padding: padding,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      iconSize: iconSize,
      selectedIconScale: selectedIconScale,
      labelStyle: labelStyle,
    );
  }
}
