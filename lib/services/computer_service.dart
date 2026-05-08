import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/computer_model.dart';
import 'wol_service.dart';

class ComputerService {
  static const String _computersKey = 'computers';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<List<ComputerModel>> getComputers() async {
    final prefs = await _prefs;
    final String? jsonStr = prefs.getString(_computersKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => ComputerModel.fromJson(e)).toList();
    } catch (e) {
      print('解析电脑列表失败: $e');
      return [];
    }
  }

  static Future<void> saveComputers(List<ComputerModel> computers) async {
    final prefs = await _prefs;
    final String jsonStr = jsonEncode(computers.map((e) => e.toJson()).toList());
    await prefs.setString(_computersKey, jsonStr);
  }

  static Future<void> addComputer(ComputerModel computer) async {
    final computers = await getComputers();
    computers.add(computer);
    await saveComputers(computers);
  }

  static Future<void> updateComputer(ComputerModel computer) async {
    final computers = await getComputers();
    final index = computers.indexWhere((c) => c.id == computer.id);
    if (index != -1) {
      computers[index] = computer;
      await saveComputers(computers);
    }
  }

  static Future<void> deleteComputer(String id) async {
    final computers = await getComputers();
    computers.removeWhere((c) => c.id == id);
    await saveComputers(computers);
  }

  static Future<void> checkAllComputersStatus() async {
    final computers = await getComputers();
    for (var computer in computers) {
      final online = await WolService.isHostOnline(computer.ipAddress);
      computer.isOnline = online;
    }
    await saveComputers(computers);
  }

  /// 根据 IP 地址自动发现 MAC 地址
  /// 通过读取 ARP 缓存表实现
  static Future<String?> discoverMacFromIp(String ipAddress) async {
    try {
      // 先 Ping 一下目标 IP，确保 ARP 表中有记录
      await WolService.isHostOnline(ipAddress);
      
      // 读取 ARP 缓存
      String? macAddress;
      if (Platform.isWindows) {
        final result = await Process.run('arp', ['-a', ipAddress], runInShell: true);
        if (result.exitCode == 0) {
          final output = result.stdout.toString();
          // 解析 Windows ARP 输出
          final regExp = RegExp(r'([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})');
          final match = regExp.firstMatch(output);
          if (match != null) {
            macAddress = match.group(0)?.toUpperCase();
          }
        }
      } else {
        // Linux/macOS
        final result = await Process.run('arp', ['-n', ipAddress], runInShell: true);
        if (result.exitCode == 0) {
          final output = result.stdout.toString();
          final regExp = RegExp(r'([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})');
          final match = regExp.firstMatch(output);
          if (match != null) {
            macAddress = match.group(0)?.toUpperCase();
          }
        }
      }
      
      // 统一格式化为 XX:XX:XX:XX:XX:XX
      if (macAddress != null) {
        macAddress = macAddress.replaceAll('-', ':');
        // 确保每段都是两位
        final parts = macAddress.split(':');
        if (parts.length == 6) {
          macAddress = parts.map((p) => p.padLeft(2, '0')).join(':');
        }
      }
      
      return macAddress;
    } catch (e) {
      print('MAC 地址发现失败: $e');
      return null;
    }
  }
}
