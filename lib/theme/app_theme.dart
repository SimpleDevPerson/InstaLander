import 'package:flutter/material.dart';

class AppTheme {
  // Instagram brand colors
  static const Color instagramBlue = Color(0xFF0095F6);
  static const Color instagramGradientStart = Color(0xFF833AB4);
  static const Color instagramGradientMid = Color(0xFFE1306C);
  static const Color instagramGradientEnd = Color(0xFFF56040);
  static const Color instagramRed = Color(0xFFED4956);

  // Samsung One UI Colors (Light)
  static const Color samsungBlue = Color(0xFF1B75E8);
  static const Color samsungBlueLight = Color(0xFFE8F0FE);
  static const Color samsungBlueContainer = Color(0xFFD6E4F0);
  static const Color samsungBlueOnContainer = Color(0xFF001D3D);
  static const Color samsungIndigo = Color(0xFF6750A4);
  static const Color samsungTeal = Color(0xFF006D77);

  // Samsung Light theme colors
  static const Color _samsungBg = Color(0xFFF5F5F5);           // Background
  static const Color _samsungOnBg = Color(0xFF1C1B1F);         // On Background
  static const Color _samsungSurface = Color(0xFFFFFFFF);      // Surface
  static const Color _samsungOnSurface = Color(0xFF1C1B1F);    // On Surface
  static const Color _samsungSurfaceVariant = Color(0xFFF0F0F0); // Surface Variant
  static const Color _samsungOnSurfaceVariant = Color(0xFF49454F); // On Surface Variant
  static const Color _samsungOutline = Color(0xFF7A767F);      // Outline
  static const Color _samsungOutlineVariant = Color(0xFFCAC4D0); // Outline Variant
  static const Color _samsungPrimary = samsungBlue;            // Primary
  static const Color _samsungOnPrimary = Color(0xFFFFFFFF);    // On Primary
  static const Color _samsungPrimaryContainer = samsungBlueContainer; // Primary Container
  static const Color _samsungOnPrimaryContainer = samsungBlueOnContainer; // On Primary Container
  static const Color _samsungSecondary = samsungIndigo;        // Secondary
  static const Color _samsungOnSecondary = Color(0xFFFFFFFF);  // On Secondary
  static const Color _samsungSecondaryContainer = Color(0xFFE8DEF8); // Secondary Container
  static const Color _samsungOnSecondaryContainer = Color(0xFF21005D); // On Secondary Container
  static const Color _samsungTertiary = samsungTeal;           // Tertiary
  static const Color _samsungOnTertiary = Color(0xFFFFFFFF);   // On Tertiary
  static const Color _samsungTertiaryContainer = Color(0xFFD1F5FF); // Tertiary Container
  static const Color _samsungOnTertiaryContainer = Color(0xFF001F20); // On Tertiary Container
  static const Color _samsungError = Color(0xFFBA1A1A);        // Error
  static const Color _samsungOnError = Color(0xFFFFFFFF);      // On Error
  static const Color _samsungErrorContainer = Color(0xFFFFDAD6); // Error Container
  static const Color _samsungOnErrorContainer = Color(0xFF410002); // On Error Container
  static const Color _samsungScrim = Color(0xFF000000);        // Scrim
  static const Color _samsungShadow = Color(0xFF000000);       // Shadow

