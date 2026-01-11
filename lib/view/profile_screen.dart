import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:anime_quiz/view/login_screen.dart';
import 'package:anime_quiz/widgets/my_button.dart';
import 'package:anime_quiz/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  Map<String, dynamic>? userData;
  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user == null) return;
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("userData")
          .doc(user!.uid)
          .get();
      if (documentSnapshot.exists) {
        setState(() {
          userData = documentSnapshot.data() as Map<String, dynamic>?;
          if (userData?["photoBase64"] != null) {
            profileImageBytes = base64Decode(userData!["photoBase64"]);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      showSnackBAR(context, "Error getting user data:$e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProfileImage(Uint8List imageBytes) async {
    if (user == null) return;
    try {
      String base64Image = base64Encode(imageBytes);
      //ensure the photobase64 is only updated when non-null
      await FirebaseFirestore.instance
          .collection("userData")
          .doc(user!.uid)
          .set({"photoBase64": base64Image}, SetOptions(merge: true));
          if (!mounted) return;
      setState(() {
        profileImageBytes = imageBytes;
      });
      showSnackBAR(context, "Profile image updated successfully");
    } catch (e) {
      showSnackBAR(context, "Failed to update profile image-_-: $e");
    }
  }

  //Choose image from gallery
  Future<void> pickImageFromGallery() async {
    final returnImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
      maxWidth: 200,
    );
    if (returnImage == null) return;
    //Convert image to bytes
    final imageBytes = await returnImage.readAsBytes();
    if (!mounted) return;

    //update profile image with new image
    await updateProfileImage(imageBytes);
  }

  //For logging out
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(child: Text("No user data found"))
          : Center(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: pickImageFromGallery,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        radius: 60,
                        backgroundImage: profileImageBytes != null
                            ? MemoryImage(profileImageBytes!)
                            : const NetworkImage(
                                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png",
                                  )
                                  as ImageProvider,
                        child: Align(
                          alignment: AlignmentGeometry.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 16,
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      userData?["name"],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Score: ${userData?["score"] * 7 ?? 0}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Divider(),
                    const SizedBox(height: 15),
                    Center(
                      child: Row(
                        children: [
                          Expanded(
                            child: MyButton(
                              onTap: signOut,
                              buttontext: "Sign Out",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
