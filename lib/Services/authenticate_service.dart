import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticateService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error occured";
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //Store data in firestore
      await _firestore.collection("userData").doc(credential.user!.uid).set({
        "name": name,
        "uid": credential.user!.uid,
        "score": 0,
      });
      res = "success";
    } else {
      res = "Please fill in all the boxes";
    }
    try {} catch (err) {
      return err.toString();
    }
    return res;
  }


//For login user
Future<String> loginUser({
  required String email,
  required String password,
}) async {
  String res = "Some error occured";

  try {
  if (email.isNotEmpty && password.isNotEmpty) {
    await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
      );

    res = "success";
  } else {
    res = "Please fill in all the boxes";
  }
  } catch (err) {
    return err.toString();
  }
  return res;
}
}
