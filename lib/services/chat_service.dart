import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../src/shared.dart';

class ChatService {
  final String? _apiKey = dotenv.env['OPENAI_API_KEY'];

  ChatService();

  Future<List<Event>> _fetchEvents(int limit) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .orderBy('date')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      // price may be int or double in Firestore
      double price = 0.0;
      if (data['price'] != null) {
        if (data['price'] is int) price = (data['price'] as int).toDouble();
        if (data['price'] is double) price = data['price'] as double;
        if (data['price'] is String) {
          price = double.tryParse(data['price'] as String) ?? 0.0;
        }
      }

      final List<Color> cols =
          (data['colors'] as List?)
              ?.map((c) {
                try {
                  return Color(int.parse(c.toString()));
                } catch (_) {
                  // fallback for numeric values
                  return Color((c as int));
                }
              })
              .cast<Color>()
              .toList() ??
          [AppColors.primaryBlue, AppColors.lightBlue];

      return Event(
        id: doc.id,
        title: (data['title'] ?? '') as String,
        date: (data['date'] ?? '') as String,
        time: (data['time'] ?? '') as String,
        location: (data['location'] ?? '') as String,
        category: (data['category'] ?? '') as String,
        price: price,
        description: (data['description'] ?? '') as String,
        bookings: (data['bookings'] ?? 0) as int,
        colors: cols,
      );
    }).toList();
  }

  Future<String> sendMessage(
    String message, {
    bool includeEvents = false,
    int eventsLimit = 10,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OPENAI_API_KEY not set in environment');
    }

    String systemPrompt =
        'You are an AI assistant for a university event app called GatherUni. Help users find events, recommend events, and answer questions.';

    final List<Map<String, String>> messages = [
      {'role': 'system', 'content': systemPrompt},
    ];

    if (includeEvents) {
      final events = await _fetchEvents(eventsLimit);
      final buffer = StringBuffer();
      buffer.writeln('Events:');
      for (var i = 0; i < events.length; i++) {
        final e = events[i];
        buffer.writeln(
          '${i + 1}. ${e.title} - ${e.date} ${e.time} - ${e.location} - ${e.category} - bookings:${e.bookings}',
        );
      }

      messages.add({'role': 'system', 'content': buffer.toString()});
    }

    messages.add({'role': 'user', 'content': message});

    final resp = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${_apiKey!}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': messages,
        'temperature': 0.2,
        'max_tokens': 600,
      }),
    );

    if (resp.statusCode >= 400) {
      throw Exception('OpenAI API error: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return '';
    final content = choices[0]['message']?['content'] as String? ?? '';
    return content.trim();
  }
}
