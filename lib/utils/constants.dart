import 'package:flutter/material.dart';

class AppColors {
  static const Color ytRed = Color(0xFFFF0000);
  static const Color ytBlack = Color(0xFF212121);
  static const Color ytDarkBg = Color(0xFF0F0F0F);
  static const Color ytDarkSurface = Color(0xFF272727);
  static const Color ytDarkCard = Color(0xFF1E1E1E);
  static const Color ytGrey = Color(0xFFAAAAAA);
  static const Color ytLightGrey = Color(0xFF606060);
  static const Color ytChipBg = Color(0xFF333333);
  static const Color ytChipSelected = Color(0xFFFFFFFF);
  static const Color ytChipText = Color(0xFFFFFFFF);
  static const Color ytChipSelectedText = Color(0xFF0F0F0F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color shortsRed = Color(0xFFFF0000);
  static const Color ytBottomBarBorder = Color(0xFF303030);
  static const Color ytSubscribeBg = Color(0xFF3D3D3D);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.ytDarkBg,
        primaryColor: AppColors.ytRed,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.ytRed,
          surface: AppColors.ytDarkSurface,
          onPrimary: AppColors.white,
          onSurface: AppColors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.ytDarkBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.white),
          titleTextStyle: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.ytDarkBg,
          selectedItemColor: AppColors.white,
          unselectedItemColor: AppColors.ytGrey,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.ytChipBg,
          selectedColor: AppColors.ytChipSelected,
          labelStyle: const TextStyle(color: AppColors.ytChipText, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide.none,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.ytBottomBarBorder,
          thickness: 0.5,
          space: 0,
        ),
      );
}
