import 'dart:typed_data';
import 'package:anime_quiz/Services/authenticate_service.dart';
import 'package:anime_quiz/view/login_screen.dart';
import 'package:anime_quiz/widgets/my_button.dart';
import 'package:anime_quiz/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordHidden = true;
  final AuthenticateService _authService = AuthenticateService();

  //Signup function to handle user reg
  void _signUp() async {
    setState(() {
      isLoading = true;
    });
    Uint8List? profileImageBytes;
    //CALL THE METHOD
    final result = await _authService.signUpUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      profileImage: profileImageBytes,
    );

    if (!mounted) return; //If the screen is open, continue. If it's closed, stop.
    if (result == "success") {
      setState(() {
        isLoading = false;
      });
      //NAVIIGATE TO THE NEXT SCREEN WITH ESSAGE
      showSnackBAR(context, "SignUp successful, now turn to Login");
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBAR(context, "SignUp Faied $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  "assets/images/SignUp-icon.png",
                ), //https://shorturl.at/EPRhs
                const SizedBox(height: 20),
          
                //Input field for name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
          
                //Input field for email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
          
                //Input field for password
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: isPasswordHidden,
                ),
                const SizedBox(height: 20),
          
                //For signup button
                isLoading
                    ? const Center(child: CircularProgressIndicator(),
                    )
                    : SizedBox(
                        width: double.infinity,
                        child: MyButton(onTap: _signUp, buttontext: "SignUp"),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login here",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
