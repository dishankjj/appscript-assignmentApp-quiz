import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DynamicAppBar extends StatelessWidget {
  const DynamicAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, aSyncSnapshot) {
          if (aSyncSnapshot.hasData) {
            return Text(
                'Welcome! ${aSyncSnapshot.data?.displayName ?? 'Error'}');
          }
          return const Text('Appscript Assignment - Quiz App');
        });
  }
}
