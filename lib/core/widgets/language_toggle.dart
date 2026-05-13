import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class LanguageToggle extends StatelessWidget {
  final Locale selectedLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const LanguageToggle({
    super.key,
    required this.selectedLocale,
    required this.onLocaleChanged,
  });

  bool get _isEnglish => selectedLocale.languageCode == 'en';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            label: 'EN',
            isSelected: _isEnglish,
            onTap: () => onLocaleChanged(const Locale('en')),
          ),
          _LanguageOption(
            label: 'BM',
            isSelected: !_isEnglish,
            onTap: () => onLocaleChanged(const Locale('ms')),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}