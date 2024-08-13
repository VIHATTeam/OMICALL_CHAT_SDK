import 'package:flutter/material.dart';

import '../../constants.dart';
import '../auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              "assets/images/chat_bubble.png",
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            const Spacer(flex: 3),
            Text(
              "Welcome to OMICALL \nmessaging app",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const Spacer(),
            Text(
              "OMICALL chat any person of your \nmother language.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.64),
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Skip",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
