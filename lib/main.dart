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
                      }else if (module['title'] == 'Words') {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const WordsScreen()),
  ).then((_) { setState(() {}); });
} else if (module['title'] == 'Quiz') {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const QuizScreen()),
  ).then((_) { setState(() {}); });
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

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ml-IN");

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
    final letter = groupedForms[groupIndex][formIndex]['letter']!;
    setState(() => playingIndex[groupIndex] = formIndex);
    await flutterTts.speak(letter);
    setState(() {
      completedSets[groupIndex].add(formIndex);
      playingIndex[groupIndex] = -1;
    });
    checkIfEverythingDone();
  }

  // Speak ALL 13 forms in a group, one after another
  void playAllForGroup(int groupIndex) async {
    for (int formIndex = 0; formIndex < 13; formIndex++) {
      setState(() => playingIndex[groupIndex] = formIndex);
      final letter = groupedForms[groupIndex][formIndex]['letter']!;
      await flutterTts.speak(letter);
      // Small pause so the highlight is visible before moving to the next one
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => completedSets[groupIndex].add(formIndex));
    }
    setState(() => playingIndex[groupIndex] = -1);
    checkIfEverythingDone();
  }

  // If every single form in every group is completed, unlock Words
  void checkIfEverythingDone() {
    int totalDone = 0;
    for (final set in completedSets) {
      totalDone += set.length;
    }
    if (totalDone == baseConsonants.length * 13) {
      setState(() {
        ProgressData.instance.combinedFormsDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool allDone = completedSets.every((set) => set.length == 13);

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
          Expanded(
            child: ListView.builder(
              itemCount: baseConsonants.length,
              itemBuilder: (context, groupIndex) {
                final int doneCount = completedSets[groupIndex].length;
                final bool groupDone = doneCount == 13;

                return ExpansionTile(
                  key: PageStorageKey(baseConsonants[groupIndex]),
                  title: Row(
                    children: [
                      Text(
                        baseConsonants[groupIndex],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$doneCount/13',
                        style: TextStyle(
                          color: groupDone ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (groupDone) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                      ],
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
                          onPressed: playingIndex[groupIndex] == -1
                              ? () => playAllForGroup(groupIndex)
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play All 13 Forms'),
                        ),
                      ),
                    ),
                    GridView.builder(
                      key: PageStorageKey('${baseConsonants[groupIndex]}_grid'),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: 13,
                      itemBuilder: (context, formIndex) {
                        final bool done = completedSets[groupIndex].contains(
                          formIndex,
                        );
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
                              color: playing
                                  ? Colors.orange[100]
                                  : (done
                                        ? Colors.green[50]
                                        : Colors.purple[50]),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: playing
                                    ? Colors.orange
                                    : (done ? Colors.green : Colors.grey[300]!),
                                width: playing || done ? 2 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        form['letter']!,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        form['sound']!,
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
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ],
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

  bool get allWordsDone {
    int total = categories.fold(0, (s, c) => s + (c['words'] as List).length);
    int done = completedPerCategory.values.fold(0, (s, e) => s + e.length);
    return done == total;
  }

  void onWordCompleted(int catIndex, int wordIndex) {
    setState(() {
      completedPerCategory.putIfAbsent(catIndex, () => {});
      completedPerCategory[catIndex]!.add(wordIndex);
      if (allWordsDone) ProgressData.instance.wordsDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Words')),
      body: Column(
        children: [
          if (allWordsDone)
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.all(12),
              child: const Text(
                '🎉 Module Complete! Quiz unlocked.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2 as double,
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
                      color: isDone ? Colors.green[50] : Colors.purple[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone ? Colors.green : Colors.grey[300]!,
                        width: isDone ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat['emoji'],
                          style: const TextStyle(fontSize: 36),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$doneCount / ${words.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (isDone)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
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
      appBar: AppBar(title: Text(widget.categoryName)),
      body: Column(
        children: [
          if (allDone)
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.all(12),
              child: Text(
                '🎉 All ${widget.categoryName} words done!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '${completed.length} / ${widget.words.length} completed',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
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
                return GestureDetector(
                  onTap: () => speakAndMark(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: playing
                          ? Colors.orange[100]
                          : (done ? Colors.green[50] : Colors.purple[50]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: playing
                            ? Colors.orange
                            : (done ? Colors.green : Colors.grey[300]!),
                        width: playing || done ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                word['emoji']!,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                word['malayalam']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                word['pronunciation']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              Text(
                                word['english']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (playing)
                                const Text(
                                  '🔊 Playing...',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
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

  void selectAnswer(String answer) {
    if (answered) return;
    setState(() {
      selectedAnswer = answer;
      answered = true;
      if (answer == questions[currentIndex]['answer']) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        answered = false;
      });
    } else {
      setState(() {
        quizFinished = true;
        if (score >= 10) {
          ProgressData.instance.quizPassed = true;
        }
      });
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
    if (quizFinished) {
      final bool passed = score >= 10;
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  passed ? '🎉 Congratulations!' : '😔 Better luck next time!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Score: $score / ${questions.length}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  '${((score / questions.length) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  passed ? 'Pass ✅ (need ≥ 10/20)' : 'Fail ❌ (need ≥ 10/20)',
                  style: TextStyle(
                    color: passed ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                if (passed)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '🏆 Claim Certificate',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (!passed)
                  ElevatedButton(
                    onPressed: retakeQuiz,
                    child: const Text('🔁 Retake Quiz'),
                  ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[currentIndex];
    final String correctAnswer = question['answer'];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Text(
              'Question ${currentIndex + 1} / ${questions.length}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.purple,
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $score',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Question box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question['question'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...List.generate(question['options'].length, (i) {
              final String option = question['options'][i];
              Color cardColor = Colors.white;
              Color borderColor = Colors.grey[300]!;

              if (answered) {
                if (option == correctAnswer) {
                  cardColor = Colors.green[100]!;
                  borderColor = Colors.green;
                } else if (option == selectedAnswer &&
                    option != correctAnswer) {
                  cardColor = Colors.red[100]!;
                  borderColor = Colors.red;
                }
              } else if (selectedAnswer == option) {
                cardColor = Colors.purple[100]!;
                borderColor = Colors.purple;
              }

              return GestureDetector(
                onTap: () => selectAnswer(option),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),

            const Spacer(),

            // Next button
            if (answered)
              SizedBox(
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
          ],
        ),
      ),
    );
  }
}
