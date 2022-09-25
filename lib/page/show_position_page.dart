import 'dart:io';

import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:gd_map/model/common_model.dart';
import 'package:gd_map/provider/position_provider.dart';
import 'package:gd_map/utils/location_util.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:map_launcher/src/models.dart' as mapType;
import 'package:amap_flutter_base/amap_flutter_base.dart';

class ShowMap extends StatefulWidget {
  Slta? sendlta;
  ShowMap({
    Key? key,
    required this.sendlta,
  }) : super(key: key);

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  final Map<String, Marker> _initMarkerMap = <String, Marker>{};

  LocationUtil locationUtil = LocationUtil(); //初始化定位

  late Marker? marker;

  AMapController? mapController;
  List<AvailableMap> mapApp = [];
  @override
  void initState() {
    super.initState();

    _addMarker(LatLng(
        widget.sendlta!.latLng!.latitude, widget.sendlta!.latLng!.longitude));

    getMap();
  }

  //获取地图 如果没有地图，则指定地图跳转网页获取
  getMap() async {
    List<AvailableMap> availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isEmpty) {
      mapApp.add(AvailableMap(
          mapName: "高德地图", mapType: mapType.MapType.amap, icon: ""));
      return;
    }
    print(availableMaps);
    for (AvailableMap item in availableMaps) {
      switch (item.mapType) {
        case mapType.MapType.amap:
          item.mapName = "高德地图";
          mapApp.add(item);
          break;
        case mapType.MapType.baidu:
          item.mapName = "百度地图";
          mapApp.add(item);
          break;
        case mapType.MapType.tencent:
          item.mapName = "腾讯地图";
          mapApp.add(item);
          break;
        case mapType.MapType.google:
          item.mapName = "谷歌地图";
          mapApp.add(item);
          break;
        case mapType.MapType.apple:
          item.mapName = "苹果地图";
          mapApp.add(item);
          break;
        default:
      }
    }
  }

  //地图创建完成
  void _onMapCreated(AMapController controller) {
    setState(() {
      mapController = controller;

      Provider.of<PositionProvider>(context, listen: false)
          .getApprovalNumber(controller);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 100,
            child: map(),
          ),
          Positioned(
            left: 20,
            top: 40,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 40,
            child: Container(
              alignment: Alignment.center,
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 100 + 10,
            child: InkWell(
              onTap: () async {
                await locationUtil.getCurrentLocation((e) async {
                  CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(
                      LatLng(e["latitude"], e["longitude"]), 15.5);
                  mapController!.moveCamera(cameraUpdate, animated: true);
                });
              },
              child: Container(
                height: 45,
                width: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          buttomPosDes(),
        ],
      ),
    );
  }

  //底部位置详情
  Widget buttomPosDes() {
    return Positioned(
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        height: 100,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.sendlta!.township}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 21,
                    ),
                  ),
                  Text(
                    "${widget.sendlta!.formatAddress}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                showBottomSheet();
              },
              child: Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.near_me,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showBottomSheet() {
    //用于在底部打开弹框的效果
    showModalBottomSheet(
        builder: (BuildContext context) {
          return buildBottomSheetWidget(context);
        },
        backgroundColor: Colors.transparent,
        context: context);
  }

  ///底部弹出框的内容
  Widget buildBottomSheetWidget(BuildContext context) {
    return Container(
      height: 65 + mapApp.length * 55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: mapApp.map((e) {
              return InkWell(
                onTap: () async {
                  print("腾讯地图");
                  openMap(e);
                },
                child: Container(
                  height: 55,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(31, 167, 164, 164),
                              width: 1))),
                  child: Text(
                    "${e.mapName}",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              );
            }).toList(),
          ),
          Container(
            height: 5,
            color: Color.fromARGB(31, 131, 129, 129),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 55,
              alignment: Alignment.center,
              child: Text(
                "取消",
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //打开地图
  //TODO 其他地图有需求的话 后续适配
  openMap(AvailableMap item) {
    switch (item.mapType) {
      case mapType.MapType.amap:
        openAmap(
            widget.sendlta!.latLng!.latitude, widget.sendlta!.latLng!.longitude,
            title: widget.sendlta!.formatAddress);
        break;
      case mapType.MapType.baidu:
        print("百度地图");
        break;
      case mapType.MapType.tencent:
        print("腾讯地图");
        break;
      case mapType.MapType.google:
        print("谷歌地图");
        break;
      case mapType.MapType.apple:
        print("苹果地图");
        break;
      default:
    }
  }

  //打开高德地图
  static Future<bool> openAmap(
    double latitude,
    double longitude, {
    String? address,
    String? title,
    bool showErr = true,
  }) async {
    String url =
        '${Platform.isAndroid ? 'android' : 'ios'}amap://viewReGeo?sourceApplication=${title ?? ""}&lat=$latitude&lon=$longitude&dev=0';
    if (Platform.isIOS) url = Uri.encodeFull(url);
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
        return true;
      } else {
        if (showErr) print('无法调起高德地图');
        return false;
      }
    } on Exception catch (e) {
      if (showErr) print('无法调起高德地图');
      return false;
    }
  }

  //地图
  Widget map() {
    CameraPosition initialCameraPosition =
        CameraPosition(target: widget.sendlta!.latLng!, zoom: 15.5);
    return AMapWidget(
      apiKey: AMapApiKey(androidKey: "f43627c1ee742cb732dc2198f00c4dae"),
      onMapCreated: _onMapCreated,
      initialCameraPosition: initialCameraPosition,
      compassEnabled: true,
      buildingsEnabled: false,
      rotateGesturesEnabled: false,
      myLocationStyleOptions: MyLocationStyleOptions(
        true,
      ),
      markers: Set<Marker>.of(_initMarkerMap.values),
    );
  }

  //没找到类似微信的图标，先凑合用
  void _addMarker(e) async {
    marker = Marker(
      position: e,
      icon: BitmapDescriptor.fromIconPath("assets/locate.png"),
    );
    setState(() {
      _initMarkerMap["0"] = marker!;
    });
  }
}
