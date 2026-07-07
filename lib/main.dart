import 'profile_screen.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'certificate/certificate_service.dart';

// ---------- APP COLORS (Kerala Theme — matched exactly from design) ----------
class AppColors {
  static const Color cream = Color(0xFFFBF7E6); // page background
  static const Color cardCream = Color(0xFFFFFEF7); // cards / input fields
  static const Color darkGreen = Color(0xFF234E14); // titles, labels, body text
  static const Color green = Color(0xFF3D6B1E); // filled buttons
  static const Color gold = Color(0xFFCDA018); // gold accent text
  static const Color softBorder = Color(0xFFE3DCC0); // pale border lines
}

// ---------- SHARED PROGRESS TRACKER ----------
// This object holds the "notice board" that every screen can read/write.
class ProgressData {
  // Singleton pattern: only ONE ProgressData exists in the whole app
  static final ProgressData instance = ProgressData._internal();
  ProgressData._internal();

  bool vowelsDone = false;
  bool consonantsDone = false;
  bool combinedFormsDone = false;
  bool wordsDone = false;
  bool quizPassed = false;
  int quizScore = 0;

  // Calculates overall progress as a percentage (0.0 to 1.0)
  double get overallProgress {
    int doneCount = 0;
    if (vowelsDone) doneCount++;
    if (consonantsDone) doneCount++;
    if (combinedFormsDone) doneCount++;
    if (wordsDone) doneCount++;
    if (quizPassed) doneCount++;
    return doneCount / 5; // 5 total stages
  }
}

// ---------- FIRESTORE PROGRESS HELPER ----------
// One shared function every screen can call to update this student's
// progress flag in Firestore, using whichever account is currently logged in.
Future<void> updateProgressInFirestore(String fieldName, dynamic value) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return; // safety check — should never happen if logged in

  await FirebaseFirestore.instance.collection('students').doc(user.uid).update({
    fieldName: value,
  });
}

// ---------- REUSABLE MALAYALAM CARD WIDGET ----------
class MalayalamCard extends StatelessWidget {
  final String malayalamText;
  final String englishText;
  final String example;
  final String meaning;
  final String emoji;
  final bool isCompleted;
  final bool isPlaying;
  final VoidCallback onTap;

  const MalayalamCard({
    super.key,
    required this.malayalamText,
    required this.englishText,
    required this.example,
    required this.meaning,
    required this.emoji,
    required this.isCompleted,
    required this.onTap,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying ? AppColors.gold : AppColors.softBorder,
            width: isPlaying ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    malayalamText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    englishText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                  Text(
                    example,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    meaning,
                    style: TextStyle(fontSize: 10, color: Colors.brown[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.green,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malayalam Learning App',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.darkGreen,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.cardCream,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.darkGreen),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------- FIRST SCREEN ----------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ---- Real artwork: crest + title + houseboat + temple, all baked in ----
              Image.asset(
                'assets/images/home_top_banner.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // ---- Cream pill banner ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Text(
                        '🌿 Learn Malayalam. Connect with our roots. 🌿',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ---- Student Card ----
                    _RoleCard(
                      avatar: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.cream,
                        child: Icon(
                          Icons.school,
                          color: AppColors.green,
                          size: 32,
                        ),
                      ),
                      title: 'Student',
                      subtitle: 'Register or log in to start learning',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---- Faculty Card (uses the REAL cropped photo) ----
                    _RoleCard(
                      avatar: const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(
                          'assets/images/faculty_avatar.png',
                        ),
                      ),
                      title: 'Faculty',
                      subtitle: 'Faculty portal access',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FacultyScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ---- Real artwork: boat + goddess outline + temple outline + flowers ----
              Image.asset(
                'assets/images/home_bottom_banner.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A reusable card used for both the "Student" and "Faculty" choices.
// `avatar` can be an icon in a circle (Student) OR a real photo (Faculty) —
// that's why it takes a Widget instead of just an icon.
class _RoleCard extends StatelessWidget {
  final Widget avatar;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.brown[400]),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.green,
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.cardCream,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- STUDENT SCREEN (now shows Registration) ----------
class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegistrationScreen();
  }
}

// ---------- SHARED AUTH WIDGETS (used by both Registration and Login) ----------

// The green/cream tab switcher at the top of the Student Portal,
// matching the real design exactly. Tapping the inactive tab swaps screens.
class _AuthTabs extends StatelessWidget {
  final bool isRegistrationActive;
  const _AuthTabs({required this.isRegistrationActive});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isRegistrationActive) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationScreen(),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isRegistrationActive
                    ? AppColors.green
                    : AppColors.cardCream,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                border: Border.all(color: AppColors.softBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: isRegistrationActive
                        ? AppColors.cardCream
                        : AppColors.darkGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'New Registration',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isRegistrationActive
                          ? AppColors.cardCream
                          : AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isRegistrationActive) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !isRegistrationActive
                    ? AppColors.green
                    : AppColors.cardCream,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
                border: Border.all(color: AppColors.softBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 16,
                    color: !isRegistrationActive
                        ? AppColors.cardCream
                        : AppColors.darkGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: !isRegistrationActive
                          ? AppColors.cardCream
                          : AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// A labeled input box matching the real design: a small bold green label
// with an icon sitting ABOVE a cream input box (not Material's floating label).
class _LabeledField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? trailing;

  const _LabeledField({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.green),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.darkGreen),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.brown[300]),
            filled: true,
            fillColor: AppColors.cream,
            suffixIcon: trailing,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.softBorder),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.softBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.gold, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// A small reusable header used by both screens: crest artwork + title + tagline.
class _AuthHeader extends StatelessWidget {
  final String tagline;
  const _AuthHeader({required this.tagline});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/crest_banner.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 6),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Malayalam ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              TextSpan(
                text: 'Learning',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '•  $tagline  •',
          style: const TextStyle(fontSize: 14, color: AppColors.darkGreen),
        ),
      ],
    );
  }
}

// ---------- REGISTRATION SCREEN ----------
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController registerNumberController =
      TextEditingController();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _AuthHeader(tagline: 'Student Portal'),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const _AuthTabs(isRegistrationActive: true),
                    const SizedBox(height: 16),

                    // ---- Form Card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Column(
                        children: [
                          _LabeledField(
                            icon: Icons.person,
                            label: 'FULL NAME',
                            hint: 'Enter your full name',
                            controller: nameController,
                          ),
                          const SizedBox(height: 14),
                          _LabeledField(
                            icon: Icons.badge,
                            label: 'REGISTER NUMBER',
                            hint: 'e.g. 22BCA001',
                            controller: registerNumberController,
                          ),
                          const SizedBox(height: 14),
                          _LabeledField(
                            icon: Icons.school,
                            label: 'CLASS',
                            hint: 'e.g. Class 8 / B.Com 2nd Y',
                            controller: classController,
                          ),
                          const SizedBox(height: 14),
                          _LabeledField(
                            icon: Icons.email,
                            label: 'EMAIL ID',
                            hint: 'your@email.com',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _LabeledField(
                            icon: Icons.phone,
                            label: 'PHONE NUMBER',
                            hint: '10-digit phone number',
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          _LabeledField(
                            icon: Icons.lock,
                            label: 'PASSWORD',
                            hint: 'Create a password',
                            controller: passwordController,
                            obscureText: obscurePassword,
                            trailing: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.darkGreen,
                                size: 18,
                              ),
                              onPressed: () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---- Register Button ----
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // ---- Validate Register Number is not empty ----
                          final regNum = registerNumberController.text.trim();
                          if (regNum.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter your Register Number.',
                                ),
                              ),
                            );
                            return;
                          }

