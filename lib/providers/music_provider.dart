import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';

/// 音乐播放器 Provider
/// 负责管理音频播放、歌曲列表和播放状态
class MusicProvider extends ChangeNotifier {
  late AudioPlayer _audioPlayer;
  List<Song> _songs = [];
  int _currentSongIndex = 0;
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  bool _isInitialized = false;

  final Song _emptySong = Song(title: '', artist: '', url: '', imagePath: '');

  /// 歌曲列表
  List<Song> get songs => _songs;

  /// 当前歌曲
  Song get currentSong => _currentSong ?? _emptySong;

  /// 是否正在播放
  bool get isPlaying => _isPlaying;

  /// 当前播放位置
  Duration get position => _position;

  /// 歌曲总时长
  Duration get duration => _duration;

  /// 播放进度百分比 (0.0 - 1.0)
  double get progress => _duration.inMilliseconds > 0
      ? _position.inMilliseconds / _duration.inMilliseconds
      : 0.0;

  /// 初始化音乐播放器
  /// [songs] - 歌曲列表
  void initialize(List<Song> songs) async {
    _songs = songs;
    _currentSongIndex = 0;
    _updateCurrentSong();
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isInitialized = true;

    _initAudioPlayer();
    _setupAudioPlayerListeners();

    if (_currentSong != null && _currentSong!.url.isNotEmpty) {
      await _loadAndPlaySong(_currentSong!.url);
    }

    notifyListeners();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void _setupAudioPlayerListeners() {
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      nextSong();
    });
  }

  /// 加载并播放歌曲
  /// [url] - 歌曲路径，格式：assets/music/xxx.mp3
  Future<void> _loadAndPlaySong(String url) async {
    if (!_isInitialized) return;

    try {
      String assetPath = url;

      // audioplayers 的 setSourceAsset 方法需要相对于 assets 目录的路径
      if (assetPath.startsWith('assets/')) {
        assetPath = assetPath.substring('assets/'.length);
      }

      await _audioPlayer.stop();
      await _audioPlayer.setSourceAsset(assetPath);
      await _audioPlayer.resume();
    } catch (e) {
      // 备用方案：尝试使用 setSourceUrl
      await _tryLoadWithUrlAndPlay(url);
    }
  }

  /// 备用加载方法：使用 setSourceUrl 并播放
  Future<void> _tryLoadWithUrlAndPlay(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('音频加载失败：$e');
    }
  }

  /// 切换播放/暂停状态
  Future<void> togglePlaying() async {
    if (!_isInitialized) return;

    if (_currentSong == null || _currentSong!.url.isEmpty) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _loadAndPlaySong(_currentSong!.url);
      }
    } catch (e) {
      debugPrint('播放控制错误：$e');
    }
  }

  /// 播放下一首
  Future<void> nextSong() async {
    if (_songs.isEmpty) return;

    _currentSongIndex = (_currentSongIndex + 1) % _songs.length;
    _updateCurrentSong();
    _resetPosition();

    if (_currentSong != null && _currentSong!.url.isNotEmpty) {
      await _loadAndPlaySong(_currentSong!.url);
    }

    notifyListeners();
  }

  /// 播放上一首
  Future<void> previousSong() async {
    if (_songs.isEmpty) return;

    _currentSongIndex = _currentSongIndex <= 0
        ? _songs.length - 1
        : _currentSongIndex - 1;
    _updateCurrentSong();
    _resetPosition();

    if (_currentSong != null && _currentSong!.url.isNotEmpty) {
      await _loadAndPlaySong(_currentSong!.url);
    }

    notifyListeners();
  }

  /// 跳转到指定位置
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('跳转进度错误：$e');
    }
  }

  void _updateCurrentSong() {
    if (_songs.isNotEmpty) {
      _currentSong = _songs[_currentSongIndex];
    }
  }

  void _resetPosition() {
    _position = Duration.zero;
    _duration = Duration.zero;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
