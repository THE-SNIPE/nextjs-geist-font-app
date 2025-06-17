import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingManagementScreen extends StatefulWidget {
  final String vetId;

  BookingManagementScreen({required this.vetId});

  @override
  _BookingManagementScreenState createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getBookingStream() {
    return _firestore
        .collection('bookings')
        .where('vetId', isEqualTo: widget.vetId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
  }

  Widget buildBookingCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final booking = BookingModel.fromMap(data, doc.id);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text('Appointment on ${booking.dateTime.toLocal()}'),
        subtitle: Text('Animal: ${booking.animalType}\nIssue: ${booking.issue}\nStatus: ${booking.status.toString().split('.').last}'),
        trailing: booking.status == BookingStatus.pending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => updateBookingStatus(booking.id, 'approved'),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => updateBookingStatus(booking.id, 'declined'),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getBookingStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading bookings'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No bookings found'));
          }
          return ListView(
            children: docs.map(buildBookingCard).toList(),
          );
        },
      ),
    );
  }
}
