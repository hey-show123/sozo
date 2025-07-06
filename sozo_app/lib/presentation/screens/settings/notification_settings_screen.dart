import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _masterNotificationEnabled = true;
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('user_settings')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();
        
        if (response != null) {
          setState(() {
            _masterNotificationEnabled = response['notifications_enabled'] ?? true;
            _reminderEnabled = response['reminder_enabled'] ?? true;
            
            // 時刻の解析
            final timeStr = response['reminder_time'] ?? '19:00';
            final parts = timeStr.split(':');
            if (parts.length == 2) {
              _reminderTime = TimeOfDay(
                hour: int.tryParse(parts[0]) ?? 19,
                minute: int.tryParse(parts[1]) ?? 0,
              );
            }
          });
        }
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_settings')
            .upsert({
              'user_id': user.id,
              'notifications_enabled': _masterNotificationEnabled,
              'reminder_enabled': _reminderEnabled,
              'reminder_time': '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('設定を保存しました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
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
    
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      _saveSettings();
    }
  }

  Future<void> _checkAndRequestPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('通知の許可が必要です'),
            content: const Text('リマインダー通知を送信するには、設定から通知を許可してください。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('設定を開く'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // マスターコントロール
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _masterNotificationEnabled
                            ? Colors.blue.shade50
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: _masterNotificationEnabled
                            ? Colors.blue.shade600
                            : Colors.grey.shade600,
                        size: 28,
                      ),
                    ),
                    title: const Text(
                      '通知を有効にする',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('すべての通知のマスター設定'),
                    trailing: Switch(
                      value: _masterNotificationEnabled,
                      onChanged: (value) async {
                        if (value) {
                          await _checkAndRequestPermission();
                        }
                        setState(() {
                          _masterNotificationEnabled = value;
                          if (!value) {
                            _reminderEnabled = false;
                          }
                        });
                        _saveSettings();
                      },
                      activeColor: Colors.blue.shade600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // リマインダー通知
                Opacity(
                  opacity: _masterNotificationEnabled ? 1.0 : 0.5,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _reminderEnabled && _masterNotificationEnabled
                                      ? Colors.orange.shade50
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.alarm,
                                  color: _reminderEnabled && _masterNotificationEnabled
                                      ? Colors.orange.shade600
                                      : Colors.grey.shade600,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'リマインダー通知',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '毎日の学習時間を通知',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _reminderEnabled && _masterNotificationEnabled,
                                onChanged: _masterNotificationEnabled
                                    ? (value) {
                                        setState(() {
                                          _reminderEnabled = value;
                                        });
                                        _saveSettings();
                                      }
                                    : null,
                                activeColor: Colors.orange.shade600,
                              ),
                            ],
                          ),
                          if (_reminderEnabled && _masterNotificationEnabled) ...[
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.access_time,
                                color: Colors.orange.shade600,
                              ),
                              title: const Text('通知時刻'),
                              trailing: TextButton(
                                onPressed: _selectTime,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.orange.shade50,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  _reminderTime.format(context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 通知の説明
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
                      const Expanded(
                        child: Text(
                          '通知が届かない場合は、デバイスの設定から通知を許可してください',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 