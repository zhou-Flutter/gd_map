import 'package:amap_flutter_base/amap_flutter_base.dart';

class Slta {
  LatLng? latLng;
  String? formatAddress;
  String? township;
  Slta({
    this.latLng,
    this.formatAddress,
    this.township,
  });
}

//模拟位置 数据模型
class ChatMessage {
  late int? messageType; //8代表位置消息
  late bool? isSelf;
  Slta? sendlta;

  ChatMessage({
    this.messageType,
    this.isSelf,
    this.sendlta,
  });
}
