import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role; // 'Husband' or 'Wife'

  @HiveField(4)
  final String securityQuestion;

  @HiveField(5)
  final String securityAnswer;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.securityQuestion,
    required this.securityAnswer,
  });
}