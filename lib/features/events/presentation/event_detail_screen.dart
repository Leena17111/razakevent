import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/event_model.dart';
import '../../../l10n/app_localizations.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event =
        ModalRoute.of(context)!.settings.arguments as EventModel;
    final l10n = AppLocalizations.of(context)!;
    final isBM = Localizations.localeOf(context).languageCode == 'ms';
    final categoryColor = _getCategoryColor(event.category);
    final isFull = event.participantCapacity != null &&
        event.registeredCount >= event.participantCapacity!;
    final isDeadlinePassed = event.registrationDeadline != null &&
        event.registrationDeadline!.isBefore(DateTime.now());
    final canRegister = !isFull && !isDeadlinePassed;
    final isFree = event.registrationFee == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(
                  context, event, l10n, isBM, categoryColor),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(event, l10n)
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: 0.1),
                      const SizedBox(height: 14),
                      _buildAboutCard(event, l10n)
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1),
                      const SizedBox(height: 14),
                      _buildFeeCard(event, l10n, isFull,
                              isDeadlinePassed, isFree)
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildRegisterButton(context, event, l10n,
                    canRegister, isFull, isDeadlinePassed)
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.3),
          ),
        ],
      ),
    );
  }

  // ── Sliver App Bar ────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(
    BuildContext context,
    EventModel event,
    AppLocalizations l10n,
    bool isBM,
    Map<String, Color> categoryColor,
  ) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back,
              color: Colors.white, size: 20),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(2),
          child: Row(
            children: [
              _langButton(isBM, 'EN'),
              _langButton(isBM, 'BM'),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ── Poster: Hero wraps only the image, not the entire stack ──
            // FIX: alignment topCenter so portrait posters crop from the
            // bottom instead of slicing through the middle of the subject.
            Hero(
              tag: 'event-poster-${event.eventId}',
              child: _buildPosterImage(event),
            ),

            // ── Gradient: bottom-heavy so it darkens just the text zone ──
            // FIX: reduced opacity (0.7 → 0.55) and starts later (0.45)
            // so it doesn't wash the whole image in darkness.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),

            // ── Category + title at bottom ──
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryColor['bg'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: categoryColor['text'],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Poster ────────────────────────────────────────────────────────────────────
  // FIX: alignment: Alignment.topCenter — crops from the bottom of portrait
  // posters rather than the center, keeping faces and titles visible.
  // The image now fills its parent via width/height: double.infinity so
  // StackFit.expand on the parent doesn't need to stretch it unnaturally.

  Widget _buildPosterImage(EventModel event) {
    final url = event.posterUrl.trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter, // ← KEY FIX
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _posterPlaceholder(),
      );
    }
    return _posterPlaceholder();
  }

  Widget _posterPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: Center(
        child: Icon(Icons.event,
            size: 60, color: AppColors.primary.withOpacity(0.3)),
      ),
    );
  }

  Widget _langButton(bool isBM, String label) {
    final isActive =
        (label == 'BM' && isBM) || (label == 'EN' && !isBM);
    return GestureDetector(
      onTap: () =>
          localeController.value = Locale(label == 'EN' ? 'en' : 'ms'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────────

  Widget _buildInfoCard(EventModel event, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.person_outline, l10n.organizerLabel,
              event.organizationName),
          const Divider(height: 16),
          _infoRow(
            Icons.calendar_today_outlined,
            l10n.dateTimeLabel,
            DateFormat('EEEE, d MMMM yyyy • h:mm a')
                .format(event.eventDateTime),
          ),
          const Divider(height: 16),
          _infoRow(Icons.location_on_outlined, l10n.venueLabel,
              event.venue),
          if (event.participantCapacity != null) ...[
            const Divider(height: 16),
            _infoRow(
              Icons.people_outline,
              l10n.capacityLabel,
              '${event.registeredCount} / ${event.participantCapacity} ${l10n.registeredCount}',
            ),
          ],
          if (event.contactPerson.isNotEmpty) ...[
            const Divider(height: 16),
            _infoRow(Icons.phone_outlined, l10n.contactLabel,
                event.contactPerson),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // ── About Card ────────────────────────────────────────────────────────────────

  Widget _buildAboutCard(EventModel event, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.aboutEvent,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 8),
          Text(
            event.description.isNotEmpty ? event.description : '-',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Fee Card ──────────────────────────────────────────────────────────────────

  Widget _buildFeeCard(
    EventModel event,
    AppLocalizations l10n,
    bool isFull,
    bool isDeadlinePassed,
    bool isFree,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.registrationFeeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )),
              Text(
                isFree
                    ? l10n.freeEvent
                    : 'RM ${event.registrationFee.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFree
                      ? Colors.green.shade600
                      : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          if (event.registrationDeadline != null) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.registrationDeadlineLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )),
                Text(
                  DateFormat('d MMM yyyy')
                      .format(event.registrationDeadline!),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDeadlinePassed
                        ? Colors.grey
                        : const Color(0xFFC8102E),
                  ),
                ),
              ],
            ),
          ],
          if (isFull || isDeadlinePassed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(Icons.info_outline,
                    size: 14, color: Colors.red.shade400),
                const SizedBox(width: 8),
                Text(
                  isFull
                      ? l10n.eventFullMessage
                      : l10n.registrationClosed,
                  style: TextStyle(
                      fontSize: 11, color: Colors.red.shade600),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  // ── Register Button ───────────────────────────────────────────────────────────

  Widget _buildRegisterButton(
    BuildContext context,
    EventModel event,
    AppLocalizations l10n,
    bool canRegister,
    bool isFull,
    bool isDeadlinePassed,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canRegister
              ? () => Navigator.pushNamed(
                    context,
                    AppRoutes.registerEvent,
                    arguments: event,
                  )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canRegister
                ? const Color(0xFFC8102E)
                : Colors.grey.shade300,
            foregroundColor: Colors.white,
            elevation: canRegister ? 4 : 0,
            shadowColor: const Color(0xFFC8102E).withOpacity(0.4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            isFull
                ? l10n.eventFullMessage
                : isDeadlinePassed
                    ? l10n.registrationClosed
                    : l10n.registerNow,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Map<String, Color> _getCategoryColor(String category) {
    const colors = {
      'Sports': {'bg': Color(0xFFDBEAFE), 'text': Color(0xFF1D4ED8)},
      'Academic': {'bg': Color(0xFFD1FAE5), 'text': Color(0xFF059669)},
      'Spiritual': {'bg': Color(0xFFE0E7FF), 'text': Color(0xFF6366F1)},
      'Welfare': {'bg': Color(0xFFFCE7F3), 'text': Color(0xFFDB2777)},
      'Entrepreneurship': {
        'bg': Color(0xFFFEF3C7),
        'text': Color(0xFFD97706),
      },
      'Culture': {'bg': Color(0xFFEDE9FE), 'text': Color(0xFF7C3AED)},
      'Arts & Media': {
        'bg': Color(0xFFFFE4E6),
        'text': Color(0xFFE11D48),
      },
      'Food': {'bg': Color(0xFFD1FAE5), 'text': Color(0xFF10B981)},
      'Safety': {'bg': Color(0xFFFEE2E2), 'text': Color(0xFFDC2626)},
      'Others': {'bg': Color(0xFFF5F6FA), 'text': Color(0xFF6B7280)},
    };
    return {
      'bg': colors[category]?['bg'] ?? const Color(0xFFF5F6FA),
      'text': colors[category]?['text'] ?? const Color(0xFF6B7280),
    };
  }
}