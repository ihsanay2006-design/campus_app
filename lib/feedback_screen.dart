import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; // for AppColors

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final List<String> questions = [
    'Learning Malayalam through my mobile phone was interesting and engaging.',
    'Mobile learning made it convenient for me to learn Malayalam at my own time.',
    'Mobile-based activities helped me learn new Malayalam words.',
    'Images, audio, and examples on the mobile helped me understand new words.',
    'Listening to Malayalam pronunciation through my mobile helped me pronounce words correctly.',
    'Repeatedly listening to Malayalam words improved my listening ability.',
    'Mobile audio activities helped me distinguish Malayalam sounds more effectively.',
    'Mobile-based reading activities improved my ability to understand simple Malayalam sentences.',
    'The activities helped me learn Malayalam sentence patterns.',
    'Mobile learning increased my interest in learning Malayalam.',
    'I felt motivated to continue learning Malayalam outside the classroom.',
    'Mobile-based practice reduced my hesitation in using Malayalam.',
    'Mobile learning helped me learn at my own pace.',
    'I would like to continue learning Malayalam through mobile-based activities.',
    'I would recommend mobile-based Malayalam learning to other students.',
  ];

  final List<String> optionLabels = [
    'Strongly Agree',
    'Agree',
    'Neutral',
    'Disagree',
    'Strongly Disagree',
  ];

  // optionLabels[0] = score 5, optionLabels[4] = score 1
  final List<int> optionScores = [5, 4, 3, 2, 1];

  // answers[questionIndex] = selected score (or null if not answered yet)
  late List<int?> answers;

  bool submitting = false;

  @override
  void initState() {
    super.initState();
    answers = List.filled(questions.length, null);
  }

  bool get allAnswered => !answers.contains(null);

  Future<void> _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => submitting = true);

    // Build a map like {"q1": 5, "q2": 4, ...}
    final Map<String, int> responses = {
      for (int i = 0; i < questions.length; i++) 'q${i + 1}': answers[i]!,
    };

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .update({'feedbackResponses': responses, 'feedbackSubmitted': true});

      // Unlock Certificate immediately without needing to reopen the app
      ProgressData.instance.feedbackSubmitted = true;

      if (mounted) {
        Navigator.pop(context, true); // true = feedback was submitted
      }
    } catch (e) {
      setState(() => submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text('Feedback Form'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'Please answer all ${questions.length} questions before submitting.',
                style: TextStyle(color: Colors.brown[400], fontSize: 13),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${questions[index]}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(optionLabels.length, (i) {
                            final bool selected =
                                answers[index] == optionScores[i];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  answers[index] = optionScores[i];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.green
                                      : AppColors.cream,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.green
                                        : AppColors.softBorder,
                                  ),
                                ),
                                child: Text(
                                  optionLabels[i],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.darkGreen,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (allAnswered && !submitting)
                      ? _submitFeedback
                      : null,
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Feedback'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
