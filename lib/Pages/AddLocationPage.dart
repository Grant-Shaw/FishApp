import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:intl/intl.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({Key? key}) : super(key: key);

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  String _currentfish = 'Select a fish type';
  String _currentweight = '0.00';
  String _currentmethod = 'Select a method...';
  final List<String> fish = [
    'Select a fish type',
    'Perch',
    'Pike',
    'Trout',
    'Roach'
  ];
  final List<String> methods = ['Select a method...', 'Bait', 'Lure'];
  late CollectionReference locations;

  void getLocations() {
    locations = FirebaseFirestore.instance.collection('locations');
  }

  @override
  void initState() {
    super.initState();
    getLocations();
  }

  //Sets the map marker colours depending on which fish is chosen.
  List<Marker> setMarker(String lati, String longi, String fish) {
    List<Marker> _tempList = [];
    Marker _marker;
    if (fish == 'Perch') {
      Marker _marker = Marker(
          markerId: MarkerId('Perch'),
          position: LatLng(double.parse(lati), double.parse(longi)),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      _tempList.add(_marker);
    }
    if (fish == 'Roach') {
      Marker _marker = Marker(
          markerId: MarkerId('Roach'),
          position: LatLng(double.parse(lati), double.parse(longi)),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange));
      _tempList.add(_marker);
    }
    if (fish == 'Pike') {
      Marker _marker = Marker(
          markerId: MarkerId('Pike'),
          position: LatLng(double.parse(lati), double.parse(longi)),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));
      _tempList.add(_marker);
    }
    if (fish == 'Trout') {
      Marker _marker = Marker(
          markerId: MarkerId('Trout'),
          position: LatLng(double.parse(lati), double.parse(longi)),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet));
      _tempList.add(_marker);
    }

    return _tempList;
  }

  // Draws the map and sets the markers to conntain  a single marker relating to whichever was selected from the list
  Widget _showMap(String lati, String longi, String fish) {
    Completer<GoogleMapController> _googleMapController = Completer();

    setMarker(lati, longi, fish);
    List<Marker> _markers = setMarker(lati, longi, fish);

    LatLng _initialPosition = LatLng(double.parse(lati), double.parse(longi));
    print(_initialPosition);
    return Container(
      child: GoogleMap(
        initialCameraPosition:
            CameraPosition(target: _initialPosition, zoom: 15),
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        markers: _markers.toSet(),
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          {
            _googleMapController.complete(controller);
          }
        },
      ),
    );
  }

  // Method which sets the icon on the list depending on which fish it is.
  Icon _setIcons(QueryDocumentSnapshot location) {
    if (location['fish'] == 'Perch') {
      return Icon(Icons.add_location_alt_outlined,
          color: Colors.redAccent[400]);
    }
    if (location['fish'] == 'Pike') {
      return Icon(Icons.add_location_alt_outlined, color: Colors.green[700]);
    }
    if (location['fish'] == 'Trout') {
      return Icon(Icons.add_location_alt_outlined, color: Colors.purple[200]);
    }
    if (location['fish'] == 'Roach') {
      return Icon(Icons.add_location_alt_outlined, color: Colors.orange[200]);
    } else
      return Icon(Icons.add_location_alt_outlined, color: Colors.blueGrey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'FishApp',
            style: GoogleFonts.kalam(fontSize: 25, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(children: <Widget>[
              DropdownButtonFormField(
                  value: _currentfish,
                  //Maps each variable in the list and creates a new menu Item (type string)
                  items: fish.map((fishes) {
                    return DropdownMenuItem<String>(
                      value: fishes,
                      child: Text('$fishes'),
                    );
                  }).toList(),
                  //When the current selection is changed, the currentfish variable is updated.
                  onChanged: (String? value) {
                    setState(() {
                      _currentfish = value!;
                    });
                  }),
              SizedBox(height: 20),
              DropdownButtonFormField(
                  value: _currentmethod,
                  //Maps each variable in the list and creates a new menu Item (type string)
                  items: methods.map((method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text('$method'),
                    );
                  }).toList(),
                  //When the current selection is changed, the currentfish variable is updated.
                  onChanged: (String? value) {
                    setState(() {
                      _currentmethod = value!;
                    });
                  }),
              Slider(
                  value: double.parse(_currentweight),
                  activeColor: Colors.lightGreenAccent,
                  inactiveColor: Colors.lightGreen,
                  min: 0,
                  max: 10.0,
                  divisions: 100,
                  onChanged: (double value) {
                    setState(() {
                      _currentweight = value.toStringAsFixed(2);
                    });
                  }),
              Text('$_currentweight lbs'),
              Text('$_currentfish'),
              ElevatedButton(
                  onPressed: () async {
                    var _time = DateFormat('hh:mm').format(DateTime.now());
                    var _date =
                        DateFormat('EEE. d MMMM').format(DateTime.now());
                    var _createdAt = Timestamp.now();
                    Position _location = await Geolocator.getCurrentPosition();
                    locations.orderBy('timestamp', descending: true);
                    locations.add({
                      'fish': _currentfish,
                      'weight': _currentweight,
                      'time': _time,
                      'lat': _location.latitude.toStringAsFixed(8),
                      'long': _location.longitude.toStringAsFixed(8),
                      'date': _date,
                      'method': _currentmethod,
                      'timestamp': _createdAt
                    });
                  },
                  child: Text('Add'))
              //When the current selection is changed, the currentfish variable is updated.
            ]),
          ),
          SizedBox(height: 10),
          Container(
            height: MediaQuery.of(context).size.height * 0.50,
            width: MediaQuery.of(context).size.width * 1,
            child: StreamBuilder(
              stream:
                  locations.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(Colors.lightGreenAccent[100]));
                } else
                  return ListView(
                    children: snapshot.data!.docs.map((location) {
                      return Ink(
                        color: Colors.transparent,
                        child: Card(
                            child: ListTile(
                          //displays a sheet which contains a list of fish caught
                          onTap: () => showModalBottomSheet(
                              context: context,
                              builder: (context) => _showMap(location['lat'],
                                  location['long'], location['fish'])),
                          //Sets Icon based on fish type
                          leading: _setIcons(location),
                          title: Text(location['fish']),
                          subtitle: Text(location['weight'] +
                              ' Lbs \n' +
                              location['method'] +
                              '\n' +
                              location['date'] +
                              '\n' +
                              location['time'] +
                              '\n'),
                          trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await locations.doc(location.id).delete();
                              }),
                        )),
                      );
                    }).toList(),
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}
