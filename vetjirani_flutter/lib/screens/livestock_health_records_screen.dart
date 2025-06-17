import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livestock_health_record.dart';

class LivestockHealthRecordsScreen extends StatefulWidget {
  final String farmerId;

  LivestockHealthRecordsScreen({required this.farmerId});

  @override
  _LivestockHealthRecordsScreenState createState() => _LivestockHealthRecordsScreenState();
}

class _LivestockHealthRecordsScreenState extends State<LivestockHealthRecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRecordsStream() {
    return _firestore
        .collection('livestock_health_records')
        .where('farmerId', isEqualTo: widget.farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _deleteRecord(String id) async {
    await _firestore.collection('livestock_health_records').doc(id).delete();
  }

  void _showAddEditDialog({LivestockHealthRecord? record}) {
    final _formKey = GlobalKey<FormState>();
    String animalName = record?.animalName ?? '';
    int age = record?.age ?? 0;
    String vaccinationStatus = record?.vaccinationStatus ?? '';
    String visitHistoryText = record?.visitHistory.join(', ') ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(record == null ? 'Add Record' : 'Edit Record'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: animalName,
                    decoration: InputDecoration(labelText: 'Animal Name'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    onSaved: (val) => animalName = val!.trim(),
                  ),
                  TextFormField(
                    initialValue: age > 0 ? age.toString() : '',
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      if (int.tryParse(val) == null) return 'Must be a number';
                      return null;
                    },
                    onSaved: (val) => age = int.parse(val!),
                  ),
                  TextFormField(
                    initialValue: vaccinationStatus,
                    decoration: InputDecoration(labelText: 'Vaccination Status'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    onSaved: (val) => vaccinationStatus = val!.trim(),
                  ),
                  TextFormField(
                    initialValue: visitHistoryText,
                    decoration: InputDecoration(labelText: 'Visit History (comma separated)'),
                    onSaved: (val) => visitHistoryText = val ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  final visitHistory = visitHistoryText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

                  final data = {
                    'farmerId': widget.farmerId,
                    'animalName': animalName,
                    'age': age,
                    'vaccinationStatus': vaccinationStatus,
                    'visitHistory': visitHistory,
                    'createdAt': record?.createdAt ?? FieldValue.serverTimestamp(),
                  };

                  if (record == null) {
                    await _firestore.collection('livestock_health_records').add(data);
                  } else {
                    await _firestore.collection('livestock_health_records').doc(record.id).update(data);
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(record == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Widget buildRecordCard(LivestockHealthRecord record) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(record.animalName),
        subtitle: Text('Age: ${record.age}\nVaccination: ${record.vaccinationStatus}\nVisits: ${record.visitHistory.join(', ')}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showAddEditDialog(record: record),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteRecord(record.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livestock Health Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getRecordsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading records'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No records found'));
          }
          final records = docs.map((doc) => LivestockHealthRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
          return ListView(
            children: records.map(buildRecordCard).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
