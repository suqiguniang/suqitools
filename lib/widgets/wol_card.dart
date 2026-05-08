import 'dart:async';
import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/wol_service.dart';

class WolCard extends StatefulWidget {
  const WolCard({super.key});

  @override
  State<WolCard> createState() => _WolCardState();
}

class _WolCardState extends State<WolCard> {
  bool _isOnline = false;
  bool _isChecking = false;
  bool _isWaking = false;
  String _ip = '';
  String _mac = '';
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final ip = await SettingsService.getWolIp();
    final mac = await SettingsService.getWolMac();
    setState(() {
      _ip = ip;
      _mac = mac;
    });
    _startStatusCheck();
  }

  void _startStatusCheck() {
    _statusTimer?.cancel();
    _checkStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_ip.isEmpty || _ip == '192.168.1.100') return;
    if (_isChecking) return;

    setState(() => _isChecking = true);
    final online = await WolService.isHostOnline(_ip);
    if (mounted) {
      setState(() {
        _isOnline = online;
        _isChecking = false;
      });
    }
  }

  Future<void> _wakeOnLan() async {
    if (_mac.isEmpty || _mac == '00:00:00:00:00:00') {
      _showError('请先在设置中配置 MAC 地址');
      return;
    }

    setState(() => _isWaking = true);
    final success = await WolService.sendWolPacket(_mac);
    if (mounted) {
      setState(() => _isWaking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '唤醒指令已发送' : '唤醒指令发送失败'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        // 发送后等待几秒再检测状态
        await Future.delayed(const Duration(seconds: 3));
        _checkStatus();
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: _isWaking ? null : _wakeOnLan,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? Colors.green.withOpacity(0.2)
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.computer_outlined,
                      size: 28,
                      color: _isOnline ? Colors.green : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (_isChecking)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Windows PC',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? Colors.green.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isOnline ? '在线' : '离线',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _isOnline ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              if (_isWaking)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              else
                Text(
                  '点击唤醒',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
