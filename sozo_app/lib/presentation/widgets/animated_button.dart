import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ui_sound_service.dart';

class AnimatedButton extends ConsumerStatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isOutlined;
  final bool playSound;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
    this.height,
    this.isOutlined = false,
    this.playSound = true,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  ConsumerState<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends ConsumerState<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() async {
    if (widget.onPressed == null) return;
    
    // 効果音を再生
    if (widget.playSound) {
      final uiSoundService = ref.read(uiSoundServiceProvider);
      await uiSoundService.playButtonTap();
    }
    
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = widget.isOutlined
        ? Colors.transparent
        : widget.backgroundColor ?? theme.colorScheme.primary;
    final defaultForegroundColor = widget.isOutlined
        ? widget.foregroundColor ?? theme.colorScheme.primary
        : widget.foregroundColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: defaultBackgroundColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                border: widget.isOutlined
                    ? Border.all(
                        color: defaultForegroundColor.withOpacity(0.5),
                        width: 2,
                      )
                    : null,
                boxShadow: widget.boxShadow ??
                    [
                      if (!widget.isOutlined)
                        BoxShadow(
                          color: defaultBackgroundColor.withOpacity(0.3),
                          blurRadius: _isPressed ? 4 : 8,
                          offset: Offset(0, _isPressed ? 2 : 4),
                        ),
                    ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: null, // GestureDetectorで処理するため、InkWellのonTapは無効化
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                  splashColor: defaultForegroundColor.withOpacity(0.2),
                  highlightColor: defaultForegroundColor.withOpacity(0.1),
                  child: Padding(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: defaultForegroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

// アイコン付きボタン
class AnimatedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;
  final bool playSound;

  const AnimatedIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
    this.playSound = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isOutlined: isOutlined,
      playSound: playSound,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
} 