import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/data/models/user_model.dart';
import 'package:amora/features/authentication/domain/auth_provider.dart';
import 'package:amora/features/authentication/presentation/widgets/custom_text_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String email;

  const SettingsScreen({super.key, required this.email});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cnicController = TextEditingController();
  final _passportController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _nikkahNamaController = TextEditingController();
  final _husbandBirthdayController = TextEditingController();
  final _wifeBirthdayController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _cnicController.dispose();
    _passportController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _nikkahNamaController.dispose();
    _husbandBirthdayController.dispose();
    _wifeBirthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userBox = await Hive.openBox<UserModel>('users');
    final user = userBox.values.firstWhere(
      (user) => user.email == widget.email,
      orElse: () => UserModel(
        id: '',
        username: '',
        email: widget.email,
        role: '',
        securityQuestion: '',
        securityAnswer: '',
        secretWord: '',
      ),
    );
    _usernameController.text = user.username;
    _cnicController.text = user.cnic ?? '';
    _passportController.text = user.passport ?? '';
    _phone1Controller.text = user.phoneNumbers?.isNotEmpty ?? false ? user.phoneNumbers![0] : '';
    _phone2Controller.text = user.phoneNumbers?.length == 2 ? user.phoneNumbers![1] : '';
    _nikkahNamaController.text = user.nikkahNama ?? '';
    _husbandBirthdayController.text = user.husbandBirthday ?? '';
    _wifeBirthdayController.text = user.wifeBirthday ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;
    final verticalSpacing = screenHeight * 0.015;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.creamWhite, AppTheme.softPink.withValues(alpha: 0.3)],
          ),
        ),
        child: FutureBuilder(
          future: _loadUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.roseGold));
            }
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.25,
                          maxWidth: screenWidth * 0.85,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.roseGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.softPink.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/images/write.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading image: $error');
                              return Container(
                                color: AppTheme.softPink.withValues(alpha: 0.2),
                                child: Icon(Icons.favorite, size: screenWidth * 0.15, color: AppTheme.roseGold),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacing * 2),
                      Text(
                        'Your Settings',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 26 * fontScaleFactor,
                          color: AppTheme.deepRose,
                          shadows: [
                            Shadow(
                              blurRadius: 3,
                              color: AppTheme.roseGold.withValues(alpha: 0.3),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: verticalSpacing * 2),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              label: 'Username',
                              controller: _usernameController,
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: verticalSpacing),
                            CustomTextField(
                              label: 'Password',
                              controller: _passwordController,
                              obscureText: true,
                              prefixIcon: Icon(
                                Icons.lock,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                            ),
                            SizedBox(height: verticalSpacing),
                            CustomTextField(
                              label: 'CNIC',
                              controller: _cnicController,
                              prefixIcon: Icon(
                                Icons.badge,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                            ),
                            SizedBox(height: verticalSpacing),
                            CustomTextField(
                              label: 'Passport',
                              controller: _passportController,
                              prefixIcon: Icon(
                                Icons.book,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                            ),
                            SizedBox(height: verticalSpacing),
                            CustomTextField(
                              label: 'Phone Number 1',
                              controller: _phone1Controller,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icon(
                                Icons.phone,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                            ),
                            SizedBox(height: verticalSpacing),
                            CustomTextField(
                              label: 'Phone Number 2',
                              controller: _phone2Controller,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icon(
                                Icons.phone,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                              maxLines: 1,
                            ),
                            SizedBox(height: verticalSpacing),
                            CustomTextField(
                              label: 'Nikkah Nama Number',
                              controller: _nikkahNamaController,
                              prefixIcon: Icon(
                                Icons.favorite,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                            ),
                            SizedBox(height: verticalSpacing),
                            CustomTextField(
                              label: 'Husband Birthday (YYYY-MM-DD)',
                              controller: _husbandBirthdayController,
                              keyboardType: TextInputType.datetime,
                              prefixIcon: Icon(
                                Icons.cake,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                            ),
                            SizedBox(height: verticalSpacing),
                            CustomTextField(
                              label: 'Wife Birthday (YYYY-MM-DD)',
                              controller: _wifeBirthdayController,
                              keyboardType: TextInputType.datetime,
                              prefixIcon: Icon(
                                Icons.cake,
                                color: AppTheme.roseGold,
                                size: 20 * fontScaleFactor,
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 2),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final phoneNumbers = [
                                    if (_phone1Controller.text.isNotEmpty) _phone1Controller.text,
                                    if (_phone2Controller.text.isNotEmpty) _phone2Controller.text,
                                  ];
                                  final success = await ref
                                      .read(authStateProvider.notifier)
                                      .updateUser(
                                        email: widget.email,
                                        username: _usernameController.text,
                                        password: _passwordController.text.isNotEmpty
                                            ? _passwordController.text
                                            : null,
                                        cnic: _cnicController.text.isNotEmpty ? _cnicController.text : null,
                                        passport: _passportController.text.isNotEmpty
                                            ? _passportController.text
                                            : null,
                                        phoneNumbers: phoneNumbers.isNotEmpty ? phoneNumbers : null,
                                        nikkahNama: _nikkahNamaController.text.isNotEmpty
                                            ? _nikkahNamaController.text
                                            : null,
                                        husbandBirthday: _husbandBirthdayController.text.isNotEmpty
                                            ? _husbandBirthdayController.text
                                            : null,
                                        wifeBirthday: _wifeBirthdayController.text.isNotEmpty
                                            ? _wifeBirthdayController.text
                                            : null,
                                      );
                                  if (success) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(const SnackBar(content: Text('Settings updated!')));
                                  } else {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(const SnackBar(content: Text('Failed to update settings')));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.roseGold,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.1,
                                  vertical: screenHeight * 0.02,
                                ),
                                minimumSize: Size(screenWidth * 0.85, screenHeight * 0.08),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 18 * fontScaleFactor, color: AppTheme.creamWhite),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Save Settings',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16 * fontScaleFactor,
                                      color: AppTheme.creamWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
