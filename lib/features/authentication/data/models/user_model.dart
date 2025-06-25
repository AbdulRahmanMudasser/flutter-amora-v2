import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String securityQuestion;

  @HiveField(5)
  final String securityAnswer;

  @HiveField(6)
  final String secretWord;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.securityQuestion,
    required this.securityAnswer,
    required this.secretWord,
  });
}