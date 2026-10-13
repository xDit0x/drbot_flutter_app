import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/domain/entities/notifications/alert.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Inicia sesión para ver tus alertas.'));
    }

    final alertsRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('alerts');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: alertsRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('No se pudieron cargar tus alertas: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = snapshot.data!.docs
            .map((doc) => Alert.fromMap(doc.id, doc.data()))
            .toList();

        if (alerts.isEmpty) {
          return const Center(child: Text('No tienes alertas'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: alerts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return Dismissible(
              key: ValueKey(alert.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => alertsRef.doc(alert.id).delete(),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: Icon(
                  alert.read
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                ),
                title: Text(
                  alert.title,
                  style: TextStyle(
                    fontWeight: alert.read
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Text(alert.body),
                onTap: () => alertsRef.doc(alert.id).update({'read': true}),
              ),
            );
          },
        );
      },
    );
  }
}
