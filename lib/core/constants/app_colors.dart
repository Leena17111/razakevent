import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────────────────────────
  // Brand colors
  // ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A237E); // Deep navy
  static const Color primaryLight = Color(0xFF3949AB); // Lighter navy/blue
  static const Color accent = Color(0xFFC8102E); // UTM red
  static const Color accentDark = Color(0xFFA00D25); // Dark red for gradients

  // ─────────────────────────────────────────────────────────────
  // Background colors
  // ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F6FA); // App background
  static const Color backgroundAlt = Color(0xFFE8E9F0); // Hover/soft grey background
  static const Color surface = Color(0xFFFFFFFF); // Cards / screens
  static const Color surfaceSoft = Color(0xFFF3F4F6); // Disabled fields / soft boxes

  // ─────────────────────────────────────────────────────────────
  // Text colors
  // ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1C1E); // Main text
  static const Color textSecondary = Color(0xFF6B7280); // Subtitle / labels
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);

  // ─────────────────────────────────────────────────────────────
  // Border / divider colors
  // ─────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF1F2F6);

  // ─────────────────────────────────────────────────────────────
  // Status colors
  // ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color error = Color(0xFFC8102E);
  static const Color warning = Color(0xFFF59E0B);

  // ─────────────────────────────────────────────────────────────
  // Role badge colors
  // These clear role names should be used in new code.
  // ─────────────────────────────────────────────────────────────

  // Student role — teal
  static const Color studentBadgeBg = Color(0xFFCCFBF1);
  static const Color studentBadgeText = Color(0xFF0F766E);

  // Organizer Head role — orange
  static const Color organizerBadgeBg = Color(0xFFFEF3C7);
  static const Color organizerBadgeText = Color(0xFFD97706);

  // Secretary role — purple
  static const Color secretaryBadgeBg = Color(0xFFEDE9FE);
  static const Color secretaryBadgeText = Color(0xFF6D28D9);

  // Admin role — red
  static const Color adminBadgeBg = Color(0xFFFEE2E2);
  static const Color adminBadgeText = Color(0xFF991B1B);

  // ─────────────────────────────────────────────────────────────
  // Backward-compatible old role color names
  // Keep these so older pages do not break.
  // ─────────────────────────────────────────────────────────────
  static const Color clubBadgeBg = organizerBadgeBg;
  static const Color clubBadgeText = organizerBadgeText;

  static const Color communityBadgeBg = secretaryBadgeBg;
  static const Color communityBadgeText = secretaryBadgeText;

  // ─────────────────────────────────────────────────────────────
  // Soft decorative colors
  // ─────────────────────────────────────────────────────────────
  static const Color accentSoft = Color(0xFFFFE6EA); // Soft red tint
  static const Color primarySoft = Color(0xFFE8EAF6); // Soft navy tint

  // ─────────────────────────────────────────────────────────────
  // Shadows
  // ─────────────────────────────────────────────────────────────
  static const Color shadowNavy = Color(0x1F1A237E); // Navy with low opacity
  static const Color shadowDark = Color(0x1A000000); // Black with low opacity
}