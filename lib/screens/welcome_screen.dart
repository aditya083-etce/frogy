import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/components/essential_button.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_Screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{

  AnimationController controller;
  Animation animation;
  Animation animation2;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(seconds: 5), vsync: this);

    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);

    animation2 = ColorTween(begin: Colors.lightGreenAccent, end: Colors.white).animate(controller);

    controller.forward();

    animation.addStatusListener((status) {
      if(status == AnimationStatus.completed)
        controller.reverse(from: 5.0);
      else if(status == AnimationStatus.dismissed)
        controller.forward();
    });

    animation.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation2.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('images/logo.png'),
                      height: animation.value*100,
                    ),
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Frogy Chat','give it a try'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            EssentialButton(
                text: 'Log In',
                colour: Colors.lightBlueAccent,
                onPressed: (){
                  Navigator.pushNamed(context,LoginScreen.id);
                }),
            EssentialButton(
                text: 'Register',
                colour: Colors.blueAccent,
                onPressed: (){
                  Navigator.pushNamed(context,RegistrationScreen.id);
                }),
          ],
        ),
      ),
    );
  }
}