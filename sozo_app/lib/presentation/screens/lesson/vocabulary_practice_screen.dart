import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../services/vocabulary_service.dart';
import '../../../data/models/lesson_model.dart';
import '../../providers/user_profile_provider.dart';
import 'key_phrase_practice_screen.dart';

class VocabularyPracticeScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;

  const VocabularyPracticeScreen({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  ConsumerState<VocabularyPracticeScreen> createState() => _VocabularyPracticeScreenState();
}

class _VocabularyPracticeScreenState extends ConsumerState<VocabularyPracticeScreen>
    with TickerProviderStateMixin {
  final VocabularyService _vocabularyService = VocabularyService();
  
  List<VocabularyQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  List<bool> _userAnswers = [];
  int _correctAnswers = 0;
  bool _isLoading = true;
  
  late AnimationController _progressController;
  late AnimationController _resultController;
  late AnimationController _feedbackController;
  late Animation<double> _progressAnimation;
  late Animation<double> _resultAnimation;
  late Animation<double> _feedbackAnimation;
  
  DateTime _startTime = DateTime.now();
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.elasticOut,
    ));
    
    _resultAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    ));
    
    _feedbackAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    ));
    
    _startTime = DateTime.now();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _resultController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _vocabularyService.getVocabularyQuestions(widget.lesson.id);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('クイズの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  void _selectAnswer(int index) {
    if (_showResult) return;
    
    setState(() {
      _selectedAnswer = index;
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkAnswer();
    });
  }

  void _checkAnswer() {
    if (_selectedAnswer == null) return;
    
    final isCorrect = _selectedAnswer == _questions[_currentQuestionIndex].correctAnswer;
    _userAnswers.add(isCorrect);
    
    if (isCorrect) {
      _correctAnswers++;
    }
    
    setState(() {
      _showResult = true;
    });
    
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    _feedbackController.forward();
    _resultController.forward();
    
    Future.delayed(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
      _resultController.reset();
      _feedbackController.reset();
      _progressController.animateTo((_currentQuestionIndex + 1) / _questions.length);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    _timer?.cancel();
    _elapsedTime = DateTime.now().difference(_startTime);
    
    final percentage = (_correctAnswers / _questions.length * 100).round();
    
    final result = VocabularyResult(
      totalQuestions: _questions.length,
      correctAnswers: _correctAnswers,
      answers: _userAnswers,
      timeTaken: _elapsedTime,
    );
    
    // ユーザーIDを取得して結果を保存
    final userId = ref.read(userProfileProvider).value?.id;
    if (userId != null) {
      _vocabularyService.saveVocabularyResult(
        userId: userId,
        lessonId: widget.lesson.id,
        result: result,
      );
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 結果アイコン
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: percentage >= 80 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  percentage >= 80 ? Icons.celebration : Icons.thumb_up,
                  size: 40,
                  color: percentage >= 80 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                '単語練習完了！',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // スコア表示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_correctAnswers / ${_questions.length}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '正解率: $percentage%',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // 所要時間
              Text(
                '所要時間: ${_elapsedTime.inMinutes}分${_elapsedTime.inSeconds % 60}秒',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // 次へボタン
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KeyPhrasePracticeScreen(lesson: widget.lesson),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'キーフレーズ練習へ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_startTime);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // ヘッダー
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 戻るボタン
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // タイトル
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '単語練習',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_currentQuestionIndex + 1} / ${_questions.length}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // プログレスバー
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 8,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressController.value,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(4),
                          );
                        },
                      ),
                    ),
                    
                    // メインコンテンツ
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // 質問カード
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _questions[_currentQuestionIndex].question,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // 選択肢
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(4, (index) {
                                  final isSelected = _selectedAnswer == index;
                                  final isCorrect = index == _questions[_currentQuestionIndex].correctAnswer;
                                  
                                  Color buttonColor = Colors.white;
                                  Color textColor = Colors.black87;
                                  Color borderColor = Colors.grey[300]!;
                                  
                                  if (_showResult) {
                                    if (isCorrect) {
                                      buttonColor = Colors.green;
                                      textColor = Colors.white;
                                      borderColor = Colors.green;
                                    } else if (isSelected && !isCorrect) {
                                      buttonColor = Colors.red;
                                      textColor = Colors.white;
                                      borderColor = Colors.red;
                                    }
                                  } else if (isSelected) {
                                    buttonColor = Theme.of(context).primaryColor;
                                    textColor = Colors.white;
                                    borderColor = Theme.of(context).primaryColor;
                                  }
                                  
                                  return GestureDetector(
                                    onTap: () => _selectAnswer(index),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: buttonColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderColor, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        _questions[_currentQuestionIndex].options[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            
                            // 解説表示エリア
                            if (_showResult && _questions[_currentQuestionIndex].explanation != null)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _questions[_currentQuestionIndex].explanation!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      
      // 正解・不正解の大きな表示
      floatingActionButton: _showResult
          ? Center(
              child: AnimatedBuilder(
                animation: _feedbackAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _feedbackAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _selectedAnswer == _questions[_currentQuestionIndex].correctAnswer ? '⭕' : '❌',
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
} 