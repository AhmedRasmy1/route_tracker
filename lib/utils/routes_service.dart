import 'dart:convert';

import 'package:route_tracker/models/location_info/location_info.dart';
import 'package:route_tracker/models/routes_model/routes_model.dart';
import 'package:http/http.dart' as http;
import 'package:route_tracker/models/routes_modifires.dart';

class RoutesService {
  final String baseUrl =
      "https://routes.googleapis.com/directions/v2:computeRoutes";
  final String apiKey = "AIzaSyBHANZAeJhQt3VAoBm07lT4rh8vJrqsXaA";
  Future<RoutesModel> fetchRoutes({
    required LocationInfoModel origin,
    required LocationInfoModel destination,
    RoutesModifires? routesModifires,
  }) async {
    Uri url = Uri.parse(baseUrl);
    Map<String, String> headres = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };
    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination": destination.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": routesModifires != null
          ? routesModifires.toJson()
          : RoutesModifires().toJson(),
      "languageCode": "en-US",
      "units": "METRIC",
    };

    var response = await http.post(url, headers: headres, body: body);
    if (response.statusCode == 200) {
      var result = RoutesModel.fromJson(jsonDecode(response.body));
      return result;
    } else {
      throw Exception("No routes found");
    }
  }
}
