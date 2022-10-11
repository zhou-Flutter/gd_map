import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gd_map/page/drag_path_search.dart';
import 'package:gd_map/provider/position_provider.dart';
import 'package:gd_map/utils/tool.dart';
import 'package:provider/provider.dart';

import 'package:core_location_fluttify/src/latlng.dart' as Lin;

class DragPath extends StatefulWidget {
  const DragPath({Key? key}) : super(key: key);

  @override
  State<DragPath> createState() => _DragPathState();
}

class _DragPathState extends State<DragPath> {
  AmapController? mapController;

  late LatLng latLng;

  List<LatLng> points = []; //路径经纬度

  InputTip? inputTipStart; //输入的起点
  InputTip? inputTipEnd; //输入的终点

  LatLng? firstDriverLng; //开车的起点
  LatLng? endDriverLng; //开车的结束点

  MarkerOption? startMark;

  @override
  void initState() {
    super.initState();
    latLng = Provider.of<PositionProvider>(context, listen: false).latLng;
  }

  //获取驾车路径
  getDrag(Lin.LatLng fromlat, Lin.LatLng toLat) async {
    DriveRouteResult res =
        await AmapSearch.instance.searchDriveRoute(from: fromlat, to: toLat);
    List<DrivePath> path = await res.drivePathList;
    List<DriveStep> driveStepList = await path[0].driveStepList;
    for (int i = 0; i < driveStepList.length; i++) {
      List<Lin.LatLng> latLng = await driveStepList[i].polyline;
      for (int j = 0; j < latLng.length; j++) {
        points.add(LatLng(latLng[j].latitude, latLng[j].longitude));
        if (i == 0 && j == 0) {
          firstDriverLng = LatLng(latLng[0].latitude, latLng[0].longitude);
        }
        if (i == driveStepList.length - 1 && j == latLng.length - 1) {
          endDriverLng = LatLng(latLng[j].latitude, latLng[j].longitude);
        }
      }
    }

    _add();
  }

  //添加轨迹
  void _add() async {
    await mapController?.addPolyline(PolylineOption(
      coordinateList: points,
      strokeColor: Colors.green,
      width: 20,
    ));

    startMark = customMark();

    mapController?.addMarkers([
      stateIcon(),
      endIcon(),
      receiptMark(),
      customMark(),
    ]);

    mapController?.setCenterCoordinate(firstDriverLng!, animated: true);
    setState(() {});
  }

  //起点圆点
  MarkerOption stateIcon() {
    return MarkerOption(
      anchorV: 0.5,
      coordinate: firstDriverLng!,
      widget: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white,
          border: Border.all(
            width: 5,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  //结束点圆点
  MarkerOption endIcon() {
    return MarkerOption(
      anchorV: 0.5,
      coordinate: endDriverLng!,
      widget: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white,
          border: Border.all(
            width: 5,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  //  起点自定义Mark
  MarkerOption customMark() {
    return MarkerOption(
      anchorV: 1.0,
      coordinate: firstDriverLng!,
      widget: Container(
        width: 150,
        height: 80,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(145, 230, 98, 89),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      "发",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: Text(
                    "运输中...",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
            Spacer(),
            Container(
              child: Text(
                "预计明天送达 >>",
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  //终点Mark
  receiptMark() {
    return MarkerOption(
      anchorV: 1.0,
      coordinate: endDriverLng!,
      widget: Container(
        width: 150,
        height: 45,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(145, 230, 98, 89),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "收",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "成都市成华区",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mapController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(child: map()),
          Positioned(
            top: 50,
            left: 10,
            child: topPosDes(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getDrag(inputTipStart!.coordinate!, inputTipEnd!.coordinate!);
        },
        child: Icon(Icons.send),
      ),
    );
  }

  //地图
  Widget map() {
    return AmapView(
      centerCoordinate: latLng,
      zoomLevel: 16,
      showZoomControl: false,
      onMapCreated: (controller) async {
        mapController = controller;

        if (Platform.isAndroid) {
          await controller.setZoomByCenter(true);
        } else if (Platform.isIOS) {
          controller.setCenterCoordinate(latLng);
          controller.setZoomLevel(16);
        }
        await controller.setRotateGesturesEnabled(false);
        await controller.setTiltGesturesEnabled(false);
        await controller.showCompass(false);
        await controller.showScaleControl(false);
      },
    );
  }

  Widget topPosDes() {
    return Container(
      width: 370,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.only(top: 15, left: 10),
                  child: Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(15),
                height: 85,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(31, 175, 168, 168),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        inputTipStart = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPos()));
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Container(
                            child: Icon(
                              Icons.noise_control_off,
                              color: Colors.green,
                            ),
                          ),
                          Container(
                            child: inputTipStart == null
                                ? Text("开始位置")
                                : Text("${inputTipStart?.name}"),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () async {
                        inputTipEnd = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPos()));
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Container(
                            child: Icon(
                              Icons.noise_control_off,
                              color: Colors.red,
                            ),
                          ),
                          Container(
                            child: inputTipEnd == null
                                ? Text("结束位置")
                                : Text("${inputTipEnd?.name}"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text("骑行"),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text("公交地铁"),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text("步行"),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  padding: EdgeInsets.all(3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Text("驾车"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
