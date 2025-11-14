import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final VoidCallback? onComplete;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.onComplete,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Set audio source
      await _audioPlayer.setUrl(widget.audioUrl);

      // Listen to position changes
      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      });

      // Listen to duration changes
      _durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() => _duration = duration);
        }
      });

      // Listen to player state changes
      _playerStateSubscription =
          _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });

          // Check if playback completed
          if (state.processingState == ProcessingState.completed) {
            widget.onComplete?.call();
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        }
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el audio: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      setState(() => _error = 'Error al reproducir: ${e.toString()}');
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      setState(() => _error = 'Error al buscar posición: ${e.toString()}');
    }
  }

  Future<void> _skipForward() async {
    final newPosition = _position + const Duration(seconds: 10);
    await _seek(newPosition > _duration ? _duration : newPosition);
  }

  Future<void> _skipBackward() async {
    final newPosition = _position - const Duration(seconds: 10);
    await _seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializePlayer,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble() > 0
                      ? _duration.inSeconds.toDouble()
                      : 1,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          _seek(Duration(seconds: value.toInt()));
                        },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip backward button
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: _isLoading ? null : _skipBackward,
              ),

              const SizedBox(width: 20),

              // Play/Pause button
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        iconSize: 36,
                        color: Theme.of(context).colorScheme.onPrimary,
                        onPressed: _togglePlayPause,
                      ),
              ),

              const SizedBox(width: 20),

              // Skip forward button
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
                onPressed: _isLoading ? null : _skipForward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
