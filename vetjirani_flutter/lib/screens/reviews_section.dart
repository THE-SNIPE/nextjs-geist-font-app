import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/review_model.dart';
import '../services/auth_service.dart';

class ReviewsSection extends StatefulWidget {
  final String vetId;

  ReviewsSection({required this.vetId});

  @override
  _ReviewsSectionState createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final _formKey = GlobalKey<FormState>();
  String _comment = '';
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getReviewsForVet(widget.vetId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error loading reviews');
            }
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Text('No reviews yet');
            }
            final reviews = docs
                .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                .toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  title: Text(review.comment),
                  subtitle: Row(
                    children: List.generate(5, (i) {
                      if (i < review.rating.floor()) {
                        return Icon(Icons.star, color: Colors.amber, size: 16);
                      } else {
                        return Icon(Icons.star_border, color: Colors.amber, size: 16);
                      }
                    }),
                  ),
                );
              },
            );
          },
        ),
        SizedBox(height: 16),
        if (currentUser != null)
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leave a Review', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Comment'),
                  maxLines: 3,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a comment' : null,
                  onSaved: (val) => _comment = val!.trim(),
                ),
                SizedBox(height: 8),
                Text('Rating'),
                Slider(
                  value: _rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _rating.toString(),
                  onChanged: (val) {
                    setState(() {
                      _rating = val;
                    });
                  },
                ),
                SizedBox(height: 8),
                _isSubmitting
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            setState(() {
                              _isSubmitting = true;
                            });
                            await firestoreService.addReview(
                              vetId: widget.vetId,
                              farmerId: currentUser.uid,
                              comment: _comment,
                              rating: _rating,
                            );
                            _formKey.currentState?.reset();
                            setState(() {
                              _rating = 5.0;
                              _isSubmitting = false;
                            });
                          }
                        },
                        child: Text('Submit Review'),
                      ),
              ],
            ),
          ),
      ],
    );
  }
}
