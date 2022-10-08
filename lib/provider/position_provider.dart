import 'package:amap_map_fluttify/amap_map_fluttify.dart';

import 'package:flutter/material.dart';
import 'package:gd_map/model/common_model.dart';
import 'package:gd_map/page/send_position_page.dart';

import 'package:gd_map/utils/event_bus.dart';

import 'package:gd_map/widgets/commo_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class PositionProvider with ChangeNotifier {
  List<ChatMessage> _chatList = []; //消息信息

  // LocationUtil locationUtil = LocationUtil(); //初始化定位

  LatLng _latLng = LatLng(39.909187, 116.397451); //当前位置指针经纬度，赋初始值

  SendPosition? sendPosition; //需要发送的地址信息

  List<Poi> poiList = []; //周边地址

  List<ChatMessage> get chatList => _chatList;
  LatLng get latLng => _latLng;

  //TODO 初始化定位  先这样 后续可加缓存优化跳转速度 防止初始定位 和目标值跨度大
  initlocation(context) async {
    bool status = await checkPermission(context);
    print("状态");
    print(status);
    if (status) {
      Location location = await AmapLocation.instance.fetchLocation();
      _latLng = location.latLng!;
      print("开始定位");
      print(location);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SendPositionPage(latLng: _latLng)));
    }
  }

  //获取权限
  Future<bool> checkPermission(context) async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      //权限通过
      return true;
    } else if (status.isDenied) {
      //权限拒绝， 需要区分IOS和Android，二者不一样
      permissionDialog(context);
    } else if (status.isPermanentlyDenied) {
      //权限永久拒绝，且不在提示，需要进入设置界面
      permissionDialog(context);
    } else if (status.isRestricted) {
      //活动限制（例如，设置了家长///控件，仅在iOS以上受支持。
      permissionDialog(context);
    } else {
      //第一次申请
      permissionDialog(context);
    }
    return false;
  }

  //定位 并返回周边
  location(context) async {
    AmapLocation.instance.fetchLocation().then((location) async {
      if (location.latLng?.latitude != 0.0 &&
          location.latLng?.longitude != 0.0) {
        if (_latLng != location.latLng) {
          _latLng = location.latLng!;

          eventBus.fire(LocationEvent(true, _latLng));
        } else {
          print("位置重复");
        }
      } else {
        // 没有获取位置经纬度
        gpsDialog(context);
      }
    });
  }

  //获取周边
  //TODO 后续有需求的话，添加翻页
  Future<List<Poi>> searchAround(LatLng latLng) async {
    return await AmapSearch.instance.searchAround(
      LatLng(latLng.latitude, latLng.longitude),
    );
  }

  //地图相机移动结束，获取地址 周边
  Future<List<Poi>> getPeriList(LatLng movelatLng) async {
    poiList = [];

    _latLng = movelatLng;

    //获取具体地址 的 文字描述
    ReGeocode descPos = await AmapSearch.instance.searchReGeocode(movelatLng);

    var address = "${descPos.township}";
    var title = descPos.formatAddress!.split("${descPos.districtName}").last;

    Poi poi = Poi(
      address: address,
      title: title,
      latLng: movelatLng,
      cityName: descPos.cityName,
      provinceName: descPos.provinceName,
      adName: descPos.districtName,
      distance: 0,
    );

    //根据经纬度获取周围的地址
    poiList = await searchAround(movelatLng);
    poiList.insert(0, poi);

    //TODO 先这样 后续自己在剪裁优化文字
    sendPosition = SendPosition(
      latLng: movelatLng,
      formatAddress: descPos.formatAddress,
      title: title,
    );

    return poiList;
  }

  ///模拟发送位置消息
  send(context) {
    _chatList.add(
      ChatMessage(messageType: 8, isSelf: true, sendPosition: sendPosition),
    );

    Navigator.pop(context);

    notifyListeners();
  }

  //点击周边的列表
  onTapPoi(Poi poi) async {
    if (poi.latLng == _latLng) return;
    _latLng = poi.latLng!;

    var formatAddress =
        "${poi.provinceName}" "${poi.cityName}" "${poi.adName}" "${poi.title}";

    sendPosition = SendPosition(
      latLng: _latLng,
      formatAddress: formatAddress,
      title: poi.title,
    );
    eventBus.fire(LocationEvent(false, _latLng));
  }
}