  // Samsung One UI Colors (Dark)
  static const Color _samsungDarkBg = Color(0xFF1C1C1C);       // Background
  static const Color _samsungDarkOnBg = Color(0xFFE6E1E5);     // On Background
  static const Color _samsungDarkSurface = Color(0xFF2C2C2C);  // Surface
  static const Color _samsungDarkOnSurface = Color(0xFFE6E1E5); // On Surface
  static const Color _samsungDarkSurfaceVariant = Color(0xFF3D3D3D); // Surface Variant
  static const Color _samsungDarkOnSurfaceVariant = Color(0xFFCAC4D0); // On Surface Variant
  static const Color _samsungDarkOutline = Color(0xFF938F99);  // Outline
  static const Color _samsungDarkOutlineVariant = Color(0xFF49454F); // Outline Variant
  static const Color _samsungDarkPrimary = Color(0xFFB0D0FF);  // Primary (Light Blue)
  static const Color _samsungDarkOnPrimary = Color(0xFF003366); // On Primary
  static const Color _samsungDarkPrimaryContainer = Color(0xFF00478A); // Primary Container
  static const Color _samsungDarkOnPrimaryContainer = Color(0xFFD6E4F0); // On Primary Container
  static const Color _samsungDarkSecondary = Color(0xFFCCC2DC); // Secondary
  static const Color _samsungDarkOnSecondary = Color(0xFF381E72); // On Secondary
  static const Color _samsungDarkSecondaryContainer = Color(0xFF4A4458); // Secondary Container
  static const Color _samsungDarkOnSecondaryContainer = Color(0xFFE8DEF8); // On Secondary Container
  static const Color _samsungDarkTertiary = Color(0xFFA0E8F5); // Tertiary
  static const Color _samsungDarkOnTertiary = Color(0xFF003639); // On Tertiary
  static const Color _samsungDarkTertiaryContainer = Color(0xFF004D51); // Tertiary Container
  static const Color _samsungDarkOnTertiaryContainer = Color(0xFFD1F5FF); // On Tertiary Container
  static const Color _samsungDarkError = Color(0xFFFFB4AB);    // Error
  static const Color _samsungDarkOnError = Color(0xFF690005);  // On Error
  static const Color _samsungDarkErrorContainer = Color(0xFF93000A); // Error Container
  static const Color _samsungDarkOnErrorContainer = Color(0xFFFFDAD6); // On Error Container

