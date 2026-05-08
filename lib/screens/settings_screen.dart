import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'computer_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _githubUrl = 'https://github.com/suqiguniang/suqitools';

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
          const Divider(),
          const _SectionHeader(title: '应用信息'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('应用名称'),
            trailing: Text('柒小盒'),
          ),
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
