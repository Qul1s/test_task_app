import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_page_transitions/awesome_page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_task_app/api_key.dart';
import 'package:test_task_app/authentication.dart';
import 'package:test_task_app/firebase_controller.dart';

import 'login_page.dart';
import 'profile_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});


  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Timer? timer;

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  CameraPosition cameraPosition = const CameraPosition(target: LatLng(50.4336117, 30.4040083), zoom: 4);

  final List<Marker> _markers = <Marker>[];

  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    getUsersLocation();
    toCurrentLocation();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => setLocation());
    super.initState();  
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromRGBO(30, 30, 30, 1)),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width*0.6,
        backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.07),
              child: Image.asset("images/logo.png", width: MediaQuery.of(context).size.width*0.2)),
            ScaleTap(
              onPressed: () {
                Navigator.push(context, AwesomePageRoute(
                                          transitionDuration: const Duration(milliseconds: 600),
                                          exitPage: widget,
                                          enterPage: const ProfilePage(),
                                          transition: StackTransition()));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.5),
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                width: MediaQuery.of(context).size.width*0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(230, 230, 230, 1),
                ), 
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height*0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.person, color: Color.fromRGBO(30, 30, 30, 1), size: 30,),
                    AutoSizeText("Мій профіль", 
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                        color: Color.fromRGBO(30, 30, 30, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                      minFontSize: 12,
                      stepGranularity: 1,
                      textAlign: TextAlign.center),
                ],))),
            ScaleTap(
              onPressed: () {
                AuthenticationServices().signOut();
                Navigator.push(context, AwesomePageRoute(
                                          transitionDuration: const Duration(milliseconds: 600),
                                          exitPage: widget,
                                          enterPage: const LoginPage(),
                                          transition: StackTransition()));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.03),
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.08),
                width: MediaQuery.of(context).size.width*0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(230, 230, 230, 1),
                ), 
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height*0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.login_rounded, color: Color.fromRGBO(30, 30, 30, 1), size: 30,),
                    AutoSizeText("Вийти", style: GoogleFonts.nunito(
                                                        textStyle: const TextStyle(
                                                        color: Color.fromRGBO(30, 30, 30, 1),
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w600)),
                                              minFontSize: 12,
                                              stepGranularity: 1,
                                              textAlign: TextAlign.center),
                ],)))],
        )
      ),
      body: GoogleMap(
        polylines: Set<Polyline>.of(polylines.values),
        mapType: MapType.terrain,
        initialCameraPosition: cameraPosition,
        markers: Set<Marker>.of(_markers),
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: toCurrentLocation,
        child: const Icon(Icons.location_searching_outlined,),
      ),
    );
  }

  void toCurrentLocation(){
     getUserCurrentLocation().then((value) async {
       CameraPosition cameraPosition = CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 14);
       final GoogleMapController controller = await _controller.future;
       controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
       setState(() {});
    });
  }

  Future<Position> getUserCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      return Future.error('Location permissions are denied');
    }
    else if(permission == LocationPermission.deniedForever){
      return Future.error('Location permissions are permanently denied');
    }
    else{
      return await Geolocator.getCurrentPosition();
    }
  }

  createPolyline(double latitude, double longitude) async {

    getUserCurrentLocation().then((value) async {
      double myLatitude = value.latitude;
      double myLongitude = value.longitude;
  
      polylinePoints = PolylinePoints();

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        api,
        PointLatLng(myLatitude, myLongitude),
        PointLatLng(latitude, longitude),
        travelMode: TravelMode.walking,
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      PolylineId id = const PolylineId('polyline');

      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 3,
      );
      
      setState(() {
        polylines[id] = polyline;       
      });

  });
}

  void setLocation(){
    getUserCurrentLocation().then((value){
      FirebaseConttoller().setLocation(FirebaseAuth.instance.currentUser!.uid, value.latitude, value.longitude);
    });
  }

  void getUsersLocation(){
      final ref = FirebaseDatabase.instance.ref('Users');
      Stream<DatabaseEvent> stream = ref.onValue;
      stream.listen((DatabaseEvent event) {
        setState(() {
          _markers.clear();

          var userLocations = jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
          userLocations.forEach((key, value) {
            _markers.add(
              Marker(
                icon: BitmapDescriptor.defaultMarkerWithHue(getMarkerColor(value["color"])),
                markerId: MarkerId(_markers.length.toString()),
                position: LatLng(value["latitude"], value["longitude"]),
                infoWindow: InfoWindow(title: value["displayName"]),
                onTap: () {
                  showProfileDialog(context, value["photoURL"], value["displayName"], value["email"], value["latitude"], value["longitude"]);
                },
              )
            );
          });
        });
      });
  }

  double getMarkerColor(String color){
    switch(color){
      case "Червоний": return BitmapDescriptor.hueRed;
      case "Жовтий": return BitmapDescriptor.hueYellow;
      case "Зелений": return BitmapDescriptor.hueGreen;
      case "Блакитний": return BitmapDescriptor.hueBlue;
      default: return BitmapDescriptor.hueRed;
    } 
  }

  void showProfileDialog(BuildContext context, image, name, mail, double latitude, double longitude) {
    showDialog<String>(
                 context: context,
                 builder: (BuildContext context) => StatefulBuilder(
                  builder: (context, setModalState){ 
                    return AlertDialog(
                      insetPadding: const EdgeInsets.all(0),
                      shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  contentPadding: const EdgeInsets.all(0),
                  content: Container(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.width* 0.05),
                                  width: MediaQuery.of(context).size.width* 0.5,
                                  height: MediaQuery.of(context).size.height* 0.3,
                                  alignment: Alignment.center,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          child: Image.network(image,
                                              height: MediaQuery.of(context).size.height*0.1,
                                              width: MediaQuery.of(context).size.height*0.1, fit: BoxFit.contain,)
                                        ),
                                        AutoSizeText(name, 
                                          maxLines: 1,
                                          minFontSize: 12,
                                          textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                  color: Color.fromRGBO(30, 30, 30, 1),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600))),
                                        AutoSizeText(mail, 
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          minFontSize: 12,
                                            style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                  color: Color.fromRGBO(30, 30, 30, 1),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600))),
                                        ScaleTap(
                                          onPressed:(){
                                            createPolyline(latitude, longitude);
                                            Navigator.pop(context);
                                          },
                                          scaleMinValue: 0.9,
                                          child: Container(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height* 0.0075,
                                                                      bottom: MediaQuery.of(context).size.height* 0.0075,
                                                                      right: MediaQuery.of(context).size.width* 0.01,
                                                                      left: MediaQuery.of(context).size.width* 0.01),
                                            height: MediaQuery.of(context).size.height* 0.07,
                                            width: MediaQuery.of(context).size.width*0.4,
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(color: Color.fromRGBO(68, 166, 247, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(10)),),
                                            child: AutoSizeText("Побудувати шлях", 
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
                                          ])));
      }));
  } 
 
}