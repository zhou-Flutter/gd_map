import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gd_map/provider/position_provider.dart';
import 'package:provider/provider.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

class PoiList extends StatefulWidget {
  ScrollController scrollController;
  bool isEqual;
  List<Poi> poiList;

  LatLng latLng;

  PoiList({
    Key? key,
    required this.scrollController,
    required this.isEqual,
    required this.poiList,
    required this.latLng,
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
              child: CircularProgressIndicator(),
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
    return InkWell(
      onTap: () {
        print(item);
        Provider.of<PositionProvider>(context, listen: false).onTapPoi(item);
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
                        "${item.distance}m",
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
              child: widget.latLng ==
                      LatLng(item.latLng!.latitude, item.latLng!.longitude)
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
