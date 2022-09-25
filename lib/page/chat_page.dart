import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gd_map/model/common_model.dart';
import 'package:gd_map/provider/position_provider.dart';
import 'package:gd_map/page/send_position_page.dart';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:gd_map/widgets/chat_map.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> chatList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chatList = context.watch<PositionProvider>().chatList;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 236, 245),
      appBar: AppBar(title: Text("模拟发送位置")),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (BuildContext context, int index) {
          return messageItem(chatList[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SendPosition()));
        },
        child: Icon(Icons.send),
      ),
    );
  }

  Widget messageItem(ChatMessage item) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        textDirection:
            item.isSelf == true ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.blue,
            ),
            child: Text("头像"),
          ),
          SizedBox(width: 10),
          ChatMap(
            item: item,
          ),
        ],
      ),
    );
  }
}
