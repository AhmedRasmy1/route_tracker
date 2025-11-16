import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/utils/location_service.dart';
import 'package:route_tracker/utils/map_services.dart';
import 'package:route_tracker/widgets/custom_list_view.dart';
import 'package:route_tracker/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({super.key});

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  late MapServices mapServices;
  late CameraPosition initialCameraPosition;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late Uuid uuid;
  late LatLng destinationn;
  List<PlaceAutocompleteModel> places = [];
  String? sesstionToken;
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};
  Timer? debounce;

  @override
  void initState() {
    mapServices = MapServices();
    initialCameraPosition = CameraPosition(target: LatLng(0, 0));
    textEditingController = TextEditingController();
    uuid = const Uuid();
    fetchPredection();
    super.initState();
  }

  void fetchPredection() {
    textEditingController.addListener(() async {
      if (debounce?.isActive ?? false) debounce!.cancel();
      debounce = Timer(const Duration(milliseconds: 100), () {});
      sesstionToken ??= uuid.v4();
      final input = textEditingController.text.trim();

      if (input.isEmpty) {
        places.clear();
        setState(() {});
        return;
      }

      await mapServices.getPredictions(
        input: input,
        sesstionToken: sesstionToken!,
        places: places,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: polyLines,
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
                mapServices: mapServices,
                onPlaceSelect: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();
                  sesstionToken = null;
                  setState(() {});

                  destinationn = LatLng(
                    placeDetailsModel.geometry!.location!.lat!,
                    placeDetailsModel.geometry!.location!.lng!,
                  );

                  var points = await mapServices.getRouteData(
                    destinationn: destinationn,
                  );
                  mapServices.displayRoute(
                    points,
                    polyLines: polyLines,
                    googleMapController: googleMapController,
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateCurrentLocation() {
    try {
      mapServices.updateCurrentLocation(
        googleMapController: googleMapController,
        markers: markers,
        onUpdateCurrentLocation: () {
          setState(() {});
        },
      );
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
