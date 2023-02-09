import 'package:firebase_database/firebase_database.dart';

class FirebaseConttoller{

  void setDataAboutUser(String? userId, String? displayName, String? email, String? photoURL, [color = "Червоний"]) async{
    final usersQuery = FirebaseDatabase.instance.ref('Users/$userId');
    await usersQuery.update({
                            "displayName": displayName,
                            "email": email,
                            "photoURL": photoURL,
                            "color": color
                            });
  }

  void setLocation(String? userId, double latitude, double longitude) async{
    final usersQuery = FirebaseDatabase.instance.ref('Users/$userId');
    await usersQuery.update({
                            "latitude": latitude,
                            "longitude": longitude,
                            });
  }

}