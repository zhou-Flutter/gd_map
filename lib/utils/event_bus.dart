import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = new EventBus();

//定位Event
class LocationEvent {
  bool isAnimate;
  LatLng latLng;

  LocationEvent(this.isAnimate, this.latLng);
}
