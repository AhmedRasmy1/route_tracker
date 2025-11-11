import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/utils/location_service.dart';

class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({super.key});

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    initialCameraPosition = CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        googleMapController = controller;
        updateCurrentLocation();
      },
      initialCameraPosition: initialCameraPosition,
      zoomControlsEnabled: false,
      markers: markers,
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getCurrentLocationData();
      LatLng mycurrentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      Marker currentLocationMarker = Marker(
        markerId: MarkerId("my_location"),
        position: mycurrentPosition,
      );
      CameraPosition myCurrentCameraPosition = CameraPosition(
        target: mycurrentPosition,
        zoom: 17,
      );
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(myCurrentCameraPosition),
      );
      markers.add(currentLocationMarker);
      setState(() {});
    } on LocationPermissionException {
      // TODO
    } on LocationPermissionException {
      // TODO
    } catch (e) {
      // TODO
    }
  }
}
