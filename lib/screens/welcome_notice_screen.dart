import 'dart:async';
import 'package:flutter/material.dart';
import 'package:index/screens/base_screen.dart';
import 'package:index/screens/privacy_policy_screen.dart';
import 'package:index/screens/fragments_screen.dart';

class WelcomeNoticeScreen extends BaseScreen {
  const WelcomeNoticeScreen({super.key});

  @override
  State<WelcomeNoticeScreen> createState() => _WelcomeNoticeScreenState();
}

class _WelcomeNoticeScreenState extends BaseScreenState<WelcomeNoticeScreen> {
  int _countdown = 10;
  Timer? _timer;
  bool _canSkip = false;

  @override
  String get screenName => 'Welcome Notice';

  @override
  Future<void> initializeScreen() async {
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _canSkip = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _navigateToApp() {
    if (_canSkip) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FragmentsScreen()),
      );
    }
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  @override
  void handleDispose() {
    _timer?.cancel();
    super.handleDispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Welcome Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.waving_hand,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Welcome Title
              Text(
                'مرحبا بك في تطبيق Index',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Welcome Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'قبل الدخول إلى عالم الإثارة والأفلام يرجى قراءة ',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      onTap: _navigateToPrivacyPolicy,
                      child: Text(
                        'سياسة الخصوصية',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'إذا لم تعمل بعض الأفلام أو المسلسلات يرجى تغيير الخادم أو المزود من الإعدادات.',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'شكراً / فريق خدمة Index',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Countdown and Continue Button
              Column(
                children: [
                  if (!_canSkip) ...[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_countdown',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'يمكنك المتابعة خلال $_countdown ثانية',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _navigateToApp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_forward),
                            const SizedBox(width: 8),
                            Text(
                              'المتابعة إلى التطبيق',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}