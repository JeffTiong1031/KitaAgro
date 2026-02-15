class UserModel {
  final String uid;
  final String email;
  final String username;
  final String fullName;
  final int age;
  final String gender;
  final String town;
  final String state;
  final String country;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.town,
    required this.state,
    required this.country,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'town': town,
      'state': state,
      'country': country,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      fullName: map['fullName'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Not Specified',
      town: map['town'] ?? 'Not Specified',
      state: map['state'] ?? 'Not Specified',
      country: map['country'] ?? 'Not Specified',
      role: map['role'] ?? 'Farmer',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
