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
        padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
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
            return GridView.builder(
              itemCount: snapshot.data!.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
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
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color:
                        cardColor, //change to color:Colors.blue for return to normal
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            documentSnapshot["image"],
                            height: 130,
                            width: double.maxFinite,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
