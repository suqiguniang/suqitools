import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';
import '../services/settings_service.dart';
import '../services/wol_service.dart';
import 'computer_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _githubUrl = '<url id="" type="url" status="" title="" wc="">https://github.com/suqiguniang/suqitools</url>';

  bool _isCheckingUpdate = false;
  String _currentVersion = '1.0.0';
  UpdateInfo? _updateInfo;
  bool _debugMode = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
    _loadDebugMode();
    _listenLogs();
  }

  Future<void> _loadDebugMode() async {
    final enabled = await SettingsService.getDebugMode();
    if (mounted) {
      setState(() {
        _debugMode = enabled;
      });
    }
  }

  void _listenLogs() {
    WolService.logStream.listen((log) {
      if (mounted && _debugMode) {
        setState(() {
          _logs.add(log);
          if (_logs.length > 200) {
            _logs.removeAt(0);
          }
        });
      }
    });
  }

  Future<void> _toggleDebugMode(bool value) async {
    await SettingsService.setDebugMode(value);
    setState(() {
      _debugMode = value;
      if (!value) {
        _logs.clear();
      }
    });
  }

  Future<void> _loadCurrentVersion() async {
    final version = await UpdateService.getCurrentVersion();
    if (mounted) {
      setState(() {
        _currentVersion = version;
      });
    }
  }

  Future<void> _checkForUpdate() async {
    setState(() => _isCheckingUpdate = true);

    final updateInfo = await UpdateService.checkForUpdate();

    if (mounted) {
      setState(() {
        _updateInfo = updateInfo;
        _isCheckingUpdate = false;
      });

      if (updateInfo == null) {
        _showError('检查更新失败，请检查网络连接');
        return;
      }

      if (updateInfo.hasUpdate) {
        _showUpdateDialog(updateInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('当前已是最新版本'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发现新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前版本: ${updateInfo.currentVersion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '最新版本: ${updateInfo.latestVersion}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (updateInfo.releaseNotes != null && updateInfo.releaseNotes!.isNotEmpty)
              Text(
                '更新内容:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (updateInfo.releaseNotes != null && updateInfo.releaseNotes!.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    updateInfo.releaseNotes!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
          if (updateInfo.downloadUrl != null)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _launchUrl(updateInfo.downloadUrl!);
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('下载更新'),
            )
          else
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _launchUrl(updateInfo.htmlUrl);
              },
              child: const Text('查看发布页'),
            ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无法打开链接'),
            backgroundColor: Colors.red,
          ),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: '设备管理'),
          ListTile(
            leading: const Icon(Icons.computer_outlined),
            title: const Text('电脑管理'),
            subtitle: const Text('管理 WoL 唤醒的电脑'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComputerSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 32),
          const _SectionHeader(title: '更新'),
          ListTile(
            leading: const Icon(Icons.system_update_outlined),
            title: const Text('检查更新'),
            subtitle: Text('当前版本: $_currentVersion${_updateInfo != null && _updateInfo!.hasUpdate ? ' (有新版本: ${_updateInfo!.latestVersion})' : ''}'),
            trailing: _isCheckingUpdate
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _updateInfo != null && _updateInfo!.hasUpdate
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                    : const Icon(Icons.chevron_right),
            onTap: _isCheckingUpdate ? null : _checkForUpdate,
          ),
          const Divider(height: 32),
          const _SectionHeader(title: '关于'),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: const Text('GitHub 仓库'),
            subtitle: const Text(
              _githubUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launchUrl(_githubUrl),
          ),
          const Divider(height: 32),
          const _SectionHeader(title: '调试'),
          SwitchListTile(
            secondary: const Icon(Icons.bug_report_outlined),
            title: const Text('Debug 模式'),
            subtitle: const Text('开启后显示操作日志'),
            value: _debugMode,
            onChanged: _toggleDebugMode,
          ),
          if (_debugMode) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '操作日志',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('清空'),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 300),
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无日志',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      reverse: true,
                      child: SelectableText(
                        _logs.join('\n'),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
            ),
          ],
          const Divider(height: 32),
          const _SectionHeader(title: '应用信息'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('版本'),
            trailing: Text(_currentVersion),
          ),
          const ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('许可证'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
