import 'package:flutter/material.dart';
import 'package:gd_map/provider/position_provider.dart';
import 'package:gd_map/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';

///地图层导航栏
Widget navigationBar(context, poiList) {
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
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        Spacer(),
        InkWell(
          onTap: poiList.isEmpty
              ? null
              : () {
                  Provider.of<PositionProvider>(context, listen: false)
                      .send(context);
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
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

///地址指针图标
Widget addressIcon(ay) {
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

///打开GPS 提示 弹窗
gpsDialog(context) {
  return showDialog(
    barrierDismissible: false, // 屏蔽点击对话框外部自动关闭
    useSafeArea: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        child: CustomDialog(
          title: "提示",
          content: "不能获取到你的位置，在设置中打开GPS和WIFI",
        ),
        onWillPop: () async {
          return Future.value(false);
        },
      );
    },
  );
}

///打开GPS 提示 弹窗
permissionDialog(context) {
  return showDialog(
    barrierDismissible: false, // 屏蔽点击对话框外部自动关闭
    useSafeArea: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        child: CustomDialog(
          title: "权限申请",
          content: "在设置中开启位置信息权限，以正常使用定位等功能",
        ),
        onWillPop: () async {
          return Future.value(false);
        },
      );
    },
  );
}
