import 'package:anime_quiz/Services/authenticate_service.dart';
import 'package:anime_quiz/view/nav_bar_category.dart';
import 'package:anime_quiz/widgets/my_button.dart';
import 'package:anime_quiz/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:anime_quiz/view/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordHidden = true;
  final AuthenticateService _authService = AuthenticateService();

  //login function to handle user reg
  void _login() async {
    setState(() {
      isLoading = true;
    });
    //CALL THE METHOD
    final result = await _authService.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted){
      return;  
      }   //If the screen is open, continue. If it's closed, stop.
    if (result == "success") {
      setState(() {
        isLoading = false;
      });
      //NAVIIGATE TO THE NEXT SCREEN WITH MESSSAGE
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavBarCategory()),
      );
    } else {
      setState(() {
        isLoading = false;
      });

      String message = result;
      if (result.contains("invalid-credential") || result.contains("user-not-found") || result.contains("wrong-password")){
        message = "Incorrect email or password. Please try again.";
      }else if (result.contains("invalid-email")){
        message = "Please enter a valid email address";
      }else if (result.contains("too-many-requests")){
        message = "Way too many attempts. Chill out";
      }

      showSnackBAR(context, message);
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
                Image.asset("assets/images/Login-icon.png"),
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

                //For login button
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: MyButton(onTap: _login, buttontext: "Login"),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Signup here",
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
