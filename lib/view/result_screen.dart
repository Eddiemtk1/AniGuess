import 'package:anime_quiz/view/nav_bar_category.dart';
import 'package:anime_quiz/widgets/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestion;
  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestion,
  });

  //final update of score
  Future<void> updateUserScore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection("userData")
          .doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist");
        }
        int existingScore = snapshot["score"] ?? 0;
        transaction.update(userRef, {"score": existingScore + score});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        title: Text("Your Results"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Stack(
                children: [
                  Lottie.network(
                    "https://lottie.host/e799a4a9-ac7f-480a-b3a0-e37277e24eed/CNuv21M3D5.json",
                    height: 200,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                  Lottie.network(
                    "https://lottie.host/e799a4a9-ac7f-480a-b3a0-e37277e24eed/CNuv21M3D5.json",
                    height: 200,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              SizedBox(height: 50),
              Text(
                "Quiz Completed, Well Done!",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                "Your score $score out of $totalQuestion",
                style: const TextStyle(fontSize: 22),
              ),
              //Calaculate the percentage
              Text(
                "${(score / totalQuestion * 100).toStringAsFixed(2)}%",
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavBarCategory(),
                          ),
                          (route) => false,
                        );
                      },
                      buttontext: "Start New Quiz",
                    ),
                  ),
                  Expanded(
                    child: MyButton(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavBarCategory(initialIndex: 1,),
                          ),
                          (route) => false,
                        );
                      },
                      buttontext: "Your Ranking",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
