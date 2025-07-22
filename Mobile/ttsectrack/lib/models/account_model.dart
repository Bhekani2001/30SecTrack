class Account {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? profileImage;

  Account({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profileImage,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      profileImage: map['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profileImage': profileImage,
    };
  }
}
