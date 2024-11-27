import 'package:cloud_firestore/cloud_firestore.dart';

class Organizer {
  String? id;
  String? name;
  String? email;
  String? address;
  String? phoneNumber;
  String? facebook;
  String? website;
  String? avatarUrl;
  String? passwordHash;
  Timestamp? createdAt;

  Organizer({
    this.id,
    this.name,
    this.email,
    this.address,
    this.phoneNumber,
    this.facebook,
    this.website,
    this.avatarUrl,
    this.passwordHash,
    this.createdAt,
  });

  // Factory constructor to create an Organizer object from Firestore data
  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      facebook: json['facebook'] as String?,
      website: json['website'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      passwordHash: json['passwordHash'] as String?,
      createdAt: json['createdAt'] as Timestamp?,
    );
  }

  // Method to convert an Organizer object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phoneNumber': phoneNumber,
      'facebook': facebook,
      'website': website,
      'avatarUrl': avatarUrl,
      'passwordHash': passwordHash,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
