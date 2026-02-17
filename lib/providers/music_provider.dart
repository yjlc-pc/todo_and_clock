import 'dart:async';
import 'package:flutter/material.dart';
import '../models/song.dart';

class MusicProvider extends ChangeNotifier {
  List<Song> _songs = [];
  int _currentSongIndex = 0;
  Song _currentSong = Song(
    title: '',
    artist: '',
    url: '',
    image: Image.asset(''),
  );
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 30);
  Timer? _progressTimer;

  List<Song> get songs => _songs;
  Song get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get progress => _duration.inMilliseconds > 0
      ? _position.inMilliseconds / _duration.inMilliseconds
      : 0.0;

  void initialize(List<Song> songs) {
    _songs = songs;
    _currentSongIndex = 0;
    _updateCurrentSong();
    _isPlaying = false;
    _position = Duration.zero;
    _progressTimer?.cancel();
    notifyListeners();
  }

  void togglePlaying() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startProgressTimer();
    } else {
      _progressTimer?.cancel();
    }
    notifyListeners();
  }

  void nextSong() {
    _currentSongIndex += 1;
    if (_currentSongIndex >= _songs.length) {
      _currentSongIndex = 0;
    }
    _updateCurrentSong();
    _position = Duration.zero;
    notifyListeners();
  }

  void previousSong() {
    _currentSongIndex -= 1;
    if (_currentSongIndex < 0) {
      _currentSongIndex = _songs.length - 1;
    }
    _updateCurrentSong();
    _position = Duration.zero;
    notifyListeners();
  }

  void seekTo(Duration position) {
    _position = position;
    notifyListeners();
  }

  void _updateCurrentSong() {
    if (_songs.isNotEmpty) {
      _currentSong = _songs[_currentSongIndex];
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_position < _duration) {
        _position += const Duration(seconds: 1);
        notifyListeners();
      } else {
        nextSong();
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}
