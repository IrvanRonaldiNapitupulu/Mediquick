// widget/kelas/quiz_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuizScreen extends StatefulWidget {
  final String moduleId;

  const QuizScreen({super.key, required this.moduleId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List quizzes = [];
  int currentIndex = 0;
  int score = 0;
  String? selectedOption;
  bool isAnswered = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://mediquick.my.id/Course/User/quiz_api.php?action=by_module&id=${widget.moduleId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            quizzes = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            quizzes = [];
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void submitAnswer() {
    final correct =
        (quizzes[currentIndex]['correct_option'] ?? '')
            .toString()
            .toUpperCase();

    if (selectedOption?.toUpperCase() == correct) {
      score++;
    }

    if (currentIndex < quizzes.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        isAnswered = false;
      });
    } else {
      showResult();
    }
  }

  void showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Selamat!", textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700], size: 60),
                const SizedBox(height: 16),
                Text(
                  "Kuis selesai!\nSkor kamu:",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  "$score / ${quizzes.length}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Kembali"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Kuis")),
        body: const Center(
          child: Text("⚠️ Tidak ada soal tersedia untuk modul ini."),
        ),
      );
    }

    final quiz = quizzes[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Soal ${currentIndex + 1} / ${quizzes.length}"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card soal
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  quiz['question'] ?? '-',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pilihan jawaban
            Column(
              children:
                  ['A', 'B', 'C', 'D'].map((option) {
                    final isSelected = selectedOption == option;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.blueAccent
                                  : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RadioListTile<String>(
                        value: option,
                        groupValue: selectedOption,
                        activeColor: Colors.blueAccent,
                        title: Text(
                          quiz['option_${option.toLowerCase()}'] ?? '-',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onChanged: (val) {
                          setState(() {
                            selectedOption = val;
                            isAnswered = true;
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            // Tombol kirim
            ElevatedButton.icon(
              onPressed: isAnswered ? submitAnswer : null,
              icon: Icon(
                currentIndex == quizzes.length - 1
                    ? Icons.check_circle
                    : Icons.arrow_forward_ios_rounded,
              ),
              label: Text(
                currentIndex == quizzes.length - 1 ? "Selesai" : "Selanjutnya",
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAnswered ? Colors.blueAccent : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
