import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:dashboard/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Icons, IconButton;
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'CupertinoReorderableList.dart';

List<Model> items = new List<Model>();
Brightness brightnessValue = Brightness.light;

void main() {
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.grey);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Dashboard',
      theme: CupertinoThemeData(
        primaryColor: Colors.blue,
        brightness: brightnessValue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    loadAsentence();
    loadTujian();
  }

  Future<String> loadUrl(String url) async {
    String a = url;
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(a));
    HttpClientResponse response = await request.close();
    a = await response.transform(utf8.decoder).join();
    httpClient.close();
    return a;
  }

  Future<void> loadTujian() async {
    String tujian = await loadUrl("https://v2.api.dailypics.cn/today");
    tujian = tujian.replaceAll("\"", "");
    tujian = tujian.replaceAll(",", "");
    tujian = tujian.replaceAll(":", "");
    tujian = tujian.replaceAll("\\r\\n", "\n");
    tujian = tujian.replaceAll("\\/\\/", "");
    String picTitle = tujian.split("p_title")[1].split("p_content")[0];
    String picLink = tujian
        .split("local_url")[1]
        .split("TID")[0]
        .replaceAll("https", "https://")
        .replaceAll("\\/", "/");
    String picContent = tujian.split("p_content")[1].split("width")[0];
    setState(() {
      items.add(
        Model(
          "图鉴日图",
          <Widget>[
            Stack(
              children: <Widget>[
                Image.network(picLink),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        picTitle + "\n" + picContent,
                        style: TextStyle(
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 20,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            CupertinoButton(
              child: Text("复制链接"),
              onPressed: () {
                Clipboard.setData(new ClipboardData(text: picLink));
              },
            ),
          ],
        ),
      );
    });
  }

  Future<void> loadAsentence() async {
    String asentence = await loadUrl(
        "https://api.lwl12.com/hitokoto/v1?encode=text&charset=utf-8");

    setState(() {
      items.add(
        Model(
          "一句",
          <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: <Widget>[
                  Text(asentence),
                ],
              ),
            ),
            CupertinoButton(
              child: Text("复制"),
              onPressed: () {
                Clipboard.setData(new ClipboardData(text: asentence));
              },
            ),
            CupertinoButton(
              child: Text("分享"),
              onPressed: () async {
                Share.share(asentence);
              },
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      brightnessValue = MediaQuery.of(context).platformBrightness;
      print(brightnessValue);
    });
    return Stack(
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Image.network(
            "https://api.neweb.top/bing.php?type=rand",
            fit: BoxFit.cover,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: new Container(
            color: Colors.black.withOpacity(0.1),
          ),
        ),
        CupertinoReorderableListView(
          children: items
              .map(
                (m) => Dismissible(
                  key: ObjectKey(Random().nextInt(10000)),
                  child: CupertinoActionSheet(
                    title: new Text(m.title),
                    actions: m.children,
                  ),
                ),
              )
              .toList(),
          onReorder: (int oldIndex, int newIndex) {
            print("$oldIndex --- $newIndex");
            setState(() {
              if (newIndex == items.length) {
                newIndex = items.length - 1;
              }

              var temp = items.removeAt(oldIndex);
              items.insert(newIndex, temp);
            });
          },
        ),
        new Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CupertinoButton(
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
