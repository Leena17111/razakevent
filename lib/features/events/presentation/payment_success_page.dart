import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/event_registration_controller.dart';
import 'payment_redirect_stub.dart'
    if (dart.library.html) 'payment_redirect_web.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _event;
  Map<String, dynamic>? _registration;

  @override
  void initState() {
    super.initState();
    _saveAndLoad();
  }

  Map<String, String> _paramsFromUrl() {
    final fragment = Uri.base.fragment;
    final queryIndex = fragment.indexOf('?');

    if (queryIndex != -1) {
      return Uri.splitQueryString(fragment.substring(queryIndex + 1));
    }

    return Uri.base.queryParameters;
  }

  Future<void> _saveAndLoad() async {
    try {
      final params = _paramsFromUrl();
      final eventId = params['eventId'];
      final faculty = params['faculty'] ?? '';

      if (eventId == null || eventId.isEmpty) {
        throw Exception('Missing event ID');
      }

      final ctrl = EventRegistrationController();

      await ctrl.saveWebPaymentRegistration(
        eventId: eventId,
        faculty: faculty,
      );

      final firestore = FirebaseFirestore.instance;
      final uid = ctrl.currentUserId;

      final eventDoc = await firestore.collection('events').doc(eventId).get();

      final regSnap = await firestore
          .collection('eventRegistrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();

      _event = eventDoc.data();
      _registration = regSnap.docs.isNotEmpty ? regSnap.docs.first.data() : {};

      if (mounted) {
        setState(() => _loading = false);
      }

      await Future.delayed(const Duration(seconds: 5));

      redirectToBrowseEvents();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: Center(child: Text(_error!)),
      );
    }

    final eventTitle = _event?['title'] ?? '-';
    final venue = _event?['venue'] ?? '-';
    final name = _registration?['fullName'] ?? '-';
    final matric = _registration?['matricNumber'] ?? '-';

    final eventDateRaw = _event?['eventDateTime'];
    final eventDate = eventDateRaw is Timestamp
        ? DateFormat('d MMM yyyy, h:mm a').format(eventDateRaw.toDate())
        : '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ADE80).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.registeredLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A237E).withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(l10n.eventInfo),
                      const SizedBox(height: 16),
                      _SuccessRow(label: l10n.fullName, value: name),
                      const SizedBox(height: 10),
                      _SuccessRow(label: l10n.studentLabel, value: matric),
                      const Divider(height: 20),
                      _SuccessRow(label: l10n.eventTitle, value: eventTitle),
                      const SizedBox(height: 10),
                      _SuccessRow(label: l10n.dateTimeLabel, value: eventDate),
                      const SizedBox(height: 10),
                      _SuccessRow(label: l10n.venue, value: venue),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.statusApproved,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.paid,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Redirecting to events...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final String label;
  final String value;

  const _SuccessRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ],
    );
  }
}
