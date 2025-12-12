// lib/models/user.dart
class User {
  final int id;
  final String username;
  final String? publicKeyPem;
  final String? createdAt;
  final String? lastSeen;

  User({
    required this.id,
    required this.username,
    this.publicKeyPem,
    this.createdAt,
    this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> j) {
    return User(
      id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
      username: j['username']?.toString() ?? '',
      publicKeyPem: j['public_key_pem']?.toString() ?? j['publicKeyPem']?.toString(),
      createdAt: j['created_at']?.toString() ?? j['createdAt']?.toString(),
      lastSeen: j['last_seen']?.toString() ?? j['lastSeen']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'public_key_pem': publicKeyPem,
        'created_at': createdAt,
        'last_seen': lastSeen,
      };
}
