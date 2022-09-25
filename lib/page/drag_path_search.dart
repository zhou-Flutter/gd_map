import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class SearchPos extends StatefulWidget {
  const SearchPos({Key? key}) : super(key: key);

  @override
  State<SearchPos> createState() => _SearchPosState();
}

class _SearchPosState extends State<SearchPos> {
  //输入框文本控制器
  TextEditingController textEditingController = TextEditingController();

  //控制焦点
  final FocusNode _focusNode = FocusNode();

  List<InputTip> tipList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  search(keyword) async {
    tipList = await AmapSearch.instance.fetchInputTips(keyword, city: "成都市");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 15, left: 10),
                    child: Icon(
                      Icons.arrow_back,
                      size: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: textEditingController,
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
                      onChanged: (e) {
                        print(e);
                        search(e);

                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
            posList(),
          ],
        ),
      ),
    );
  }

  Widget posList() {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: tipList.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Navigator.pop(context, tipList[index]);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.pin_drop,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "${tipList[index].name}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            "${tipList[index].district}${tipList[index].address}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
