import 'package:flutter/material.dart';

class Song {
  Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.image,
  });
  String title;
  String artist;
  String url;
  Image image;
}
