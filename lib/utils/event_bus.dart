import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:event_bus/event_bus.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

EventBus eventBus = new EventBus();

//定位Event
class LocationEvent {
  bool isAnimate;
  List<Poi> poiList;
  LatLng latLng;

  LocationEvent(this.isAnimate, this.poiList, this.latLng);
}
