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

  List<Song> get songs => _songs;
  Song get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  void initialize(List<Song> songs) {
    _songs = songs;
    _currentSongIndex = 0;
    _updateCurrentSong();
    _isPlaying = false;
    togglePlaying();
  }

  void togglePlaying() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void nextSong() {
    _currentSongIndex += 1;
    _updateCurrentSong();
    notifyListeners();
  }

  void previousSong() {
    _currentSongIndex -= 1;
    _updateCurrentSong();
    notifyListeners();
  }

  void _updateCurrentSong() {
    _currentSong = _songs[_currentSongIndex];
  }
}
