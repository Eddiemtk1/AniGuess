import 'package:anime_quiz/view/quiz_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizCategory extends StatefulWidget {
  const QuizCategory({super.key});

  @override
  State<QuizCategory> createState() => _QuizCategoryState();
}

class _QuizCategoryState extends State<QuizCategory> {
  final CollectionReference mycollection = FirebaseFirestore.instance
      .collection("quizzes");
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 80),
              child: StreamBuilder(
                stream: mycollection.orderBy("level", descending: false).snapshots(),
                //Quiz categories now appear in ascending difficulty level
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No categories found"));
                  }
              
                  //Quiz Difficulty
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    padding: EdgeInsets.only(bottom: 20),
              
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          snapshot.data!.docs[index];
                      String docID = documentSnapshot.id;
                      Color cardColor = Colors.blue;
              
                      if (docID == "easy") {
                        cardColor = Colors.green;
                      }
                      if (docID == "medium") {
                        cardColor = Colors.yellow;
                      }
                      if (docID == "hard") {
                        cardColor = Colors.red;
                      }
              
                      //Press quiz to go to quiz screeen
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuizScreen(categoryName: documentSnapshot.id
                                  ),
                            ),
                          );
                        },
                        //Quiz category rectangles
                        child: Container(
                          height: 180,
                          margin: EdgeInsets.only(bottom: 10),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color:
                                cardColor, //change to color:Colors.blue for return to normal
                            child: Column(
                              children: [
                                Expanded(
                                  child: 
                                ClipRRect(
                                  borderRadius: BorderRadiusGeometry.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    documentSnapshot["image"],
                                    height: 80,
                                    width: double.maxFinite,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  documentSnapshot["title"],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
