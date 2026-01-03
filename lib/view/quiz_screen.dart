import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String categoryName;
  const QuizScreen({super.key, required this.categoryName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> question = [];
  int currentIndex = 0, score = 0;
  int? selectedOption;
  bool hasAnswered = false, isLoading = true;
  @override
  void initState() {
    _fetchQuestions();
    super.initState();
  }

  Future<void> _fetchQuestions() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("quizzes")
          .doc(widget.categoryName)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null && data.containsKey("questions")) {
          var questionMap = data["questions"];

          if (questionMap is Map<String, dynamic>) {
            var fetchQuestions = questionMap.entries.map((entry) {
              var q = entry.value;
              var optionsMap = q["options"] as Map<String, dynamic>;
              var optionList = optionsMap.entries.toList()
                ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
              var options = optionList.map((e) => e.value.toString()).toList();
              return {
                "questionText": q["questionText"] ?? "No Question",
                "options": options,
                "correctIndex": int.tryParse(q["correctIndex"].toString()) ?? 0,
              };
            }).toList();
            //Shuffle and limit the question
            fetchQuestions.shuffle(Random());
            if (fetchQuestions.length > 20) {
              fetchQuestions = fetchQuestions.sublist(0, 20);
            }
            setState(() => question = fetchQuestions);
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (question.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text("-_- No Questions Available")),
      );
    }
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / question.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blueAccent,
              minHeight: 8,
            ),
            const SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      foregroundColor: Colors.white,
      title: Text(
        "${widget.categoryName} (S{currentIndex+1}/${question.length})",
      ),
      centerTitle: true,
      backgroundColor: Colors.blueAccent,
    );
  }
}
