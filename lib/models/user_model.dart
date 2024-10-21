enum UserRole { user, admin }

class UserModel {
  final String id;
  final String email;
  final UserRole role;

  UserModel({required this.id, required this.email, required this.role});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'user',
    };
  }
}
