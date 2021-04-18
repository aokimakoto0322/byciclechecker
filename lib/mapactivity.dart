import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mapactivity extends StatelessWidget{

  Set<Marker> _markers = {};

  GoogleMapController mapController;
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              _markers.add(
                Marker(
                  markerId: MarkerId("場所"),
                  position: LatLng(snapshot.data.getDouble("lat") ?? 0, snapshot.data.getDouble("lng") ?? 0)
                ),
              );
              GoogleMap(
                markers: _markers,
                initialCameraPosition: CameraPosition(
                  target: LatLng(snapshot.data.getDouble("lat") ?? 0, snapshot.data.getDouble("lng") ?? 0),
                  zoom: 30.0
                ),
              );
            }else{
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
  
}