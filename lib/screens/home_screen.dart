import 'package:flutter/material.dart';
import '../models/computer_model.dart';
import '../models/panel_item_model.dart';
import '../models/web_card_model.dart';
import '../services/computer_service.dart';
import '../services/web_card_service.dart';
import '../widgets/panel_card.dart';
import '../widgets/computer_card.dart';
import '../widgets/web_card_widget.dart';
import 'add_web_card_screen.dart';
import 'computer_settings_screen.dart';
import 'settings_screen.dart';
import 'webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<PanelItemModel> _defaultItems = const [
    PanelItemModel(
      id: 'sunpanel',
      title: 'SunPanel',
      description: '访问 SunPanel 管理面板',
      iconAsset: 'assets/icons/sunpanel.svg',
      url: 'https://sunpanel.suqi.qzz.io:8443',
    ),
  ];

  List<ComputerModel> _computers = [];
  List<WebCardModel> _webCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final computers = await ComputerService.getComputers();
    final webCards = await WebCardService.getWebCards();
    setState(() {
      _computers = computers;
      _webCards = webCards;
      _isLoading = false;
    });
  }

  Future<void> _addWebCard() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWebCardScreen(),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _manageComputers() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComputerSettingsScreen(),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('柒小盒'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.computer_outlined),
            onPressed: _manageComputers,
            tooltip: '电脑管理',
          ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    '点击下方卡片访问服务，长按自定义卡片可删除',
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
                        // 默认服务卡片
                        PanelCard(
                          item: _defaultItems[0],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  title: _defaultItems[0].title,
                                  url: _defaultItems[0].url,
                                ),
                              ),
                            );
                          },
                        ),
                        // 电脑唤醒卡片
                        ..._computers.map((computer) => ComputerCard(
                              computer: computer,
                            )),
                        // 自定义网页卡片
                        ..._webCards.map((card) => WebCardWidget(
                              card: card,
                              onDeleted: _loadData,
                            )),
                        // 添加卡片按钮
                        _AddCardButton(
                          onAddWebCard: _addWebCard,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AddCardButton extends StatelessWidget {
  final VoidCallback onAddWebCard;

  const _AddCardButton({required this.onAddWebCard});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: InkWell(
        onTap: onAddWebCard,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.add,
                  size: 28,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '添加卡片',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '添加自定义网页',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
