import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:gd_map/model/common_model.dart';
import 'package:gd_map/page/send_position_page.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:gd_map/utils/event_bus.dart';
import 'package:gd_map/utils/location_util.dart';
import 'package:core_location_fluttify/src/latlng.dart' as Lin;

class PositionProvider with ChangeNotifier {
  List<ChatMessage> _chatList = []; //消息信息

  LocationUtil locationUtil = LocationUtil(); //初始化定位

  LatLng _latLng = LatLng(39.909187, 116.397451); //当前经纬度，赋初始值 也是要发送的经纬度

  Slta? sendlta; //需要发送的地址信息

  List<Poi> poiList = []; //周边地址

  List<ChatMessage> get chatList => _chatList;
  LatLng get latLng => _latLng;

  //初始化定位
  initlocation() async {
    await locationUtil.getCurrentLocation((e) async {
      _latLng = LatLng(e["latitude"], e["longitude"]);
    });
  }

  //定位 并返回周边
  location() async {
    await locationUtil.getCurrentLocation((e) async {
      poiList = [];

      _latLng = LatLng(e["latitude"], e["longitude"]);

      sendlta = Slta(
          latLng: _latLng,
          formatAddress: "${e["address"]}",
          township: "${e["district"]}${e["street"]}${e["description"]}");

      poiList = await searchAround(_latLng);

      poiList.insert(
          0,
          Poi(
              address: e["address"],
              title: e["description"],
              latLng: Lin.LatLng(e["latitude"], e["longitude"]),
              cityName: e["city"],
              provinceName: e["province"],
              distance: 0,
              adName: e["district"]));

      eventBus.fire(LocationEvent(true, poiList, _latLng));
    }, once: false);
  }

  //地图相机移动结束，获取地址 周边
  Future<List<Poi>> cameraMoveEnd(CameraPosition cameraPosition) async {
    poiList = [];

    _latLng = cameraPosition.target;

    var linL = Lin.LatLng(
        cameraPosition.target.latitude, cameraPosition.target.longitude);

    //获取具体地址 的 文字描述
    ReGeocode descPos = await AmapSearch.instance.searchReGeocode(linL);

    //先这样拼吧，后续自己在剪裁优化文字
    sendlta = Slta(
        latLng: LatLng(
            cameraPosition.target.latitude, cameraPosition.target.longitude),
        formatAddress: descPos.formatAddress,
        township: "${descPos.districtName}${descPos.township}");

    //根据经纬度获取周围的地址
    poiList = await searchAround(cameraPosition.target);

    //添加当前的位置
    poiList.insert(
        0,
        Poi(
            address: descPos.formatAddress,
            title: "${descPos.districtName}${descPos.township}",
            latLng: Lin.LatLng(cameraPosition.target.latitude,
                cameraPosition.target.longitude),
            cityName: descPos.cityName,
            provinceName: descPos.provinceName,
            distance: 0,
            adName: descPos.districtName));

    return poiList;
  }

  //开始定位
  startLocation() {
    locationUtil.startLocation();
  }

  //销毁定位
  destroyLocation() {
    locationUtil.destroyLocation();
  }

  //获取周边
  //TODO 后续有需求的话，添加翻页
  Future<List<Poi>> searchAround(LatLng latLng) async {
    return await AmapSearch.instance.searchAround(
      Lin.LatLng(latLng.latitude, latLng.longitude),
    );
  }

  //点击地图标记
  onTapPoi(Poi poi) {
    _latLng = LatLng(poi.latLng!.latitude, poi.latLng!.longitude);
    sendlta = Slta(
        latLng: latLng, formatAddress: poi.address, township: "${poi.title}");
    eventBus.fire(LocationEvent(false, poiList, latLng));
  }

  ///模拟发送位置消息
  sendPosition(context) {
    _chatList.add(ChatMessage(messageType: 8, isSelf: true, sendlta: sendlta));

    //TODO  发送成功，返回页面
    Navigator.pop(context);
    notifyListeners();
  }

  //TODO  获取审图号 在需要的地方展示
  void getApprovalNumber(AMapController mapController) async {
    //普通地图审图号
    String? mapContentApprovalNumber =
        await mapController.getMapContentApprovalNumber();
    //卫星地图审图号
    String? satelliteImageApprovalNumber =
        await mapController.getSatelliteImageApprovalNumber();
  }
}
