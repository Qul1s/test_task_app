import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_task_app/firebase_controller.dart';


class AuthenticationServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>["email"]);

  Future<UserCredential> signInWithGoogle() async{
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );

    UserCredential authResult = await _auth.signInWithCredential(credential);
    FirebaseConttoller().setDataAboutUser(authResult.user!.uid, authResult.user!.displayName, authResult.user!.email, authResult.user!.photoURL);

    return authResult;
  }

  Future<void> signOut() async {
      await FirebaseAuth.instance.signOut();
     _googleSignIn.signOut();
  }
}

