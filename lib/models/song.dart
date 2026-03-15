import 'dart:convert';
import 'package:flutter/material.dart';

class Song {
  Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.imagePath,
  });

  final String title;
  final String artist;
  final String url;
  final String imagePath;

  Widget getImage({double width = 96, double height = 96}) {
    if (imagePath.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[800],
        child: const Icon(Icons.music_note, size: 48, color: Colors.white),
      );
    }
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: const Icon(Icons.music_note, size: 48, color: Colors.white),
        );
      },
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imagePath: json['image'] as String? ?? '',
    );
  }

  static Future<List<Song>> loadSongsFromJson(String jsonString) async {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Song.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
