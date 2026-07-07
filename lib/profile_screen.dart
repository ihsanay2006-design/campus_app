import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'main.dart'; // for AppColors, ProgressData
import 'certificate/certificate_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  bool working = false;
  String? error;

  String name = '';
  String studentClass = '';
  String email = '';
  String phone = '';
  String registerNumber = '';
  bool certEligible = false;

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
      final data = doc.data();
      if (data != null) {
        name = data['name'] ?? '';
        studentClass = data['studentClass'] ?? '';
        email = data['email'] ?? '';
        phone = data['phone'] ?? '';
        registerNumber = data['registerNumber'] ?? '';
      }
    }
    certEligible = await CertificateService.isEligible();
    setState(() => loading = false);
  }

  Future<void> _downloadCertificateAgain() async {
    setState(() {
      working = true;
      error = null;
    });
    try {
      final Uint8List bytes =
          await CertificateService.generatePdfForCurrentUser();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'malayalam_certificate.pdf',
      );
      setState(() => working = false);
    } catch (e) {
      setState(() {
        error = 'Could not generate certificate. Please try again.';
        working = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Back button + Title ----
                    Row(
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
                          '👤 Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ---- Avatar + name card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(18),
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
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.green,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name.isNotEmpty ? name : 'Student',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          if (studentClass.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              studentClass,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.brown[400],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Contact info card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.badge,
                            label: 'Register No',
                            value: registerNumber,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: email,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Progress card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: ProgressData.instance.overallProgress,
                              minHeight: 10,
                              backgroundColor: AppColors.softBorder,
                              color: AppColors.green,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(ProgressData.instance.overallProgress * 100).toStringAsFixed(0)}% complete',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown[400],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ModuleCheck(
                            'Vowels',
                            ProgressData.instance.vowelsDone,
                          ),
                          _ModuleCheck(
                            'Consonants',
                            ProgressData.instance.consonantsDone,
                          ),
                          _ModuleCheck(
                            'Combined Forms',
                            ProgressData.instance.combinedFormsDone,
                          ),
                          _ModuleCheck(
                            'Words',
                            ProgressData.instance.wordsDone,
                          ),
                          _ModuleCheck(
                            'Quiz (score: ${ProgressData.instance.quizScore}/20)',
                            ProgressData.instance.quizPassed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Certificate card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Certificate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (!certEligible)
                            Text(
                              'Complete all modules and pass the quiz to unlock your certificate.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.brown[400],
                              ),
                            )
                          else ...[
                            if (error != null) ...[
                              Text(
                                error!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: working
                                    ? null
                                    : _downloadCertificateAgain,
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
                                label: const Text(
                                  '📄 Download Certificate Again',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.green),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGreen,
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '-',
            style: TextStyle(fontSize: 13, color: Colors.brown[400]),
          ),
        ),
      ],
    );
  }
}

class _ModuleCheck extends StatelessWidget {
  final String label;
  final bool done;
  const _ModuleCheck(this.label, this.done);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: done ? AppColors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: done ? AppColors.darkGreen : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
