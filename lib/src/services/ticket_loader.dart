import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:my_app/src/models/ticket.dart';

class TicketLoader {
  static Future<List<Ticket>> loadFromAssets() async {
    final jsonStr = await rootBundle.loadString('assets/sample_tickets.json');
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    final list = (map['tickets'] as List<dynamic>?) ?? [];
    return list.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
  }
}
