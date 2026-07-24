import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/core/constants/api_constants.dart';

class QuizScreen extends StatefulWidget {
  final int moduleId;

  const QuizScreen({super.key, required this.moduleId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> quizzes = [];
  int currentIndex = 0;
  String? selectedOption;
  int score = 0;
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
          '${ApiConstants.courseQuizApi}?action=by_module&id=${widget.moduleId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            quizzes = List.from(data['data']);
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
    final correct = quizzes[currentIndex]['correct_option'];
    if (selectedOption == correct) {
      score += 10;
    }

    if (currentIndex < quizzes.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        isAnswered = false;
      });
    } else {
      showResultDialog();
    }
  }

  void showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Kuis Selesai! 🎉'),
            content: Text(
              'Skor Akhir Anda: $score / ${quizzes.length * 10}',
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Kuis...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuis')),
        body: const Center(child: Text('Belum ada kuis untuk modul ini.')),
      );
    }

    final quiz = quizzes[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Kuis ${currentIndex + 1}/${quizzes.length}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  (quiz['question'] ?? '-').toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                          (quiz['option_${option.toLowerCase()}'] ?? '-').toString(),
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
            ElevatedButton(
              onPressed: isAnswered ? submitAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6482AD),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 40,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                currentIndex == quizzes.length - 1
                    ? 'Lihat Hasil'
                    : 'Pertanyaan Selanjutnya',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
