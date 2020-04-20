import 'dart:io';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';



class Person {
  String name;
  String email;
}
Person newcar = new Person(); 

double initlat;
double initlong=0.0;
class personview extends StatefulWidget {
  @override
  personviewState createState() {
    return personviewState();
  }
}
class personviewState extends State<personview> with AfterLayoutMixin<personview> {
  final _formKey = GlobalKey<FormState>();
  Location location = new Location();
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  Future<DocumentReference> _addGeoPoint(Person person) async {
    var pos = await location.getLocation();
    GeoFirePoint point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    print(pos.longitude);
    DocumentReference reference = Firestore.instance.document("locations/" + person.name );
    reference.setData({ 
      'position': point.data,
      'name': person.name,
      'email': person.email,
      'identifier': 'p'
    });
    
  }

  void _submitForm() async{

    var pos = await location.getLocation();
    initlat=pos.latitude;
    initlong=pos.longitude;
    final FormState form = _formKey.currentState;
    form.save();
    _addGeoPoint(newcar);
    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => mapview()),
                    );
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
          title: Text('Walk  away',textAlign: TextAlign.center,),
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
                onSaved: (input) => newcar.name=input,
              ),

              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.directions_car),
                  hintText: 'Enter your email',
                  labelText: 'email',
                ),
                onSaved: (input) => newcar.email=input,
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
  Firestore firestore1 = Firestore.instance;
  _yes(BuildContext c) {
    Navigator.pop(c, true);
    print("heyyy");
    delnode();
  }
  delnode () {
    firestore1.collection('locations').document(newcar.name).delete();
    newcar.name="";
    newcar.email="";
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: new Scaffold(
        body: FireMap(),
        ),
      onWillPop: () => showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Warning'),
        content: Text('Do you really want to exit'),
        actions: [
          FlatButton(
            child: Text('Yes'),
            onPressed: () => _yes(c),
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    ),
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
  BehaviorSubject<double> radius = BehaviorSubject<double>.seeded(1.0);
  Stream<dynamic> query;

  // Subscription
  StreamSubscription subscription;
  @override 
  void afterFirstLayout(BuildContext context) {
    Person nowcar=new Person();
    nowcar=newcar;
    _addGeoPoint(nowcar);
    _listenLocation();
    print("hii");
  }

  var i=0;

  delnode () {
    firestore.collection('locations').document(newcar.name).delete();
    newcar.email="";
    newcar.name="";
  }

  trial (BuildContext c) {
    flag=false;
    _stopListen();
    Navigator.pop(c, true);
    print("heyyy");
    delnode();
  }

  var flag=false;
  build(context)  {
    i+=1;
    if (i==3) {
      i=0;
      updatenode();
    }
    print(i);

    /**/
  
    return Stack(children: [
    GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(initlat,initlong),
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
            child: Icon(Icons.arrow_back, color: Colors.white),
            color: Colors.blue,
            onPressed: () => trial(context)
          )
      ),
      Positioned(
        bottom: 50,
        left: 10,
        child: Slider(
          min: 1.0,
          max: 5.0, 
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

  updatenode() async {
    var pos = await location.getLocation();
    GeoFirePoint point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    Firestore.instance  .collection('locations').document(newcar.name)
      .updateData({
        'position': point.data,
      });
  }

  // Set GeoLocation Data
  Future<DocumentReference> _addGeoPoint(Person car) async {
    var pos = await location.getLocation();
    GeoFirePoint point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    print(pos.longitude);
    DocumentReference reference = Firestore.instance.document("locations/" + car.name );
    reference.setData({ 
      'position': point.data,
      'name': car.name,
      'email': car.email,
      'identifier': 'p'
    });
    
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    mapController.clearMarkers();
    documentList.forEach((DocumentSnapshot document) {
        String identifier=document.data['identifier'];
        if (identifier=='p') {
          GeoPoint pos = document.data['position']['geopoint'];
        double distance = document.data['distance'];
        String name = document.data['name'];
        if(newcar.name!=name) {
        var marker = MarkerOptions(
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.fromAsset('assets/ped.png'),
          infoWindowText: InfoWindowText('Info :','Name : $name')
        );


        mapController.addMarker(marker);
        }
        }
        else {
          GeoPoint pos = document.data['position']['geopoint'];
        double distance = document.data['distance'];
        String name = document.data['name'];
        String car_no= document.data['number'];
        String car_model = document.data['model'];
        String color = document.data['color'];
        double speed = document.data['speed'] * 3.6;
        var marker = MarkerOptions(
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.fromAsset('assets/car.png'),
          infoWindowText: InfoWindowText('Info : $car_no, curr speed: $speed km/hr','model $car_model, color $color')
        );


        mapController.addMarker(marker);
        
        }
        
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
          1.0: 18.0,
          2.0: 17.0,
          3.0: 16.0,
          4.0: 15.0,
          5.0: 15.0 
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