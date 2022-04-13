import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/donations/donations_screen.dart';

import 'auth/login.dart';
import 'donations/upload_donation.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
         builder:(ctx, userSnapshot){
            if(userSnapshot.data == null){
              print('User is not logged in yet!');
              return Login();
            }
            else if(userSnapshot.hasData) {
              print('User is already logged in');
              return DonationScreen();
            }

            else if (userSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('An error has been occurred. Try again later.'),
                ),
              );
            }

            else if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Scaffold(
              body: Center(
                child: Text('An error has been occurred. Try again later.'),
              ),
            );


         }
    );

  }
}