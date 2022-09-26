import 'dart:math';

import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gd_map/page/draw_path.dart';
import 'package:gd_map/provider/position_provider.dart';

import 'package:gd_map/page/send_position_page.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import 'package:gd_map/page/chat_page.dart';
import 'package:gd_map/page/show_position_page.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PositionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Provider Demo',
        initialRoute: '/',
        routes: {
          '/': (context) => GdMap(),
        },
      ),
    );
  }
}

class GdMap extends StatefulWidget {
  GdMap({Key? key}) : super(key: key);

  @override
  State<GdMap> createState() => _GdMapState();
}

class _GdMapState extends State<GdMap> {
  List plate = [
    {"title": "模拟微信聊天发送位置", "page": ChatPage()},
    {"title": "绘制路径轨迹", "page": DragPath()},
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //初始化定位
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<PositionProvider>(context, listen: false).initlocation(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Plate")),
      body: ListView.builder(
        itemCount: plate.length,
        itemBuilder: (BuildContext context, int index) {
          return item(plate[index]);
        },
      ),
    );
  }

  Widget item(item) {
    return Card(
      child: ListTile(
        title: Text("${item["title"]}"),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => item["page"]));
        },
      ),
    );
  }
}
