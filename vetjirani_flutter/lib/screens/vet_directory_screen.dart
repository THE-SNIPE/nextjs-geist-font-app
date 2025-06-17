import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import '../models/user_model.dart';

class VetDirectoryScreen extends StatefulWidget {
  @override
  _VetDirectoryScreenState createState() => _VetDirectoryScreenState();
}

class _VetDirectoryScreenState extends State<VetDirectoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final geo = GeoFlutterFire();
  List<VetModel> vets = [];
  bool isLoading = true;

  String searchQuery = '';
  String filterSpecialty = '';

  @override
  void initState() {
    super.initState();
    fetchVets();
  }

  Future<void> fetchVets() async {
    setState(() {
      isLoading = true;
    });

    Query query = _firestore.collection('users').where('role', isEqualTo: 'Vet');

    if (filterSpecialty.isNotEmpty) {
      query = query.where('specialties', arrayContains: filterSpecialty);
    }

    if (searchQuery.isNotEmpty) {
      // For simplicity, search by name starting with searchQuery
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery).where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
    }

    final snapshot = await query.get();

    final vetList = snapshot.docs.map((doc) => VetModel.fromMap(doc.data(), doc.id)).toList();

    setState(() {
      vets = vetList;
      isLoading = false;
    });
  }

  Widget buildVetCard(VetModel vet) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(vet.name),
        subtitle: Text('Specialties: ${vet.specialties.join(', ')}\nLocation: ${vet.location}'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VetProfileScreen(vet: vets[index]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vet Directory'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.trim();
                });
                fetchVets();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Filter by Specialty',
                border: OutlineInputBorder(),
              ),
              items: [
                '',
                'Cattle',
                'Goats',
                'Sheep',
                'Poultry',
                'Equine',
                'Swine',
              ].map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty.isEmpty ? 'All' : specialty),
                );
              }).toList(),
              value: filterSpecialty,
              onChanged: (val) {
                setState(() {
                  filterSpecialty = val ?? '';
                });
                fetchVets();
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : vets.isEmpty
                    ? Center(child: Text('No vets found'))
                    : ListView.builder(
                        itemCount: vets.length,
                        itemBuilder: (context, index) {
                          return buildVetCard(vets[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
