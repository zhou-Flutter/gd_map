import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:gd_map/model/common_model.dart';
import 'package:gd_map/page/send_position_page.dart';
import 'package:gd_map/page/show_position_page.dart';

import 'package:gd_map/provider/position_provider.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

class ChatMap extends StatefulWidget {
  ChatMessage item;
  ChatMap({
    required this.item,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatMap> createState() => _ChatMapState();
}

class _ChatMapState extends State<ChatMap> {
  LatLng latLng = LatLng(39.909187, 116.397451);

  Slta? sendlta; //发送的位置信息

  final Map<String, Marker> _initMarkerMap = <String, Marker>{};

  late Marker? marker; //位置标记

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addMarker(widget.item.sendlta!.latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (e) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShowMap(sendlta: widget.item.sendlta)));
      },
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            width: 230,
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.item.sendlta!.township}"),
                Text(
                  "${widget.item.sendlta!.formatAddress}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
            child: Container(
              height: 100,
              width: 230,
              child: map(),
            ),
          ),
        ],
      ),
    );
  }

  //显示地图
  Widget map() {
    return AMapWidget(
      apiKey: AMapApiKey(androidKey: "f43627c1ee742cb732dc2198f00c4dae"),
      // onMapCreated: onMapCreated,
      initialCameraPosition:
          CameraPosition(target: widget.item.sendlta!.latLng!, zoom: 16),
      scaleEnabled: false,
      buildingsEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomGesturesEnabled: false,
      touchPoiEnabled: false,
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
