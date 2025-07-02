import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/domain/auth_provider.dart';
import 'package:amora/features/authentication/presentation/screens/login_screen.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const OtpVerificationScreen({super.key, required this.email, required this.otp});

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('OtpVerificationScreen loaded with email: ${widget.email}, otp: ${widget.otp}');
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.02;
    final verticalSpacing = screenHeight * 0.015;
    final fieldWidthFraction = screenWidth > 600 ? 0.85 : 0.98;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/bg-3.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalSpacing * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: verticalSpacing * 2, bottom: verticalSpacing),
                      child: Text(
                        'Verify Your Love',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22 * fontScaleFactor,
                          fontWeight: FontWeight.w700,
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
                        textDirection: RegExp(r'[\u0600-\u06FF]').hasMatch('Verify Your Love')
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: verticalSpacing * 2),
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.18,
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
                          'assets/images/otp.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading image: $error');
                            return Container(
                              color: AppTheme.softPink.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.favorite,
                                size: screenWidth * 0.15,
                                color: AppTheme.roseGold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 20, color: AppTheme.roseGold),
                        SizedBox(width: 8),
                        Expanded(
                          child: Divider(color: AppTheme.roseGold, thickness: 1),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.favorite, size: 20, color: AppTheme.roseGold),
                      ],
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    Text(
                      'Enter the OTP',
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
                      textDirection: RegExp(r'[\u0600-\u06FF]').hasMatch('Enter the OTP')
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14 * fontScaleFactor,
                                color: AppTheme.deepRose,
                              ),
                              decoration: InputDecoration(
                                labelText: 'OTP',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: AppTheme.roseGold,
                                  size: 20 * fontScaleFactor,
                                ),
                                filled: true,
                                fillColor: AppTheme.softPink.withValues(alpha: 0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.deepRose, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.02,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length != 6) {
                                  return 'Please enter a 6-digit OTP';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 2),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () async {
                                debugPrint('Verifying OTP: ${_otpController.text} for email: ${widget.email}');
                                if (_formKey.currentState!.validate()) {
                                  final isValid = await ref.read(authStateProvider.notifier).verifyOtp(
                                    widget.email,
                                    _otpController.text,
                                  );
                                  if (isValid) {
                                    debugPrint('OTP verified, navigating to LoginScreen');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('OTP verified successfully!')),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    );
                                  } else {
                                    debugPrint('OTP verification failed');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Invalid OTP')),
                                    );
                                  }
                                } else {
                                  debugPrint('OTP form validation failed');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.roseGold,
                                foregroundColor: AppTheme.creamWhite,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.1,
                                  vertical: screenHeight * 0.02,
                                ),
                                minimumSize: Size(double.infinity, screenHeight * 0.05),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppTheme.deepRose, width: 1.5),
                                ),
                                elevation: 4,
                                shadowColor: AppTheme.softPink.withValues(alpha: 0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 18 * fontScaleFactor,
                                    color: AppTheme.creamWhite,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    authState.isLoading ? 'Verifying...' : 'Verify OTP',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16 * fontScaleFactor,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.creamWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}