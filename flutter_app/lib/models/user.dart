class User {
  final String username;
  final String accessToken;

  User({required this.username, required this.accessToken});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      accessToken: map['access_token'] ?? '',
    );
  }
}
