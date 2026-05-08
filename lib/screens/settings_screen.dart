import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _githubPlaceholder = 'https://github.com/yourusername/navigation-panel';

  final _ipController = TextEditingController();
  final _macController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _macController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final ip = await SettingsService.getWolIp();
    final mac = await SettingsService.getWolMac();
    setState(() {
      _ipController.text = ip;
      _macController.text = mac;
      _isLoading = false;
    });
  }

  Future<void> _saveWolSettings() async {
    final ip = _ipController.text.trim();
    final mac = _macController.text.trim();

    // 简单验证 IP 格式
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(ip)) {
      _showError('IP 地址格式不正确');
      return;
    }

    // 简单验证 MAC 格式
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    if (!macRegex.hasMatch(mac)) {
      _showError('MAC 地址格式不正确，应为 XX:XX:XX:XX:XX:XX');
      return;
    }

    await SettingsService.setWolIp(ip);
    await SettingsService.setWolMac(mac);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WoL 设置已保存'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const _SectionHeader(title: 'WoL 设置'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _ipController,
                        decoration: const InputDecoration(
                          labelText: '电脑 IP 地址',
                          hintText: '例如: 192.168.1.100',
                          prefixIcon: Icon(Icons.network_check_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _macController,
                        decoration: const InputDecoration(
                          labelText: '电脑 MAC 地址',
                          hintText: '例如: 00:11:22:33:44:55',
                          prefixIcon: Icon(Icons.memory_outlined),
                          border: OutlineInputBorder(),
                          helperText: '格式: XX:XX:XX:XX:XX:XX 或 XX-XX-XX-XX-XX-XX',
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saveWolSettings,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('保存 WoL 设置'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                const _SectionHeader(title: '关于'),
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: const Text('GitHub 仓库'),
                  subtitle: const Text(
                    _githubPlaceholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _launchUrl(_githubPlaceholder),
                ),
                const Divider(),
                const _SectionHeader(title: '应用信息'),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('版本'),
                  trailing: Text('1.0.0'),
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
