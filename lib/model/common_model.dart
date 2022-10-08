import 'package:amap_map_fluttify/amap_map_fluttify.dart';

class SendPosition {
  LatLng? latLng;
  String? title;
  String? formatAddress;

  SendPosition({
    this.latLng,
    this.title,
    this.formatAddress,
  });
}

//模拟位置 数据模型
class ChatMessage {
  late int? messageType; //8代表位置消息
  late bool? isSelf;
  SendPosition? sendPosition;

  ChatMessage({
    this.messageType,
    this.isSelf,
    this.sendPosition,
  });
}
