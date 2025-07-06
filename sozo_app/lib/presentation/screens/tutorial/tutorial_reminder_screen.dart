import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'tutorial_dialog_wrapper_screen.dart';

class TutorialReminderScreen extends ConsumerStatefulWidget {
  const TutorialReminderScreen({super.key});

  @override
  ConsumerState<TutorialReminderScreen> createState() => _TutorialReminderScreenState();
}

class _TutorialReminderScreenState extends ConsumerState<TutorialReminderScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0); // デフォルト19:00
  bool _isLoading = false;
  bool _notificationEnabled = true;

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue.shade600,
            colorScheme: ColorScheme.light(primary: Colors.blue.shade600),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveReminderSettings() async {
    setState(() => _isLoading = true);

    try {
      // 通知権限をリクエスト
      if (_notificationEnabled) {
        final status = await Permission.notification.request();
        if (!mounted) return; // 早期リターン
        
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('通知を有効にするには、設定から通知を許可してください'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_settings')
            .upsert({
              'user_id': user.id,
              'reminder_enabled': _notificationEnabled,
              'reminder_time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);
      }

      if (!mounted) return; // 早期リターン
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TutorialDialogWrapperScreen(),
        ),
      );
    } catch (e) {
      print('Error saving reminder settings: $e');
      if (!mounted) return; // 早期リターン
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プログレスバー
              LinearProgressIndicator(
                value: 0.95, // 4.75/5ステップ
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 40),
              
              // タイトル
              const Text(
                'リマインダーを\n設定しましょう',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              
              // 説明
              Text(
                '毎日の学習を忘れないように通知します',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              
              // 通知設定
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 48,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(height: 16),
                    
                    // 時刻選択
                    InkWell(
                      onTap: _notificationEnabled ? _selectTime : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _notificationEnabled
                              ? Colors.white
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _notificationEnabled
                                ? Colors.orange.shade300
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: _notificationEnabled
                                  ? Colors.orange.shade600
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _notificationEnabled
                                    ? Colors.orange.shade600
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 通知ON/OFFスイッチ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'リマインダー通知',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: _notificationEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationEnabled = value;
                            });
                          },
                          activeColor: Colors.orange.shade600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 説明テキスト
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '通知設定は後から「メニュー」→「設定」から変更できます',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // スキップボタン
              TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TutorialDialogWrapperScreen(),
                    ),
                  );
                },
                child: Text(
                  'あとで設定する',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // 次へボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveReminderSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '次へ',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
} 