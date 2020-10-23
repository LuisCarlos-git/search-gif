import 'package:flutter/material.dart';
import 'package:search_gif/Widgets/home_page/index.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Serach Gifs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(hintColor: Colors.white),
      home: HomePage(),
    ),
  );
}
