class Ticket {
  final String id;
  final String qrData;
  final String userName;
  final String eventId;
  final String eventTitle;
  final String eventDate; // ISO 8601
  final String location;
  final bool isPaid;
  final double price;
  final String purchaseTimestamp; // ISO 8601

  Ticket({
    required this.id,
    required this.qrData,
    required this.userName,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.location,
    required this.isPaid,
    required this.price,
    required this.purchaseTimestamp,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json['id'] as String,
    qrData: json['qrData'] as String,
    userName: json['userName'] as String,
    eventId: json['eventId'] as String,
    eventTitle: json['eventTitle'] as String,
    eventDate: json['eventDate'] as String,
    location: json['location'] as String,
    isPaid: json['isPaid'] as bool,
    price: (json['price'] as num).toDouble(),
    purchaseTimestamp: json['purchaseTimestamp'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'qrData': qrData,
    'userName': userName,
    'eventId': eventId,
    'eventTitle': eventTitle,
    'eventDate': eventDate,
    'location': location,
    'isPaid': isPaid,
    'price': price,
    'purchaseTimestamp': purchaseTimestamp,
  };

  // Convenience constructor for creating a simple ticket; QR data is a serialized string
  static Ticket createSimple({
    required String id,
    required String userName,
    required String eventId,
    required String eventTitle,
    required String eventDate,
    required String location,
    required bool isPaid,
    required double price,
  }) {
    final ts = DateTime.now().toUtc().toIso8601String();
    final qr = 'TICKET|$id|$userName|$eventId|$ts';
    return Ticket(
      id: id,
      qrData: qr,
      userName: userName,
      eventId: eventId,
      eventTitle: eventTitle,
      eventDate: eventDate,
      location: location,
      isPaid: isPaid,
      price: price,
      purchaseTimestamp: ts,
    );
  }
}
