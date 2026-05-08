import 'package:flutter/material.dart';
import '../models/computer_model.dart';
import '../services/computer_service.dart';
import '../services/wol_service.dart';

class ComputerSettingsScreen extends StatefulWidget {
  const ComputerSettingsScreen({super.key});

  @override
  State<ComputerSettingsScreen> createState() => _ComputerSettingsScreenState();
}

class _ComputerSettingsScreenState extends State<ComputerSettingsScreen> {
  List<ComputerModel> _computers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComputers();
  }

  Future<void> _loadComputers() async {
    final computers = await ComputerService.getComputers();
    setState(() {
      _computers = computers;
      _isLoading = false;
    });
  }

  Future<void> _addComputer() async {
    final result = await showDialog<ComputerModel>(
      context: context,
      builder: (context) => const _ComputerEditDialog(),
    );
    if (result != null) {
      await ComputerService.addComputer(result);
      _loadComputers();
    }
  }

  Future<void> _editComputer(ComputerModel computer) async {
    final result = await showDialog<ComputerModel>(
      context: context,
      builder: (context) => _ComputerEditDialog(computer: computer),
    );
    if (result != null) {
      await ComputerService.updateComputer(result);
      _loadComputers();
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

  Future<void> _wakeComputer(ComputerModel computer) async {
    if (computer.macAddress.isEmpty) {
      _showError('MAC 地址为空');
      return;
    }

    final success = await WolService.sendWolPacket(
      computer.macAddress,
      ipAddress: computer.ipAddress,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '唤醒指令已发送: ${computer.name}' : '唤醒指令发送失败'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteComputer(ComputerModel computer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${computer.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ComputerService.deleteComputer(computer.id);
      _loadComputers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电脑管理'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _computers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.computer_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无电脑',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击右下角按钮添加电脑',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _computers.length,
                  itemBuilder: (context, index) {
                    final computer = _computers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: computer.isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(computer.name),
                        subtitle: Text('${computer.ipAddress}\n${computer.macAddress}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.power_settings_new),
                              tooltip: '唤醒电脑',
                              color: computer.isOnline ? Colors.green : null,
                              onPressed: () => _wakeComputer(computer),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editComputer(computer),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteComputer(computer),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addComputer,
        icon: const Icon(Icons.add),
        label: const Text('添加电脑'),
      ),
    );
  }
}

class _ComputerEditDialog extends StatefulWidget {
  final ComputerModel? computer;

  const _ComputerEditDialog({this.computer});

  @override
  State<_ComputerEditDialog> createState() => _ComputerEditDialogState();
}

class _ComputerEditDialogState extends State<_ComputerEditDialog> {
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _macController = TextEditingController();
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    if (widget.computer != null) {
      _nameController.text = widget.computer!.name;
      _ipController.text = widget.computer!.ipAddress;
      _macController.text = widget.computer!.macAddress;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _macController.dispose();
    super.dispose();
  }

  Future<void> _discoverMac() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showError('请先输入 IP 地址');
      return;
    }

    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(ip)) {
      _showError('IP 地址格式不正确');
      return;
    }

    setState(() => _isDiscovering = true);
    final mac = await WolService.discoverMacFromIp(ip);
    setState(() => _isDiscovering = false);

    if (mac != null) {
      setState(() {
        _macController.text = mac;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MAC 地址已自动填充'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      _showError('无法自动发现 MAC 地址，请手动输入');
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

  void _save() {
    final name = _nameController.text.trim();
    final ip = _ipController.text.trim();
    final mac = _macController.text.trim();

    if (name.isEmpty) {
      _showError('请输入电脑名称');
      return;
    }

    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(ip)) {
      _showError('IP 地址格式不正确');
      return;
    }

    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    if (!macRegex.hasMatch(mac)) {
      _showError('MAC 地址格式不正确');
      return;
    }

    final computer = ComputerModel(
      id: widget.computer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      ipAddress: ip,
      macAddress: mac.toUpperCase(),
      isOnline: widget.computer?.isOnline ?? false,
    );

    Navigator.pop(context, computer);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.computer == null ? '添加电脑' : '编辑电脑'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '电脑名称',
                hintText: '例如: 客厅电脑',
                prefixIcon: Icon(Icons.computer_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP 地址',
                hintText: '例如: 192.168.1.100',
                prefixIcon: Icon(Icons.network_check_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _macController,
              decoration: InputDecoration(
                labelText: 'MAC 地址',
                hintText: '例如: 00:11:22:33:44:55',
                prefixIcon: const Icon(Icons.memory_outlined),
                suffixIcon: _isDiscovering
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: '自动发现 MAC',
                        onPressed: _discoverMac,
                      ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
