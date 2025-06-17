class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? '',
      role: data['role'] ?? '',
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'role': role,
      'createdAt': createdAt,
    };
  }
}

class VetModel extends UserModel {
  final List<String> specialties;
  final String bio;
  final double rating;
  final int reviewCount;
  final int yearsOfExperience;

  VetModel({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String location,
    required DateTime createdAt,
    required this.specialties,
    required this.bio,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.yearsOfExperience,
  }) : super(
          uid: uid,
          name: name,
          email: email,
          phone: phone,
          location: location,
          role: 'Vet',
          createdAt: createdAt,
        );

  factory VetModel.fromMap(Map<String, dynamic> data, String uid) {
    return VetModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? '',
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
      specialties: List<String>.from(data['specialties'] ?? []),
      bio: data['bio'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'specialties': specialties,
      'bio': bio,
      'rating': rating,
      'reviewCount': reviewCount,
      'yearsOfExperience': yearsOfExperience,
    });
    return map;
  }
}
