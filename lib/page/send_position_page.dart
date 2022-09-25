import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import 'package:gd_map/provider/position_provider.dart';
import 'package:gd_map/utils/event_bus.dart';
import 'package:gd_map/utils/location_util.dart';
import 'package:gd_map/widgets/custom_bottom_sheet.dart';

import 'package:provider/provider.dart';

class SendPosition extends StatefulWidget {
  SendPosition({
    Key? key,
  }) : super(key: key);

  @override
  State<SendPosition> createState() => _SendPositionState();
}

class _SendPositionState extends State<SendPosition>
    with SingleTickerProviderStateMixin {
  CameraPosition? initialCameraPosition; //初始相机位置

  AMapController? mapController;

  List<Poi> poiList = []; //周边地址

  late final AnimationController _controller; //控制地址图标弹跳
  late Animation<double> animation;

  double ay = 0; //地址图标Y轴的动画参数

  bool isAnimate = true; //控制是否需要地址图标弹跳动画，以及有弹跳要刷新周边

  LatLng? latLng;

  @override
  void initState() {
    super.initState();

    //初始相机位置
    latLng = Provider.of<PositionProvider>(context, listen: false).latLng;
    initialCameraPosition = CameraPosition(target: latLng!, zoom: 15.5);

    addressIconAnimated();

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

  //地图创建完成
  void onMapCreated(AMapController controller) {
    setState(() {
      mapController = controller;
      Provider.of<PositionProvider>(context, listen: false)
          .getApprovalNumber(controller);
    });
  }

  //初始校准定位
  location() async {
    Provider.of<PositionProvider>(context, listen: false).location();
    eventBus.on<LocationEvent>().listen((event) {
      if (mounted) {
        isAnimate = event.isAnimate;
        moveMapCamera(event.latLng);
        poiList = event.poiList;
        latLng = event.latLng;

        setState(() {});
      }
    });
  }

  //地图相机移动
  moveMapCamera(latLng) {
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(latLng, 15.5);
    mapController!.moveCamera(cameraUpdate, animated: true);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    Provider.of<PositionProvider>(context, listen: false).destroyLocation();
    super.deactivate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    mapController?.disponse();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustBottomSheet(
        mapController: mapController,
        child: map(),
        poiList: poiList,
        navigationBar: navigationBar(),
        addressIcon: addressIcon(),
        latLng: latLng!,
      ),
    );
  }

  //地图
  Widget map() {
    return AMapWidget(
      apiKey: AMapApiKey(androidKey: "f43627c1ee742cb732dc2198f00c4dae"),
      onMapCreated: onMapCreated,
      initialCameraPosition: initialCameraPosition!,
      compassEnabled: true,
      buildingsEnabled: false,
      rotateGesturesEnabled: false,
      onPoiTouched: (AMapPoi e) {
        moveMapCamera(e.latLng!);
      },
      myLocationStyleOptions: MyLocationStyleOptions(
        true,
      ),
      onCameraMoveEnd: (CameraPosition cameraPosition) async {
        if (!isAnimate) {
          isAnimate = true;
          return;
        }
        _controller.forward();
        poiList = [];
        setState(() {});

        poiList = await Provider.of<PositionProvider>(context, listen: false)
            .cameraMoveEnd(cameraPosition);

        if (mounted) {
          latLng = context.read<PositionProvider>().latLng;
          setState(() {});
        }
      },
    );
  }

  //地址图标
  Widget addressIcon() {
    return Transform(
      transform: Matrix4.translationValues(0, -ay, 0),
      child: Container(
        width: 30,
        height: 55,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.green,
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              child: Container(
                width: 5,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //地图层导航栏
  Widget navigationBar() {
    return Container(
      padding: EdgeInsets.only(right: 25, left: 25, top: 45, bottom: 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black26,
            Colors.black26,
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              "取消",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Spacer(),
          InkWell(
            onTap: poiList.isEmpty
                ? null
                : () {
                    Provider.of<PositionProvider>(context, listen: false)
                        .sendPosition(context);
                  },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: poiList.isEmpty ? Colors.black45 : Colors.green,
              ),
              child: Text(
                "发送",
                style: TextStyle(
                  color: Colors.white,
                  // fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
