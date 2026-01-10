import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({super.key});
  Stream<List<Map<String, dynamic>>> getLeaderboardData() {
    return FirebaseFirestore.instance
        .collection('userData')
        .orderBy('score', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  String getShortName(String name){
    return name.length > 7 ? name.substring(0, 7) : name;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: getLeaderboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return Center(child: Text('No users found -_-'));
          }
          final topThree = users.take(3).toList();
          final remainingUser = users.skip(3).toList();

          return Column(
            children: [
              //The Big 3
              const SizedBox(height: 90),
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/podium2.jpg',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      child: Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (topThree.isNotEmpty) //1st place
                      Positioned(
                        top: 35,
                        right: 0,
                        left: 0,
                        child: _buildTopUser(topThree[0], 1, context),
                      ),
                    if (topThree.length >= 2) //2nd place
                      Positioned(
                        top: 85,
                        left: 30,
                        child: _buildTopUser(
                          topThree[1],
                          2,
                          context,
                        ), //3rd place
                      ),
                    if (topThree.length >= 3)
                      Positioned(
                        top: 100,
                        right: 30,
                        child: _buildTopUser(topThree[2], 3, context),
                      ),
                  ],
                ),
              ),
              //Rest of the users
              Expanded(
                child: ListView.builder(
                  itemCount: remainingUser.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final user = remainingUser[index];
                    final rank = index + 4;
                    return _buildRegularUser(user, rank, context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopUser(
    Map<String, dynamic> user,
    int rank,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: rank == 1 ? 30 : 30,
            backgroundImage: user['photoBase64'] != null
                ? MemoryImage(base64Decode(user['photoBase64']))
                : null,
            child: user['photoBase64'] == null
                ? Icon(Icons.person, size: 30)
                : null,
          ),
          SizedBox(height: 10),
          //User name
          Center(
            child: rank == 1
          ? Text(
            user['name'],
            maxLines: 1,
            style: TextStyle(
              fontSize: rank == 1 ? 18 : 18,
              fontWeight: FontWeight.bold,
            ),
          )
          : Text(
            getShortName(
            user['name'],),
            maxLines: 1,
            style: TextStyle(
              fontSize: rank == 1 ? 18 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),),

          const SizedBox(height: 5),
          Container(
            height: 30,
            width: 90,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('👍', style: TextStyle(fontSize: 19)),
                SizedBox(width: 5),
                Text(
                  '${user['score']*7}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildRegularUser(
  Map<String, dynamic> user,
  int rank,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.all(15),
    child: Row(
      children: [
        Text(
          '$rank',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(width: 12),
        //Avatar
        CircleAvatar(
          radius: 25,
          backgroundImage: user['photoBase64'] != null
              ? MemoryImage(base64Decode(user['photoBase64']))
              : null,
        ),
        const SizedBox(width: 16),
        //name of useer
        Text(
          user['name'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        //total points
        Container(
          height: 30,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('👍', style: TextStyle(fontSize: 19)),
              SizedBox(width: 5),
              Text(
                '${user['score']*7}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
