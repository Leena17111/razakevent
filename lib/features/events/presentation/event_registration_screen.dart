import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../data/models/event_model.dart';
import '../logic/event_registration_controller.dart';

const List<String> _kFaculties = [
  'Azman Hashim International Business School (AHIBS)',
  'Faculty of Built Environment and Surveying',
  'Faculty of Chemical and Energy Engineering',
  'Faculty of Computing',
  'Faculty of Educational Sciences and Technology (FEST)',
  'Faculty of Electrical Engineering',
  'Faculty of Management',
  'Faculty of Mechanical Engineering',
  'Faculty of Civil Engineering',
  'Faculty of Science',
  'Faculty of Social Sciences and Humanities',
  'Malaysia-Japan International Institute of Technology (MJIIT)',
];

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState
    extends State<EventRegistrationScreen> {
  late final EventRegistrationController _ctrl;
  late final EventModel _event;
  bool _eventLoaded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = EventRegistrationController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_eventLoaded) {
      _event =
          ModalRoute.of(context)!.settings.arguments as EventModel;
      _eventLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ctrl.loadUserProfile();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isFree => _event.registrationFee <= 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EventRegistrationController>.value(
      value: _ctrl,
      child: Consumer<EventRegistrationController>(
        builder: (context, ctrl, _) {
          final isEn =
              Localizations.localeOf(context).languageCode == 'en';

          if (ctrl.step == RegistrationStep.success) {
            return _SuccessScreen(
                event: _event, ctrl: ctrl, isEn: isEn);
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Column(
              children: [
                _Header(
                  event: _event,
                  ctrl: ctrl,
                  isEn: isEn,
                  isFree: _isFree,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    child: Column(
                      children: [
                        if (ctrl.errorMessage != null) ...[
                          _ErrorBanner(
                            message: ctrl.errorMessage!,
                            onDismiss: ctrl.clearError,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (ctrl.step == RegistrationStep.form)
                          _FormStep(
                            event: _event,
                            ctrl: ctrl,
                            isEn: isEn,
                            isFree: _isFree,
                          )
                        else
                          _PaymentStep(
                            event: _event,
                            ctrl: ctrl,
                            isEn: isEn,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final EventModel event;
  final EventRegistrationController ctrl;
  final bool isEn;
  final bool isFree;

  const _Header({
    required this.event,
    required this.ctrl,
    required this.isEn,
    required this.isFree,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E),
            Color(0xFF283593),
            Color(0xFF3949AB),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (ctrl.step == RegistrationStep.payment) {
                        ctrl.goBackToForm();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        _langBtn(context, 'EN', isEn),
                        _langBtn(context, 'BM', isEn),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                isEn ? 'Register for Event' : 'Daftar untuk Acara',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                event.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isFree) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: ctrl.step == RegistrationStep.payment
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _langBtn(BuildContext context, String label, bool isEn) {
    final active =
        (label == 'EN' && isEn) || (label == 'BM' && !isEn);
    return GestureDetector(
      onTap: () => localeController.value =
          Locale(label == 'EN' ? 'en' : 'ms'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: active ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Form Step ─────────────────────────────────────────────────────────────────

class _FormStep extends StatefulWidget {
  final EventModel event;
  final EventRegistrationController ctrl;
  final bool isEn;
  final bool isFree;

  const _FormStep({
    required this.event,
    required this.ctrl,
    required this.isEn,
    required this.isFree,
  });

  @override
  State<_FormStep> createState() => _FormStepState();
}

class _FormStepState extends State<_FormStep> {
  bool _facultyOpen = false;

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final isEn = widget.isEn;

    return Column(
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(
                  isEn ? 'YOUR INFORMATION' : 'MAKLUMAT ANDA'),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.lock_outline,
                      size: 12, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(
                    isEn
                        ? 'Auto-filled from your profile'
                        : 'Diisi secara automatik dari profil anda',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ReadOnlyField(
                label: isEn ? 'Full Name' : 'Nama Penuh',
                value: ctrl.userName,
              ),
              const SizedBox(height: 12),
              _ReadOnlyField(
                label: isEn ? 'Matric Number' : 'Nombor Matrik',
                value: ctrl.userMatric,
              ),
              const SizedBox(height: 12),
              _ReadOnlyField(
                label: isEn ? 'Phone Number' : 'Nombor Telefon',
                value: ctrl.userPhone,
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? 'Faculty' : 'Fakulti',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () =>
                    setState(() => _facultyOpen = !_facultyOpen),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ctrl.fieldErrors.containsKey('faculty')
                          ? Colors.red
                          : ctrl.selectedFaculty.isNotEmpty
                              ? AppColors.primary.withOpacity(0.3)
                              : Colors.transparent,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          ctrl.selectedFaculty.isEmpty
                              ? (isEn
                                  ? 'Select your faculty'
                                  : 'Pilih fakulti anda')
                              : ctrl.selectedFaculty,
                          style: TextStyle(
                            fontSize: 13,
                            color: ctrl.selectedFaculty.isEmpty
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF1C1C1E),
                            fontWeight: ctrl.selectedFaculty.isNotEmpty
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _facultyOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF6B7280), size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              if (_facultyOpen) ...[
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _kFaculties.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final f = _kFaculties[i];
                      final selected = ctrl.selectedFaculty == f;
                      return InkWell(
                        onTap: () {
                          ctrl.setFaculty(f);
                          setState(() => _facultyOpen = false);
                        },
                        child: Container(
                          color: selected
                              ? const Color(0xFFE8EAF6)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? AppColors.primary
                                  : const Color(0xFF1C1C1E),
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (ctrl.fieldErrors.containsKey('faculty')) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 13, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      ctrl.fieldErrors['faculty']!,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PrimaryButton(
          label: widget.isFree
              ? (isEn ? 'Register Now' : 'Daftar Sekarang')
              : (isEn
                  ? 'Continue to Payment'
                  : 'Teruskan ke Pembayaran'),
          isLoading: ctrl.isLoading,
          onPressed: () => ctrl.proceedFromForm(
            isFreeEvent: widget.isFree,
            isEn: isEn,
            eventId: widget.event.eventId,
          ),
        ),
      ],
    );
  }
}

// ── Payment Step ──────────────────────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  final EventModel event;
  final EventRegistrationController ctrl;
  final bool isEn;

  const _PaymentStep({
    required this.event,
    required this.ctrl,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final fee = event.registrationFee;
    final deadline = event.registrationDeadline != null
        ? DateFormat('d MMM yyyy').format(event.registrationDeadline!)
        : '-';

    return Column(
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(isEn ? 'PAYMENT' : 'PEMBAYARAN'),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEn
                                ? 'Registration Fee'
                                : 'Yuran Pendaftaran',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11),
                          ),
                          Text(
                            'RM ${fee.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isEn ? 'Deadline' : 'Tarikh Akhir',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11),
                        ),
                        Text(
                          deadline,
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEn
                            ? 'Payment must be completed before the registration deadline.'
                            : 'Pembayaran mesti diselesaikan sebelum tarikh akhir pendaftaran.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF635BFF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text('S',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Stripe',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF1C1C1E))),
                        const Spacer(),
                        const Icon(Icons.lock_outline,
                            size: 14, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEn
                          ? 'You will be redirected to Stripe to complete your payment securely.'
                          : 'Anda akan diarahkan ke Stripe untuk menyelesaikan pembayaran anda dengan selamat.',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  isEn ? 'Secured by Stripe' : 'Dilindungi oleh Stripe',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PrimaryButton(
          label: ctrl.isLoading
              ? (isEn ? 'Processing...' : 'Memproses...')
              : '${isEn ? 'Pay with Stripe' : 'Bayar dengan Stripe'} — RM ${fee.toStringAsFixed(2)}',
          isLoading: ctrl.isLoading,
          icon: Icons.credit_card,
          onPressed: () =>
              ctrl.initiateStripePayment(eventId: event.eventId),
        ),
      ],
    );
  }
}

// ── Success Screen ────────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  final EventModel event;
  final EventRegistrationController ctrl;
  final bool isEn;

  const _SuccessScreen({
    required this.event,
    required this.ctrl,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = event.registrationFee <= 0;

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
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 48),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isEn
                      ? 'Registration Successful!'
                      : 'Pendaftaran Berjaya!',
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
                      _SectionLabel(isEn
                          ? 'REGISTRATION INFORMATION'
                          : 'MAKLUMAT PENDAFTARAN'),
                      const SizedBox(height: 16),
                      _SuccessRow(
                          label: isEn ? 'Name' : 'Nama',
                          value: ctrl.userName),
                      const SizedBox(height: 10),
                      _SuccessRow(
                          label: isEn ? 'Matric No.' : 'No. Matrik',
                          value: ctrl.userMatric),
                      const Divider(height: 20),
                      _SuccessRow(
                          label: isEn ? 'Event' : 'Acara',
                          value: event.title),
                      const SizedBox(height: 10),
                      _SuccessRow(
                        label: isEn ? 'Date' : 'Tarikh',
                        value: DateFormat('d MMM yyyy, h:mm a')
                            .format(event.eventDateTime),
                      ),
                      const SizedBox(height: 10),
                      _SuccessRow(
                          label: isEn ? 'Venue' : 'Tempat',
                          value: event.venue),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEn
                                ? 'Payment Status'
                                : 'Status Pembayaran',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: isFree
                                  ? const Color(0xFFDBEAFE)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isFree
                                  ? (isEn ? 'Free' : 'Percuma')
                                  : (isEn ? 'Paid' : 'Dibayar'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isFree
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isEn ? 'Back to Events' : 'Kembali ke Acara',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
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

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
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

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.lock_outline,
                  size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final String label;
  final String value;
  const _SuccessRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF6B7280))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E))),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final IconData? icon;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC8102E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: const Color(0xFFC8102E).withOpacity(0.4),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner(
      {required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFDC2626), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: Color(0xFFDC2626), fontSize: 12)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close,
                color: Color(0xFFDC2626), size: 16),
          ),
        ],
      ),
    );
  }
}