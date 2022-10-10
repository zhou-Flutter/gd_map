import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gd_map/page/send_position_page.dart';
import 'package:gd_map/provider/position_provider.dart';
import 'package:gd_map/utils/tool.dart';
import 'package:provider/provider.dart';

class PoiList extends StatefulWidget {
  ScrollController scrollController;
  bool isEqual;
  List<Poi> poiList;
  LatLng latLng;

  CustBottomSheetListener custBottomSheetListener;

  PoiList({
    Key? key,
    required this.scrollController,
    required this.isEqual,
    required this.poiList,
    required this.latLng,
    required this.custBottomSheetListener,
  }) : super(key: key);

  @override
  State<PoiList> createState() => _PoiListState();
}

class _PoiListState extends State<PoiList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.poiList.length == 0
          ? Center(
              child: Container(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: Colors.black38,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(0),
              physics: widget.isEqual
                  ? NeverScrollableScrollPhysics()
                  : ClampingScrollPhysics(),
              controller: widget.scrollController,
              shrinkWrap: true,
              itemCount: widget.poiList.length,
              itemBuilder: (BuildContext context, int index) {
                return listItem(widget.poiList[index]);
              },
            ),
    );
  }

  Widget listItem(Poi item) {
    String distance = Tool().formatDistance(item.distance);
    return InkWell(
      onTap: () {
        widget.custBottomSheetListener.poiItemOnTap(item);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        distance,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                      Text(
                        "|",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${item.address}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: 10,
              alignment: Alignment.center,
              child: widget.latLng == item.latLng
                  ? Icon(
                      Icons.done,
                      color: Colors.green,
                    )
                  : Container(),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
      ),
    );
  }
}

class SearchPoiList extends StatefulWidget {
  ScrollController scrollController;
  bool isEqual;
  List<Poi> poiList;

  CustBottomSheetListener custBottomSheetListener;
  Function? itemOnTap;

  SearchPoiList({
    Key? key,
    required this.scrollController,
    required this.isEqual,
    required this.poiList,
    required this.custBottomSheetListener,
    this.itemOnTap,
  }) : super(key: key);

  @override
  State<SearchPoiList> createState() => _SearchPoiListState();
}

class _SearchPoiListState extends State<SearchPoiList> {
  LatLng? checkLatLng;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.poiList.isEmpty
          ? Container()
          : ListView.builder(
              padding: EdgeInsets.all(0),
              physics: widget.isEqual
                  ? NeverScrollableScrollPhysics()
                  : ClampingScrollPhysics(),
              controller: widget.scrollController,
              shrinkWrap: true,
              itemCount: widget.poiList.length,
              itemBuilder: (BuildContext context, int index) {
                return listItem(widget.poiList[index]);
              },
            ),
    );
  }

  Widget listItem(Poi item) {
    String distance = Tool().formatDistance(item.distance);
    return InkWell(
      onTap: () {
        checkLatLng = item.latLng;
        widget.custBottomSheetListener.searchPoiItemOnTap(item);
        widget.itemOnTap?.call();
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        distance,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                      Text(
                        "|",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${item.address}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: 10,
              alignment: Alignment.center,
              child: checkLatLng == item.latLng
                  ? Icon(
                      Icons.done,
                      color: Colors.green,
                    )
                  : Container(),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
      ),
    );
  }
}
