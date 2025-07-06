import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:sozo_app/services/achievement_service.dart';
import 'package:sozo_app/services/audio_player_service.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementNotification extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String icon;
  final String category;
  final int xpReward;
  final VoidCallback? onDismiss;

  const AchievementNotification({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.xpReward = 0,
    this.onDismiss,
  });

  @override
  ConsumerState<AchievementNotification> createState() => _AchievementNotificationState();
}

class _AchievementNotificationState extends ConsumerState<AchievementNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _iconController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconRotation;
  late Animation<double> _iconBounce;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    
    // アニメーションコントローラーの初期化
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 紙吹雪コントローラー
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // アニメーションの設定
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _iconRotation = Tween<double>(
      begin: -0.2,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticInOut,
    ));
    
    _iconBounce = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticInOut,
    ));
    
    // アニメーションの開始
    _startAnimations();
    
    // 3秒後に自動で消える
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }
  
  void _startAnimations() async {
    // 効果音を再生
    _playSound();
    
    // 紙吹雪を開始
    _confettiController.play();
    
    // スライドアニメーション
    await _slideController.forward();
    
    // スケールアニメーション
    _scaleController.forward();
    
    // アイコンのループアニメーション
    _iconController.repeat(reverse: true);
  }
  
  void _playSound() async {
    try {
      final audioService = ref.read(audioPlayerServiceProvider);
      
      // カテゴリ別の効果音ファイル
      String soundFile;
      switch (widget.category) {
        case 'milestone':
          soundFile = 'achievement_milestone.wav';
          break;
        case 'streak':
          soundFile = 'achievement_streak.wav';
          break;
        case 'skill':
          soundFile = 'achievement_skill.wav';
          break;
        case 'challenge':
          soundFile = 'achievement_challenge.wav';
          break;
        case 'special':
          soundFile = 'achievement_special.wav';
          break;
        default:
          soundFile = 'achievement_default.wav';
      }
      
      // assets/sounds/から音声を再生
      await audioService.playAssetAudio('sounds/$soundFile');
    } catch (e) {
      print('効果音の再生に失敗しました: $e');
    }
  }

  void _dismiss() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _iconController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    // アイコン名からIconDataを取得
    switch (iconName) {
      case 'flag':
        return Icons.flag;
      case 'fire':
        return Icons.local_fire_department;
      case 'star':
        return Icons.star;
      case 'diamond':
        return Icons.diamond;
      case 'mic':
        return Icons.mic;
      case 'star_outline':
        return Icons.star_outline;
      case 'book':
        return Icons.book;
      case 'chat':
        return Icons.chat;
      case 'flash_on':
        return Icons.flash_on;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'nights_stay':
        return Icons.nights_stay;
      case 'weekend':
        return Icons.weekend;
      case 'trending_up':
        return Icons.trending_up;
      case 'timer':
        return Icons.timer;
      case 'people':
        return Icons.people;
      case 'celebration':
        return Icons.celebration;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'milestone':
        return Colors.purple;
      case 'streak':
        return Colors.orange;
      case 'skill':
        return Colors.blue;
      case 'challenge':
        return Colors.green;
      case 'special':
        return Colors.pink;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.category);

    return Stack(
      children: [
        // 紙吹雪
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 100,
            minBlastForce: 80,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
            ],
          ),
        ),
        // メイン通知
        AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          categoryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                          spreadRadius: -5,
                        ),
                      ],
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🎉 実績解除！ヘッダー
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.celebration, color: Colors.amber, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              '実績解除！',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.celebration, color: Colors.amber, size: 24),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // アイコン
                            AnimatedBuilder(
                              animation: _iconController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _iconRotation.value,
                                  child: Transform.scale(
                                    scale: _iconBounce.value,
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            categoryColor,
                                            categoryColor.withOpacity(0.7),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: categoryColor.withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _getIconData(widget.icon),
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            // テキスト情報
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // XP報酬
                            if (widget.xpReward > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.amber[400]!, Colors.amber[600]!],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${widget.xpReward} XP',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// 実績通知を表示するためのオーバーレイヘルパー
class AchievementNotificationOverlay {
  static void show(BuildContext context, Achievement achievement) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: AchievementNotification(
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          category: achievement.category,
          xpReward: achievement.xpReward,
          onDismiss: () {
            overlayEntry.remove();
          },
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  // 複数の実績を順番に表示
  static void showMultiple(BuildContext context, List<Achievement> achievements) {
    if (achievements.isEmpty) return;
    
    void showNext(int index) {
      if (index >= achievements.length) return;
      
      final overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;
      
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 0,
          right: 0,
          child: AchievementNotification(
            title: achievements[index].title,
            description: achievements[index].description,
            icon: achievements[index].icon,
            category: achievements[index].category,
            xpReward: achievements[index].xpReward,
            onDismiss: () {
              overlayEntry.remove();
              // 次の実績を表示
              Future.delayed(const Duration(milliseconds: 500), () {
                showNext(index + 1);
              });
            },
          ),
        ),
      );
      
      overlay.insert(overlayEntry);
    }
    
    showNext(0);
  }
} 