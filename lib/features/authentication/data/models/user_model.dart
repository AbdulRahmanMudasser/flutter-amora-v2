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

  @HiveField(7)
  final String? cnic;

  @HiveField(8)
  final String? passport;

  @HiveField(9)
  final List<String>? phoneNumbers;

  @HiveField(10)
  final String? nikkahNama;

  @HiveField(11)
  final String? husbandBirthday;

  @HiveField(12)
  final String? wifeBirthday;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.securityQuestion,
    required this.securityAnswer,
    required this.secretWord,
    this.cnic,
    this.passport,
    this.phoneNumbers,
    this.nikkahNama,
    this.husbandBirthday,
    this.wifeBirthday,
  });
}