import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/models/place_details_model/place_details_model.dart';

class PlacesService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey = 'AIzaSyBHANZAeJhQt3VAoBm07lT4rh8vJrqsXaA';
  Future<List<PlaceAutocompleteModel>> getPredictions({
    required String input,
    required String sessionToken,
  }) async {
    var response = await http.get(
      Uri.parse(
        '$baseUrl/autocomplete/json?key=$apiKey&input=$input&sessiontoken=$sessionToken',
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceAutocompleteModel> places = [];
      for (var item in data) {
        places.add(PlaceAutocompleteModel.fromJson(item));
      }
      return places;
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<PlaceDetailsModel> getPlcaceDetails({required String placeID}) async {
    var response = await http.get(
      Uri.parse('$baseUrl/details/json?key=$apiKey&place_id=$placeID'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['result'];
      var result = PlaceDetailsModel.fromJson(data);
      return result;
    } else {
      throw Exception('Failed to load details');
    }
  }
}
