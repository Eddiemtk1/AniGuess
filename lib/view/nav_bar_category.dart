import 'package:anime_quiz/view/leaderboard.dart';
import 'package:anime_quiz/view/profile_screen.dart';
import 'package:anime_quiz/view/quiz_category.dart';
import 'package:flutter/material.dart';

class NavBarCategory extends StatefulWidget {
  final int initialIndex;
  const NavBarCategory({super.key, this.initialIndex = 1});

  @override
  State<NavBarCategory> createState() => _NavBarCategoryState();
}

class _NavBarCategoryState extends State<NavBarCategory> {
  final PageStorageBucket bucket = PageStorageBucket();
  final pages = [
    const QuizCategory(),
    const Leaderboard(),
    const ProfileScreen()
  ];
  late int selectedIndex;
  @override
  void initState() {
    selectedIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: bucket, 
      child: pages[selectedIndex],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: "Leaderboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
