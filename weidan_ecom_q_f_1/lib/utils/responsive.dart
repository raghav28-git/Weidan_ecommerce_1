import 'package:flutter/material.dart';

class Responsive {
  // ── Breakpoints ─────────────────────────────────────────────────────────────
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Very small phones: width < 360 OR height < 640 (e.g. iPhone SE 1st gen)
  static bool isSmallPhone(BuildContext context) {
    final s = MediaQuery.of(context).size;
    return s.width < 360 || s.height < 640;
  }

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 900;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // ── Dimensions ──────────────────────────────────────────────────────────────
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // ── Padding & spacing ────────────────────────────────────────────────────────
  /// Horizontal page padding: 16 phone · 24 tablet · 32 desktop
  static double hPadding(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 900) return 32;
    if (w >= 600) return 24;
    return 16;
  }

  /// Vertical section spacing: 16 phone · 20 tablet · 24 desktop
  /// Reduced to 10 on very small phones to prevent content from being cut off.
  static double vSpacing(BuildContext context) {
    if (isSmallPhone(context)) return 10;
    final w = screenWidth(context);
    if (w >= 900) return 24;
    if (w >= 600) return 20;
    return 16;
  }

  /// Compact spacing for tightly packed sections on small screens.
  static double vSpacingSmall(BuildContext context) =>
      isSmallPhone(context) ? 6 : 10;

  /// Adaptive vertical padding for the dark header block.
  static EdgeInsets headerPadding(BuildContext context) {
    final h = screenHeight(context);
    final hPad = (screenWidth(context) * 0.05).clamp(14.0, 24.0);
    final vPad = h < 640 ? 10.0 : (h < 750 ? 14.0 : 18.0);
    return EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad + 2);
  }

  // ── Grid ────────────────────────────────────────────────────────────────────
  /// Grid columns: 2 phone · 3 tablet · 4 desktop
  /// In landscape phone → 3 columns
  static int gridColumns(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 900) return 4;
    if (w >= 600) return 3;
    if (isLandscape(context)) return 3;
    return 2;
  }

  /// Product card aspect ratio — width / height.
  /// Higher value = shorter card. Lower value = taller card.
  /// Tuned so the info area (name + price + button) never overflows.
  static double cardAspectRatio(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 900) return 0.72;
    if (w >= 600) return 0.68;
    if (isLandscape(context)) return 0.80;
    if (isSmallPhone(context)) return 0.62;
    return 0.65;
  }

  /// Cross-axis spacing for product grids.
  static double gridSpacing(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 900) return 20;
    if (w >= 600) return 16;
    return 12;
  }

  /// Returns a fully configured [SliverGridDelegateWithFixedCrossAxisCount]
  /// that adapts columns, spacing and aspect ratio to the current screen.
  static SliverGridDelegateWithFixedCrossAxisCount productGridDelegate(
    BuildContext context,
  ) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: gridColumns(context),
      childAspectRatio: cardAspectRatio(context),
      crossAxisSpacing: gridSpacing(context),
      mainAxisSpacing: gridSpacing(context),
    );
  }

  // ── Typography ───────────────────────────────────────────────────────────────
  /// Scale a base font size proportionally to screen width.
  /// Clamps between [min] and [max].
  static double fontSize(
    BuildContext context,
    double base, {
    double min = 10,
    double max = 40,
  }) {
    final scale = screenWidth(context) / 390; // 390 = iPhone 14 logical width
    return (base * scale).clamp(min, max);
  }

  // ── Image heights ────────────────────────────────────────────────────────────
  /// Banner / hero image height: 42% of screen height, clamped.
  static double bannerHeight(BuildContext context) {
    final h = screenHeight(context);
    if (isLandscape(context)) return (h * 0.60).clamp(160, 280);
    return (h * 0.42).clamp(180, 320);
  }

  /// Product detail image height: 45% of screen height, clamped.
  static double productImageHeight(BuildContext context) {
    final h = screenHeight(context);
    if (isLandscape(context)) return (h * 0.65).clamp(200, 360);
    return (h * 0.45).clamp(240, 420);
  }

  // ── Modal / dialog ───────────────────────────────────────────────────────────
  /// Max width for centred modals / dialogs.
  static double modalWidth(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 900) return 600;
    if (w >= 600) return w * 0.88;
    return w; // full-width on phone
  }

  /// Max width for Alert/confirm dialogs.
  static double dialogWidth(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 900) return 480;
    if (w >= 600) return w * 0.70;
    return w * 0.88;
  }

  /// Horizontal padding inside forms — tighter on phone, roomier on tablet.
  static double formPadding(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 900) return 32;
    if (w >= 600) return 28;
    return 20;
  }

  /// Max height for bottom sheets.
  /// Accounts for status bar, keyboard insets, and a safe breathing gap.
  static double sheetMaxHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.size.height - mq.padding.top - mq.viewInsets.bottom - 24;
  }

  /// Wraps [child] in a keyboard-aware, size-constrained dialog shell.
  /// Use this instead of bare [Dialog] to get responsive width + scroll.
  static Widget responsiveDialog({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenWidth(context) - dialogWidth(context)) / 2,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth(context),
          maxHeight: sheetMaxHeight(context),
        ),
        child: SingleChildScrollView(
          padding: padding ?? const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }

  // ── Nav bar ──────────────────────────────────────────────────────────────────
  /// Height of the floating pill nav bar.
  static const double navBarHeight = 58.0;

  /// Gap between the bottom of the pill and the safe-area edge.
  static const double navBarGap = 20.0;

  /// Total bottom clearance a scrollable needs so content clears the navbar.
  static double navBarClearance(BuildContext context) =>
      navBarHeight + navBarGap + MediaQuery.of(context).padding.bottom + 16;

  /// Pill width: full-bleed on phone, capped on tablet/desktop.
  static double navBarPillWidth(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 900) return 480;
    if (w >= 600) return (w * 0.60).clamp(360.0, 480.0);
    return (w - 48).clamp(240.0, 420.0);
  }

  /// Bottom position of the floating navbar from the screen bottom edge.
  static double navBarBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom + navBarGap;

  // ── Safe content width ───────────────────────────────────────────────────────
  /// Usable content width after horizontal padding.
  static double contentWidth(BuildContext context) =>
      screenWidth(context) - hPadding(context) * 2;
}
