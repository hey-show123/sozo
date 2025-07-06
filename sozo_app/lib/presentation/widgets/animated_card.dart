import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ui_sound_service.dart';

class AnimatedCard extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? customShadow;
  final bool playSound;
  final Duration? animationDelay;
  final bool shimmerEffect;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.customShadow,
    this.playSound = true,
    this.animationDelay,
    this.shimmerEffect = false,
  }) : super(key: key);

  @override
  ConsumerState<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends ConsumerState<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 4.0,
      end: (widget.elevation ?? 4.0) * 0.5,
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
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() async {
    if (widget.onTap == null) return;
    
    if (widget.playSound) {
      final uiSoundService = ref.read(uiSoundServiceProvider);
      await uiSoundService.playButtonTap();
    }
    
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = widget.backgroundColor ?? theme.cardColor;
    
    Widget card = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: widget.margin,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                  boxShadow: widget.customShadow ??
                      [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: _isHovered ? 12 : _elevationAnimation.value,
                          offset: Offset(0, _isHovered ? 6 : _elevationAnimation.value * 0.5),
                          spreadRadius: _isHovered ? 2 : 0,
                        ),
                      ],
                ),
                child: ClipRRect(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: null, // GestureDetectorで処理するため、InkWellのonTapは無効化
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                      splashColor: theme.colorScheme.primary.withOpacity(0.1),
                      highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: _isHovered
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.03),
                                    Colors.transparent,
                                  ],
                                )
                              : null,
                        ),
                        child: Padding(
                          padding: widget.padding ??
                              const EdgeInsets.all(16),
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
      ),
    );

    // シマー効果を追加
    if (widget.shimmerEffect) {
      card = card
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2000.ms,
            color: theme.colorScheme.primary.withOpacity(0.05),
          );
    }

    // 初期アニメーション
    return card
        .animate(delay: widget.animationDelay ?? 0.ms)
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

// グラデーション付きカード
class GradientAnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<Color> gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool playSound;

  const GradientAnimatedCard({
    Key? key,
    required this.child,
    required this.gradientColors,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.playSound = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      margin: margin,
      borderRadius: borderRadius,
      playSound: playSound,
      backgroundColor: Colors.transparent,
      customShadow: [
        BoxShadow(
          color: gradientColors.first.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(20),
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
} 