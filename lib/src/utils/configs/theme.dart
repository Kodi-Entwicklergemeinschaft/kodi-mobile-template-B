import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_theme.dart';

enum DarkOption { dynamic, alwaysOn, alwaysOff }

class AppTheme {
  ///Default font
  static const String defaultFont = "Poppins";

  ///List Font support
  static final List<String> fontSupport = [
    "OpenSans",
    "Montserrat",
    "Raleway",
    "Roboto",
    "Merriweather",
    "Poppins"
  ];

  ///Default Theme
  static final ThemeModel defaultTheme = ThemeModel.fromJson({
    "name": "default",
    "primary": '#e30613',
    "secondary": "#979797",
  });

  ///List Theme Support in Application
  static final List themeSupport = [
    {
      "name": "default",
      "primary": '#e30613',
      "secondary": "#979797",
    },
    {
      "name": "green",
      "primary": 'ff82B541',
      "secondary": "ffff8a65",
    },
    {
      "name": "orange",
      "primary": 'fff4a261',
      "secondary": "ff2A9D8F",
    }
  ].map((item) => ThemeModel.fromJson(item)).toList();

  ///Dark Theme option
  static DarkOption darkThemeOption = DarkOption.alwaysOff;

  ///Get theme data
  static ThemeData getTheme({
    required ThemeModel theme,
    required Brightness brightness,
    String? font,
  }) {
    ColorScheme? colorScheme;
    switch (brightness) {
      case Brightness.light:
        colorScheme = ColorScheme.light(
          primary: theme.primary,
          secondary: theme.secondary,
        );
        break;
      case Brightness.dark:
        colorScheme = ColorScheme.dark(
          primary: theme.primary,
          secondary: theme.secondary,
        );
        break;
      default:
        colorScheme = ColorScheme.dark(
          primary: theme.primary,
          secondary: theme.secondary,
        );
        break;
    }

    final isDark = colorScheme.brightness == Brightness.dark;
    final indicatorColor = isDark ? colorScheme.onSurface : colorScheme.primary;

    return ThemeData(
      brightness: colorScheme.brightness,
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
          backgroundColor:
              isDark ? Colors.white.withAlpha(30) : const Color(0xFFe1e1e1),
          foregroundColor: isDark ? Colors.white : Colors.black,
          shadowColor: isDark ? null : colorScheme.onSurface.withOpacity(0.2),
          iconTheme: IconThemeData(color: colorScheme.primary)),
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      // bottomAppBarColor: colorScheme.surface,
      cardColor: colorScheme.surface,
      dividerColor: colorScheme.onSurface.withOpacity(0.12),
      dialogBackgroundColor: colorScheme.surface,
      indicatorColor: indicatorColor,
      applyElevationOverlayColor: isDark,
      shadowColor: const Color(0xFFa39f94),

      ///Custom
      fontFamily: font,
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.8,
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        shape: CircularNotchedRectangle(),  
      ),
      colorScheme: colorScheme
          .copyWith(surface: colorScheme.surface)
          .copyWith(error: colorScheme.error)
          .copyWith(surface: colorScheme.surface),
    );
  }

  ///export language dark option
  static String langDarkOption(DarkOption option) {
    switch (option) {
      case DarkOption.dynamic:
        return "dynamic_theme";
      case DarkOption.alwaysOff:
        return "always_off";
      default:
        return "always_on";
    }
  }

  ///Singleton factory
  static final AppTheme _instance = AppTheme._internal();

  factory AppTheme() {
    return _instance;
  }

  AppTheme._internal();
}
