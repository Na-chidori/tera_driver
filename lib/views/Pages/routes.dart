// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'packgage:latlong/latlong.dart';

// class Routes extends StatefulWidget {
//   const Routes({super.key});

//   @override
//   State<Routes> createState() => _RoutesState();
// }

// class _RoutesState extends State<Routes> {
//   @override
//   Widget build(BuildContext context) {
//     return FlutterMap(
//       options:MapOptions{
//         initailCenter: LatLng(1.2878,103,8666),
//         initalZoom:13,
//         interactionOptions: const InteractionOptions(flags:~InteractiveFlag.doubleTapZoom),
//       },
//       children:[
//         openStreetMapTileLayer,
//         MarekerLayer(markers: [
//           Marker(point:LatLng(1.2878,103.666)),
//                 width:60,
//                 height:60,
//                 alignement:Alignment.centerLeft,
//                 child:GestureDetector(
//                   onTap:(){

//                   },
//                   child:Icon(Icons.location_pin,size 60,color:Colors.red),
//                 )

//         ])
//       ],
//     );
//   }
// }

// TilelLayer get openStreetMapTileLayer => TileLayer{
//   urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//   userAgentPackageName:'dev.fleaflet.flutter_map.example',
// }

import 'package:flutter/material.dart';

class Routes extends StatelessWidget {
  const Routes({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
