import 'package:flutter/material.dart';
import '../models/user_model.dart';

class VetProfileScreen extends StatelessWidget {
  final VetModel vet;

  VetProfileScreen({required this.vet});

  Widget buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;
    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber);
        } else if (index == fullStars && halfStar) {
          return Icon(Icons.star_half, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, color: Colors.amber);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vet.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              vet.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Specialties: ${vet.specialties.join(', ')}'),
            SizedBox(height: 8),
            Text('Location: ${vet.location}'),
            SizedBox(height: 8),
            Text('Years of Experience: ${vet.yearsOfExperience}'),
            SizedBox(height: 8),
            buildRatingStars(vet.rating),
            SizedBox(height: 8),
            Text('Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(vet.bio),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingRequestScreen(vetId: vet.uid),
                  ),
                );
              },
              child: Text('Request Appointment'),
            ),
            SizedBox(height: 24),
            Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ReviewsSection(vetId: vet.uid),
          ],
        ),
      ),
    );
  }
}
