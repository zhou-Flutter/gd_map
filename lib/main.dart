import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:gd_map/page/draw_path.dart';
import 'package:gd_map/provider/position_provider.dart';
import 'package:gd_map/page/chat_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AmapSearch.instance.updatePrivacyAgree(true);
  await AmapSearch.instance.updatePrivacyShow(true);
  await AmapService.instance.init(iosKey: '842309d7c40ba5e687141496498b1199');

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
    {"title": "绘制 路径和Mark", "page": DragPath()},
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("地图定位")),
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
