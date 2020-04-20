import 'dart:io';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import "cars.dart";
import "pedestrians.dart";

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
                      MaterialPageRoute(builder: (context) => personview()),
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

