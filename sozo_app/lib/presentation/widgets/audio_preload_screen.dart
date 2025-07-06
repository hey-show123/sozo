import 'package:flutter/material.dart';

class AudioPreloadScreen extends StatelessWidget {
  final int currentProgress;
  final int totalProgress;
  final String lessonTitle;
  final VoidCallback? onCancel;

  const AudioPreloadScreen({
    super.key,
    required this.currentProgress,
    required this.totalProgress,
    required this.lessonTitle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage = totalProgress > 0 ? (currentProgress / totalProgress) : 0.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アニメーション付きアイコン
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景の円形プログレス
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progressPercentage,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                      ),
                    ),
                    // 中央のアイコン
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // タイトル
              Text(
                '音声ファイルを準備中',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // レッスン名
              Text(
                lessonTitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // プログレスバー
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  widthFactor: progressPercentage,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // プログレス数値
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$currentProgress / $totalProgress ファイル',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // 説明テキスト
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'レッスンで使用する音声ファイルを準備しています。\n完了後はスムーズに練習を開始できます。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // キャンセルボタン（オプション）
              if (onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// アニメーション付きローディング画面
class AnimatedAudioPreloadScreen extends StatefulWidget {
  final int currentProgress;
  final int totalProgress;
  final String lessonTitle;
  final VoidCallback? onCancel;
  final String? currentTask;

  const AnimatedAudioPreloadScreen({
    super.key,
    required this.currentProgress,
    required this.totalProgress,
    required this.lessonTitle,
    this.onCancel,
    this.currentTask,
  });

  @override
  State<AnimatedAudioPreloadScreen> createState() => _AnimatedAudioPreloadScreenState();
}

class _AnimatedAudioPreloadScreenState extends State<AnimatedAudioPreloadScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // パルスアニメーション
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 回転アニメーション
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // アニメーション開始
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = widget.totalProgress > 0 ? (widget.currentProgress / widget.totalProgress) : 0.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アニメーション付きアイコン
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 背景の円形プログレス
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: progressPercentage,
                              strokeWidth: 6,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                            ),
                          ),
                          // 回転するアイコン
                          AnimatedBuilder(
                            animation: _rotationAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationAnimation.value * 2 * 3.14159,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // タイトル
              Text(
                '音声ファイルを準備中',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              
              const SizedBox(height: 12),
              
                             // レッスン名
               Text(
                 widget.lessonTitle,
                 style: TextStyle(
                   fontSize: 16,
                   color: Colors.grey[600],
                 ),
                 textAlign: TextAlign.center,
               ),
               
               // 現在のタスク表示
               if (widget.currentTask != null) ...[
                 const SizedBox(height: 8),
                 Text(
                   widget.currentTask!,
                   style: TextStyle(
                     fontSize: 14,
                     color: Colors.blue.shade600,
                     fontWeight: FontWeight.w500,
                   ),
                   textAlign: TextAlign.center,
                 ),
               ],
              
              const SizedBox(height: 32),
              
              // プログレスバー
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width * progressPercentage,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // プログレス数値
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.currentProgress} / ${widget.totalProgress} ファイル',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // 説明テキスト
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'レッスンで使用する音声ファイルを準備しています。\n完了後はスムーズに練習を開始できます。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // キャンセルボタン（オプション）
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 