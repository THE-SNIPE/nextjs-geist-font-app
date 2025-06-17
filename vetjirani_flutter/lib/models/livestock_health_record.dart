import 'package:cloud_firestore/cloud_firestore.dart';

class LivestockHealthRecord {
  final String id;
  final String farmerId;
  final String animalName;
  final int age;
  final String vaccinationStatus;
  final List<String> visitHistory;
  final DateTime createdAt;

  LivestockHealthRecord({
    required this.id,
    required this.farmerId,
    required this.animalName,
    required this.age,
    required this.vaccinationStatus,
    required this.visitHistory,
    required this.createdAt,
  });

  factory LivestockHealthRecord.fromMap(Map<String, dynamic> data, String id) {
    return LivestockHealthRecord(
      id: id,
      farmerId: data['farmerId'] ?? '',
      animalName: data['animalName'] ?? '',
      age: data['age'] ?? 0,
      vaccinationStatus: data['vaccinationStatus'] ?? '',
      visitHistory: List<String>.from(data['visitHistory'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'animalName': animalName,
      'age': age,
      'vaccinationStatus': vaccinationStatus,
      'visitHistory': visitHistory,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