                          // ---- Check for duplicate Register Number in Firestore ----
                          try {
                            final existing = await FirebaseFirestore.instance
                                .collection('students')
                                .where('registerNumber', isEqualTo: regNum)
                                .get();

                            if (existing.docs.isNotEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This Register Number is already registered.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                          } catch (e) {
                            // If the duplicate check itself fails, we still continue safely
                          }

                          try {
                            // Step 1: Create the account in Firebase Auth
                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                            // Step 2: Save all details including Register Number in Firestore
                            await FirebaseFirestore.instance
                                .collection('students')
                                .doc(userCredential.user!.uid)
                                .set({
                                  'name': nameController.text.trim(),
                                  'registerNumber': regNum,
                                  'studentClass': classController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'phone': phoneController.text.trim(),
                                  'vowelsDone': false,
                                  'consonantsDone': false,
                                  'combinedFormsDone': false,
                                  'wordsDone': false,
                                  'quizPassed': false,
                                  'quizScore': 0,
                                  'completed': false,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            // Step 3: Show success and go to Login
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Account created! Please log in.',
                                  ),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String message =
                                'Registration failed. Please try again.';
                            if (e.code == 'email-already-in-use') {
                              message = 'That email is already registered.';
                            } else if (e.code == 'weak-password') {
                              message =
                                  'Password should be at least 6 characters.';
                            } else if (e.code == 'invalid-email') {
                              message = 'Please enter a valid email address.';
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            }
                          }
                        },
                        child: const Text('🌿  Register & Start Learning  🌿'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('←  Back to role selection  →'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/river_banner.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- LOGIN SCREEN ----------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  // ---- Forgot Password function ----
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardCream,
        title: const Text(
          'Reset Password',
          style: TextStyle(color: AppColors.darkGreen),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your registered email. We will send you a password reset link.',
              style: TextStyle(fontSize: 13, color: Colors.brown[400]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email ID',
                labelStyle: const TextStyle(color: AppColors.darkGreen),
                prefixIcon: const Icon(Icons.email, color: AppColors.green),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.softBorder),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.softBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your email')),
                );
                return;
              }
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✅ Password reset email sent! Check your inbox.',
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 4),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _AuthHeader(tagline: 'Student Portal'),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const _AuthTabs(isRegistrationActive: false),
                    const SizedBox(height: 16),

                    // ---- Form Card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Column(
                        children: [
                          _LabeledField(
                            icon: Icons.email,
                            label: 'EMAIL ID',
                            hint: 'your@email.com',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _LabeledField(
                            icon: Icons.lock,
                            label: 'PASSWORD',
                            hint: 'Enter your password',
                            controller: passwordController,
                            obscureText: obscurePassword,
                            trailing: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.darkGreen,
                                size: 18,
                              ),
                              onPressed: () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DashboardScreen(),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String message = 'Login failed. Please try again.';
                            if (e.code == 'user-not-found' ||
                                e.code == 'wrong-password' ||
                                e.code == 'invalid-credential') {
                              message = 'Incorrect email or password.';
                            } else if (e.code == 'invalid-email') {
                              message = 'Please enter a valid email address.';
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            }
                          }
                        },
                        child: const Text('🌿  Login  🌿'),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ---- Forgot Password link ----
                    TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      child: const Text('Forgot Password?'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('←  Back to role selection  →'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/river_banner.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- DASHBOARD SCREEN ----------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Read REAL progress from the shared tracker
    double progress = ProgressData.instance.overallProgress;

    // List of all modules, with lock status now based on real progress
    final List<Map<String, dynamic>> modules = [
      {'title': 'Vowels', 'icon': '🔤', 'locked': false}, // always unlocked
      {
        'title': 'Consonants',
        'icon': '🔠',
        'locked': !ProgressData.instance.vowelsDone,
      },
      {
        'title': 'Combined Forms',
        'icon': '🔗',
        'locked': !ProgressData.instance.consonantsDone,
      },
      {
        'title': 'Words',
        'icon': '📖',
        'locked': !ProgressData.instance.combinedFormsDone,
      },
      {
        'title': 'Quiz',
        'icon': '📝',
        'locked': !ProgressData.instance.wordsDone,
      },
      {
        'title': 'Certificate',
        'icon': '🏆',
        'locked': !ProgressData.instance.quizPassed,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Custom Header: coconut tree + title (left), logout (right) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('🌴', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Malayalam Learning App',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  // ---- PASTE THIS NEW BLOCK HERE ----
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  // ---- END NEW BLOCK — Logout GestureDetector stays right after, unchanged ----
                  GestureDetector(
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 16,
                            color: AppColors.darkGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ---- Overall Progress Card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.softBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overall Progress',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: AppColors.softBorder,
                              color: AppColors.green,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% complete',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown[400],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Modules',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ---- Modules Grid ----
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.05,
                          ),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        final bool locked = module['locked'];

                        return GestureDetector(
                          onTap: () {
                            if (locked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Complete previous module first!',
                                  ),
                                ),
                              );
                            } else if (module['title'] == 'Vowels') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VowelsScreen(),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (module['title'] == 'Consonants') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ConsonantsScreen(),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (module['title'] == 'Combined Forms') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CombinedFormsScreen(),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (module['title'] == 'Words') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WordsScreen(),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (module['title'] == 'Quiz') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QuizScreen(),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (module['title'] == 'Certificate') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CertificateScreen(),
                                ),
                              ).then((_) => setState(() {}));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: locked
                                  ? Colors.grey[100]
                                  : AppColors.cardCream,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: locked
                                    ? Colors.grey[300]!
                                    : AppColors.softBorder,
                              ),
                              boxShadow: locked
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        module['icon'],
                                        style: TextStyle(
                                          fontSize: 32,
                                          color: locked
                                              ? Colors.grey[400]
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        module['title'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: locked
                                              ? Colors.grey
                                              : AppColors.darkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (locked)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.lock,
                                      size: 16,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- VOWELS SCREEN ----------
class VowelsScreen extends StatefulWidget {
  const VowelsScreen({super.key});

  @override
  State<VowelsScreen> createState() => _VowelsScreenState();
}

class _VowelsScreenState extends State<VowelsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String studentName = '';

  Future<void> loadStudentName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        studentName = doc.data()?['name'] ?? '';
      });
    }
  }

