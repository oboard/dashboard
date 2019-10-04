import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:dashboard/manager.dart';
import 'package:dashboard/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/services.dart';
import 'CupertinoAcitionCard.dart';
import 'CupertinoReorderableList.dart';
import 'appbutton.dart';
import 'load.dart';
import 'manager.dart';

List<Dismissible> items = new List<Dismissible>();
Brightness brightnessValue = Brightness.light;

String what;

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
        primaryContrastingColor: Colors.blueGrey,
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  Animation<double> alpha;
  bool isMenu = false;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
    animation = new CurvedAnimation(parent: controller, curve: Curves.easeOut);
    alpha = new Tween(begin: 255.0, end: 0.0).animate(animation); // 动画
    controller.forward();
    alpha.addListener(() {
      setState(() {});
    });

    //关闭菜单的EventBus
    //订阅eventbus
    eventBus.on().listen((event) {
      setState(() {
        switch (event.toString()) {
          case 'setState':
            setState(() {
              controller.reverse();
              controller.forward();
            });
            break;
          case 'closeMenu':
            closeMenu();
            break;
        }
      });
    });

    loadList();
  }

  closeMenu() {
    isMenu = false;
    controller.forward();
    setState(() {});
    alpha.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      brightnessValue = MediaQuery.of(context).platformBrightness;
    });

    ;
    return Container(
      color: Colors.grey,
      child: Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Image.network(
              "https://api.neweb.top/bing.php?type=rand",
              fit: BoxFit.cover,
            ),
          ),
          CupertinoReorderableListView(
            children: items.toList(),
            onReorder: (int oldIndex, int newIndex) {
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
                    color: CupertinoTheme.of(context)
                        .barBackgroundColor
                        .withOpacity(0.3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CupertinoButton(
                          child: Icon(
                            Icons.add,
                            size: 30,
                          ),
                          onPressed: () {
                            isMenu = true;
                            controller.duration = Duration(milliseconds: 300);
                            controller.reverse();
                            setState(() {});
                            alpha.addListener(() {
                              setState(() {});
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: alpha.value >= 0.1,
            child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: alpha.value / 255 * 50,
                    sigmaY: alpha.value / 255 * 50),
                child: Container(
                  color: CupertinoTheme.of(context)
                      .barBackgroundColor
                      .withAlpha(100),
                )),
          ),
          Visibility(
            visible: isMenu,
            child: Opacity(
              opacity: alpha.value / 255,
              child: Transform.scale(
                scale: 1.5 - alpha.value / 255 / 2,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: GridView.count(
                        //水平子Widget之间间距
                        crossAxisSpacing: 10.0,
                        //垂直子Widget之间间距
                        mainAxisSpacing: 10.0,
                        //一行的Widget数量
                        crossAxisCount: 1,
                        childAspectRatio: 3,
                        children: <Widget>[
                          AppButton(
                            image: Image.network(
                              "https://www.dailypics.cn/static/assets/images/favicon.ico",
                              height: 64,
                            ),
                            title: Text("图鉴日图"),
                            id: 'tujian',
                          ),
                          AppButton(
                            image: Image.network(
                              "https://hitokoto.cn/favicon.ico",
                              height: 64,
                            ),
                            title: Text("一言"),
                            id: 'yiyan',
                          ),
                          AppButton(
                            image: Image.network(
                              "https://vignette.wikia.nocookie.net/logopedia/images/0/09/Bing-2.png/revision/latest/scale-to-width-down/220?cb=20160504230420",
                              height: 64,
                            ),
                            title: Text("必应日图"),
                            id: 'bingpic',
                          ),
                        ],
                      ),
                    ),
                    new Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: CupertinoTheme.of(context)
                                  .barBackgroundColor
                                  .withOpacity(0.3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CupertinoButton(
                                    child: Icon(
                                      Icons.close,
                                      size: 30,
                                    ),
                                    onPressed: () => closeMenu(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
