import 'dart:io';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:gd_map/model/common_model.dart';
import 'package:gd_map/page/send_position_page.dart';
import 'package:gd_map/page/show_position_page.dart';

import 'package:gd_map/provider/position_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (e) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ShowMap(sendPosition: widget.item.sendPosition),
          ),
        );
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
                Text(
                  "${widget.item.sendPosition!.title}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${widget.item.sendPosition!.formatAddress}",
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
    return AmapView(
      centerCoordinate: widget.item.sendPosition!.latLng,
      zoomLevel: 16,
      showCompass: false,
      showScaleControl: false,
      showZoomControl: false,
      onMapCreated: (controller) async {
        if (Platform.isAndroid) {
          controller.setZoomByCenter(true);
        } else if (Platform.isIOS) {
          controller.setZoomLevel(16);
          controller.setCenterCoordinate(widget.item.sendPosition!.latLng!);
          controller.showCompass(false);
          controller.showScaleControl(false);
        }
        controller.setAllGesturesEnabled(false);
      },
      markers: [
        MarkerOption(
          anchorV: 1.0,
          coordinate: widget.item.sendPosition!.latLng!,
          iconProvider: AssetImage('assets/wechat_locate.png'),
        ),
      ],
    );
  }
}
