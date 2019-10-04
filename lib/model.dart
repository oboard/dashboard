import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Model {
  const Model(this.title, this.children, this.id);

  final String title;
  final List<Widget> children;
  final String id;
}
