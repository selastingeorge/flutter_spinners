import 'package:flutter/material.dart';

ThemeData genericTheme = ThemeData(
  fontFamily: "Inter",
  colorScheme: ColorScheme.dark(),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF0c0c0c),

  cardTheme: CardThemeData(
    color: Colors.white.withAlpha(5),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.white.withAlpha(10), width: 1),
    ),
    elevation: 0,
  ),

  tooltipTheme: TooltipThemeData(
    preferBelow: false,
    padding: EdgeInsets.all(10),
    verticalOffset: 15,
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(250),
      borderRadius: BorderRadius.circular(5),
    ),
    textStyle: TextStyle(
      fontSize: 12,
      fontFamily: "Inter",
      color: Color(0xFF060606),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withAlpha(5),
    selectedColor: Colors.white,
    disabledColor: Colors.white.withAlpha(10),
    secondarySelectedColor: Colors.white,
    shadowColor: Colors.transparent,
    showCheckmark: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: BorderSide.none,
    ),
    labelStyle: const TextStyle(
      color: Colors.white,
      fontVariations: [FontVariation('wght', 500)],
    ),
    secondaryLabelStyle: const TextStyle(color: Colors.black),
    side: BorderSide.none,
    color: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
      WidgetState.selected: Colors.white,
      WidgetState.any: Colors.white.withAlpha(10),
    }),
  ),
);
