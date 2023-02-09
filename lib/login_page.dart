// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_page_transitions/awesome_page_transitions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:test_task_app/authentication.dart';
import 'map_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  void initState() {
    AuthenticationServices().signOut();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: const Color.fromRGBO(30, 30, 30, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset("images/logo.png", width: MediaQuery.of(context).size.width*0.4),
          Container(
            width: MediaQuery.of(context).size.width*0.8,
            height: MediaQuery.of(context).size.height*0.07,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromRGBO(245, 245, 245, 1)
            ),
            child: SignInButton(
                    Buttons.Google,
                    text: "Sign up with Google",
                    shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(15)),
                    onPressed: () {
                      AuthenticationServices().signInWithGoogle().then((value){
                        Navigator.push(context, AwesomePageRoute(
                                                 transitionDuration: const Duration(milliseconds: 600),
                                                 exitPage: widget,
                                                 enterPage: const MapPage(),
                                                 transition: StackTransition()));
                                });
                    },
                  )
          )
      ],
    ));
  }
}

