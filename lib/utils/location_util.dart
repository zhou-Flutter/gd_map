//定位 util
import 'dart:async';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationUtil {
  StreamSubscription<Map<String, Object>>? _locationListener;
  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
  PermissionStatus? status;

  LocationUtil() {
    AMapFlutterLocation.setApiKey(
        "f43627c1ee742cb732dc2198f00c4dae", //androidkey
        "f43627c1ee742cb732dc2198f00c4dae" //ioskey
        );

    /// 设置是否已经包含高德隐私政策并弹窗展示显示用户查看，如果未包含或者没有弹窗展示，高德定位SDK将不会工作
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    /// <b>必须保证在调用定位功能之前调用， 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    ///
    /// [hasContains] 隐私声明中是否包含高德隐私政策说明
    ///
    /// [hasShow] 隐私权政策是否弹窗展示告知用户
    AMapFlutterLocation.updatePrivacyShow(true, true);

    /// 设置是否已经取得用户同意，如果未取得用户同意，高德定位SDK将不会工作
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    ///
    /// <b>必须保证在调用定位功能之前调用, 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    ///
    /// [hasAgree] 隐私权政策是否已经取得用户同意
    AMapFlutterLocation.updatePrivacyAgree(true);
  }

  /// 动态申请定位权限
  Future<bool> _requestPermission() async {
    status = await Permission.location.status;

    if (status == PermissionStatus.granted) {
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      print('status=$status');
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> getCurrentLocation(Function(Map result) onLocationChanged,
      {once = true}) async {
    bool isPermitted = await _requestPermission();
    print('isPermitted=$isPermitted');
    if (!isPermitted) {
      throw ('请在手机设置中开启本app位置权限');
    }

    if (isPermitted) {
      ///注册定位结果监听
      _locationListener = _locationPlugin
          .onLocationChanged()
          .listen((Map<String, Object> result) {
        onLocationChanged(result);

        stopLocation(once);
      });
      startLocation();
    }
  }

  ///设置定位参数
  void setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption();

    // locationOption.locationMode = AMapLocationMode.Battery_Saving; //低精度定位
    locationOption.onceLocation = true; //单次定位

    ///将定位参数设置给定位插件
    _locationPlugin.setLocationOption(locationOption);
  }

  ///开始定位
  void startLocation() {
    setLocationOption();
    _locationPlugin.startLocation();
  }

  ///停止定位
  void stopLocation(once) {
    _locationPlugin.stopLocation();
    once ? destroyLocation() : null;
  }

  //销毁定位
  destroyLocation() {
    cancel();
    _locationPlugin.destroy();
  }

  //取消定位
  void cancel() {
    if (null != _locationListener) {
      _locationListener?.cancel(); // 停止定位
    }
  }
}
