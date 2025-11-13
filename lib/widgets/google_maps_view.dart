import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/utils/google_maps_places_service.dart';
import 'package:route_tracker/utils/location_service.dart';
import 'package:route_tracker/widgets/custom_list_view.dart';
import 'package:route_tracker/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({super.key});

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late GoogleMapsPlacesService googleMapsPlacesService;
  late Uuid uuid;
  List<PlaceAutocompleteModel> places = [];
  String? sesstionToken;
  Set<Marker> markers = {};

  @override
  void initState() {
    initialCameraPosition = CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    textEditingController = TextEditingController();
    googleMapsPlacesService = GoogleMapsPlacesService();
    uuid = const Uuid();
    fetchPredection();
    super.initState();
  }

  void fetchPredection() {
    textEditingController.addListener(() async {
      sesstionToken ??= uuid.v4();
      final input = textEditingController.text.trim();

      if (input.isEmpty) {
        places.clear();
        setState(() {});
        return;
      }

      var result = await googleMapsPlacesService.getPredictions(
        input: input,
        sessionToken: sesstionToken!,
      );
      places
        ..clear()
        ..addAll(result);
      setState(() {});
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();
          },
          initialCameraPosition: initialCameraPosition,
          zoomControlsEnabled: false,
          markers: markers,
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            spacing: 10,
            children: [
              CustomTextField(textEditingController: textEditingController),
              CustomListView(
                places: places,
                googleMapsPlacesService: googleMapsPlacesService,
                onPlaceSelect: (placeDetailsModel) {
                  textEditingController.clear();
                  places.clear();
                  sesstionToken = null;
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
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
