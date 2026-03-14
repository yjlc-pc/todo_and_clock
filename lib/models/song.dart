import 'dart:convert';
import 'package:flutter/material.dart';

/// 歌曲模型 - 纯数据类
class Song {
  final String title;
  final String artist;
  final String url;
  final String imagePath;

  Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.imagePath,
  });

  /// 从 JSON 创建歌曲
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imagePath: json['image'] as String? ?? '',
    );
  }

  /// 从 JSON 字符串加载歌曲列表
  static Future<List<Song>> loadSongsFromJson(String jsonString) async {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Song.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 获取歌曲封面图片
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
}
