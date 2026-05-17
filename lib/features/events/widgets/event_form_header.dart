import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';

class EventFormHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const EventFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 54),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
              const Spacer(),
              ValueListenableBuilder<Locale>(
                valueListenable: localeController,
                builder: (context, locale, _) {
                  return LanguageToggle(
                    selectedLocale: locale,
                    onLocaleChanged: (newLocale) {
                      localeController.value = newLocale;
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textWhite.withOpacity(0.88),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.textWhite.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: AppColors.textWhite, size: 20),
        ),
      ),
    );
  }
}