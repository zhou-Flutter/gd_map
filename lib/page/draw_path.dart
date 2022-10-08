// import 'dart:math';

// import 'package:amap_map_fluttify/amap_map_fluttify.dart';
// import 'package:amap_search_fluttify/amap_search_fluttify.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:gd_map/page/drag_path_search.dart';
// import 'package:gd_map/provider/position_provider.dart';
// import 'package:gd_map/utils/tool.dart';
// import 'package:provider/provider.dart';

// import 'package:core_location_fluttify/src/latlng.dart' as Lin;

// class DragPath extends StatefulWidget {
//   const DragPath({Key? key}) : super(key: key);

//   @override
//   State<DragPath> createState() => _DragPathState();
// }

// class _DragPathState extends State<DragPath> {
//   AMapController? mapController;

//   CameraPosition? initialCameraPosition; //初始相机位置
//   late LatLng latLng;

//   List<LatLng> points = []; //路径经纬度

//   InputTip? inputTipStart; //输入的起点
//   InputTip? inputTipEnd; //输入的终点

//   final Map<String, Marker> _initMarkerMap = <String, Marker>{}; //覆盖点
//   final Map<String, Polyline> _polyline = <String, Polyline>{}; //绘制折线 轨迹

//   LatLng? firstDriverLng; //开车的起点
//   LatLng? endDriverLng; //开车的结束点

//   @override
//   void initState() {
//     super.initState();
//     latLng = Provider.of<PositionProvider>(context, listen: false).latLng;
//     initialCameraPosition = CameraPosition(target: latLng, zoom: 15.5);
//   }

//   //地图创建完成
//   void onMapCreated(AMapController controller) {
//     setState(() {
//       mapController = controller;
//     });
//   }

//   //获取驾车路径
//   getDrag(Lin.LatLng fromlat, Lin.LatLng toLat) async {
//     DriveRouteResult res =
//         await AmapSearch.instance.searchDriveRoute(from: fromlat, to: toLat);
//     List<DrivePath> path = await res.drivePathList;
//     List<DriveStep> driveStepList = await path[0].driveStepList;
//     for (int i = 0; i < driveStepList.length; i++) {
//       List<Lin.LatLng> latLng = await driveStepList[i].polyline;
//       for (int j = 0; j < latLng.length; j++) {
//         points.add(LatLng(latLng[j].latitude, latLng[j].longitude));
//         if (i == 0 && j == 0) {
//           firstDriverLng = LatLng(latLng[0].latitude, latLng[0].longitude);
//         }
//         if (i == driveStepList.length - 1 && j == latLng.length - 1) {
//           endDriverLng = LatLng(latLng[j].latitude, latLng[j].longitude);
//         }
//       }
//     }

//     _add();
//   }

//   //添加轨迹
//   void _add() async {
//     ByteData? byteData = await Tool.widgetToByteData(
//       riderView(),
//       devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
//     );

//     //绘制轨迹
//     final Polyline polyline = Polyline(
//         color: Colors.red, width: 5.0, points: points, capType: CapType.round);
//     _polyline[polyline.id] = polyline;

//     //绘制起点覆盖点
//     Marker marker = Marker(
//         position: firstDriverLng!,
//         icon: BitmapDescriptor.fromIconPath("assets/startIcon.png"));

//     // 显示自定义的view
//     Marker marker2 = Marker(
//       position: firstDriverLng!,
//       icon: BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List()),
//     );
//     //终点覆盖点
//     Marker marker3 = Marker(
//         position: endDriverLng!,
//         icon: BitmapDescriptor.fromIconPath("assets/endPoi.png"));

//     _initMarkerMap[marker.id] = marker;
//     _initMarkerMap[marker2.id] = marker2;
//     _initMarkerMap[marker3.id] = marker3;

//     //相机移动
//     CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(
//         LatLng(inputTipStart!.coordinate!.latitude,
//             inputTipStart!.coordinate!.longitude),
//         15.5);
//     mapController!.moveCamera(cameraUpdate, animated: true);

//     setState(() {});
//   }

//   ///自定义view
//   riderView() {
//     return Container(
//       width: 400,
//       height: 150,
//       margin: EdgeInsets.only(bottom: 135),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         textDirection: TextDirection.ltr,
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.all(5),
//             child: Directionality(
//               textDirection: TextDirection.ltr,
//               child: Text(
//                 '骑手正在飞奔中 。。。',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 35,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.all(5),
//             child: Directionality(
//               textDirection: TextDirection.ltr,
//               child: Text(
//                 "预计时间: 12:13",
//                 style: TextStyle(color: Colors.black, fontSize: 30),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     mapController?.disponse();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(child: map()),
//           Positioned(
//             top: 30,
//             left: 10,
//             child: topPosDes(),
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           getDrag(inputTipStart!.coordinate!, inputTipEnd!.coordinate!);
//         },
//         child: Icon(Icons.send),
//       ),
//     );
//   }

//   //地图
//   Widget map() {
//     return AMapWidget(
//       apiKey: AMapApiKey(
//           androidKey: "f43627c1ee742cb732dc2198f00c4dae",
//           iosKey: "842309d7c40ba5e687141496498b1199"),
//       onMapCreated: onMapCreated,
//       initialCameraPosition: initialCameraPosition!,
//       compassEnabled: true,
//       buildingsEnabled: false,
//       rotateGesturesEnabled: false,
//       polylines: Set<Polyline>.of(_polyline.values),
//       markers: Set<Marker>.of(_initMarkerMap.values),
//     );
//   }

//   Widget topPosDes() {
//     return Container(
//       width: 400,
//       height: 140,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.only(top: 15, left: 10),
//                   child: Icon(
//                     Icons.arrow_back,
//                     size: 30,
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.all(10),
//                 padding: EdgeInsets.all(15),
//                 height: 85,
//                 width: 330,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Color.fromARGB(31, 175, 168, 168),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     InkWell(
//                       onTap: () async {
//                         inputTipStart = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SearchPos()));
//                         setState(() {});
//                       },
//                       child: Row(
//                         children: [
//                           Container(
//                             child: Icon(
//                               Icons.noise_control_off,
//                               color: Colors.green,
//                             ),
//                           ),
//                           Container(
//                             child: inputTipStart == null
//                                 ? Text("开始位置")
//                                 : Text("${inputTipStart?.name}"),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Spacer(),
//                     InkWell(
//                       onTap: () async {
//                         inputTipEnd = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SearchPos()));
//                         setState(() {});
//                       },
//                       child: Row(
//                         children: [
//                           Container(
//                             child: Icon(
//                               Icons.noise_control_off,
//                               color: Colors.red,
//                             ),
//                           ),
//                           Container(
//                             child: inputTipEnd == null
//                                 ? Text("结束位置")
//                                 : Text("${inputTipEnd?.name}"),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   alignment: Alignment.center,
//                   child: Text("骑行"),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   alignment: Alignment.center,
//                   child: Text("公交地铁"),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   alignment: Alignment.center,
//                   child: Text("步行"),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   margin: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
//                   padding: EdgeInsets.all(3),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                       color: Colors.blue[100],
//                       borderRadius: BorderRadius.circular(10)),
//                   child: Text("驾车"),
//                 ),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
