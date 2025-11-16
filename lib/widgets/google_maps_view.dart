import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/models/location_info/lat_lng.dart';
import 'package:route_tracker/models/location_info/location.dart';
import 'package:route_tracker/models/location_info/location_info.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/models/routes_model/route.dart';
import 'package:route_tracker/models/routes_model/routes_model.dart';
import 'package:route_tracker/utils/google_maps_places_service.dart';
import 'package:route_tracker/utils/location_service.dart';
import 'package:route_tracker/utils/routes_service.dart';
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
  late RoutesService routesService;
  late LatLng currentLocation;
  late LatLng destinationn;
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
    routesService = RoutesService();
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

                  destinationn = LatLng(
                    placeDetailsModel.geometry!.location!.lat!,
                    placeDetailsModel.geometry!.location!.lng!,
                  );

                  getRouteData();
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
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
        markerId: MarkerId("my_location"),
        position: currentLocation,
      );
      CameraPosition myCurrentCameraPosition = CameraPosition(
        target: currentLocation,
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

  Future<List<LatLng>> getRouteData() async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        ),
      ),
    );
    LocationInfoModel destination = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: destinationn.latitude,
          longitude: destinationn.longitude,
        ),
      ),
    );
    RoutesModel routes = await routesService.fetchRoutes(
      origin: origin,
      destination: destination,
    );

    List<LatLng> points = getDecodedRoute(routes);
    return points;
  }

  List<LatLng> getDecodedRoute(RoutesModel routes) {
    List<PointLatLng> result = PolylinePoints.decodePolyline(
      routes.routes!.first.polyline!.encodedPolyline!,
    );
    List<LatLng> points = result
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    return points;
  }
}
