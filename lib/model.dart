import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Model {
  const Model(@required this.title, this.children);

  final String title;
  final List<Widget> children;
}