import 'package:flutter/material.dart';

class NavBarCategory extends StatefulWidget {
  const NavBarCategory({super.key});

  @override
  State<NavBarCategory> createState() => _NavBarCategoryState();
}

class _NavBarCategoryState extends State<NavBarCategory> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(backgroundColor: Colors.lightBlue,)
    );
  }
}