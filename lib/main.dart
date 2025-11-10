import 'package:flutter/material.dart';
import 'package:route_tracker/widgets/google_maps_view.dart';

void main() {
  runApp(const RouterTracker());
}

class RouterTracker extends StatelessWidget {
  const RouterTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: GoogleMapsView()),
    );
  }
}
