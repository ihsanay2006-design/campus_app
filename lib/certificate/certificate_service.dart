import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'certificate_generator.dart';

/// STEP 3 — Certificate PDF generation service.
///
/// Responsible for:
///  - Checking that the logged-in student has actually completed the
///    course and passed the quiz (eligibility rule).
///  - Fetching the REAL name/email from Firestore (your app's 'students'
///    collection — never asks the user to type their name again).
///  - Calling CertificateGenerator (Step 2) to produce the PDF bytes.
///
/// Storage upload and Firestore metadata (certificates/{certificateId})
/// are added in Step 4 — this file does not touch Storage yet.
class CertificateService {
  /// Returns true only if every module is complete AND the quiz was passed.
  static Future<bool> isEligible() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .get();

    if (!doc.exists) return false;
    final data = doc.data()!;

    return data['vowelsDone'] == true &&
        data['consonantsDone'] == true &&
        data['combinedFormsDone'] == true &&
        data['wordsDone'] == true &&
        data['quizPassed'] == true;
  }

  /// Fetches the real student name + email from Firestore, then generates
  /// the certificate PDF bytes using the Step 2 generator.
  static Future<Uint8List> generatePdfForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in.');
    }

    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .get();

    final String studentName =
        doc.data()?['name'] ?? user.displayName ?? 'Student';

    // studentEmail isn't used inside this file yet — Step 5 (email) will
    // read it the same way. Fetched here now so eligibility + data-fetch
    // logic lives in one place.
    // final String studentEmail = doc.data()?['email'] ?? user.email ?? '';

    return CertificateGenerator.generate(studentName: studentName);
  }
}
