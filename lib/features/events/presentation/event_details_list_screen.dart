import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/file_upload_service.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/event_details_controller.dart';
import '../widgets/event_card.dart';
import 'event_details_form_screen.dart';

class EventDetailsListScreen extends StatefulWidget {
  const EventDetailsListScreen({super.key});

  @override
  State<EventDetailsListScreen> createState() => _EventDetailsListScreenState();
}

class _EventDetailsListScreenState extends State<EventDetailsListScreen> {
  final EventDetailsController _controller = EventDetailsController();
  final FileUploadService _fileUploadService = FileUploadService();

  late Future<OrganizerProfileInfo?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _controller.getOrganizerProfile();
  }

  Future<void> _openAddForm(OrganizerProfileInfo profile) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsFormScreen(
          organizerProfile: profile,
        ),
      ),
    );
  }

  Future<void> _openEditForm(
    OrganizerProfileInfo profile,
    EventModel event,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsFormScreen(
          organizerProfile: profile,
          event: event,
        ),
      ),
    );
  }

  Future<void> _deleteEvent(EventModel event) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteEventQuestion),
          content: Text(l10n.deleteEventConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n.delete,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _controller.deleteEvent(event.eventId);

      if (event.posterStoragePath.isNotEmpty) {
        try {
          await _fileUploadService.deleteFileByPath(event.posterStoragePath);
        } catch (_) {
          // If the Storage file is already missing, keep the event deletion successful.
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.eventDeletedSuccessfully),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unableToDeleteEvent),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<OrganizerProfileInfo?>(
          future: _profileFuture,
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final profile = profileSnapshot.data;

            if (profile == null || profile.organizationName.isEmpty) {
              return _buildMessageState(
                icon: Icons.error_outline_rounded,
                title: l10n.organizerProfileLoadError,
                subtitle: l10n.organizationDetailsMissing,
              );
            }

            return Column(
              children: [
                _buildHeader(context, l10n, profile),
                Expanded(
                  child: StreamBuilder<List<EventModel>>(
                    stream: _controller.getEventsCreatedByOrganizer(
                      profile.uid,
                    ),
                    builder: (context, eventSnapshot) {
                      if (eventSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (eventSnapshot.hasError) {
                        return _buildMessageState(
                          icon: Icons.error_outline_rounded,
                          title: l10n.unableToLoadEvents,
                          subtitle: l10n.tryAgainLater,
                        );
                      }

                      final events = eventSnapshot.data ?? [];

                      if (events.isEmpty) {
                        return _buildEmptyState(l10n, profile);
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 72, 20, 26),
                        itemCount: events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final event = events[index];

                          return EventCard(
                            event: event,
                            onEdit: () => _openEditForm(profile, event),
                            onDelete: () => _deleteEvent(event),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    OrganizerProfileInfo profile,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
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
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.home,
                ),
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
          const SizedBox(height: 26),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.eventDetails,
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
              l10n.manageYourEventInformation,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textWhite.withOpacity(0.88),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Transform.translate(
            offset: const Offset(0, 28),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _openAddForm(profile),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addEvent),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textWhite,
                  elevation: 9,
                  shadowColor: AppColors.shadowDark,
                  textStyle: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    OrganizerProfileInfo profile,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_note_rounded,
                color: AppColors.primary,
                size: 54,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.noEventsYet,
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addFirstEvent,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => _openAddForm(profile),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addEvent),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textWhite,
                  textStyle: AppTextStyles.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.error, size: 46),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(fontSize: 13),
            ),
          ],
        ),
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