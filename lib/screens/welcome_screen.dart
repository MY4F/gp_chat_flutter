import 'package:flutter/material.dart';
import 'package:gp_chat_flutter/screens/registration_screen.dart';
import 'package:gp_chat_flutter/screens/signin_screen.dart';
import 'package:gp_chat_flutter/widgets/my_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String screenRoute = 'welcome_screen';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  height: 180,
                  child: Image.asset('images/logo1.png'),
                ),
                Text(
                  'Voicey',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            MyButton(
              color: Colors.white,
              title: "Sign In",
              onPressed: () {
                Navigator.pushNamed(context, SignInScreen.screenRoute);
              },
              textColor: Colors.black,
            ),
            MyButton(
              color: Colors.black,
              title: 'Sign Up',
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.screenRoute);
              },
                textColor: Colors.white
            )
          ],
        ),
      ),
    );
  }
}