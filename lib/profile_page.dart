import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_page_transitions/awesome_page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_controller.dart';
import 'map_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});


  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String email = "";
  String color = "Червоний";
  String image = "";
  TextEditingController nameController = TextEditingController();
  List<String> colorList = <String>['Червоний', 'Блакитний', 'Зелений', 'Жовтий'];

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async{

      final ref = FirebaseDatabase.instance.ref('Users/${FirebaseAuth.instance.currentUser!.uid}');

      Stream<DatabaseEvent> stream = ref.onValue;
      stream.listen((DatabaseEvent event){
        setState(() {
          var info = jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
          image = info["photoURL"].toString();
          email = info["email"].toString();
          color = info["color"].toString();
          nameController = TextEditingController(text: info["displayName"].toString());
        });
      });
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: const Color.fromRGBO(30, 30, 30, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaleTap(
                  opacityMinValue: 0.2,
                  scaleMinValue: 0.8,
                  duration: const Duration(milliseconds: 1000),
                  onPressed:() {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(10, 10, 10, 1),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width* 0.05,
                                            top: MediaQuery.of(context).size.height* 0.04),
                    width: MediaQuery.of(context).size.width* 0.1,
                    height: MediaQuery.of(context).size.width* 0.1,
                    child: const Icon(Icons.arrow_back_outlined, size: 30, color: Color.fromRGBO(255, 255, 255, 1)))),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width* 0.12,
                                          top: MediaQuery.of(context).size.height* 0.04),
                  width: MediaQuery.of(context).size.width* 0.5,
                  height: MediaQuery.of(context).size.height* 0.04,
                  child: AutoSizeText("Профіль", 
                    textAlign: TextAlign.end,
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 19,
                      fontWeight: FontWeight.w600)))),
                        ],),
                Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.05),
                  alignment: Alignment.center,
                  child: Image.network(image,
                                      height: MediaQuery.of(context).size.height*0.2,
                                      width: MediaQuery.of(context).size.height*0.2, 
                                      fit: BoxFit.contain)),
                headerText("Пошта"),
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.0075,
                                            bottom: MediaQuery.of(context).size.height* 0.0075,
                                            right: MediaQuery.of(context).size.width* 0.005,
                                            left: MediaQuery.of(context).size.width* 0.005),
                  height: MediaQuery.of(context).size.height* 0.06,
                  width: MediaQuery.of(context).size.width*0.9,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color.fromRGBO(200, 200, 200, 1),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: AutoSizeText(email, 
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 12,
                    style: GoogleFonts.montserrat(
                      decoration: TextDecoration.none,
                      textStyle: const TextStyle(
                      color: Color.fromRGBO(30, 30, 30, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600)))),
                headerText("Ім'я"),
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.0075,
                                            bottom: MediaQuery.of(context).size.height* 0.0075,
                                            right: MediaQuery.of(context).size.width* 0.005,
                                            left: MediaQuery.of(context).size.width* 0.005),
                  height: MediaQuery.of(context).size.height* 0.06,
                  width: MediaQuery.of(context).size.width*0.9,
                  decoration: const BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1),
                                                  borderRadius: BorderRadius.all(Radius.circular(10)),),
                  child: TextField(
                      onChanged: (text) => setState(() => text),
                      controller: nameController,
                      obscureText: false,
                      keyboardType: TextInputType.name,
                      textAlign: TextAlign.center,
                      cursorColor: const Color.fromRGBO(240, 240, 240, 1),
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(borderSide:BorderSide(color: Colors.black, width: 1)),
                      enabledBorder: UnderlineInputBorder(borderSide:BorderSide(color: Colors.black, width: 1)),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1))),
                      style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        textStyle: const TextStyle(
                        color: Color.fromRGBO(30, 30, 30, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                    )),
                    headerText("Колір"),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.0075,
                                                bottom: MediaQuery.of(context).size.height* 0.0075,
                                                right: MediaQuery.of(context).size.width* 0.005,
                                                left: MediaQuery.of(context).size.width* 0.005),
                      height: MediaQuery.of(context).size.height* 0.06,
                      width: MediaQuery.of(context).size.width*0.9,
                      decoration: const BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1),
                                                      borderRadius: BorderRadius.all(Radius.circular(10)),),
                      child: DropdownButton<String>(
                                  value: color,
                                  borderRadius: BorderRadius.circular(10),
                                  icon: const Icon(Icons.arrow_downward, size: 25, color: Color.fromRGBO(30, 30, 30, 1)),
                                  elevation: 16,
                                  alignment: Alignment.center,
                                  style: GoogleFonts.montserrat(
                                    decoration: TextDecoration.none,
                                    textStyle: const TextStyle(
                                    color: Color.fromRGBO(30, 30, 30, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                                  underline: Container(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      color = value!;
                                    });
                                  },
                                  items: colorList.map<DropdownMenuItem<String>>((String value){
                                      return DropdownMenuItem<String>(value: value,child: Text(value));
                                    }).toList()
                                )),
                    ScaleTap(
                      onPressed:() => FirebaseConttoller().setDataAboutUser(FirebaseAuth.instance.currentUser!.uid, nameController.text, email, image, color),
                      scaleMinValue: 0.9,
                      child: Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.1),
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.0075,
                                                  bottom: MediaQuery.of(context).size.height* 0.0075,
                                                  right: MediaQuery.of(context).size.width* 0.005,
                                                  left: MediaQuery.of(context).size.width* 0.005),
                        height: MediaQuery.of(context).size.height* 0.09,
                        width: MediaQuery.of(context).size.width*0.9,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color.fromRGBO(10, 10, 10, 1),
                                                        borderRadius: BorderRadius.all(Radius.circular(10)),),
                        child: AutoSizeText("Зберегти", 
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 12,
                          style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            textStyle: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.w600)))),
                )
        ],
    )));
  }


  Widget headerText(String text){
    return Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.02),
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.0075,
                                        bottom: MediaQuery.of(context).size.height* 0.0075,
                                        right: MediaQuery.of(context).size.width* 0.005,
                                        left: MediaQuery.of(context).size.width* 0.005),
              height: MediaQuery.of(context).size.height* 0.06,
              width: MediaQuery.of(context).size.width*0.9,
              alignment: Alignment.centerLeft,
              child: AutoSizeText(text, 
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 12,
                style: GoogleFonts.montserrat(
                  decoration: TextDecoration.none,
                  textStyle: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600))));
  }
}

