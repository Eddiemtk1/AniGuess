// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:anime_quiz/view/result_screen.dart';
import 'package:anime_quiz/widgets/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    debugPrint("LOOKING FOR DOCUMENT NAMED: ${widget.categoryName}");
    try {
      var collectionSnapshot = await FirebaseFirestore.instance
          .collection("quizzes")
          .doc(widget.categoryName)
          .collection("questions")
          .get();

      var fetchQuestions = collectionSnapshot.docs.map((doc) {
        var data = doc.data();

        List<String> options = List<String>.from(data["options"]);

        return {
          "questionText": data["questionText"] ?? "No Question",
          "options": options,
          "correctIndex": int.tryParse(data["correctIndex"].toString()) ?? 0,
        };
      }).toList();

      //Shuffle and limit the question
      fetchQuestions.shuffle(Random());
      if (fetchQuestions.length > 20) {
        fetchQuestions = fetchQuestions.sublist(0, 20);
      }
      setState(() {
        question = fetchQuestions;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error getting questions");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //Check the correct answer
  void _checkAnswer(int index) {
    setState(() {
      hasAnswered = true;
      selectedOption = index;
      if (question[currentIndex]["correctIndex"] == index) {
        score++;
      }
    });
  }

  //for next question
  Future<void> _nextQuestion() async {
    if (currentIndex < question.length - 1) {
      setState(() {
        currentIndex++;
        hasAnswered = false;
        selectedOption = null;
      });
    } else {
      await _updateUserScore();
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(score: score,totalQuestion: question.length,)),
      );
    }
  }

  Future<void> _updateUserScore() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      var userRef = FirebaseFirestore.instance
          .collection("userData")
          .doc(user.uid);
          await FirebaseFirestore.instance.runTransaction((transaction)async{
            var snapshot = await transaction.get(userRef);
            if(!snapshot.exists) return;
            int existingScore = snapshot["score"] ?? 0;
            transaction.update(userRef, {"score": existingScore + score});
          });
    } catch (e) {
      debugPrint("error update score $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: (question.isEmpty)
                  ? 0
                  : (currentIndex + 1) / question.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blueAccent,
              minHeight: 15,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                question.isNotEmpty
                    ? question[currentIndex]["questionText"] as String
                    : "Loading...",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            //for option list
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return _buildOption(index);
                },
                separatorBuilder: (_, _) => SizedBox(height: 15),
                itemCount: question[currentIndex]["options"].length,
              ),
            ),
            //Conditionally render the next/finish button
            if (hasAnswered)
              MyButton(
                onTap: _nextQuestion,
                buttontext: currentIndex == question.length - 1
                    ? "Finish"
                    : "Next",
              ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index) {
    bool isCorrect = question[currentIndex]["correctIndex"] == index;
    bool isSelected = selectedOption == index;
    Color bgcolor = hasAnswered
        ? (isCorrect
              ? Colors.green.shade300
              : isSelected
              ? Colors.red.shade300
              : Colors.grey.shade200)
        : Colors.grey.shade200;
    Color textColor = hasAnswered && (isCorrect || isSelected)
        ? Colors.white
        : Colors.black;
    return InkWell(
      onTap: hasAnswered? null :()=>_checkAnswer(index),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        decoration: BoxDecoration(
          color: bgcolor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          question[currentIndex]["options"][index],
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: textColor),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      foregroundColor: Colors.white,
      title: Text(
        "${widget.categoryName} (${currentIndex + 1}/${question.length})",
      ),
      centerTitle: true,
      backgroundColor: Colors.blueAccent,
    );
  }
}
