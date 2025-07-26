import 'package:flutter/material.dart';
import 'package:music_app/layouts/auth/sign_in/index.dart';

class RequestLogin extends StatelessWidget {
  const RequestLogin({super.key});

  void _onSignIn(context) async {
    showModalBottomSheetSignIn(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Please login to use this feature!',
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              _onSignIn(context);
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
