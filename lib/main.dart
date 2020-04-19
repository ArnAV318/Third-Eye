import 'dart:io';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';


void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      home: new selectview(),
    );
  }
}

class selectview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
        appBar: AppBar(
        title: Text('Drive  away',textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: Center(
        child: Column (
          children : [

            Text('Third Eye',style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 40)
            ),

            Text('This app aims to provide drivers realtime info of their surrounding and making the roads safer for drivers and the pedestrians',style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 20,),
              textAlign: TextAlign.center,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              textDirection: TextDirection.ltr,
              children: [
                RaisedButton(
                  child: Text('Pedestrian'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => mapview()),
                    );
                  },
                ),

                RaisedButton(
                  child: Text('Driver'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => carview()),
                    );
                  },
                ),
              ],
            ),
            
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        )
      ),
      )
    );
  }}

class Car {
  String name;
  String car_no;
  String car_info;
  String car_color;

}

class carview extends StatefulWidget {
  @override
  carviewState createState() {
    return carviewState();
  }
}
class carviewState extends State<carview> with AfterLayoutMixin<carview> {
  final _formKey = GlobalKey<FormState>();
  Car newcar = new Car(); 
  void _submitForm() {

    final FormState form = _formKey.currentState;
    form.save();
    
  }

  @override
  
  void afterFirstLayout(BuildContext context) {
    print("Hsllo there this widget is ready");
  }


  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
        
        home: Scaffold(
        appBar: AppBar(
          title: Text('Drive  away',textAlign: TextAlign.center,),
          centerTitle: true,
        ),
        body: Center(
          child: new Form(
            key: _formKey,
            child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: 'Enter your full name',
                  labelText: 'Name',
                ),
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.directions_car),
                  hintText: 'Enter the car\'s registration no.',
                  labelText: 'Car no.',
                ),
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.directions_car),
                  hintText: 'Enter the car\'s model',
                  labelText: 'Car info',
                ),
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.color_lens),
                  hintText: 'Enter the car\'s colour',
                  labelText: 'Color',
                ),
              ),
              new Container(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: new RaisedButton(
                        child: const Text('Submit'),
                        onPressed: _submitForm,
                      )),


            ],
            )

            ),
      )
    )
    );
  }
  }


class mapview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
        body: FireMap(),
      )
    );
  }}

class FireMap extends StatefulWidget {
  State createState() => FireMapState();
}


class FireMapState extends State<FireMap> with AfterLayoutMixin<FireMap> {
  GoogleMapController mapController;
  Location location = new Location();
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  // Stateful Data
  BehaviorSubject<double> radius = BehaviorSubject<double>.seeded(100.0);
  Stream<dynamic> query;

  // Subscription
  StreamSubscription subscription;
  @override 
  void afterFirstLayout(BuildContext context) {
    Car nowcar=new Car();
    nowcar.name="arnav";
    nowcar.car_no="mh 05 ab 6131";
    nowcar.car_info="etios";
    nowcar.car_color="black";
    _addGeoPoint(nowcar);
    _listenLocation();
    print("hii");
  }

  var i=1;

  var flag=false;
  build(context)  {
    i+=1;
    if (i==2) {
      print(_location.latitude);
      i=1;
    }
    
    if(!flag){
      sleep(const Duration(seconds:1));
      flag=true;
    }
    
    /*firestore.collection('locations').getDocuments().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }});*/
    return Stack(children: [
    GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_location.latitude,_location.longitude),
            zoom: 15
          ),
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          mapType: MapType.normal, 
          compassEnabled: true,
          trackCameraPosition: true,
      ),
     Positioned(
          bottom: 50,
          right: 10,
          child: 
          FlatButton(
            child: Icon(Icons.pin_drop, color: Colors.white),
            color: Colors.green,
            onPressed: null
          )
      ),
      Positioned(
        bottom: 50,
        left: 10,
        child: Slider(
          min: 100.0,
          max: 500.0, 
          divisions: 4,
          value: radius.value,
          label: 'Radius ${radius.value}km',
          activeColor: Colors.green,
          inactiveColor: Colors.green.withOpacity(0.2),
          onChanged: _updateQuery,
        )
      )
    ]);
  }

  // Map Created Lifecycle Hook
  _onMapCreated(GoogleMapController controller) {
    _startQuery();
    setState(() {
      mapController = controller;
    });
  }

  _addMarker() {
    var marker = MarkerOptions(
      position: mapController.cameraPosition.target,
      icon: BitmapDescriptor.defaultMarker,
      infoWindowText: InfoWindowText('Magic Marker', '🍄🍄🍄')
    );

    mapController.addMarker(marker);
  }

  _animateToUser() async {
    var pos = await location.getLocation();
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 17.0,
        )
      )
    );
  }

  // Set GeoLocation Data
  Future<DocumentReference> _addGeoPoint(Car car) async {
    var pos = await location.getLocation();
    GeoFirePoint point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    print(pos.longitude);
    DocumentReference reference = Firestore.instance.document("locations/" + car.car_no );
    reference.setData({ 
      'position': point.data,
      'name': car.name,
      'number': car.car_no,
      'model': car.car_info,
      'color': car.car_color,
      'speed': pos.speed
    });
    
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    mapController.clearMarkers();
    documentList.forEach((DocumentSnapshot document) {
        GeoPoint pos = document.data['position']['geopoint'];
        double distance = document.data['distance'];
        String name = document.data['name'];
        String car_no= document.data['number'];
        String car_model = document.data['model'];
        String color = document.data['color'];
        double speed = document.data['speed'];
        var marker = MarkerOptions(
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindowText: InfoWindowText('Info : $car_no ','model $car_model, color $color, curr speed: $')
        );


        mapController.addMarker(marker);
    });
  }

  _startQuery() async {
    // Get users location
    var pos = await location.getLocation();
    double lat = pos.latitude;
    double lng = pos.longitude;


    // Make a referece to firestore
    var ref = firestore.collection('locations');
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // subscribe to query
    subscription = radius.switchMap((rad) {
      return geo.collection(collectionRef: ref).within(
        center: center, 
        radius: rad, 
        field: 'position', 
        strictMode: true
      );
    }).listen(_updateMarkers);
  }

  _updateQuery(value) {
      final zoomMap = {
          100.0: 12.0,
          200.0: 10.0,
          300.0: 7.0,
          400.0: 6.0,
          500.0: 5.0 
      };
      final zoom = zoomMap[value];
      mapController.moveCamera(CameraUpdate.zoomTo(zoom));

      setState(() {
        radius.add(value);
      });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

  _listenLocation() async {
    _locationSubscription = location.onLocationChanged().handleError((err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        _error = null;
        _location = currentLocation;
      });
    });

  }

  _stopListen() async {
    _locationSubscription.cancel();
  }


}