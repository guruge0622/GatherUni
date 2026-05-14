import 'package:flutter/material.dart';
import 'package:my_app/src/models/ticket.dart';
import 'package:my_app/src/services/ticket_loader.dart';

class SampleTicketsScreen extends StatefulWidget {
  const SampleTicketsScreen({Key? key}) : super(key: key);

  @override
  State<SampleTicketsScreen> createState() => _SampleTicketsScreenState();
}

class _SampleTicketsScreenState extends State<SampleTicketsScreen> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = TicketLoader.loadFromAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample Tickets')),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty)
            return const Center(child: Text('No sample tickets found'));
          return ListView.separated(
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = tickets[i];
              return ListTile(
                title: Text(t.eventTitle),
                subtitle: Text(
                  '${t.userName} • ${t.eventDate} • ${t.location}',
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      t.isPaid ? 'Paid' : 'Free',
                      style: TextStyle(
                        color: t.isPaid ? Colors.green : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('ID: ${t.id}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Ticket ${t.id}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${t.userName}'),
                        Text('Event: ${t.eventTitle}'),
                        Text('Date: ${t.eventDate}'),
                        const SizedBox(height: 8),
                        Text('QR data:'),
                        SelectableText(t.qrData),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
