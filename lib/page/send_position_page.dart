import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gd_map/provider/position_provider.dart';

import 'package:gd_map/widgets/commo_widgets.dart';
import 'package:gd_map/widgets/custom_bottom_sheet.dart';

import 'package:provider/provider.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';

class SendPositionPage extends StatefulWidget {
  LatLng latLng;

  SendPositionPage({
    required this.latLng,
    Key? key,
  }) : super(key: key);

  @override
  State<SendPositionPage> createState() => _SendPositionPageState();
}

class _SendPositionPageState extends State<SendPositionPage>
    with SingleTickerProviderStateMixin
    implements CustBottomSheetListener {
  AmapController? mapController;

  List<Poi> poiList = []; //周边地址

  late final AnimationController _controller; //控制地址图标弹跳
  late Animation<double> animation;

  double ay = 0; //地址图标Y轴的动画参数

  bool isAnimate = true; //控制是否需要地址图标弹跳动画，以及有弹跳要刷新周边

  LatLng? latLng = LatLng(39.909187, 116.397451); //位置指针经纬度

  Timer? _timer;

  int _start = 0; //计时器 计数

  bool isSearch = false; // 是否是搜索模式

  bool isSend = false; //是否可以发送

  @override
  void initState() {
    super.initState();

    addressIconAnimated();

    latLng = widget.latLng;

    location();
  }

  ///地址图标动画控制
  addressIconAnimated() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        double animateValue = animation.value;
        if (animateValue < 0.5) {
          ay = 15 * animateValue;
        } else {
          ay = 15 * (1 - animateValue);
        }
        setState(() {});
      });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        ay = 0;
        setState(() {});
      }
    });
  }

  //初始化  获取周边
  initPeriList(LatLng latLng) async {
    Provider.of<PositionProvider>(context, listen: false)
        .getPeriList(latLng)
        .then((value) {
      poiList = value;
      isSend = true;
      setState(() {});
    });
  }

  //初始化定位
  location() async {
    AmapLocation.instance.fetchLocation().then((location) async {
      if (location.latLng?.latitude != 0.0 &&
          location.latLng?.longitude != 0.0) {
        if (latLng != location.latLng) {
          latLng = location.latLng!;
          mapController?.setCenterCoordinate(latLng!);
          initPeriList(location.latLng!);
        } else {
          print("位置重复");
        }
      } else {
        // 没有获取位置经纬度
        gpsDialog(context);
      }
    });
  }

  //设置定位mark
  setMark(LatLng latLng) {
    isAnimate = false;
    mapController?.setCenterCoordinate(latLng, animated: false);
    mapController?.clear(keepMyLocation: true);
    mapController?.addMarker(
      MarkerOption(
        anchorV: 1.0,
        coordinate: latLng,
        iconProvider: AssetImage('assets/wechat_locate.png'),
      ),
    );
    timer();
  }

  //抵消地图开始移动到结束的时间
  //isAnimate 用来区分点击周边列表地图移动 和拖动地图定位移动地图 来控制位置icon 是否需要动画
  timer() {
    _start = 0;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_start == 1) {
          isAnimate = true;
          _timer?.cancel();
        } else {
          _start++;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustBottomSheet(
        child: map(),
        poiList: poiList,
        navigationBar: navigationBar(context, isSend, isSearch),
        addressIcon: addressIcon(ay),
        latLng: latLng!,
        custBottomSheetListener: this,
      ),
    );
  }

  //地图
  Widget map() {
    return AmapView(
      centerCoordinate: latLng,
      showZoomControl: false,
      zoomLevel: 16,
      onMapCreated: (controller) async {
        if (Platform.isAndroid) {
          controller.setZoomByCenter(true);
        } else if (Platform.isIOS) {
          await controller.setZoomLevel(16);
        }
        mapController = controller;
        //要添加  await 啊这
        await controller.setCenterCoordinate(latLng!);
        controller.setTiltGesturesEnabled(false);
        controller.setRotateGesturesEnabled(false);
        controller.showCompass(false);
        controller.showScaleControl(false);
        controller.showMyLocation(MyLocationOption());
      },
      onMapMoveEnd: ((MapMove move) async {
        if (isSearch) return;
        if (move.coordinate != latLng) {
          if (isAnimate) {
            isSend = false;
            poiList = [];

            latLng = move.coordinate;
            setState(() {});

            _controller.forward();

            initPeriList(move.coordinate!);
          }
        }
      }),
    );
  }

  @override
  void cancelBtnOnTap() async {
    // TODO: implement cancelBtnCallback
    isAnimate = false;
    isSend = true;
    mapController?.setCenterCoordinate(latLng!, animated: false);
    mapController?.clear(keepMyLocation: true);
    setState(() {});
    timer();
  }

  @override
  void locationOnTap() {
    // TODO: implement locationBtn
    if (isSearch) {
      AmapLocation.instance.fetchLocation().then((location) async {
        if (location.latLng?.latitude != 0.0 &&
            location.latLng?.longitude != 0.0) {
          mapController?.setCenterCoordinate(latLng!);
        } else {
          // 没有获取位置经纬度
          gpsDialog(context);
        }
      });
    } else {
      location();
    }
  }

  @override
  void poiItemOnTap(Poi poi) {
    // TODO: implement poiItemOnTap
    latLng = poi.latLng;
    isAnimate = false;
    mapController?.setCenterCoordinate(poi.latLng!);

    Provider.of<PositionProvider>(context, listen: false).sendDes(poi, false);
    timer();
    setState(() {});
  }

  @override
  void searchPoiItemOnTap(Poi searchPoi) {
    // TODO: implement searchPoiItemOnTap
    isSend = true;
    Provider.of<PositionProvider>(context, listen: false)
        .sendDes(searchPoi, true);
    setState(() {});

    setMark(searchPoi.latLng!);
  }

  @override
  void keyboardSearcOnTap(Poi poi) {
    // TODO: implement searchBtn
    setMark(poi.latLng!);
  }

  @override
  void isSearchCallback(bool search) {
    // TODO: implement isSearchCallback
    isSearch = search;
    isSend = false;
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    mapController?.dispose();
    super.dispose();
  }
}

abstract class CustBottomSheetListener {
  void cancelBtnOnTap();
  void locationOnTap();
  void poiItemOnTap(Poi poi);
  void searchPoiItemOnTap(Poi searchPoi);
  void keyboardSearcOnTap(Poi poi);
  void isSearchCallback(bool isSearch);
}
