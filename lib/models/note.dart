import 'package:flutter/material.dart';

class Note {
  String title;
  String content;
  Color color;
  String imageUrl;

  Note({
    required this.title,
    required this.content,
    this.color = Colors.white,
    this.imageUrl = "",
  });
}
