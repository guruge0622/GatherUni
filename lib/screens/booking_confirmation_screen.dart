import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2;
import 'package:intl/intl.dart';
import '../src/theme/design_system.dart';
import '../src/shared.dart' as app_shared;
import 'package:qr_flutter/qr_flutter.dart' as qrf;

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bookingId = args != null ? args['bookingId'] as String? : null;
    final appEvent = args != null ? args['event'] as app_shared.Event? : null;
    final quantity = args != null ? args['quantity'] as int? : 1;
    final total = args != null ? args['total'] as num? : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: GatherColors.background,
        foregroundColor: GatherColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: GatherColors.withOpacity(
                        GatherColors.primary,
                        .06,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: GatherColors.withOpacity(
                          GatherColors.success,
                          .14,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: GatherColors.success,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Booking Confirmed!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: GatherColors.primary),
                    ),
                    const SizedBox(height: 8),
                    if (appEvent != null)
                      Text(
                        appEvent.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      )
                    else
                      Text(
                        'Your Event',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 12),
                    if (appEvent != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text('${appEvent.date} • ${appEvent.time}'),
                          const SizedBox(width: 14),
                          const Icon(Icons.location_on_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text(appEvent.location),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 20),

                    // QR card (shows QR if qrData provided)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: GatherColors.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Center(
                              child: args != null && args['qrData'] != null
                                  ? qrf.QrImage(
                                      data: args['qrData'] as String,
                                      version: qrf.QrVersions.auto,
                                      size: 150,
                                    )
                                  : const Icon(
                                      Icons.qr_code_2_outlined,
                                      size: 110,
                                      color: Colors.black54,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Booking ID: ${bookingId ?? '—'}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tickets'),
                              const SizedBox(height: 6),
                              Text(
                                '${quantity ?? 1} x General',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total Paid'),
                              const SizedBox(height: 6),
                              Text(
                                total == null ? '—' : '\$${total.toString()}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: GatherColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Try to build a sensible start/end time from event data
                              DateTime start;
                              try {
                                start = DateFormat('MMMM d, yyyy h:mm a')
                                    .parseLoose(
                                      '${appEvent?.date ?? ''} ${appEvent?.time ?? ''}',
                                    );
                              } catch (_) {
                                try {
                                  start = DateFormat('MMM d, yyyy h:mm a')
                                      .parseLoose(
                                        '${appEvent?.date ?? ''} ${appEvent?.time ?? ''}',
                                      );
                                } catch (_) {
                                  start = DateTime.now().add(
                                    const Duration(days: 1),
                                  );
                                }
                              }
                              final end = start.add(const Duration(hours: 2));

                              final calEvent = add2.Event(
                                title: appEvent?.title ?? 'Event',
                                description: appEvent?.description ?? '',
                                location: appEvent?.location ?? '',
                                startDate: start,
                                endDate: end,
                              );

                              try {
                                await add2.Add2Calendar.addEvent2Cal(calEvent);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to calendar'),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to add calendar event: ${e.toString()}',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: const Text('Add to Calendar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: GatherColors.primary,
                              elevation: 0,
                              side: BorderSide(
                                color: GatherColors.withOpacity(
                                  GatherColors.primary,
                                  .12,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/tickets'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('View My Ticket'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
