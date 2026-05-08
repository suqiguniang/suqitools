import 'package:flutter/material.dart';
import '../models/web_card_model.dart';
import '../services/web_card_service.dart';

class AddWebCardScreen extends StatefulWidget {
  const AddWebCardScreen({super.key});

  @override
  State<AddWebCardScreen> createState() => _AddWebCardScreenState();
}

class _AddWebCardScreenState extends State<AddWebCardScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showError('请输入标题');
      return;
    }

    if (url.isEmpty) {
      _showError('请输入网址');
      return;
    }

    // 简单验证 URL
    final urlRegex = RegExp(r'^https?://.+');
    if (!urlRegex.hasMatch(url)) {
      _showError('网址格式不正确，需要以 http:// 或 https:// 开头');
      return;
    }

    final card = WebCardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description.isEmpty ? '自定义网页服务' : description,
      url: url,
      createdAt: DateTime.now(),
    );

    await WebCardService.addWebCard(card);

    if (mounted) {
      Navigator.pop(context, true);
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
        title: const Text('添加网页卡片'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '例如: 我的网站',
                prefixIcon: Icon(Icons.title_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: '网址',
                hintText: '例如: https://example.com',
                prefixIcon: Icon(Icons.link_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                hintText: '例如: 个人博客',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
