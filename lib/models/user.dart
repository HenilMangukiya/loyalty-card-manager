import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String? name;

  User({
    required this.id,
    required this.email,
    required this.password,
    this.name,
  });

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
    );
  }
} 