import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No events'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final title = d['title'] ?? '';
              final desc = d['description'] ?? '';
              return ListTile(title: Text(title), subtitle: Text(desc));
            },
          );
        },
      ),
    );
  }
}
