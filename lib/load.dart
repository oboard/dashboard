import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:share/share.dart';

import 'CupertinoAcitionCard.dart';
import 'main.dart';
import 'manager.dart';
import 'model.dart';

Future loadList() async {
  what = await Manager().readShared("list");
  print(what);
  if (what == null || what.indexOf(';') == -1) {
    what = 'yiyan;tujian;';
    Manager().writeShared('list', what);
  }
  List<String> whats = what.split(';');
  for (String w in whats) {
    loadId(w);
  }
}

loadId(String w) async {
  Model m;
  switch (w) {
    case 'tujian':
      m = await loadTujian();
      break;
    case 'yiyan':
      m = await loadAsentence();
      break;
    case 'bingpic':
      m = await loadBingPic();
      break;
  }
  Dismissible d = Dismissible(
    key: ObjectKey(Random().nextInt(10000)),
    child: CupertinoActionCard(
      title: new Text(m.title),
      actions: m.children,
    ),
    onDismissed: (DismissDirection direction) async {
      items.removeAt(items.length);
      String list = await Manager().readShared('list');
      int index = list.indexOf(m.id);
      list = list.substring(0, index) + list.substring(index + m.id.length + 1);
      Manager().writeShared('list', list);
    },
  );
  items.add(d);
  eventBus.fire('setState');
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

Future<Model> loadTujian() async {
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
  Model m = Model(
      "图鉴日图",
      <Widget>[
        Stack(
          children: <Widget>[
            Image.network(picLink),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        picTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          picContent,
                          style: TextStyle(
                            color: Color.fromARGB(200, 255, 255, 255),
                            fontSize: 15,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: CupertinoButton(
                child: Text("复制图片链接"),
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: picLink));
                },
              ),
            ),
          ],
        ),
      ],
      'tujian');
  return m;
}

Future<Model> loadBingPic() async {
  String bingpic = await loadUrl("https://bing.biturl.top/");
  bingpic = bingpic.replaceAll("\":\"", "");
  bingpic = bingpic.replaceAll("\",\"", "");
  bingpic = bingpic.replaceAll("\\r\\n", "\n");
  bingpic = bingpic.replaceAll(",", "");
  String picLink = bingpic.split("url")[1].split("copyright")[0];
  String picContent = bingpic.split("copyright")[1].split("copyright_link")[0];
  Model m = Model(
      "必应日图",
      <Widget>[
        Stack(
          children: <Widget>[
            Image.network(picLink),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          picContent,
                          style: TextStyle(
                            color: Color.fromARGB(200, 255, 255, 255),
                            fontSize: 15,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: CupertinoButton(
                child: Text("复制图片链接"),
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: picLink));
                },
              ),
            ),
          ],
        ),
      ],
      'bingpic');
  return m;
}

Future<Model> loadAsentence() async {
  String asentence = await loadUrl(
      "https://api.lwl12.com/hitokoto/v1?encode=text&charset=utf-8");

  Model m = Model(
      "一言",
      <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: <Widget>[
              Text(asentence),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Center(
                  child: CupertinoButton(
                    child: Text("复制"),
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(text: asentence));
                    },
                  ),
                )),
            Expanded(
              flex: 1,
              child: CupertinoButton(
                child: Text("分享"),
                onPressed: () async {
                  Share.share(asentence);
                },
              ),
            ),
          ],
        ),
      ],
      'yiyan');
  return m;
}
