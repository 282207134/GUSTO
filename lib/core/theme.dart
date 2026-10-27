import 'package:flutter/material.dart';

const yellow = Color(0xFFFFC447);
const orange = Color(0xFFFF9800);
const muted = Color(0xFF99999C);
const line = Color(0xFFECECEE);
const purple = Color(0xFF6A3EE6);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(
    seedColor: yellow,
    primary: yellow,
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 15, color: Colors.black, height: 1.35),
    bodySmall: TextStyle(fontSize: 12, color: muted, height: 1.4),
    titleLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -.7,
    ),
    titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
  ),
  dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
  inputDecorationTheme: const InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: line)),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: yellow, width: 2),
    ),
    labelStyle: TextStyle(color: muted, fontSize: 14),
    contentPadding: EdgeInsets.symmetric(vertical: 14),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.white),
    trackColor: WidgetStateProperty.resolveWith(
      (s) =>
          s.contains(WidgetState.selected) ? yellow : const Color(0xFFDADADD),
    ),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  ),
);
