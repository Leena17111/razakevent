import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
}