import 'package:flutter/material.dart';
import '../models/panel_item_model.dart';
import '../widgets/panel_card.dart';
import '../widgets/wol_card.dart';
import 'settings_screen.dart';
import 'webview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<PanelItemModel> _items = const [
    PanelItemModel(
      id: 'sunpanel',
      title: 'SunPanel',
      description: '访问 SunPanel 管理面板',
      iconAsset: 'assets/icons/sunpanel.svg',
      url: 'https://sunpanel.suqi.qzz.io:8443',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导航面板'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '我的服务',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方卡片访问对应服务或唤醒设备',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  // SunPanel 卡片
                  PanelCard(
                    item: _items[0],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                            title: _items[0].title,
                            url: _items[0].url,
                          ),
                        ),
                      );
                    },
                  ),
                  // WoL 卡片
                  const WolCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
