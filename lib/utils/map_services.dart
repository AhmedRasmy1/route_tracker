import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/models/location_info/lat_lng.dart';
import 'package:route_tracker/models/location_info/location.dart';
import 'package:route_tracker/models/location_info/location_info.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/models/place_details_model/place_details_model.dart';
import 'package:route_tracker/models/routes_model/routes_model.dart';
import 'package:route_tracker/utils/google_maps_places_service.dart';
import 'package:route_tracker/utils/location_service.dart';
import 'package:route_tracker/utils/routes_service.dart';

class MapServices {
  PlacesService placesService = PlacesService();
  LocationService locationService = LocationService();
  RoutesService routesService = RoutesService();
  LatLng? currentLocation;

  Future<void> getPredictions({
    required String input,
    required String sesstionToken,
    required List<PlaceAutocompleteModel> places,
  }) async {
    if (input.isEmpty) {
      places.clear();
      return;
    }

    var result = await placesService.getPredictions(
      input: input,
      sessionToken: sesstionToken,
    );
    places
      ..clear()
      ..addAll(result);
  }

  Future<List<LatLng>> getRouteData({required LatLng destinationn}) async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation!.latitude,
          longitude: currentLocation!.longitude,
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

  void displayRoute(
    List<LatLng> points, {
    required Set<Polyline> polyLines,
    required GoogleMapController googleMapController,
  }) {
    Polyline routes = Polyline(
      polylineId: PolylineId('route'),
      points: points,
      color: Colors.blue,
      width: 5,
    );

    polyLines.add(routes);
    LatLngBounds bounds = getLatLngBounds(points);
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 32));
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    var southwestLatitude = points.first.latitude;
    var southwestLongitude = points.first.longitude;
    var northEastLatitude = points.first.latitude;
    var northEastLongitude = points.first.longitude;

    for (var point in points) {
      southwestLatitude = min(southwestLatitude, point.latitude);
      southwestLongitude = min(southwestLongitude, point.longitude);

      northEastLatitude = max(northEastLatitude, point.latitude);
      northEastLongitude = max(northEastLongitude, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(southwestLatitude, southwestLongitude),
      northeast: LatLng(northEastLatitude, northEastLongitude),
    );
  }

  void updateCurrentLocation({
    required GoogleMapController googleMapController,
    required Set<Marker> markers,
    required Function onUpdateCurrentLocation,
  }) async {
    locationService.getRealTimeLocationData((locationData) {
      final loc = LatLng(locationData.latitude!, locationData.longitude!);

      // خزّن اللوكيشن عشان getRouteData تعرف تستخدمه
      currentLocation = loc;

      Marker currentLocationMarker = Marker(
        markerId: MarkerId("my_location"),
        position: loc,
      );

      CameraPosition myCurrentCameraPosition = CameraPosition(
        target: loc,
        zoom: 17,
      );

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(myCurrentCameraPosition),
      );

      markers.add(currentLocationMarker);
      onUpdateCurrentLocation();
    });
  }

  Future<PlaceDetailsModel> getPlcaceDetails({required String placeID}) async {
    return await placesService.getPlcaceDetails(placeID: placeID);
  }
}
