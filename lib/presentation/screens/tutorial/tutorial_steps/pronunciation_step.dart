import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/services/audio_player_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class PronunciationStep extends ConsumerStatefulWidget {
  const PronunciationStep({super.key});

  @override
  ConsumerState<PronunciationStep> createState() => _PronunciationStepState();
}

class _PronunciationStepState extends ConsumerState<PronunciationStep> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _hasRecorded = false;
  PronunciationAssessmentResult? _pronunciationResult;
  
  final String _practiceText = "Hello, nice to meet you!";

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _pronunciationResult = null;
    });

    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/tutorial_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: path,
        );
      } else {
        setState(() => _isRecording = false);
        _showError('マイクへのアクセス許可が必要です');
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() => _isRecording = false);
      _showError('録音開始に失敗しました');
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    try {
      final audioPath = await _audioRecorder.stop();
      if (audioPath != null) {
        final audioFile = File(audioPath);
        
        // 発音評価を実行
        final speechService = ref.read(azureSpeechServiceProvider);
        final result = await speechService.assessPronunciation(
          audioFile: audioFile,
          expectedText: _practiceText,
        );

        if (result != null) {
          setState(() {
            _pronunciationResult = result;
            _hasRecorded = true;
            _isAnalyzing = false;
          });
        }
        
        // 録音ファイルを削除
        try {
          await audioFile.delete();
        } catch (_) {}
      }
    } catch (e) {
      print('Error in pronunciation assessment: $e');
      _showError('発音評価に失敗しました');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  Color _getWordScoreColor(double score) {
    if (score >= 90) {
      return const Color(0xFF4CAF50); // 濃い緑
    } else if (score >= 80) {
      return const Color(0xFF8BC34A); // 明るい緑
    } else if (score >= 70) {
      return const Color(0xFFFFEB3B); // 黄色
    } else if (score >= 60) {
      return const Color(0xFFFF9800); // オレンジ
    } else {
      return const Color(0xFFE91E63); // ピンク/赤
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.record_voice_over,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            '発音練習を体験',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            '下の文章を読んでみましょう',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          
                      // 練習テキスト（既存UIと同じスタイル）
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    // フレーズ
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _practiceText,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 発音記号
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '[həˈloʊ naɪs tu mit ju]',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 意味
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyan.shade50, Colors.blue.shade50],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        'こんにちは、はじめまして！',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
          
                      // 録音ボタン（既存UIと同じスタイル）
            GestureDetector(
              onTapDown: _isAnalyzing ? null : (_) => _toggleRecording(),
              onTapUp: _isAnalyzing || !_isRecording ? null : (_) => _toggleRecording(),
              onTapCancel: () async {
                if (_isRecording) {
                  await _audioRecorder.stop();
                  setState(() => _isRecording = false);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isRecording ? 140 : _isAnalyzing ? 130 : 120,
                height: _isRecording ? 140 : _isAnalyzing ? 130 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isRecording
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : _isAnalyzing
                            ? [Colors.orange.shade400, Colors.orange.shade600]
                            : [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? Colors.red : _isAnalyzing ? Colors.orange : Colors.blue)
                          .withOpacity(0.4),
                      blurRadius: _isRecording ? 25 : _isAnalyzing ? 20 : 15,
                      spreadRadius: _isRecording ? 8 : _isAnalyzing ? 5 : 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _isAnalyzing
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4,
                          ),
                        )
                      : Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: _isRecording ? 56 : 48,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (_isRecording ? Colors.red : _isAnalyzing ? Colors.orange : Colors.blue)
                    .shade700.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (_isRecording ? Colors.red : _isAnalyzing ? Colors.orange : Colors.blue)
                      .shade700.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isRecording
                      ? Icon(Icons.mic, color: Colors.red.shade700, size: 20)
                      : _isAnalyzing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.orange.shade700,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.touch_app, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isRecording
                        ? '話し終わったらタップして停止'
                        : _isAnalyzing
                            ? '分析中...'
                            : '長押しで録音開始',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isRecording ? Colors.red.shade700 : _isAnalyzing ? Colors.orange.shade700 : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          
          // 結果表示
          if (_pronunciationResult != null) ...[
            const SizedBox(height: 32),
            _buildResultCard(),
          ],
          
          // ヒント
          if (!_hasRecorded)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'マイクボタンをタップして録音してみましょう',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final accuracy = _pronunciationResult!.accuracyScore;
    final fluency = _pronunciationResult!.fluencyScore;
    final completeness = _pronunciationResult!.completenessScore;
    final pronunciation = _pronunciationResult!.pronunciationScore;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '発音スコア',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // 総合スコア
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getScoreColor(pronunciation).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  color: _getScoreColor(pronunciation),
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  '${pronunciation.toInt()}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: _getScoreColor(pronunciation),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  ' / 100',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 詳細スコア
          _buildScoreItem('正確さ', accuracy),
          _buildScoreItem('流暢さ', fluency),
          _buildScoreItem('完成度', completeness),
          const SizedBox(height: 12),
          
          // 単語ごとの評価を表示
          if (_pronunciationResult!.wordScores != null && 
              _pronunciationResult!.wordScores!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              '単語ごとの評価:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Builder(
                builder: (context) {
                  // 重複する単語を除去
                  final uniqueWords = <String, WordScore>{};
                  for (final word in _pronunciationResult!.wordScores!) {
                    if (!uniqueWords.containsKey(word.word.toLowerCase())) {
                      uniqueWords[word.word.toLowerCase()] = word;
                    }
                  }
                  final filteredWords = uniqueWords.values.toList();
                  
                  return Wrap(
                    spacing: 4,
                    runSpacing: 8,
                    children: filteredWords.map((word) {
                      return RichText(
                        text: TextSpan(
                          text: word.word,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getWordScoreColor(word.accuracyScore),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          if (pronunciation >= 80)
            Text(
              '素晴らしい発音です！🎉',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            )
          else if (pronunciation >= 60)
            Text(
              'いい調子です！もう少し練習しましょう',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange,
                  ),
            )
          else
            Text(
              'ゆっくり、はっきり発音してみましょう',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(score),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${score.toInt()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
} 