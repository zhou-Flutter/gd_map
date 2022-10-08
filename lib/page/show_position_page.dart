import 'dart:io';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:gd_map/model/common_model.dart';

import 'package:map_launcher/map_launcher.dart';

import 'package:url_launcher/url_launcher_string.dart';

import 'package:map_launcher/src/models.dart' as mapType;

class ShowMap extends StatefulWidget {
  SendPosition? sendPosition;
  ShowMap({
    Key? key,
    required this.sendPosition,
  }) : super(key: key);

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  AmapController? mapController;

  List<AvailableMap> mapApp = []; //需要跳转的App
  @override
  void initState() {
    super.initState();

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
          item.mapName = "Apple地图";
          mapApp.add(item);
          break;
        default:
      }
    }
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
                Location location = await AmapLocation.instance.fetchLocation();

                // mapController?.showMyLocation(MyLocationOption(
                //     show: true, myLocationType: MyLocationType.Locate));

                mapController?.setCenterCoordinate(location.latLng!);
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
                    "${widget.sendPosition!.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 21,
                    ),
                  ),
                  Text(
                    "${widget.sendPosition!.formatAddress}",
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
        openAmap(widget.sendPosition!.latLng!.latitude,
            widget.sendPosition!.latLng!.longitude,
            title: widget.sendPosition!.formatAddress);
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
        print("Apple地图");
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
    return AmapView(
      centerCoordinate: widget.sendPosition!.latLng,
      zoomLevel: 16,
      showZoomControl: false,
      onMapCreated: (controller) async {
        mapController = controller;

        if (Platform.isAndroid) {
          await controller.setZoomByCenter(true);
        } else if (Platform.isIOS) {
          controller.setCenterCoordinate(widget.sendPosition!.latLng!);
          controller.setZoomLevel(16);
        }
        await controller.showMyLocation(
          MyLocationOption(show: true, myLocationType: MyLocationType.Show),
        );
        await controller.setRotateGesturesEnabled(false);
        await controller.setTiltGesturesEnabled(false);
        await controller.showCompass(false);
        await controller.showScaleControl(false);
      },
      markers: [
        MarkerOption(
          anchorV: 1.0,
          coordinate: widget.sendPosition!.latLng!,
          iconProvider: AssetImage('assets/wechat_locate.png'),
        ),
      ],
    );
  }
}
