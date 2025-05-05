import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String notifyLocation;
  final DateTime? createdAt;

  UserData({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.notifyLocation,
    required this.createdAt,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      userId: map['userId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      notifyLocation: map['notifyLocation'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'notifyLocation': notifyLocation,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'UserData{userId: $userId, firstName: $firstName, lastName: $lastName, email: $email, notifyLocation: $notifyLocation, createdAt: $createdAt}';
  }
}
