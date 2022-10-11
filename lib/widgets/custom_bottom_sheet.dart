import 'dart:async';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gd_map/page/send_position_page.dart';
import 'package:gd_map/provider/position_provider.dart';

import 'package:gd_map/widgets/poi_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class CustBottomSheet extends StatefulWidget {
  Widget child;

  List<Poi> poiList;
  Widget navigationBar;
  Widget addressIcon;
  LatLng latLng;
  CustBottomSheetListener custBottomSheetListener;
  CustBottomSheet({
    required this.child,
    required this.poiList,
    required this.navigationBar,
    required this.addressIcon,
    required this.latLng,
    required this.custBottomSheetListener,
    Key? key,
  }) : super(key: key);

  @override
  State<CustBottomSheet> createState() => _CustBottomSheetState();
}

class _CustBottomSheetState extends State<CustBottomSheet>
    with WidgetsBindingObserver {
  ScrollController scrollController = ScrollController();

  double minHeight = 300; //初始高度

  double dragHeight = 300; //拖拽高度

  double maxHeight = 600; //最大高度

  double _pointerDy = 0; //初始位置

  bool isActive = false; //底部buttomsheet 是否激活

  int milliseconds = 250; //动画时长

  bool isDrag = true; //是否可点击

  //输入框文本控制器
  TextEditingController textEditingController = TextEditingController();

  //控制焦点
  final FocusNode _focusNode = FocusNode();

  bool isSearch = false; //是否显示搜索列表

  String keyword = ""; //搜索关键字

  List<Poi> searchPoiList = []; //关键字搜索列表

  late StreamSubscription<bool> keyboardSubscription; //键盘监听

  bool keyboardState = false; //键盘是否弹起

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //初始化
    WidgetsBinding.instance.addObserver(this);

    var keyboardVisibilityController = KeyboardVisibilityController();

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible) {
        isSearch = true;
        keyboardState = true;
        widget.custBottomSheetListener.isSearchCallback(isSearch);

        if (isActive) return;
        dragHeight = maxHeight;
        isActive = true;
        isDrag = false;
        setState(() {});

        //动画时间禁止操作
        Future.delayed(Duration(milliseconds: milliseconds));
        isDrag = true;
      } else {
        keyboardState = false;
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(),
        bottomMap(),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: widget.navigationBar,
        ),
        locationBtn(),
        bottomSheet(),
      ],
    );
  }

  //底层的地图
  Widget bottomMap() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: milliseconds),
      top: -(dragHeight - 300) * 0.5,
      child: Stack(
        children: [
          Container(
            height: 600,
            color: Colors.blue,
            width: MediaQuery.of(context).size.width,
            child: widget.child,
          ),
          isSearch
              ? Container()
              : Positioned(
                  top: 300 - 50,
                  left: MediaQuery.of(context).size.width / 2 - 15,
                  child: widget.addressIcon,
                ),
        ],
      ),
    );
  }

  ///定位按钮
  Widget locationBtn() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: milliseconds),
      bottom: dragHeight + 10,
      right: 10,
      child: Listener(
        onPointerUp: !isDrag
            ? null
            : ((event) async {
                if (!isActive) return;
                dragHeight = minHeight;
                isActive = false;
                isDrag = false;
                FocusScope.of(context).unfocus();

                if (keyword.length == 0) {
                  isSearch = false;
                  widget.custBottomSheetListener.cancelBtnOnTap();
                  searchPoiList = [];
                }
                setState(() {});

                //动画时间禁止操作
                await Future.delayed(Duration(milliseconds: milliseconds));
                isDrag = true;
                setState(() {});
              }),
        child: InkWell(
          onTap: () async {
            widget.custBottomSheetListener.locationOnTap();
          },
          child: Container(
            height: 45,
            width: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Icon(
              Icons.my_location,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  //底部滑动sheet
  Widget bottomSheet() {
    return Positioned(
      bottom: 0,
      child: Listener(
        onPointerMove: !isDrag
            ? null
            : (event) {
                print("滑动");
                milliseconds = 50;
                //控制 内部LisView 是否可以滑动
                if (isSearch) {
                  if (searchPoiList.isNotEmpty) {
                    if (scrollController.offset != 0) return;
                  }
                } else {
                  if (widget.poiList.isNotEmpty) {
                    if (scrollController.offset != 0) return;
                  }
                }

                if (isActive) {
                  if (event.position.dy - _pointerDy > 0) {
                    double distance =
                        maxHeight - (event.position.dy - _pointerDy).abs();
                    if (distance > minHeight) {
                      dragHeight = distance;
                    }
                  }
                } else {
                  if (_pointerDy - event.position.dy > 0) {
                    double distance =
                        minHeight + (event.position.dy - _pointerDy).abs();
                    if (distance < maxHeight) {
                      dragHeight = distance;
                    }
                  }
                }

                setState(() {});
              },
        onPointerDown: !isDrag
            ? null
            : (event) {
                // 触摸事件开始 手指开始接触屏幕,设置初始位置
                _pointerDy = event.position.dy;
              },
        onPointerUp: !isDrag
            ? null
            : (e) async {
                milliseconds = 250;
                isDrag = false;
                if (isActive) {
                  if (dragHeight > maxHeight - 50) {
                    isActive = true;
                    dragHeight = maxHeight;
                  } else {
                    //激活状态到未激活状态
                    FocusScope.of(context).unfocus();
                    if (keyword.isEmpty) {
                      isSearch = false;
                      widget.custBottomSheetListener.isSearchCallback(isSearch);
                    }

                    isActive = false;
                    dragHeight = minHeight;
                  }
                } else {
                  if (dragHeight > minHeight + 50) {
                    isActive = true;
                    dragHeight = maxHeight;
                  } else {
                    isActive = false;
                    dragHeight = minHeight;
                  }
                }
                setState(() {});

                //动画时间禁止操作
                await Future.delayed(Duration(milliseconds: milliseconds));
                isDrag = true;
                setState(() {});
              },
        child: AnimatedContainer(
          duration: Duration(milliseconds: milliseconds),
          height: dragHeight,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              search(),
              AnimatedContainer(
                duration: Duration(milliseconds: milliseconds),
                height: dragHeight - 65,
                child: isSearch
                    ? SearchPoiList(
                        scrollController: scrollController,
                        isEqual: dragHeight != maxHeight,
                        poiList: searchPoiList,
                        custBottomSheetListener: widget.custBottomSheetListener,
                        itemOnTap: () {
                          if (!keyboardState) return;
                          if (!isActive) return;
                          dragHeight = minHeight;
                          isActive = false;
                          isDrag = false;
                          FocusScope.of(context).unfocus();
                          setState(() {});

                          //动画时间禁止操作
                          Future.delayed(Duration(milliseconds: milliseconds));
                          isDrag = true;
                          setState(() {});
                        })
                    : PoiList(
                        scrollController: scrollController,
                        isEqual: dragHeight != maxHeight,
                        poiList: widget.poiList,
                        latLng: widget.latLng,
                        custBottomSheetListener: widget.custBottomSheetListener,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget search() {
    return Container(
      padding: EdgeInsets.all(13),
      height: 65,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: textEditingController,
                textInputAction: TextInputAction.search,
                focusNode: _focusNode,
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: "搜索",
                  hintStyle: TextStyle(
                    color: Colors.black45,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.black45,
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 10),
                  filled: false,
                  isCollapsed: true,
                  border: InputBorder.none,
                ),
                onChanged: (e) async {
                  keyword = e;
                  searchPoiList = await Provider.of<PositionProvider>(context,
                          listen: false)
                      .searchKeyword(keyword);
                  setState(() {});
                },
                onSubmitted: ((value) {
                  print("开始搜索");

                  if (searchPoiList.isNotEmpty) {
                    widget.custBottomSheetListener
                        .keyboardSearcOnTap(searchPoiList[0]);
                  }
                  if (!isActive) return;
                  dragHeight = minHeight;
                  isActive = false;
                  isDrag = false;
                  setState(() {});

                  //动画时间禁止操作
                  Future.delayed(Duration(milliseconds: milliseconds));
                  isDrag = true;
                  setState(() {});
                }),
              ),
            ),
          ),
          isSearch
              ? InkWell(
                  onTap: () {
                    print("开始关闭");
                    if (isActive) {
                      dragHeight = minHeight;
                      isActive = false;
                      isDrag = false;

                      setState(() {});

                      FocusScope.of(context).unfocus();

                      //动画时间禁止操作
                      Future.delayed(Duration(milliseconds: milliseconds), (() {
                        isDrag = true;
                      }));
                    }
                    isSearch = false;
                    textEditingController.clear();
                    keyword = "";
                    widget.custBottomSheetListener.cancelBtnOnTap();
                    searchPoiList = [];

                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "取消",
                      style: TextStyle(
                        color: Color.fromARGB(255, 109, 134, 170),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