  // Light theme colors (Instagram default)
  static const Color _lightBg = Color(0xFFFAFAFA);
  static const Color _lightText = Color(0xFF262626);
  static const Color _lightCardBg = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFDBDBDB);
  static const Color _lightSubText = Color(0xFF8E8E8E);
  static const Color _lightWlBtnBg = Color(0xFFEFEFEF);
  static const Color _lightWlBtnHover = Color(0xFFDBDBDB);

  // Dark theme colors (Instagram default)
  static const Color _darkBg = Color(0xFF121212);
  static const Color _darkText = Color(0xFFF5F5F5);
  static const Color _darkCardBg = Color(0xFF1E1E1E);
  static const Color _darkBorder = Color(0xFF333333);
  static const Color _darkSubText = Color(0xFFA0A0A0);
  static const Color _darkWlBtnBg = Color(0xFF2C2C2C);
  static const Color _darkWlBtnHover = Color(0xFF3D3D3D);

  // Build theme helper
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color bg,
    required Color text,
    required Color cardBg,
    required Color border,
    required Color subText,
    required Color wlBtnBg,
    required Color wlBtnHover,
    required double borderRadius,
    required double elevation,
    required Color shadowColor,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required double cardElevation,
    required double buttonBorderRadius,
    required double inputBorderRadius,
    required double chipBorderRadius,
    required double dialogBorderRadius,
    required double bottomSheetBorderRadius,
    required EdgeInsets cardMargin,
    required EdgeInsets appBarPadding,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        foregroundColor: text,
        elevation: elevation,
        surfaceTintColor: isDark ? Colors.transparent : Colors.white,
        centerTitle: false,
        titleSpacing: 16,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: text,
          fontFamily: 'Roboto',
          letterSpacing: -0.5,
        ),
        toolbarHeight: 56,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: cardElevation,
        shadowColor: shadowColor,
        surfaceTintColor: isDark ? Colors.transparent : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: border, width: isDark ? 0.5 : 1),
        ),
        margin: cardMargin,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: border, width: isDark ? 0.5 : 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: border, width: isDark ? 0.5 : 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: instagramRed, width: isDark ? 0.5 : 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: instagramRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: subText,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        labelStyle: TextStyle(
          color: subText,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonBorderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 40),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            letterSpacing: 0.25,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonBorderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 40),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            letterSpacing: 0.25,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border, width: isDark ? 0.5 : 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonBorderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 40),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            letterSpacing: 0.25,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonBorderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(48, 40),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            letterSpacing: 0.25,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 0.5,
        space: 1,
        indent: 16,
        endIndent: 16,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: wlBtnBg,
        disabledColor: wlBtnBg.withValues(alpha: 0.5),
        selectedColor: primary.withValues(alpha: 0.12),
        secondarySelectedColor: primary,
        labelStyle: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        side: BorderSide(color: border, width: isDark ? 0.5 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(chipBorderRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardBg,
        indicatorColor: primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
              fontFamily: 'Roboto',
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: subText,
            fontFamily: 'Roboto',
          );
        }),
        height: 80,
        surfaceTintColor: isDark ? Colors.transparent : Colors.white,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(bottomSheetBorderRadius)),
        ),
        elevation: 0,
        surfaceTintColor: cardBg,
        dragHandleColor: subText.withValues(alpha: 0.5),
        dragHandleSize: const Size(32, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogBorderRadius)),
        elevation: 0,
        surfaceTintColor: cardBg,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
          fontFamily: 'Roboto',
          letterSpacing: -0.25,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: text,
          fontFamily: 'Roboto',
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        surfaceTintColor: cardBg,
        textStyle: TextStyle(
          color: text,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        labelTextStyle: WidgetStateProperty.all(TextStyle(
          color: text,
          fontSize: 14,
          fontFamily: 'Roboto',
        )),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(cardBg),
          surfaceTintColor: WidgetStateProperty.all(cardBg),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          elevation: WidgetStateProperty.all(2),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
        selectedTileColor: primary.withValues(alpha: 0.08),
        iconColor: subText,
        textColor: text,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: text,
          fontFamily: 'Roboto',
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 13,
          color: subText,
          fontFamily: 'Roboto',
        ),
        leadingAndTrailingTextStyle: TextStyle(
          fontSize: 13,
          color: subText,
          fontFamily: 'Roboto',
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? Colors.grey[400] : Colors.grey[300];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withValues(alpha: 0.5);
          return isDark ? Colors.grey[800] : Colors.grey[300];
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return border;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return border;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: border,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: subText,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),
        dividerColor: border,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: text.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: bg,
          fontSize: 12,
          fontFamily: 'Roboto',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        preferBelow: true,
        verticalOffset: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? _samsungDarkSurfaceVariant : _samsungSurfaceVariant,
        contentTextStyle: TextStyle(
          color: isDark ? _samsungDarkOnSurface : _samsungOnSurface,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        actionTextColor: primary,
      ),
    );
  }

  // Standard Instagram Light Theme
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        primary: instagramBlue,
        secondary: instagramGradientMid,
        bg: _lightBg,
        text: _lightText,
        cardBg: _lightCardBg,
        border: _lightBorder,
        subText: _lightSubText,
        wlBtnBg: _lightWlBtnBg,
        wlBtnHover: _lightWlBtnHover,
        borderRadius: 12,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        colorScheme: const ColorScheme.light(
          primary: instagramBlue,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFE8F0FE),
          onPrimaryContainer: Color(0xFF001D3D),
          secondary: instagramGradientMid,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFFCE4EC),
          onSecondaryContainer: Color(0xFF4A0000),
          tertiary: Color(0xFF006D77),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFD1F5FF),
          onTertiaryContainer: Color(0xFF001F20),
          error: instagramRed,
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
          surface: _lightCardBg,
          onSurface: _lightText,
          surfaceContainerHighest: Color(0xFFF5F5F5),
          onSurfaceVariant: _lightSubText,
          outline: _lightBorder,
          outlineVariant: _lightBorder,
          shadow: Color(0x19000000), // 0.06 alpha
          scrim: Color(0x4D000000), // 0.3 alpha
          inverseSurface: _darkCardBg,
          onInverseSurface: _darkText,
          inversePrimary: Color(0xFF80D0FF),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _lightText,
            fontFamily: 'Roboto',
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _lightText,
            fontFamily: 'Roboto',
            letterSpacing: -0.25,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: _lightText,
            fontFamily: 'Roboto',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: _lightSubText,
            fontFamily: 'Roboto',
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Roboto',
            letterSpacing: 0.25,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _lightSubText,
            fontFamily: 'Roboto',
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            color: _lightSubText,
            fontFamily: 'Roboto',
          ),
        ),
        cardElevation: 2,
        buttonBorderRadius: 12,
        inputBorderRadius: 12,
        chipBorderRadius: 20,
        dialogBorderRadius: 20,
        bottomSheetBorderRadius: 24,
        cardMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        appBarPadding: const EdgeInsets.symmetric(horizontal: 16),
      );

  // Standard Instagram Dark Theme
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        primary: instagramBlue,
        secondary: instagramGradientMid,
        bg: _darkBg,
        text: _darkText,
        cardBg: _darkCardBg,
        border: _darkBorder,
        subText: _darkSubText,
        wlBtnBg: _darkWlBtnBg,
        wlBtnHover: _darkWlBtnHover,
        borderRadius: 12,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        colorScheme: const ColorScheme.dark(
          primary: instagramBlue,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF00478A),
          onPrimaryContainer: Color(0xFFD6E4F0),
          secondary: instagramGradientMid,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFF4A0000),
          onSecondaryContainer: Color(0xFFFCE4EC),
          tertiary: Color(0xFF006D77),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFF004D51),
          onTertiaryContainer: Color(0xFFD1F5FF),
          error: instagramRed,
          onError: Colors.white,
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          surface: _darkCardBg,
          onSurface: _darkText,
          surfaceContainerHighest: Color(0xFF2C2C2C),
          onSurfaceVariant: _darkSubText,
          outline: _darkBorder,
          outlineVariant: _darkBorder,
          shadow: Color(0x4D000000), // 0.3 alpha
          scrim: Color(0x80000000), // 0.5 alpha
          inverseSurface: _lightCardBg,
          onInverseSurface: _lightText,
          inversePrimary: instagramBlue,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _darkText,
            fontFamily: 'Roboto',
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _darkText,
            fontFamily: 'Roboto',
            letterSpacing: -0.25,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: _darkText,
            fontFamily: 'Roboto',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: _darkSubText,
            fontFamily: 'Roboto',
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Roboto',
            letterSpacing: 0.25,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _darkSubText,
            fontFamily: 'Roboto',
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            color: _darkSubText,
            fontFamily: 'Roboto',
          ),
        ),
        cardElevation: 2,
        buttonBorderRadius: 12,
        inputBorderRadius: 12,
        chipBorderRadius: 20,
        dialogBorderRadius: 20,
        bottomSheetBorderRadius: 24,
        cardMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        appBarPadding: const EdgeInsets.symmetric(horizontal: 16),
      );

  // Samsung One UI Light Theme
  static ThemeData get samsungLightTheme => _buildTheme(
        brightness: Brightness.light,
        primary: _samsungPrimary,
        secondary: _samsungSecondary,
        bg: _samsungBg,
        text: _samsungOnBg,
        cardBg: _samsungSurface,
        border: _samsungOutlineVariant,
        subText: _samsungOnSurfaceVariant,
        wlBtnBg: _samsungSurfaceVariant,
        wlBtnHover: _samsungOutlineVariant,
        borderRadius: 16, // Samsung cards have 16dp radius
        elevation: 1, // Samsung uses subtle elevation
        shadowColor: _samsungShadow.withValues(alpha: 0.04),
        colorScheme: const ColorScheme.light(
          primary: _samsungPrimary,
          onPrimary: _samsungOnPrimary,
          primaryContainer: _samsungPrimaryContainer,
          onPrimaryContainer: _samsungOnPrimaryContainer,
          secondary: _samsungSecondary,
          onSecondary: _samsungOnSecondary,
          secondaryContainer: _samsungSecondaryContainer,
          onSecondaryContainer: _samsungOnSecondaryContainer,
          tertiary: _samsungTertiary,
          onTertiary: _samsungOnTertiary,
          tertiaryContainer: _samsungTertiaryContainer,
          onTertiaryContainer: _samsungOnTertiaryContainer,
          error: _samsungError,
          onError: _samsungOnError,
          errorContainer: _samsungErrorContainer,
          onErrorContainer: _samsungOnErrorContainer,
          surface: _samsungSurface,
          onSurface: _samsungOnSurface,
          surfaceContainerHighest: _samsungSurfaceVariant,
          onSurfaceVariant: _samsungOnSurfaceVariant,
          outline: _samsungOutline,
          outlineVariant: _samsungOutlineVariant,
          shadow: _samsungShadow,
          scrim: _samsungScrim,
          inverseSurface: _samsungDarkSurface,
          onInverseSurface: _samsungDarkOnSurface,
          inversePrimary: _samsungDarkPrimary,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _samsungOnBg,
            fontFamily: 'Roboto',
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _samsungOnBg,
            fontFamily: 'Roboto',
            letterSpacing: -0.25,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _samsungOnBg,
            fontFamily: 'Roboto',
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _samsungOnBg,
            fontFamily: 'Roboto',
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _samsungOnBg,
            fontFamily: 'Roboto',
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _samsungOnBg,
            fontFamily: 'Roboto',
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _samsungOnSurface,
            fontFamily: 'Roboto',
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _samsungOnSurface,
            fontFamily: 'Roboto',
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _samsungOnSurface,
            fontFamily: 'Roboto',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: _samsungOnSurface,
            fontFamily: 'Roboto',
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: _samsungOnSurface,
            fontFamily: 'Roboto',
            height: 1.43,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: _samsungOnSurfaceVariant,
            fontFamily: 'Roboto',
            height: 1.33,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Roboto',
            letterSpacing: 0.25,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _samsungOnSurfaceVariant,
            fontFamily: 'Roboto',
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            color: _samsungOnSurfaceVariant,
            fontFamily: 'Roboto',
          ),
        ),
        cardElevation: 1,
        buttonBorderRadius: 28, // Samsung buttons are very round (28dp)
        inputBorderRadius: 16, // Samsung inputs have 16dp radius
        chipBorderRadius: 20,
        dialogBorderRadius: 28, // Samsung dialogs have 28dp radius
        bottomSheetBorderRadius: 28, // Samsung bottom sheets have 28dp radius
        cardMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        appBarPadding: const EdgeInsets.symmetric(horizontal: 16),
      );

  // Samsung One UI Dark Theme
  static ThemeData get samsungDarkTheme => _buildTheme(
        brightness: Brightness.dark,
        primary: _samsungDarkPrimary,
        secondary: _samsungDarkSecondary,
        bg: _samsungDarkBg,
        text: _samsungDarkOnBg,
        cardBg: _samsungDarkSurface,
        border: _samsungDarkOutlineVariant,
        subText: _samsungDarkOnSurfaceVariant,
        wlBtnBg: _samsungDarkSurfaceVariant,
        wlBtnHover: _samsungDarkOutlineVariant,
        borderRadius: 16,
        elevation: 1,
        shadowColor: _samsungShadow.withValues(alpha: 0.3),
        colorScheme: const ColorScheme.dark(
          primary: _samsungDarkPrimary,
          onPrimary: _samsungDarkOnPrimary,
          primaryContainer: _samsungDarkPrimaryContainer,
          onPrimaryContainer: _samsungDarkOnPrimaryContainer,
          secondary: _samsungDarkSecondary,
          onSecondary: _samsungDarkOnSecondary,
          secondaryContainer: _samsungDarkSecondaryContainer,
          onSecondaryContainer: _samsungDarkOnSecondaryContainer,
          tertiary: _samsungDarkTertiary,
          onTertiary: _samsungDarkOnTertiary,
          tertiaryContainer: _samsungDarkTertiaryContainer,
          onTertiaryContainer: _samsungDarkOnTertiaryContainer,
          error: _samsungDarkError,
          onError: _samsungDarkOnError,
          errorContainer: _samsungDarkErrorContainer,
          onErrorContainer: _samsungDarkOnErrorContainer,
          surface: _samsungDarkSurface,
          onSurface: _samsungDarkOnSurface,
          surfaceContainerHighest: _samsungDarkSurfaceVariant,
          onSurfaceVariant: _samsungDarkOnSurfaceVariant,
          outline: _samsungDarkOutline,
          outlineVariant: _samsungDarkOutlineVariant,
          shadow: _samsungShadow,
          scrim: _samsungScrim,
          inverseSurface: _samsungSurface,
          onInverseSurface: _samsungOnSurface,
          inversePrimary: _samsungPrimary,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _samsungDarkOnBg,
            fontFamily: 'Roboto',
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _samsungDarkOnBg,
            fontFamily: 'Roboto',
            letterSpacing: -0.25,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _samsungDarkOnBg,
            fontFamily: 'Roboto',
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _samsungDarkOnBg,
            fontFamily: 'Roboto',
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _samsungDarkOnBg,
            fontFamily: 'Roboto',
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _samsungDarkOnBg,
            fontFamily: 'Roboto',
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _samsungDarkOnSurface,
            fontFamily: 'Roboto',
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _samsungDarkOnSurface,
            fontFamily: 'Roboto',
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _samsungDarkOnSurface,
            fontFamily: 'Roboto',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: _samsungDarkOnSurface,
            fontFamily: 'Roboto',
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: _samsungDarkOnSurface,
            fontFamily: 'Roboto',
            height: 1.43,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: _samsungDarkOnSurfaceVariant,
            fontFamily: 'Roboto',
            height: 1.33,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Roboto',
            letterSpacing: 0.25,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _samsungDarkOnSurfaceVariant,
            fontFamily: 'Roboto',
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            color: _samsungDarkOnSurfaceVariant,
            fontFamily: 'Roboto',
          ),
        ),
        cardElevation: 1,
        buttonBorderRadius: 28,
        inputBorderRadius: 16,
        chipBorderRadius: 20,
        dialogBorderRadius: 28,
        bottomSheetBorderRadius: 28,
        cardMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        appBarPadding: const EdgeInsets.symmetric(horizontal: 16),
      );

  // Get appropriate theme based on app theme mode and system brightness
  static ThemeData getTheme(BuildContext context, {required bool isSamsungTheme, required bool isDark}) {
    if (isSamsungTheme) {
      return isDark ? samsungDarkTheme : samsungLightTheme;
    }
    return isDark ? darkTheme : lightTheme;
  }

  // Helper to get Instagram gradient
  static const LinearGradient instagramGradient = LinearGradient(
    colors: [
      instagramGradientStart,
      instagramGradientMid,
      instagramGradientEnd,
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Samsung gradient
  static const LinearGradient samsungGradient = LinearGradient(
    colors: [
      Color(0xFF1B75E8),
      Color(0xFF6750A4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Get colors based on brightness and theme mode
  static Color getCardBg(BuildContext context, {bool isSamsung = false}) {
    if (isSamsung) {
      return Theme.of(context).brightness == Brightness.dark ? _samsungDarkSurface : _samsungSurface;
    }
    return Theme.of(context).brightness == Brightness.dark ? _darkCardBg : _lightCardBg;
  }

  static Color getBorderColor(BuildContext context, {bool isSamsung = false}) {
    if (isSamsung) {
      return Theme.of(context).brightness == Brightness.dark ? _samsungDarkOutlineVariant : _samsungOutlineVariant;
    }
    return Theme.of(context).brightness == Brightness.dark ? _darkBorder : _lightBorder;
  }

  static Color getSubTextColor(BuildContext context, {bool isSamsung = false}) {
    if (isSamsung) {
      return Theme.of(context).brightness == Brightness.dark ? _samsungDarkOnSurfaceVariant : _samsungOnSurfaceVariant;
    }
    return Theme.of(context).brightness == Brightness.dark ? _darkSubText : _lightSubText;
  }

  static Color getWlBtnBg(BuildContext context, {bool isSamsung = false}) {
    if (isSamsung) {
      return Theme.of(context).brightness == Brightness.dark ? _samsungDarkSurfaceVariant : _samsungSurfaceVariant;
    }
    return Theme.of(context).brightness == Brightness.dark ? _darkWlBtnBg : _lightWlBtnBg;
  }

  static Color getWlBtnHover(BuildContext context, {bool isSamsung = false}) {
    if (isSamsung) {
      return Theme.of(context).brightness == Brightness.dark ? _samsungDarkOutlineVariant : _samsungOutlineVariant;
    }
    return Theme.of(context).brightness == Brightness.dark ? _darkWlBtnHover : _lightWlBtnHover;
  }

  static Color getBgColor(BuildContext context, {bool isSamsung = false}) {
    if (isSamsung) {
      return Theme.of(context).brightness == Brightness.dark ? _samsungDarkBg : _samsungBg;
    }
    return Theme.of(context).brightness == Brightness.dark ? _darkBg : _lightBg;
  }

  static Color getTextColor(BuildContext context, {bool isSamsung = false}) {
    if (isSamsung) {
      return Theme.of(context).brightness == Brightness.dark ? _samsungDarkOnBg : _samsungOnBg;
    }
    return Theme.of(context).brightness == Brightness.dark ? _darkText : _lightText;
  }

  // Get the primary color for current theme
  static Color getPrimaryColor(BuildContext context, {bool isSamsung = false}) {
    if (isSamsung) {
      return Theme.of(context).brightness == Brightness.dark ? _samsungDarkPrimary : _samsungPrimary;
    }
    return instagramBlue;
  }
}