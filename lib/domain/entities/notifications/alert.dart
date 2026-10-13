import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? route;
  final bool read;
  final Timestamp? createdAt;

  const Alert({
    required this.id,
    required this.title,
    this.body = '',
    this.type = 'general',
    this.route,
    this.read = false,
    this.createdAt,
  });

  factory Alert.fromMap(String id, Map<String, dynamic> map) {
    return Alert(
      id: id,
      title: (map['title'] ?? 'Aviso').toString(),
      body: (map['body'] ?? '').toString(),
      type: (map['type'] ?? 'general').toString(),
      route: map['route']?.toString(),
      read: map['read'] == true,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
