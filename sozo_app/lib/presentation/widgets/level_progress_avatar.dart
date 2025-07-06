import 'package:flutter/material.dart';
import 'dart:math' as math;

class LevelProgressAvatar extends StatefulWidget {
  final String? avatarUrl;
  final double progress; // 0.0 ~ 1.0
  final int currentLevel;
  final int remainingXp;
  final double size;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  const LevelProgressAvatar({
    Key? key,
    this.avatarUrl,
    required this.progress,
    required this.currentLevel,
    required this.remainingXp,
    this.size = 80,
    this.progressColor = Colors.amber,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 4,
  }) : super(key: key);

  @override
  State<LevelProgressAvatar> createState() => _LevelProgressAvatarState();
}

class _LevelProgressAvatarState extends State<LevelProgressAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(LevelProgressAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + widget.strokeWidth * 2,
      height: widget.size + widget.strokeWidth * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // プログレスバー
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(
                  widget.size + widget.strokeWidth * 2,
                  widget.size + widget.strokeWidth * 2,
                ),
                painter: CircularProgressPainter(
                  progress: _animation.value,
                  progressColor: widget.progressColor,
                  backgroundColor: widget.backgroundColor.withOpacity(0.3),
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),
          
          // アバター
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                  ? widget.avatarUrl!.startsWith('http')
                      ? Image.network(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                      : Image.asset(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                  : _buildDefaultAvatar(),
            ),
          ),
          
          // レベルバッジ
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Lv.${widget.currentLevel}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // XPツールチップ（タップで表示）
          if (widget.remainingXp > 0)
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('あと${widget.remainingXp}XPでレベルアップ！'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: widget.progressColor,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.progressColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: widget.size * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}

// 円形プログレスバーのペインター
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 背景の円
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // プログレスの円弧
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 上から開始
      sweepAngle,
      false,
      progressPaint,
    );

    // 進捗が100%に近い場合はキラキラエフェクト
    if (progress > 0.95) {
      final glowPaint = Paint()
        ..color = progressColor.withOpacity(0.3)
        ..strokeWidth = strokeWidth * 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
} 