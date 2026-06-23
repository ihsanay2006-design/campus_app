import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
          color: isPlaying
              ? Colors.orange[100]
              : (isCompleted ? Colors.green[50] : Colors.purple[50]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying
                ? Colors.orange
                : (isCompleted ? Colors.green : Colors.grey[300]!),
            width: isPlaying || isCompleted ? 2 : 1,
          ),
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    englishText,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                  Text(
                    example,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    meaning,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.check_circle, color: Colors.green, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

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
                        ).then((_) {
                          setState(() {});
                        });
                      } else if (module['title'] == 'Consonants') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConsonantsScreen(),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      } else if (module['title'] == 'Combined Forms') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CombinedFormsScreen(),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
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
    await flutterTts.speak(letter);

    setState(() {
      completed.add(index);

      // If all vowels are now done, update the shared progress tracker
      if (completed.length == vowels.length) {
        ProgressData.instance.vowelsDone = true;
      }
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
                crossAxisCount: 2, // fewer per row since cards are bigger now
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85, // makes cards a bit taller
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

  // All 36 Malayalam consonants with their English pronunciation
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

      // If all consonants are done, update shared progress tracker
      if (completed.length == consonants.length) {
        ProgressData.instance.consonantsDone = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool allDone = completed.length == consonants.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Consonants')),
      body: Column(
        children: [
          if (allDone)
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.all(12),
              child: const Text(
                '🎉 Module Complete! Combined Forms unlocked.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    3, // fewer per row since cards now show examples
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
    );
  }
}

// ---------- COMBINED FORMS SCREEN ----------
class CombinedFormsScreen extends StatefulWidget {
  const CombinedFormsScreen({super.key});

  @override
  State<CombinedFormsScreen> createState() => _CombinedFormsScreenState();
}

class _CombinedFormsScreenState extends State<CombinedFormsScreen> {
  final FlutterTts flutterTts = FlutterTts();

  // Base consonants (same 36 as before, just the letters)
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

  // Vowel signs (the small marks added to a consonant) + their pronunciation suffix
  // '' (empty) represents the consonant's natural "a" sound with no extra sign
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

  // This list will hold all 468 generated combined forms
  late List<Map<String, String>> combinedForms;

  final Set<int> completed = {};

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ml-IN");
    combinedForms = generateCombinedForms();
  }

  // Builds all combinations: 36 consonants x 13 vowel signs = 468 forms
  List<Map<String, String>> generateCombinedForms() {
    List<Map<String, String>> result = [];

    for (String consonant in baseConsonants) {
      for (var vowel in vowelSigns) {
        String combinedLetter =
            consonant + vowel['sign']!; // joins consonant + vowel sign
        String pronunciation =
            consonant + vowel['suffix']!; // e.g. "ka" + "aa" style text

        result.add({'letter': combinedLetter, 'sound': pronunciation});
      }
    }

    return result;
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void speakAndMark(int index) async {
    final letter = combinedForms[index]['letter']!;
    await flutterTts.speak(letter);

    setState(() {
      completed.add(index);

      if (completed.length == combinedForms.length) {
        ProgressData.instance.combinedFormsDone = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool allDone = completed.length == combinedForms.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Combined Forms')),
      body: Column(
        children: [
          if (allDone)
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.all(12),
              child: const Text(
                '🎉 Module Complete! Words unlocked.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          // Shows progress count, since 468 is a lot to track visually
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Completed: ${completed.length} / ${combinedForms.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // smaller boxes since there are SO many
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: combinedForms.length,
              itemBuilder: (context, index) {
                final bool done = completed.contains(index);

                return GestureDetector(
                  onTap: () => speakAndMark(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: done ? Colors.green[50] : Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
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
                                combinedForms[index]['letter']!,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                combinedForms[index]['sound']!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (done)
                          const Positioned(
                            top: 2,
                            right: 2,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 12,
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
