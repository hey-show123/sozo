import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedAvatar extends StatefulWidget {
  final bool isPlaying;
  final double size;
  final String? fallbackAvatarPath;
  final Widget? fallbackWidget;
  
  const AnimatedAvatar({
    super.key,
    required this.isPlaying,
    this.size = 120,
    this.fallbackAvatarPath,
    this.fallbackWidget,
  });
  
  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar> {
  Timer? _animationTimer;
  bool _showOpenMouth = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.isPlaying) {
      _startAnimation();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }
  
  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _showOpenMouth = !_showOpenMouth;
        });
      }
    });
  }
  
  void _stopAnimation() {
    _animationTimer?.cancel();
    setState(() {
      _showOpenMouth = false;
    });
  }
  
  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }
  
  String _getAvatarImagePath(bool isOpenMouth) {
    return isOpenMouth 
        ? 'assets/images/avatars/character_mouth_open.png'
        : 'assets/images/avatars/character_mouth_closed.png';
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: widget.isPlaying
          ? Image.asset(
              _getAvatarImagePath(_showOpenMouth),
              key: ValueKey<bool>(_showOpenMouth),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                if (widget.fallbackAvatarPath != null) {
                  return Image.asset(
                    widget.fallbackAvatarPath!,
                    fit: BoxFit.contain,
                  );
                }
                return widget.fallbackWidget ?? _buildPlaceholder();
              },
            )
          : Image.asset(
              _getAvatarImagePath(false),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                if (widget.fallbackAvatarPath != null) {
                  return Image.asset(
                    widget.fallbackAvatarPath!,
                    fit: BoxFit.contain,
                  );
                }
                return widget.fallbackWidget ?? _buildPlaceholder();
              },
            ),
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }
} 