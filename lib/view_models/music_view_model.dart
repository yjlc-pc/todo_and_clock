import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/song.dart';
import 'base_view_model.dart';

/// 音乐 ViewModel
/// 负责音乐播放的业务逻辑和状态管理
class MusicViewModel extends BaseViewModel {
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

  List<Song> get songs => _songs;
  Song get currentSong => _currentSong ?? _emptySong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get progress => _duration.inMilliseconds > 0
      ? _position.inMilliseconds / _duration.inMilliseconds
      : 0.0;

  @override
  Future<void> initialize() async {
    _initAudioPlayer();
    _setupAudioPlayerListeners();
    _isInitialized = true;
  }

  /// 初始化音乐播放器并加载歌曲
  Future<void> loadSongs() async {
    try {
      final jsonString = await rootBundle.loadString('assets/music/songs.json');
      _songs = await Song.loadSongsFromJson(jsonString);
      _currentSongIndex = 0;
      _updateCurrentSong();
      
      if (_currentSong != null && _currentSong!.url.isNotEmpty) {
        await _loadAndPlaySong(_currentSong!.url);
      }
      
      notifyListeners();
    } catch (e) {
      setError('加载歌曲失败：$e');
    }
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

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      nextSong();
    });
  }

  Future<void> _loadAndPlaySong(String url) async {
    if (!_isInitialized) return;

    try {
      String assetPath = url;
      if (assetPath.startsWith('assets/')) {
        assetPath = assetPath.substring('assets/'.length);
      }

      await _audioPlayer.stop();
      await _audioPlayer.setSourceAsset(assetPath);
      await _audioPlayer.resume();
    } catch (e) {
      await _tryLoadWithUrlAndPlay(url);
    }
  }

  Future<void> _tryLoadWithUrlAndPlay(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('音频加载失败：$e');
    }
  }

  /// 切换播放/暂停
  Future<void> togglePlaying() async {
    if (!_isInitialized || _currentSong == null || _currentSong!.url.isEmpty) {
      return;
    }

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

    _currentSongIndex = _currentSongIndex <= 0 ? _songs.length - 1 : _currentSongIndex - 1;
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
