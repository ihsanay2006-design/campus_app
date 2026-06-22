import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Campus App', home: const HomeScreen());
  }
}

// ---------- FIRST SCREEN ----------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentScreen(),
                  ),
                );
              },
              child: const Text('Student'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Faculty screen will go here later
              },
              child: const Text('Faculty'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: classController,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  print('Name: ${nameController.text}');
                  print('Class: ${classController.text}');
                  print('Email: ${emailController.text}');
                  print('Phone: ${phoneController.text}');
                  print('Password: ${passwordController.text}');
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Already have an account? Login'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                // For now, just go straight to Dashboard
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- DASHBOARD SCREEN ----------
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Progress is 0% for now — we will calculate this for real later
    double progress = 0.0;

    // List of all modules, in order, with their lock status
    final List<Map<String, dynamic>> modules = [
      {
        'title': 'Vowels',
        'icon': '🔤',
        'locked': false,
      }, // first one is unlocked
      {'title': 'Consonants', 'icon': '🔠', 'locked': true},
      {'title': 'Combined Forms', 'icon': '🔗', 'locked': true},
      {'title': 'Words', 'icon': '📖', 'locked': true},
      {'title': 'Quiz', 'icon': '📝', 'locked': true},
      {'title': 'Certificate', 'icon': '🏆', 'locked': true},
    ];

    return Scaffold(
      appBar: AppBar(
        // Left side: coconut tree + title
        title: const Row(
          children: [
            Text('🌴 ', style: TextStyle(fontSize: 22)),
            Text('Malayalam Learning App', style: TextStyle(fontSize: 18)),
          ],
        ),
        // Right side: logout button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Goes back to the very first screen and removes everything in between
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Overall Progress ----
            const Text(
              'Overall Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress, // 0.0 to 1.0
              minHeight: 12,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Text('${(progress * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 24),

            // ---- Modules Grid ----
            const Text(
              'Modules',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 boxes per row
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
                            content: Text('Complete previous module first!'),
                          ),
                        );
                      } else if (module['title'] == 'Vowels') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VowelsScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening ${module['title']}...'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: locked ? Colors.grey[200] : Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  module['icon'],
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  module['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: locked ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (locked)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.lock,
                                size: 18,
                                color: Colors.grey,
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

// ---------- VOWELS SCREEN ----------
class VowelsScreen extends StatefulWidget {
  const VowelsScreen({super.key});

  @override
  State<VowelsScreen> createState() => _VowelsScreenState();
}

class _VowelsScreenState extends State<VowelsScreen> {
  final FlutterTts flutterTts = FlutterTts(); // the "voice" engine

  // Each vowel has: the Malayalam letter, and how to pronounce it
  final List<Map<String, String>> vowels = [
    {'letter': 'അ', 'sound': 'a'},
    {'letter': 'ആ', 'sound': 'aa'},
    {'letter': 'ഇ', 'sound': 'i'},
    {'letter': 'ഈ', 'sound': 'ii'},
    {'letter': 'ഉ', 'sound': 'u'},
    {'letter': 'ഊ', 'sound': 'uu'},
    {'letter': 'ഋ', 'sound': 'ru'},
    {'letter': 'എ', 'sound': 'e'},
    {'letter': 'ഏ', 'sound': 'ee'},
    {'letter': 'ഐ', 'sound': 'ai'},
    {'letter': 'ഒ', 'sound': 'o'},
    {'letter': 'ഓ', 'sound': 'oo'},
    {'letter': 'ഔ', 'sound': 'au'},
    {'letter': 'അം', 'sound': 'am'},
    {'letter': 'അഃ', 'sound': 'aha'},
  ];

  // Tracks which letters have been tapped already
  final Set<int> completed = {};

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ml-IN"); // Malayalam language code
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void speakAndMark(int index) async {
    final letter = vowels[index]['letter']!;
    await flutterTts.speak(letter); // plays the FULL sound of the letter

    setState(() {
      completed.add(index); // mark this letter as done
    });
  }

  @override
  Widget build(BuildContext context) {
    bool allDone = completed.length == vowels.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Vowels')),
      body: Column(
        children: [
          if (allDone)
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.all(12),
              child: const Text(
                '🎉 Module Complete! Consonants unlocked.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 letters per row
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: vowels.length,
              itemBuilder: (context, index) {
                final bool done = completed.contains(index);

                return GestureDetector(
                  onTap: () => speakAndMark(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: done ? Colors.green[50] : Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: done ? Colors.green : Colors.grey[300]!,
                        width: done ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                vowels[index]['letter']!,
                                style: const TextStyle(
                                  fontSize: 32,
                                ), // big Malayalam letter
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vowels[index]['sound']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey, // smaller English text
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (done)
                          const Positioned(
                            top: 6,
                            right: 6,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
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
    );
  }
}
