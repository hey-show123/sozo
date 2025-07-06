import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../services/audio_player_service.dart';
import '../../../services/audio_storage_service.dart';
import '../../../services/character_service.dart';
import '../../../data/models/lesson_model.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/animated_avatar.dart';
import 'dialog_practice_screen.dart';

class ListeningPracticeScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;

  const ListeningPracticeScreen({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  ConsumerState<ListeningPracticeScreen> createState() => _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends ConsumerState<ListeningPracticeScreen> {
  List<Map<String, dynamic>> _dialogues = [];
  int _currentDialogueIndex = 0;
  bool _isLoading = true;
  bool _isPlayingAudio = false;
  bool _showTranscript = false;

  @override
  void initState() {
    super.initState();
    _loadDialogues();
  }

  void _loadDialogues() {
    print('ListeningPracticeScreen: Loading dialogues...');
    print('Lesson ID: ${widget.lesson.id}');
    print('Lesson title: ${widget.lesson.title}');
    print('Raw dialogues data: ${widget.lesson.dialogues}');
    
    setState(() {
      _dialogues = List<Map<String, dynamic>>.from(widget.lesson.dialogues);
      
      // テスト用：ダイアログが空の場合はダミーデータを追加
      if (_dialogues.isEmpty) {
        print('ListeningPracticeScreen: No dialogues found, adding dummy data');
        _dialogues = [
          {
            'text': 'Would you like to do a treatment as well?',
            'japanese': 'トリートメントもされたいですか？',
            'speaker': 'Staff'
          },
          {
            'text': 'Yes, please. What kind of treatments do you have?',
            'japanese': 'はい、お願いします。どのような種類のトリートメントがありますか？',
            'speaker': 'Customer'
          },
          {
            'text': 'We have deep conditioning and hair masks.',
            'japanese': 'ディープコンディショニングとヘアマスクがあります。',
            'speaker': 'Staff'
          }
        ];
      }
      
      _isLoading = false;
    });
    
    print('Loaded ${_dialogues.length} dialogues');
    if (_dialogues.isNotEmpty) {
      print('First dialogue: ${_dialogues[0]}');
    }
  }

  Future<void> _playDialogue() async {
    if (_isPlayingAudio || _dialogues.isEmpty) return;
    
    setState(() {
      _isPlayingAudio = true;
      _showTranscript = false;
    });

    HapticFeedback.lightImpact();

    try {
      final audioPlayer = ref.read(audioPlayerServiceProvider);
      final audioStorage = ref.read(audioStorageServiceProvider);
      
      final dialogue = _dialogues[_currentDialogueIndex];
      final text = dialogue['text'] as String? ?? '';
      final speaker = dialogue['speaker'] as String? ?? '';
      
      // 音声設定を決定
      String voice;
      if (speaker == 'Staff') {
        // スタッフは常にSarahの声で発音指導
        voice = CharacterService.getVoiceModel('sarah');
      } else {
        // お客様は選択されたキャラクターの声
        voice = CharacterService.getVoiceModel(widget.lesson.characterId);
      }
      
      final audioUrl = await audioStorage.getOrCreateKeyPhraseAudio(
        phrase: text,
        lessonId: widget.lesson.id,
        voice: voice,
      );
      await audioPlayer.playAudioFromUrl(audioUrl);

    } catch (e) {
      print('Error playing dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('音声の再生に失敗しました。OpenAI APIキーを設定してください。'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '設定方法',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('README_OPENAI_SETUP.mdを参照してください'),
                    duration: Duration(seconds: 5),
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  void _toggleTranscript() {
    setState(() {
      _showTranscript = !_showTranscript;
    });
    HapticFeedback.selectionClick();
  }

  void _nextDialogue() {
    if (_currentDialogueIndex < _dialogues.length - 1) {
      setState(() {
        _currentDialogueIndex++;
        _showTranscript = false;
      });
      HapticFeedback.lightImpact();
    } else {
      _finishListening();
    }
  }

  void _previousDialogue() {
    if (_currentDialogueIndex > 0) {
      setState(() {
        _currentDialogueIndex--;
        _showTranscript = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _finishListening() {
    HapticFeedback.mediumImpact();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DialogPracticeScreen(lesson: widget.lesson),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ListeningPracticeScreen: Building widget...');
    print('_isLoading: $_isLoading');
    print('_dialogues.length: ${_dialogues.length}');
    
    if (_isLoading) {
      print('ListeningPracticeScreen: Showing loading screen');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_dialogues.isEmpty) {
      print('ListeningPracticeScreen: Showing empty dialogues screen');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'リスニング練習データがありません',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _finishListening,
                child: const Text('ダイアログ練習へ進む'),
              ),
            ],
          ),
        ),
      );
    }

    print('ListeningPracticeScreen: Showing main content');
    final currentDialogue = _dialogues[_currentDialogueIndex];
    print('Current dialogue: $currentDialogue');
    final isStaff = (currentDialogue['speaker'] as String?) == 'Staff';
    final progress = (_currentDialogueIndex + 1) / _dialogues.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('リスニング練習 ${_currentDialogueIndex + 1}/${_dialogues.length}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/lesson_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // プログレスバー
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 20),
                
                // アバター
                AnimatedAvatar(
                  isPlaying: _isPlayingAudio,
                  size: 150,
                ),
                const SizedBox(height: 20),
                
                // スピーカー表示
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isStaff 
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isStaff ? Colors.blue : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isStaff ? '👩‍💼 スタッフ' : '👤 お客様',
                    style: TextStyle(
                      color: isStaff ? Colors.blue[700] : Colors.green[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // 再生ボタン
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isPlayingAudio
                        ? [Colors.orange[400]!, Colors.red[400]!]
                        : [Colors.blue[400]!, Colors.purple[400]!],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: _isPlayingAudio ? null : _playDialogue,
                      child: Icon(
                        _isPlayingAudio ? Icons.graphic_eq : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 指示テキスト
                Text(
                  _isPlayingAudio ? '再生中...' : '🎧 音声を聞いてください',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                
                // トランスクリプト表示ボタン
                if (!_isPlayingAudio)
                  TextButton.icon(
                    onPressed: _toggleTranscript,
                    icon: Icon(
                      _showTranscript ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    label: Text(
                      _showTranscript ? 'テキストを隠す' : 'テキストを表示',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                
                // トランスクリプト表示
                if (_showTranscript)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '英語',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentDialogue['text'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '日本語',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentDialogue['japanese'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Spacer(),
                
                // ナビゲーションボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _currentDialogueIndex > 0 ? _previousDialogue : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('前へ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _nextDialogue,
                        icon: Icon(
                          _currentDialogueIndex < _dialogues.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                        ),
                        label: Text(
                          _currentDialogueIndex < _dialogues.length - 1 ? '次へ' : '完了',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
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
      ),
    );
  }
} 