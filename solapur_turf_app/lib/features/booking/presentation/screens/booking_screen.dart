import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../turf/domain/entities/turf_listing.dart';
import '../../../turf/presentation/providers/turf_provider.dart';
import '../../domain/entities/booking.dart';
import '../providers/booking_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String turfId;
  const BookingScreen({super.key, required this.turfId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<AvailabilitySlot> _selectedSlots = [];
  PaymentMethod _paymentMethod = PaymentMethod.fullOnline;
  late final Razorpay _razorpay;
  String? _pendingBookingId;
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  String get _dateString => DateFormat('yyyy-MM-dd').format(_selectedDate);

  double get _totalAmount {
    if (_selectedSlots.isEmpty) return 0;
    final turfAsync = ref.read(turfDetailProvider(widget.turfId));
    final rate = turfAsync.valueOrNull?.hourlyRate ?? 0;
    return rate * _selectedSlots.length; 
  }

  void _openRazorpay(CreateBookingResult result) {
    _pendingBookingId = result.bookingId;
    _pendingOrderId = result.razorpayOrderId;
    _razorpay.open({
      'key': AppConstants.razorpayKeyId,
      'amount': (result.onlineAmount * 100).toInt(), 
      'name': AppConstants.razorpayAppName,
      'description': 'Turf Booking',
      'order_id': result.razorpayOrderId,
      'currency': result.currency,
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#0E7C61'}, // Deep Green Primary
    });
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    if (_pendingBookingId == null) return;
    ref.read(bookingNotifierProvider.notifier).verifyPayment(
          bookingId: _pendingBookingId!,
          paymentId: response.paymentId ?? '',
          signature: response.signature ?? '',
          orderId: response.orderId ?? '',
        );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (_pendingOrderId != null) {
      ref.read(bookingNotifierProvider.notifier).reportPaymentFailure(
        orderId: _pendingOrderId!,
        paymentId: '', 
        errorCode: response.code.toString(),
        errorMessage: response.message ?? 'Payment failed',
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {}

  Future<void> _confirmBooking() async {
    if (_selectedSlots.isEmpty) return;
    HapticFeedback.mediumImpact();
    // Sort slots by time
    _selectedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Check for gaps (Item #27)
    for (int i = 0; i < _selectedSlots.length - 1; i++) {
      final current = AppFormatters.parseTimeString(_selectedSlots[i].endTime);
      final next = AppFormatters.parseTimeString(_selectedSlots[i+1].startTime);
      if (current != next) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select consecutive time slots (no gaps).'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final startTime = _selectedSlots.first.startTime;
    final endTime = _selectedSlots.last.endTime;

    await ref.read(bookingNotifierProvider.notifier).createBooking(
          turfId: widget.turfId,
          bookingDate: _dateString,
          startTime: startTime,
          endTime: endTime,
          paymentMethod: _paymentMethod.apiValue,
        );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    ref.listen(bookingNotifierProvider, (_, next) {
      next.mapOrNull(
        awaitingPayment: (s) => _openRazorpay(s.result),
        success: (s) {
          // Invalidate both providers so the slot grid and bookings list refresh
          ref.invalidate(myBookingsProvider);
          ref.invalidate(
            availableSlotsProvider(turfId: widget.turfId, date: _dateString),
          );
          setState(() => _selectedSlots.clear());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking confirmed! 🎉'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/user/booking-confirmation', extra: s.booking);
        },
        error: (e) {
          final msg = e.message.contains('Overlap') || e.message.contains('already booked')
              ? 'That slot is already booked. Please choose a different time.'
              : e.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    final turfAsync = ref.watch(turfDetailProvider(widget.turfId));
    final slotsAsync = ref.watch(
      availableSlotsProvider(turfId: widget.turfId, date: _dateString),
    );
    final bookingState = ref.watch(bookingNotifierProvider);
    final isLoading = bookingState.maybeMap(
      creating: (_) => true,
      verifying: (_) => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        centerTitle: true,
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: turfAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => AppErrorWidget(
          message: e is Failure ? e.userMessage : e.toString(),
        ),
        data: (turf) => SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini Context Card 
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.dividerLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: turf.imageUrls?.isNotEmpty == true
                                    ? DecorationImage(
                                        image: NetworkImage(turf.imageUrls!.first),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: AppColors.primaryContainer,
                              ),
                              child: turf.imageUrls?.isEmpty ?? true
                                  ? const Icon(Icons.sports_soccer, color: AppColors.primary)
                                  : null,
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    turf.turfName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Gap(4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondaryLight),
                                      const Gap(4),
                                      Expanded(
                                        child: Text(
                                          '${turf.city}, ${turf.state}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                
                      const Gap(32),
                
                      // ── Step 1: Date ─────────────────────────────────────────────
                      const _SectionHeader(
                        number: '1',
                        title: 'Select Date',
                      ),
                      const Gap(16),
                      _DatePicker(
                        selected: _selectedDate,
                        onChanged: (d) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedDate = d;
                            _selectedSlots.clear();
                          });
                        },
                      ),
                
                      const Gap(32),
                
                      // ── Step 2: Slots ─────────────────────────────────────────────
                      const _SectionHeader(
                        number: '2',
                        title: 'Select Time Slots',
                      ),
                      const Gap(16),
                      slotsAsync.when(
                        loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            )),
                        error: (e, _) => AppErrorWidget(
                          message: 'Could not load slots',
                          onRetry: () => ref.invalidate(
                            availableSlotsProvider(
                                turfId: widget.turfId, date: _dateString),
                          ),
                        ),
                        data: (slots) => slots.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.dividerLight),
                                ),
                                child: const Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.event_busy, size: 48, color: AppColors.textHint),
                                      Gap(16),
                                      Text('No slots available', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                                      Text('Please try another date', style: TextStyle(color: AppColors.textSecondaryLight)),
                                    ],
                                  ),
                                ),
                              )
                            : _SlotGrid(
                                slots: slots,
                                selectedSlots: _selectedSlots,
                                onToggle: (slot) {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    if (_selectedSlots.contains(slot)) {
                                      _selectedSlots.remove(slot);
                                    } else {
                                      _selectedSlots.add(slot);
                                    }
                                  });
                                },
                              ),
                      ),
                
                      const Gap(32),
                
                      // ── Step 3: Payment Method ────────────────────────────────────
                      const _SectionHeader(
                        number: '3',
                        title: 'Payment Method',
                      ),
                      const Gap(16),
                      _PaymentMethodSelector(
                        selected: _paymentMethod,
                        onChanged: (pm) {
                          HapticFeedback.selectionClick();
                          setState(() => _paymentMethod = pm);
                        },
                        totalAmount: _totalAmount,
                      ),
                
                      const Gap(32),
                
                      // ── Summary Header ──
                      if (_selectedSlots.isNotEmpty) ...[
                        const Text(
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const Gap(16),
                        _CheckoutReceipt(
                          turf: turf,
                          date: _selectedDate,
                          slots: _selectedSlots,
                          paymentMethod: _paymentMethod,
                          totalAmount: _totalAmount,
                        ),
                      ],
                      const Gap(100), // Scrolling padding
                    ],
                  ),
                ),
              ),

              // ── Sticky Confirmation Bar ──
              if (_selectedSlots.isNotEmpty)
                PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    if (didPop) return;
                    final bool? exit = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Booking?'),
                        content: const Text('Are you sure you want to exit? Your progress will be lost and the slot will be released.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('CONTINUE'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('YES, EXIT'),
                          ),
                        ],
                      ),
                    );
                    if (exit == true) {
                      if (_pendingBookingId != null) {
                        await ref.read(bookingNotifierProvider.notifier).cancelBooking(_pendingBookingId!);
                      }
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        )
                      ],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _paymentMethod == PaymentMethod.partialOnlineCash 
                                ? 'Pay Now (${AppFormatters.formatCurrency(AppConstants.cashBookingAdvanceAmount)})' 
                                : (_paymentMethod == PaymentMethod.cashOnBooking ? 'Pay at Venue' : 'Total Amount'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(
                              _paymentMethod == PaymentMethod.partialOnlineCash
                                  ? AppConstants.cashBookingAdvanceAmount
                                  : (_paymentMethod == PaymentMethod.cashOnBooking ? 0.0 : _totalAmount),
                            ),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          if (_paymentMethod != PaymentMethod.fullOnline)
                            Text(
                              'Total: ${AppFormatters.formatCurrency(_totalAmount)}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                            ),
                        ],
                      ),
                      const Gap(24),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _confirmBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading 
                            ? const SizedBox(
                                height: 24, 
                                width: 24, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Proceed to Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Gap(8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared UI Widgets ──

class _SectionHeader extends StatelessWidget {
  final String number;
  final String title;

  const _SectionHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const Gap(12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  const _DatePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
    return SizedBox(
      height: 90,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (_, i) {
          final day = days[i];
          final isSelected = DateFormat('yyyy-MM-dd').format(day) ==
              DateFormat('yyyy-MM-dd').format(selected);
              
          return GestureDetector(
            onTap: () => onChanged(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.dividerLight,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    DateFormat('MMM').format(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: isSelected ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    DateFormat('d').format(day),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    DateFormat('EEE').format(day),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  final List<AvailabilitySlot> slots;
  final List<AvailabilitySlot> selectedSlots;
  final ValueChanged<AvailabilitySlot> onToggle;

  const _SlotGrid({
    required this.slots,
    required this.selectedSlots,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final slot = slots[i];
        final isSelected = selectedSlots.contains(slot);
        final isBooked = !slot.isAvailable;

        return GestureDetector(
          onTap: isBooked ? null : () => onToggle(slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.grey.withOpacity(0.05)
                  : isSelected
                      ? AppColors.primary
                      : AppColors.surfaceLight,
              border: Border.all(
                color: isBooked
                    ? AppColors.dividerLight.withOpacity(0.5)
                    : isSelected
                        ? AppColors.primary
                        : AppColors.dividerLight,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                if (isBooked)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(Icons.lock_outline, size: 12, color: AppColors.textHint.withOpacity(0.5)),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppFormatters.formatTimeString(slot.startTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: isBooked
                              ? AppColors.textHint
                              : isSelected
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                          decoration: isBooked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        '1 Hour',
                        style: TextStyle(
                          fontSize: 10,
                          color: isBooked
                              ? AppColors.textHint.withOpacity(0.3)
                              : isSelected
                                  ? Colors.white70
                                  : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;
  final double totalAmount;

  const _PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final methods = [
      PaymentMethod.fullOnline,
      PaymentMethod.partialOnlineCash,
      PaymentMethod.cashOnBooking,
    ];

    return Column(
      children: methods.map((pm) {
        final isSelected = selected == pm;
        final advanceAmount = pm == PaymentMethod.partialOnlineCash
            ? AppConstants.cashBookingAdvanceAmount
            : (pm == PaymentMethod.cashOnBooking ? 0.0 : totalAmount);

        return GestureDetector(
          onTap: () => onChanged(pm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer.withOpacity(0.5) : AppColors.surfaceLight,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.dividerLight,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textHint,
                      width: isSelected ? 6 : 2,
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pm.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        totalAmount > 0 
                            ? 'Pay ${AppFormatters.formatCurrency(advanceAmount)} now to reserve'
                            : 'Select slots to see pricing',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CheckoutReceipt extends StatelessWidget {
  final TurfListing turf;
  final DateTime date;
  final List<AvailabilitySlot> slots;
  final PaymentMethod paymentMethod;
  final double totalAmount;

  const _CheckoutReceipt({
    required this.turf,
    required this.date,
    required this.slots,
    required this.paymentMethod,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final onlineAmount =
        paymentMethod == PaymentMethod.partialOnlineCash
            ? 50.0
            : (paymentMethod == PaymentMethod.cashOnBooking ? 0.0 : totalAmount);
    final cashAmount = totalAmount - onlineAmount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ReceiptRow(label: 'Date', value: AppFormatters.formatDate(date)),
                const Gap(12),
                _ReceiptRow(label: 'Duration', value: '${slots.length} Hours'),
                const Gap(12),
                _ReceiptRow(label: 'Base Rate', value: '${AppFormatters.formatCurrency(turf.hourlyRate)} / hr'),
                
                const Gap(16),
                const Divider(color: AppColors.dividerLight),
                const Gap(16),
                
                _ReceiptRow(label: 'Total Required Setup', value: AppFormatters.formatCurrency(totalAmount), bold: true),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'To Pay Now', 
                  value: AppFormatters.formatCurrency(onlineAmount),
                  color: AppColors.primaryDark,
                  bold: true,
                  valueSize: 18,
                ),
                if (cashAmount > 0) ...[
                  const Gap(8),
                  _ReceiptRow(
                    label: 'Pay at Venue', 
                    value: AppFormatters.formatCurrency(cashAmount),
                    color: AppColors.textSecondaryLight,
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  final double valueSize;

  const _ReceiptRow({
    required this.label, 
    required this.value,
    this.bold = false, 
    this.color,
    this.valueSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