  final List<Map<String, String>> vowels = [
    {
      'letter': 'അ',
      'sound': 'a',
      'example': 'അമ്മ',
      'meaning': 'Mother',
      'emoji': '👩',
    },
    {
      'letter': 'ആ',
      'sound': 'aa',
      'example': 'ആന',
      'meaning': 'Elephant',
      'emoji': '🐘',
    },
    {
      'letter': 'ഇ',
      'sound': 'i',
      'example': 'ഇല',
      'meaning': 'Leaf',
      'emoji': '🍃',
    },
    {
      'letter': 'ഈ',
      'sound': 'ii',
      'example': 'ഈച്ച',
      'meaning': 'Fly',
      'emoji': '🪰',
    },
    {
      'letter': 'ഉ',
      'sound': 'u',
      'example': 'ഉറുമ്പ്',
      'meaning': 'Ant',
      'emoji': '🐜',
    },
    {
      'letter': 'ഊ',
      'sound': 'uu',
      'example': 'ഊഞ്ഞാൽ',
      'meaning': 'Swing',
      'emoji': '🪢',
    },
    {
      'letter': 'ഋ',
      'sound': 'ru',
      'example': 'ഋതു',
      'meaning': 'Season',
      'emoji': '🍂',
    },
    {
      'letter': 'എ',
      'sound': 'e',
      'example': 'എലി',
      'meaning': 'Mouse',
      'emoji': '🐭',
    },
    {
      'letter': 'ഏ',
      'sound': 'ee',
      'example': 'ഏണി',
      'meaning': 'Ladder',
      'emoji': '🪜',
    },
    {
      'letter': 'ഐ',
      'sound': 'ai',
      'example': 'ഐസ്',
      'meaning': 'Ice',
      'emoji': '🧊',
    },
    {
      'letter': 'ഒ',
      'sound': 'o',
      'example': 'ഒട്ടകം',
      'meaning': 'Camel',
      'emoji': '🐫',
    },
    {
      'letter': 'ഓ',
      'sound': 'oo',
      'example': 'ഓട്',
      'meaning': 'Tile',
      'emoji': '🧱',
    },
    {
      'letter': 'ഔ',
      'sound': 'au',
      'example': 'ഔഷധം',
      'meaning': 'Medicine',
      'emoji': '💊',
    },
    {
      'letter': 'അം',
      'sound': 'am',
      'example': 'പയ്യം',
      'meaning': 'Cow',
      'emoji': '🐄',
    },
    {
      'letter': 'അഃ',
      'sound': 'aha',
      'example': 'ദുഃഖം',
      'meaning': 'Sadness',
      'emoji': '😢',
    },
  ];

