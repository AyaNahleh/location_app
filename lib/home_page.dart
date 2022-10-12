import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_app/location_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//-122.085749655962;
//37.42796133580664;
class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController googleMapController;
  final Set<Marker> _markers = {};
  final List<LocationHelper> visitedLocation=[];
  bool checkUser=false;

  double? userLocationLongitude;
  double? userLocationLatitude;
  double? longitude;
  double? latitude;



  @override
  void initState() {
    getCurrentUserLocation();
    super.initState();
  }

  Future<void> getCurrentUserLocation() async {

    final locData = await Location().getLocation();
    setState(() {
      userLocationLongitude = locData.longitude!;
      userLocationLatitude = locData.latitude!;

    });

    _addMarker('user Location',LatLng(userLocationLatitude!, userLocationLongitude!));
    // if(checkUser){
    //   googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(latitude!, longitude!), 14));
    //   visitedLocation.add(LocationHelper(longitude!, latitude!));
    // }else {
    //   return;
    // }

  }

  void getBackToCurrentLocation() {
    final currentUser = LatLng(userLocationLatitude!, userLocationLongitude!);
    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(currentUser, 14));
    setState(() {
      visitedLocation.add(LocationHelper(currentUser.longitude, currentUser.latitude));
      longitude=userLocationLongitude;
      latitude=userLocationLatitude;
    });
    _markers.clear();
    _addMarker('user Location', currentUser);
  }

  void getRandomLocation() {
    final random = getRandomDataLocation();
    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(random, 14));
    setState(() {
      visitedLocation.add(LocationHelper(random.longitude, random.latitude));
      latitude=random.latitude;
      longitude=random.longitude;

    });
    _markers.clear();
    _addMarker('random Location', random);
  }

  void previousLocations() {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        scrollable: true,
        elevation: 0,
        backgroundColor: Colors.white.withAlpha(200),
            content: Column(
              children: [
               const Text('Previous',style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                SizedBox(
                  height: 70,
                  width: 200,
                  child:visitedLocation.isNotEmpty? ListView.builder(
                    reverse: true,
                    itemCount: visitedLocation.length,
                      itemBuilder: (ctx,i){
                    return Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Lat: ${visitedLocation[i].latitude.toInt()}',style:const TextStyle(fontWeight: FontWeight.normal),),
                          Text('Lon: ${visitedLocation[i].longitude.toInt()}',style: const TextStyle(fontWeight: FontWeight.normal),),
                        ],
                      ),
                    );

                  }):const Text('no visited location yet',textAlign: TextAlign.center,),
                ),

              ],
            ),
            title: Column(
              children: [
               const Text('Current Location',textAlign: TextAlign.center,),
                Text('Latitude: ${longitude==null?userLocationLongitude!.toInt():longitude!.toInt()}',style: const TextStyle(fontWeight: FontWeight.normal),),
                Text('Longitude:${latitude==null?userLocationLatitude!.toInt():latitude!.toInt()}',style: const TextStyle(fontWeight: FontWeight.normal),),

              ],
            ),
          );

    });
  }

  LatLng getRandomDataLocation() {
    //This is to generate 10 random points
    double x0 = userLocationLatitude!;
    double y0 = userLocationLongitude!;
    Random random = Random();
    // Convert radius from meters to degrees
    double radiusInDegrees = 100000 / 111000;
    double u = random.nextDouble();
    double v = random.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double x = w * cos(t);
    double y = w * sin(t) * 1.75;
    // Adjust the x-coordinate for the shrinking of the east-west distances
    double newX = x / sin(y0);
    double foundLatitude = newX + x0;
    double foundLongitude = y + y0;
    LatLng randomLatLng = LatLng(foundLatitude, foundLongitude);

    return randomLatLng;
  }

  void _addMarker(String location,LatLng userLocation) {
    setState(() {
      _markers.add(
        Marker(
            markerId:  MarkerId(location),
            position: userLocation,
            icon: BitmapDescriptor.defaultMarker),
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        userLocationLongitude != null && userLocationLatitude != null
            ? GoogleMap(
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
          },

          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(userLocationLatitude!, userLocationLongitude!),
            zoom: 14,
          ),
        )
            : const Center(child: CircularProgressIndicator()),

        Positioned(
          top: 20,
          child: IconButton(
              onPressed: previousLocations,
              icon: const Icon(
                Icons.info,
                size: 30,
                color: Colors.blue,
              )),
        ),
        Positioned(
            bottom: 30,
            right: 50,
            left: 50,
            child: Column(
              children: [
                GestureDetector(
                  onTap: getRandomLocation,
                  child: Container(
                    height: 70,
                    width: 250,
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(color: Colors.grey, blurRadius: 10)
                        ],
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: const Text(
                      'Teleport me to somewhere random',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: getBackToCurrentLocation,
                  child: Container(
                    height: 70,
                    width: 250,
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(color: Colors.grey, blurRadius: 10)
                        ],
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: const Center(
                      child: Text(
                        'Bring me back home',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ))
      ]),
    );
  }
}
