import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreen();
}

class ProfileScreen extends State<ProfileScreen> {
    final User? user = FirebaseAuth.instance.currentUser;
    bool isLoading = true;
    void initState(){
        super.initState();
        fetchUserData();
    }

        Future<void> fetchUserData() async{
            if(user == null) return;
            try{
                DocumentSnapshot documentSnapshot = await Fir
            }catch(e){
                print(e.toString());
            }
        }

    @override
    Widget build(BuildContext context){
        return const Placeholder();
    }
}

