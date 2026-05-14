import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';
import '../src/backend/firebase_service.dart';
import 'package:qr_flutter/qr_flutter.dart' as qrf;
import 'dart:convert';

enum PaymentMethod { card, qr }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;
  PaymentMethod _method = PaymentMethod.card;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final event = args != null ? args['event'] as Event? : null;
    final quantity = args != null ? args['quantity'] as int? : null;
    final count = quantity ?? 1;
    final total = (event?.price ?? 0) * count;

    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          if (event != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE6ECF6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: event.colors),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.event_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: GatherColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$count ticket(s)',
                          style: const TextStyle(
                            color: GatherColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    total == 0 ? 'Free' : '\$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: GatherColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Payment method selector
          Row(
            children: [
              ChoiceChip(
                label: const Text('Card'),
                selected: _method == PaymentMethod.card,
                onSelected: (_) => setState(() => _method = PaymentMethod.card),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('QR'),
                selected: _method == PaymentMethod.qr,
                onSelected: (_) => setState(() => _method = PaymentMethod.qr),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE6ECF6)),
            ),
            child: _method == PaymentMethod.card
                ? const Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Card number',
                          prefixIcon: Icon(Icons.credit_card_rounded),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(labelText: 'MM/YY'),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(labelText: 'CVC'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Name on card',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                    ],
                  )
                : // QR view
                  Center(
                    child: Column(
                      children: [
                        const Text('Scan this QR to pay'),
                        const SizedBox(height: 12),
                        Container(
                          width: 180,
                          height: 180,
                          color: Colors.white,
                          child: qrf.QrImage(
                            data: _buildQrData(event, count, total),
                            version: qrf.QrVersions.auto,
                            gapless: false,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(_buildQrData(event, count, total)),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (event == null) return;
                      setState(() => _loading = true);
                      final user = FirebaseService.instance.currentUser;
                      if (user == null) {
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please sign in to continue'),
                          ),
                        );
                        return;
                      }

                      try {
                        final bookingRef = await FirebaseService.instance
                            .createBookingTransactional(
                              eventId: event.id,
                              userId: user.uid,
                            );
                        final qrData = _method == PaymentMethod.qr
                            ? _buildQrData(event, count, total)
                            : null;
                        if (!mounted) return;
                        Navigator.of(context).pushReplacementNamed(
                          '/booking-confirmation',
                          arguments: {
                            'bookingId': bookingRef.id,
                            'event': event,
                            'quantity': count,
                            'total': total,
                            if (qrData != null) 'qrData': qrData,
                          },
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking failed: ${e.toString()}'),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: GatherColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(total == 0 ? 'Confirm Booking' : 'Pay Now'),
            ),
          ),
        ],
      ),
    );
  }

  String _buildQrData(Event? event, int count, num total) {
    final payload = {
      'type': 'gatheruni_payment',
      'eventId': event?.id,
      'title': event?.title,
      'quantity': count,
      'total': total,
      'ts': DateTime.now().toIso8601String(),
    };
    return jsonEncode(payload);
  }
}