  final Set<int> completed = {};

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ml-IN");
    loadStudentName();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void speakAndMark(int index) async {
    final letter = vowels[index]['letter']!;
    await flutterTts.speak(letter);
    setState(() {
      completed.add(index);
    });
    if (completed.length == vowels.length) {
      setState(() {
        ProgressData.instance.vowelsDone = true;
      });
      await updateProgressInFirestore('vowelsDone', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool allDone = completed.length == vowels.length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Header: 🌴 Malayalam (left) + student name pill (right) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('🌴 ', style: TextStyle(fontSize: 22)),
                  const Text(
                    'Malayalam',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.green,
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          studentName.isNotEmpty ? studentName : '...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- Back button + Title row ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: AppColors.darkGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    '🔤 Vowels',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (allDone)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green, width: 1.5),
                ),
                child: const Text(
                  '🎉 Module Complete! Consonants unlocked.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: vowels.length,
                itemBuilder: (context, index) {
                  final bool done = completed.contains(index);
                  return MalayalamCard(
                    malayalamText: vowels[index]['letter']!,
                    englishText: vowels[index]['sound']!,
                    example: vowels[index]['example']!,
                    meaning: vowels[index]['meaning']!,
                    emoji: vowels[index]['emoji']!,
                    isCompleted: done,
                    onTap: () => speakAndMark(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- CONSONANTS SCREEN ----------
class ConsonantsScreen extends StatefulWidget {
  const ConsonantsScreen({super.key});

  @override
  State<ConsonantsScreen> createState() => _ConsonantsScreenState();
}

class _ConsonantsScreenState extends State<ConsonantsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String studentName = '';

  Future<void> loadStudentName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        studentName = doc.data()?['name'] ?? '';
      });
    }
  }

  final List<Map<String, String>> consonants = [
    {
      'letter': 'ക',
      'sound': 'ka',
      'example': 'കാക്ക',
      'meaning': 'Crow',
      'emoji': '🐦‍⬛',
    },
    {
      'letter': 'ഖ',
      'sound': 'kha',
      'example': 'ഖഡ്ഗം',
      'meaning': 'Sword',
      'emoji': '⚔️',
    },
    {
      'letter': 'ഗ',
      'sound': 'ga',
      'example': 'ഗ ജം',
      'meaning': 'Elephant',
      'emoji': '🐘',
    },
    {
      'letter': 'ഘ',
      'sound': 'gha',
      'example': 'ഘടം',
      'meaning': 'Pot',
      'emoji': '🏺',
    },
    {
      'letter': 'ങ',
      'sound': 'nga',
      'example': 'അങ്കം',
      'meaning': 'Battle',
      'emoji': '⚔️',
    },
    {
      'letter': 'ച',
      'sound': 'cha',
      'example': 'ചക്ക',
      'meaning': 'Jackfruit',
      'emoji': '🍈',
    },
    {
      'letter': 'ഛ',
      'sound': 'chha',
      'example': 'ഛായ',
      'meaning': 'Shadow',
      'emoji': '🌑',
    },
    {
      'letter': 'ജ',
      'sound': 'ja',
      'example': 'ജലം',
      'meaning': 'Water',
      'emoji': '💧',
    },
    {
      'letter': 'ഝ',
      'sound': 'jha',
      'example': 'ഝടുതി',
      'meaning': 'Speed',
      'emoji': '💨',
    },
    {
      'letter': 'ഞ',
      'sound': 'nja',
      'example': 'ഞാവൽ',
      'meaning': 'Java plum',
      'emoji': '🍇',
    },
    {
      'letter': 'ട',
      'sound': 'ta',
      'example': 'ടാപ്പ്',
      'meaning': 'Tap',
      'emoji': '🚰',
    },
    {
      'letter': 'ഠ',
      'sound': 'tha',
      'example': 'ഠാണാ',
      'meaning': 'Police Station',
      'emoji': '🚓',
    },
    {
      'letter': 'ഡ',
      'sound': 'da',
      'example': 'ഡോക്ടർ',
      'meaning': 'Doctor',
      'emoji': '🩺',
    },
    {
      'letter': 'ഢ',
      'sound': 'dha',
      'example': 'ഢക്ക',
      'meaning': 'Drum',
      'emoji': '🥁',
    },
    {
      'letter': 'ണ',
      'sound': 'na',
      'example': 'കണ്ണ്',
      'meaning': 'Eye',
      'emoji': '👁️',
    },
    {
      'letter': 'ത',
      'sound': 'tha',
      'example': 'തേൻ',
      'meaning': 'Honey',
      'emoji': '🍯',
    },
    {
      'letter': 'ഥ',
      'sound': 'thha',
      'example': 'കഥ',
      'meaning': 'Story',
      'emoji': '📖',
    },
    {
      'letter': 'ദ',
      'sound': 'dha',
      'example': 'ദീപം',
      'meaning': 'Lamp',
      'emoji': '🪔',
    },
    {
      'letter': 'ധ',
      'sound': 'dhha',
      'example': 'ധനം',
      'meaning': 'Wealth',
      'emoji': '💰',
    },
    {
      'letter': 'ന',
      'sound': 'na',
      'example': 'നായ',
      'meaning': 'Dog',
      'emoji': '🐕',
    },
    {
      'letter': 'പ',
      'sound': 'pa',
      'example': 'പശു',
      'meaning': 'Cow',
      'emoji': '🐄',
    },
    {
      'letter': 'ഫ',
      'sound': 'pha',
      'example': 'ഫലം',
      'meaning': 'Fruit',
      'emoji': '🍎',
    },
    {
      'letter': 'ബ',
      'sound': 'ba',
      'example': 'ബസ്',
      'meaning': 'Bus',
      'emoji': '🚌',
    },
    {
      'letter': 'ഭ',
      'sound': 'bha',
      'example': 'ഭൂമി',
      'meaning': 'Earth',
      'emoji': '🌍',
    },
    {
      'letter': 'മ',
      'sound': 'ma',
      'example': 'മഴ',
      'meaning': 'Rain',
      'emoji': '🌧️',
    },
    {
      'letter': 'യ',
      'sound': 'ya',
      'example': 'യാത്ര',
      'meaning': 'Journey',
      'emoji': '🚗',
    },
    {
      'letter': 'ര',
      'sound': 'ra',
      'example': 'രാജാവ്',
      'meaning': 'King',
      'emoji': '👑',
    },
    {
      'letter': 'ല',
      'sound': 'la',
      'example': 'ലഡു',
      'meaning': 'Sweet ball',
      'emoji': '🍡',
    },
    {
      'letter': 'വ',
      'sound': 'va',
      'example': 'വാഴ',
      'meaning': 'Banana tree',
      'emoji': '🌴',
    },
    {
      'letter': 'ശ',
      'sound': 'sha',
      'example': 'ശംഖ്',
      'meaning': 'Conch shell',
      'emoji': '🐚',
    },
    {
      'letter': 'ഷ',
      'sound': 'sha',
      'example': 'ഷർട്ട്',
      'meaning': 'Shirt',
      'emoji': '👕',
    },
    {
      'letter': 'സ',
      'sound': 'sa',
      'example': 'സൂര്യൻ',
      'meaning': 'Sun',
      'emoji': '☀️',
    },
    {
      'letter': 'ഹ',
      'sound': 'ha',
      'example': 'ഹംസം',
      'meaning': 'Swan',
      'emoji': '🦢',
    },
    {
      'letter': 'ള',
      'sound': 'la',
      'example': 'വാള',
      'meaning': 'Sword',
      'emoji': '⚔️',
    },
    {
      'letter': 'ഴ',
      'sound': 'zha',
      'example': 'പുഴ',
      'meaning': 'River',
      'emoji': '🏞️',
    },
    {
      'letter': 'റ',
      'sound': 'ra',
      'example': 'പറ',
      'meaning': 'Drum',
      'emoji': '🥁',
    },
  ];

  final Set<int> completed = {};

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ml-IN");
    loadStudentName();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void speakAndMark(int index) async {
    final letter = consonants[index]['letter']!;
    await flutterTts.speak(letter);
    setState(() {
      completed.add(index);
    });
    if (completed.length == consonants.length) {
      setState(() {
        ProgressData.instance.consonantsDone = true;
      });
      await updateProgressInFirestore('consonantsDone', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool allDone = completed.length == consonants.length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Header: 🌴 Malayalam (left) + real student name pill (right) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('🌴 ', style: TextStyle(fontSize: 22)),
                  const Text(
                    'Malayalam',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.green,
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          studentName.isNotEmpty ? studentName : '...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- Back button + Title ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: AppColors.darkGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    '🔠 Consonants',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (allDone)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green, width: 1.5),
                ),
                child: const Text(
                  '🎉 Module Complete! Combined Forms unlocked.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: consonants.length,
                itemBuilder: (context, index) {
                  final bool done = completed.contains(index);
                  return MalayalamCard(
                    malayalamText: consonants[index]['letter']!,
                    englishText: consonants[index]['sound']!,
                    example: consonants[index]['example']!,
                    meaning: consonants[index]['meaning']!,
                    emoji: consonants[index]['emoji']!,
                    isCompleted: done,
                    onTap: () => speakAndMark(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- COMBINED FORMS SCREEN ----------
// Shows all 36 consonants as expandable rows.
// Each row, when opened, shows that consonant's 13 combined forms
// (consonant + each vowel sign) plus a "Play All" button.
class CombinedFormsScreen extends StatefulWidget {
  const CombinedFormsScreen({super.key});

  @override
  State<CombinedFormsScreen> createState() => _CombinedFormsScreenState();
}

class _CombinedFormsScreenState extends State<CombinedFormsScreen> {
  final FlutterTts flutterTts = FlutterTts();

  // The 36 base consonants (same letters as the Consonants screen)
  final List<String> baseConsonants = [
    'ക',
    'ഖ',
    'ഗ',
    'ഘ',
    'ങ',
    'ച',
    'ഛ',
    'ജ',
    'ഝ',
    'ഞ',
    'ട',
    'ഠ',
    'ഡ',
    'ഢ',
    'ണ',
    'ത',
    'ഥ',
    'ദ',
    'ധ',
    'ന',
    'പ',
    'ഫ',
    'ബ',
    'ഭ',
    'മ',
    'യ',
    'ര',
    'ല',
    'വ',
    'ശ',
    'ഷ',
    'സ',
    'ഹ',
    'ള',
    'ഴ',
    'റ',
  ];

  // The English sound of each base consonant (same order as above)
  final List<String> baseSounds = [
    'ka',
    'kha',
    'ga',
    'gha',
    'nga',
    'cha',
    'chha',
    'ja',
    'jha',
    'nja',
    'ta',
    'tha',
    'da',
    'dha',
    'na',
    'tha',
    'thha',
    'dha',
    'dhha',
    'na',
    'pa',
    'pha',
    'ba',
    'bha',
    'ma',
    'ya',
    'ra',
    'la',
    'va',
    'sha',
    'sha',
    'sa',
    'ha',
    'la',
    'zha',
    'ra',
  ];

  // The 13 vowel signs that attach to a consonant, with their suffix sound
  final List<Map<String, String>> vowelSigns = [
    {'sign': '', 'suffix': 'a'},
    {'sign': 'ാ', 'suffix': 'aa'},
    {'sign': 'ി', 'suffix': 'i'},
    {'sign': 'ീ', 'suffix': 'ii'},
    {'sign': 'ു', 'suffix': 'u'},
    {'sign': 'ൂ', 'suffix': 'uu'},
    {'sign': 'ൃ', 'suffix': 'ru'},
    {'sign': 'െ', 'suffix': 'e'},
    {'sign': 'േ', 'suffix': 'ee'},
    {'sign': 'ൈ', 'suffix': 'ai'},
    {'sign': 'ൊ', 'suffix': 'o'},
    {'sign': 'ോ', 'suffix': 'oo'},
    {'sign': 'ൌ', 'suffix': 'au'},
  ];

  // groupedForms[i] = the 13 combined forms that belong to baseConsonants[i]
  late List<List<Map<String, String>>> groupedForms;

  // completedSets[i] = which form-indexes (0-12) are already tapped inside group i
  late List<Set<int>> completedSets;

  // playingIndex[i] = which form (0-12) is currently being spoken inside group i
  // -1 means nothing is playing in that group right now
  late List<int> playingIndex;

  // Tracks the very last form spoken anywhere, to show in the bottom mini-bar
  String? lastPlayedLabel; // e.g. "(6/13) കൂ – Koo"

  // Holds the real logged-in student's name, fetched from Firestore.
  // Starts empty while we are still loading it.
  String studentName = '';

  // Asks Firebase "who is logged in?" then reads that student's name
  // from the 'students' collection in Firestore.
  Future<void> loadStudentName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // not logged in — keep it blank

    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .get();

    if (doc.exists && mounted) {
      setState(() {
        studentName = doc.data()?['name'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ml-IN");
    loadStudentName(); // fetch the real student's name as soon as screen opens

    groupedForms = List.generate(baseConsonants.length, (i) {
      // Remove the trailing "a" from the base sound to get the root sound
      // e.g. "ka" -> "k", so we can build k+aa="kaa", k+i="ki", etc.
      final String root = baseSounds[i].substring(0, baseSounds[i].length - 1);

      return vowelSigns.map((vowel) {
        return {
          'letter': baseConsonants[i] + vowel['sign']!,
          'sound': root + vowel['suffix']!,
        };
      }).toList();
    });

    completedSets = List.generate(baseConsonants.length, (_) => <int>{});
    playingIndex = List.generate(baseConsonants.length, (_) => -1);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  // Speak ONE form and mark it as done
  void speakAndMark(int groupIndex, int formIndex) async {
    final form = groupedForms[groupIndex][formIndex];
    setState(() {
      playingIndex[groupIndex] = formIndex;
      lastPlayedLabel =
          '(${formIndex + 1}/13) ${form['letter']} – ${form['sound']}';
    });
    await flutterTts.speak(form['letter']!);
    setState(() {
      completedSets[groupIndex].add(formIndex);
      playingIndex[groupIndex] = -1;
    });
    checkIfEverythingDone();
  }

  // Speak ALL 13 forms in a group, one after another
  void playAllForGroup(int groupIndex) async {
    for (int formIndex = 0; formIndex < 13; formIndex++) {
      final form = groupedForms[groupIndex][formIndex];
      setState(() {
        playingIndex[groupIndex] = formIndex;
        lastPlayedLabel =
            '(${formIndex + 1}/13) ${form['letter']} – ${form['sound']}';
      });
      await flutterTts.speak(form['letter']!);
      // Small pause so the highlight is visible before moving to the next one
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => completedSets[groupIndex].add(formIndex));
    }
    setState(() => playingIndex[groupIndex] = -1);
    checkIfEverythingDone();
  }

  // If every single form in every group is completed, unlock Words
  void checkIfEverythingDone() async {
    int totalDone = 0;
    for (final set in completedSets) {
      totalDone += set.length;
    }
    if (totalDone == baseConsonants.length * 13) {
      setState(() {
        ProgressData.instance.combinedFormsDone = true;
      });
      await updateProgressInFirestore('combinedFormsDone', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool allDone = completedSets.every((set) => set.length == 13);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Custom header: 🌴 Malayalam (left) + Divya pill (right) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('🌴 ', style: TextStyle(fontSize: 22)),
                  const Text(
                    'Malayalam',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.green,
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          studentName.isNotEmpty ? studentName : '...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ---- Decorative river/temple artwork banner ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/river_banner.png',
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---- Back button + Title row ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: AppColors.darkGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      '🔗 Combined Letters Practice',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- Description paragraph ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Each consonant combines with 13 vowel signs (സ്വരചിഹ്നങ്ങൾ). '
                "Tap a row to expand it, tap any form to hear it, or use 'Play All' "
                'to hear all 13 in sequence.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.brown[500],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (allDone)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green, width: 1.5),
                ),
                child: const Text(
                  '🎉 Module Complete! Words unlocked.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),

            // ---- The expandable list ----
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                itemCount: baseConsonants.length,
                itemBuilder: (context, groupIndex) {
                  final int doneCount = completedSets[groupIndex].length;
                  final bool groupDone = doneCount == 13;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: PageStorageKey(baseConsonants[groupIndex]),
                        tilePadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                        iconColor: AppColors.darkGreen,
                        collapsedIconColor: AppColors.darkGreen,
                        leading: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.link,
                            color: AppColors.green,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          '${baseConsonants[groupIndex]}-vargam combinations',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: groupDone
                                    ? AppColors.green.withOpacity(0.15)
                                    : AppColors.cream,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.softBorder),
                              ),
                              child: Text(
                                '$doneCount/13',
                                style: TextStyle(
                                  color: groupDone
                                      ? AppColors.green
                                      : Colors.brown[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (groupDone)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.green,
                                size: 18,
                              )
                            else
                              const Icon(
                                Icons.expand_more,
                                color: AppColors.darkGreen,
                              ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  foregroundColor: AppColors.cardCream,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: playingIndex[groupIndex] == -1
                                    ? () => playAllForGroup(groupIndex)
                                    : null,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Play All 13 Forms'),
                              ),
                            ),
                          ),
                          GridView.builder(
                            key: PageStorageKey(
                              '${baseConsonants[groupIndex]}_grid',
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.1,
                                ),
                            itemCount: 13,
                            itemBuilder: (context, formIndex) {
                              final bool done = completedSets[groupIndex]
                                  .contains(formIndex);
                              final bool playing =
                                  playingIndex[groupIndex] == formIndex;
                              final form = groupedForms[groupIndex][formIndex];

                              return GestureDetector(
                                onTap: playingIndex[groupIndex] == -1
                                    ? () => speakAndMark(groupIndex, formIndex)
                                    : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: AppColors.cream,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: playing
                                          ? AppColors.gold
                                          : (done
                                                ? AppColors.green
                                                : AppColors.softBorder),
                                      width: playing || done ? 2 : 1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              form['letter']!,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkGreen,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              form['sound']!,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.gold,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (done)
                                        const Positioned(
                                          top: 3,
                                          right: 3,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: AppColors.green,
                                            size: 13,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ---- Bottom mini audio-bar (shows the last played form) ----
            if (lastPlayedLabel != null)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.softBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lastPlayedLabel!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key});
  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Greetings',
      'emoji': '👋',
      'words': [
        {
          'malayalam': 'ഹലോ',
          'english': 'Hello',
          'pronunciation': 'halo',
          'emoji': '👋',
        },
        {
          'malayalam': 'നന്ദി',
          'english': 'Thank you',
          'pronunciation': 'nandi',
          'emoji': '🙏',
        },
        {
          'malayalam': 'സ്വാഗതം',
          'english': 'Welcome',
          'pronunciation': 'svagatham',
          'emoji': '🤗',
        },
        {
          'malayalam': 'ശുഭദിനം',
          'english': 'Good day',
          'pronunciation': 'shubhadinam',
          'emoji': '☀️',
        },
        {
          'malayalam': 'ശുഭരാത്രി',
          'english': 'Good night',
          'pronunciation': 'shubharathri',
          'emoji': '🌙',
        },
        {
          'malayalam': 'വിട',
          'english': 'Goodbye',
          'pronunciation': 'vida',
          'emoji': '👋',
        },
      ],
    },
    {
      'name': 'Fruits',
      'emoji': '🍎',
      'words': [
        {
          'malayalam': 'ആപ്പിൾ',
          'english': 'Apple',
          'pronunciation': 'aappil',
          'emoji': '🍎',
        },
        {
          'malayalam': 'വാഴപ്പഴം',
          'english': 'Banana',
          'pronunciation': 'vaazhappazham',
          'emoji': '🍌',
        },
        {
          'malayalam': 'മാമ്പഴം',
          'english': 'Mango',
          'pronunciation': 'maampazham',
          'emoji': '🥭',
        },
        {
          'malayalam': 'ഓറഞ്ച്',
          'english': 'Orange',
          'pronunciation': 'oranch',
          'emoji': '🍊',
        },
        {
          'malayalam': 'മുന്തിരി',
          'english': 'Grapes',
          'pronunciation': 'munthiri',
          'emoji': '🍇',
        },
        {
          'malayalam': 'തണ്ണിമത്തൻ',
          'english': 'Watermelon',
          'pronunciation': 'thannimathan',
          'emoji': '🍉',
        },
      ],
    },
    {
      'name': 'Animals',
      'emoji': '🐾',
      'words': [
        {
          'malayalam': 'പൂച്ച',
          'english': 'Cat',
          'pronunciation': 'poocha',
          'emoji': '🐱',
        },
        {
          'malayalam': 'നായ',
          'english': 'Dog',
          'pronunciation': 'naaya',
          'emoji': '🐶',
        },
        {
          'malayalam': 'ആന',
          'english': 'Elephant',
          'pronunciation': 'aana',
          'emoji': '🐘',
        },
        {
          'malayalam': 'സിംഹം',
          'english': 'Lion',
          'pronunciation': 'simham',
          'emoji': '🦁',
        },
        {
          'malayalam': 'പശു',
          'english': 'Cow',
          'pronunciation': 'pashu',
          'emoji': '🐄',
        },
        {
          'malayalam': 'മത്സ്യം',
          'english': 'Fish',
          'pronunciation': 'mathsyam',
          'emoji': '🐟',
        },
      ],
    },
    {
      'name': 'Family',
      'emoji': '👨‍👩‍👧‍👦',
      'words': [
        {
          'malayalam': 'അമ്മ',
          'english': 'Mother',
          'pronunciation': 'amma',
          'emoji': '👩',
        },
        {
          'malayalam': 'അച്ഛൻ',
          'english': 'Father',
          'pronunciation': 'achan',
          'emoji': '👨',
        },
        {
          'malayalam': 'മകൻ',
          'english': 'Son',
          'pronunciation': 'makan',
          'emoji': '👦',
        },
        {
          'malayalam': 'മകൾ',
          'english': 'Daughter',
          'pronunciation': 'makal',
          'emoji': '👧',
        },
        {
          'malayalam': 'മുത്തശ്ശി',
          'english': 'Grandmother',
          'pronunciation': 'muthashi',
          'emoji': '👵',
        },
        {
          'malayalam': 'മുത്തശ്ശൻ',
          'english': 'Grandfather',
          'pronunciation': 'muthashan',
          'emoji': '👴',
        },
      ],
    },
    {
      'name': 'Colors',
      'emoji': '🎨',
      'words': [
        {
          'malayalam': 'ചുവപ്പ്',
          'english': 'Red',
          'pronunciation': 'chuvappu',
          'emoji': '🔴',
        },
        {
          'malayalam': 'നീല',
          'english': 'Blue',
          'pronunciation': 'neela',
          'emoji': '🔵',
        },
        {
          'malayalam': 'പച്ച',
          'english': 'Green',
          'pronunciation': 'pacha',
          'emoji': '🟢',
        },
        {
          'malayalam': 'മഞ്ഞ',
          'english': 'Yellow',
          'pronunciation': 'manja',
          'emoji': '🟡',
        },
        {
          'malayalam': 'വെള്ള',
          'english': 'White',
          'pronunciation': 'vella',
          'emoji': '⚪',
        },
        {
          'malayalam': 'കറുപ്പ്',
          'english': 'Black',
          'pronunciation': 'karuppu',
          'emoji': '⚫',
        },
      ],
    },
    {
      'name': 'Numbers',
      'emoji': '🔢',
      'words': [
        {
          'malayalam': 'ഒന്ന്',
          'english': 'One',
          'pronunciation': 'onnu',
          'emoji': '1️⃣',
        },
        {
          'malayalam': 'രണ്ട്',
          'english': 'Two',
          'pronunciation': 'randu',
          'emoji': '2️⃣',
        },
        {
          'malayalam': 'മൂന്ന്',
          'english': 'Three',
          'pronunciation': 'moonnu',
          'emoji': '3️⃣',
        },
        {
          'malayalam': 'നാല്',
          'english': 'Four',
          'pronunciation': 'naalu',
          'emoji': '4️⃣',
        },
        {
          'malayalam': 'അഞ്ച്',
          'english': 'Five',
          'pronunciation': 'anchu',
          'emoji': '5️⃣',
        },
        {
          'malayalam': 'പത്ത്',
          'english': 'Ten',
          'pronunciation': 'paththu',
          'emoji': '🔟',
        },
      ],
    },
  ];

  final Map<int, Set<int>> completedPerCategory = {};
  String studentName = '';

  Future<void> loadStudentName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .get();
    if (doc.exists && mounted) {
      setState(() => studentName = doc.data()?['name'] ?? '');
    }
  }

  @override
  void initState() {
    super.initState();
    loadStudentName();
  }

  bool get allWordsDone {
    int total = categories.fold(0, (s, c) => s + (c['words'] as List).length);
    int done = completedPerCategory.values.fold(0, (s, e) => s + e.length);
    return done == total;
  }

  void onWordCompleted(int catIndex, int wordIndex) async {
    setState(() {
      completedPerCategory.putIfAbsent(catIndex, () => {});
      completedPerCategory[catIndex]!.add(wordIndex);
    });
    if (allWordsDone) {
      setState(() => ProgressData.instance.wordsDone = true);
      await updateProgressInFirestore('wordsDone', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('🌴 ', style: TextStyle(fontSize: 22)),
                  const Text(
                    'Malayalam',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.green,
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          studentName.isNotEmpty ? studentName : '...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: AppColors.darkGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    '📖 Words',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (allWordsDone)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green, width: 1.5),
                ),
                child: const Text(
                  '🎉 Module Complete! Quiz unlocked.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final words = cat['words'] as List;
                  final doneCount = completedPerCategory[index]?.length ?? 0;
                  final isDone = doneCount == words.length;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordCategoryScreen(
                          categoryName: cat['name'],
                          words: words.cast<Map<String, String>>(),
                          initialCompleted: completedPerCategory[index] ?? {},
                          onWordCompleted: (wi) => onWordCompleted(index, wi),
                        ),
                      ),
                    ).then((_) => setState(() {})),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDone
                              ? AppColors.green
                              : AppColors.softBorder,
                          width: isDone ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  cat['emoji'],
                                  style: const TextStyle(fontSize: 34),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$doneCount / ${words.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isDone)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle,
                                color: AppColors.green,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WordCategoryScreen extends StatefulWidget {
  final String categoryName;
  final List<Map<String, String>> words;
  final Set<int> initialCompleted;
  final Function(int) onWordCompleted;

  const WordCategoryScreen({
    super.key,
    required this.categoryName,
    required this.words,
    required this.initialCompleted,
    required this.onWordCompleted,
  });

  @override
  State<WordCategoryScreen> createState() => _WordCategoryScreenState();
}

class _WordCategoryScreenState extends State<WordCategoryScreen> {
  final FlutterTts flutterTts = FlutterTts();
  late Set<int> completed;
  int? currentlyPlaying;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ml-IN");
    completed = Set.from(widget.initialCompleted);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void speakAndMark(int index) async {
    setState(() => currentlyPlaying = index);
    await flutterTts.speak(widget.words[index]['malayalam']!);
    setState(() {
      currentlyPlaying = null;
      completed.add(index);
    });
    widget.onWordCompleted(index);
  }

  @override
  Widget build(BuildContext context) {
    bool allDone = completed.length == widget.words.length;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: AppColors.darkGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    widget.categoryName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (allDone)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green, width: 1.5),
                ),
                child: Text(
                  '🎉 All ${widget.categoryName} words done!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${completed.length} / ${widget.words.length} completed',
                  style: TextStyle(
                    color: Colors.brown[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: widget.words.length,
                itemBuilder: (context, index) {
                  final word = widget.words[index];
                  final bool done = completed.contains(index);
                  final bool playing = currentlyPlaying == index;
                  return MalayalamCard(
                    malayalamText: word['malayalam']!,
                    englishText: word['pronunciation']!,
                    example: word['english']!,
                    meaning: '',
                    emoji: word['emoji']!,
                    isCompleted: done,
                    isPlaying: playing,
                    onTap: () => speakAndMark(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- QUIZ SCREEN ----------
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String studentName = '';

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Which is the Malayalam vowel for "a"?',
      'options': ['അ', 'ആ', 'ഇ', 'ഉ'],
      'answer': 'അ',
    },
    {
      'question': 'What does "ആന" mean?',
      'options': ['Cat', 'Elephant', 'Cow', 'Dog'],
      'answer': 'Elephant',
    },
    {
      'question': 'Which letter sounds like "ka"?',
      'options': ['ഗ', 'ച', 'ക', 'ട'],
      'answer': 'ക',
    },
    {
      'question': 'What does "അമ്മ" mean?',
      'options': ['Father', 'Sister', 'Mother', 'Brother'],
      'answer': 'Mother',
    },
    {
      'question': 'Which vowel sounds like "ii"?',
      'options': ['ഇ', 'ഈ', 'ഉ', 'എ'],
      'answer': 'ഈ',
    },
    {
      'question': 'What is the Malayalam word for "Water"?',
      'options': ['ജലം', 'മഴ', 'പുഴ', 'തേൻ'],
      'answer': 'ജലം',
    },
    {
      'question': 'Which letter sounds like "ma"?',
      'options': ['പ', 'ബ', 'മ', 'ന'],
      'answer': 'മ',
    },
    {
      'question': 'What does "നായ" mean?',
      'options': ['Cat', 'Dog', 'Fish', 'Cow'],
      'answer': 'Dog',
    },
    {
      'question': 'Which combined form is "ka + aa"?',
      'options': ['കി', 'കാ', 'കു', 'കെ'],
      'answer': 'കാ',
    },
    {
      'question': 'What does "മഴ" mean?',
      'options': ['Sun', 'Wind', 'Rain', 'Cloud'],
      'answer': 'Rain',
    },
    {
      'question': 'Which vowel sounds like "u"?',
      'options': ['ഊ', 'ഉ', 'ഋ', 'ഐ'],
      'answer': 'ഉ',
    },
    {
      'question': 'What is the Malayalam word for "Sun"?',
      'options': ['ചന്ദ്രൻ', 'സൂര്യൻ', 'നക്ഷത്രം', 'ആകാശം'],
      'answer': 'സൂര്യൻ',
    },
    {
      'question': 'Which letter sounds like "ra"?',
      'options': ['ല', 'വ', 'ര', 'യ'],
      'answer': 'ര',
    },
    {
      'question': 'What does "പൂച്ച" mean?',
      'options': ['Dog', 'Cow', 'Cat', 'Elephant'],
      'answer': 'Cat',
    },
    {
      'question': 'Which combined form is "pa + i"?',
      'options': ['പാ', 'പി', 'പു', 'പെ'],
      'answer': 'പി',
    },
    {
      'question': 'What does "നന്ദി" mean?',
      'options': ['Hello', 'Goodbye', 'Sorry', 'Thank you'],
      'answer': 'Thank you',
    },
    {
      'question': 'Which letter sounds like "sa"?',
      'options': ['ശ', 'ഷ', 'സ', 'ഹ'],
      'answer': 'സ',
    },
    {
      'question': 'What does "ഭൂമി" mean?',
      'options': ['Sky', 'Earth', 'Sea', 'Mountain'],
      'answer': 'Earth',
    },
    {
      'question': 'Which vowel sounds like "ai"?',
      'options': ['ഒ', 'ഓ', 'ഔ', 'ഐ'],
      'answer': 'ഐ',
    },
    {
      'question': 'What does "വാഴപ്പഴം" mean?',
      'options': ['Mango', 'Apple', 'Banana', 'Grapes'],
      'answer': 'Banana',
    },
  ];

  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool answered = false;
  bool quizFinished = false;

  Future<void> loadStudentName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .get();
    if (doc.exists && mounted) {
      setState(() => studentName = doc.data()?['name'] ?? '');
    }
  }

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ml-IN");
    loadStudentName();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void selectAnswer(String answer) {
    if (answered) return;
    flutterTts.speak(answer);
    setState(() {
      selectedAnswer = answer;
      answered = true;
      if (answer == questions[currentIndex]['answer']) score++;
    });
  }

  void nextQuestion() async {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        answered = false;
      });
    } else {
      setState(() => quizFinished = true);
      // Fixed: pass mark is now >= 13 (65% of 20), was >= 10
      if (score >= 13) {
        setState(() {
          ProgressData.instance.quizPassed = true;
          ProgressData.instance.quizScore = score;
        });
        await updateProgressInFirestore('quizPassed', true);
      }
      await updateProgressInFirestore('quizScore', score);
    }
  }

  void retakeQuiz() {
    setState(() {
      currentIndex = 0;
      score = 0;
      selectedAnswer = null;
      answered = false;
      quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizFinished) return _buildResultScreen();

    final question = questions[currentIndex];
    final String correctAnswer = question['answer'];
    final List<String> options = List<String>.from(question['options']);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Header: 🌴 Malayalam (left) + student pill (right) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('🌴 ', style: TextStyle(fontSize: 22)),
                  const Text(
                    'Malayalam',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.green,
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          studentName.isNotEmpty ? studentName : '...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ---- Decorative river/temple banner ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/river_banner.png',
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ---- Back button + Title ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: AppColors.darkGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    '📝 Quiz  🌿',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Question counter + Score pill ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentIndex + 1} of ${questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Score: ',
                            style: TextStyle(
                              color: AppColors.darkGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '$score',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / questions.length,
                  minHeight: 10,
                  backgroundColor: AppColors.softBorder,
                  color: AppColors.green,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ---- Question card ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardCream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.softBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '»»',
                            style: TextStyle(
                              color: Colors.brown[300],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MALAYALAM QUIZ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '««',
                            style: TextStyle(
                              color: Colors.brown[300],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('🌼', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 12),

                      Text(
                        question['question'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: AppColors.softBorder, thickness: 1),
                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.4,
                        children: options.map((option) {
                          Color borderColor = AppColors.softBorder;
                          Color bgColor = AppColors.cream;

                          if (answered) {
                            if (option == correctAnswer) {
                              borderColor = AppColors.green;
                              bgColor = AppColors.green.withOpacity(0.1);
                            } else if (option == selectedAnswer) {
                              borderColor = Colors.redAccent;
                              bgColor = Colors.redAccent.withOpacity(0.08);
                            }
                          } else if (selectedAnswer == option) {
                            borderColor = AppColors.gold;
                          }

                          return GestureDetector(
                            onTap: () => selectAnswer(option),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppColors.gold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.volume_up,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkGreen,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '🌿',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---- Next button ----
            if (answered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: nextQuestion,
                    child: Text(
                      currentIndex < questions.length - 1
                          ? 'Next Question →'
                          : 'See Result',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final bool passed = score >= 13; // 65% of 20
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.softBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    passed ? '🎉' : '😔',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    passed ? 'Congratulations!' : 'Better luck next time!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Score: $score / ${questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((score / questions.length) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: passed ? AppColors.green : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed ? 'Pass ✅ (need ≥ 13/20)' : 'Fail ❌ (need ≥ 13/20)',
                    style: TextStyle(
                      color: passed ? AppColors.green : Colors.redAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (passed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('🏆  Claim Certificate'),
                      ),
                    ),
                  if (!passed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: retakeQuiz,
                        child: const Text('🔁  Retake Quiz'),
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- CERTIFICATE SCREEN ----------
class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});
  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

enum _CertState { loading, locked, ready }

class _CertificateScreenState extends State<CertificateScreen> {
  _CertState state = _CertState.loading;
  bool working = false;
  String? error;
  String studentName = '';

  // Cached in memory only — lets "Download Again" skip regenerating
  // within this session. Not persisted (no Storage in this build).
  Uint8List? _cachedPdfBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();
      studentName = doc.data()?['name'] ?? '';
    }

    final eligible = await CertificateService.isEligible();
    setState(() => state = eligible ? _CertState.ready : _CertState.locked);
  }

  Future<void> _generateAndShare({bool forceRegenerate = false}) async {
    setState(() {
      working = true;
      error = null;
    });
    try {
      final bytes = forceRegenerate || _cachedPdfBytes == null
          ? await CertificateService.generatePdfForCurrentUser()
          : _cachedPdfBytes!;

      _cachedPdfBytes = bytes;

      // Mark completion in Firestore (reuses your existing 'students' fields)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .update({
              'completed': true,
              'completedDate': DateTime.now().toIso8601String(),
              'quizScore': ProgressData.instance.quizScore,
            });
      }

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'malayalam_certificate.pdf',
      );
      setState(() => working = false);
    } catch (e) {
      setState(() {
        error = 'Something went wrong. Please try again.';
        working = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text('Certificate'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (state == _CertState.loading) {
      return const CircularProgressIndicator(color: AppColors.green);
    }

    if (state == _CertState.locked) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.softBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 56, color: AppColors.gold),
            const SizedBox(height: 14),
            const Text(
              'Certificate Locked',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete all modules and pass the quiz (≥ 65%) to unlock your certificate.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.brown[400]),
            ),
          ],
        ),
      );
    }

    final bool hasGenerated = _cachedPdfBytes != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          const Text(
            '🎉 You passed the Quiz!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            studentName.isNotEmpty
                ? 'Congratulations, $studentName!'
                : 'Congratulations!',
            style: TextStyle(color: Colors.brown[400]),
          ),
          const SizedBox(height: 24),
          if (error != null) ...[
            Text(
              error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: working ? null : () => _generateAndShare(),
              icon: working
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(
                hasGenerated
                    ? '📄 Download Certificate Again'
                    : 'Download Certificate',
              ),
            ),
          ),
          if (hasGenerated) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: working
                  ? null
                  : () => _generateAndShare(forceRegenerate: true),
              child: const Text('Regenerate certificate'),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------- FACULTY SCREEN ----------
class FacultyScreen extends StatefulWidget {
  const FacultyScreen({super.key});
  @override
  State<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyScreen> {
  // This will hold the list of completed students from Firestore
  List<Map<String, dynamic>> completedStudents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCompletedStudents();
  }

  // Fetch all students where completed == true from Firestore
  Future<void> loadCompletedStudents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('completed', isEqualTo: true)
          .get();

      setState(() {
        completedStudents = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading students: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Portal'),
        actions: [
          // Refresh button to reload the list
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadCompletedStudents();
            },
          ),
        ],
      ),
      body: isLoading
          // Show loading spinner while fetching
          ? const Center(child: CircularProgressIndicator())
          // Show empty message if no students completed yet
          : completedStudents.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🧑‍🏫', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text(
                    'No students have completed the course yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          // Show list of completed students
          : Column(
              children: [
                // Header showing count
                Container(
                  width: double.infinity,
                  color: Colors.green[50],
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '🏆 ${completedStudents.length} student(s) completed the course',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                // Student list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: completedStudents.length,
                    itemBuilder: (context, index) {
                      final student = completedStudents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.green[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name + completion badge
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    student['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Class
                              Row(
                                children: [
                                  const Icon(
                                    Icons.school,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Class: ${student['class'] ?? '-'}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Email
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(student['email'] ?? '-'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Phone
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(student['phone'] ?? '-'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Score
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Quiz Score: ${student['quizScore'] ?? '-'} / 20',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Completion date
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Completed: ${_formatDate(student['completedDate'])}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // Converts "2024-01-15T10:30:00" to "15/01/2024"
  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '-';
    }
  }
}
