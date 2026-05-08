import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class WolService {
  static final StreamController<String> _logController = StreamController<String>.broadcast();
  static Stream<String> get logStream => _logController.stream;

  static void _log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final log = '[$timestamp] $message';
    _logController.add(log);
  }

  /// 发送 Wake-on-LAN 魔术包
  /// macAddress 格式: "00:11:22:33:44:55" 或 "00-11-22-33-44-55"
  static Future<bool> sendWolPacket(String macAddress, {int port = 9, String? ipAddress}) async {
    try {
      _log('开始发送 WoL 唤醒包...');
      _log('目标 MAC: $macAddress');
      _log('目标端口: $port');

      final cleanMac = macAddress.replaceAll(RegExp(r'[:-]'), '');
      _log('清理后 MAC: $cleanMac (长度: ${cleanMac.length})');

      if (cleanMac.length != 12) {
        _log('错误: MAC 地址格式不正确，长度应为 12');
        throw ArgumentError('MAC 地址格式不正确');
      }

      // 构建魔术包: 6个0xFF + 16次MAC地址重复
      final macBytes = <int>[];
      for (int i = 0; i < cleanMac.length; i += 2) {
        macBytes.add(int.parse(cleanMac.substring(i, i + 2), radix: 16));
      }
      _log('MAC 字节: $macBytes');

      final packet = BytesBuilder();
      // 6 bytes of 0xFF
      for (int i = 0; i < 6; i++) {
        packet.addByte(0xFF);
      }
      // 16 repetitions of MAC address
      for (int i = 0; i < 16; i++) {
        packet.add(macBytes);
      }

      final data = packet.toBytes();
      _log('魔术包大小: ${data.length} bytes');

      // 尝试多种方式发送
      bool sent = false;

      // 方式1: 发送到广播地址
      try {
        _log('尝试发送到广播地址 255.255.255.255:$port');
        final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        socket.broadcastEnabled = true;
        final broadcastAddress = InternetAddress('255.255.255.255');
        final result = socket.send(data, broadcastAddress, port);
        socket.close();
        _log('广播发送结果: $result bytes');
        if (result > 0) sent = true;
      } catch (e) {
        _log('广播发送失败: $e');
      }

      // 方式2: 如果提供了 IP，发送到子网广播
      if (ipAddress != null && ipAddress.isNotEmpty) {
        try {
          final parts = ipAddress.split('.');
          if (parts.length == 4) {
            final subnetBroadcast = '${parts[0]}.${parts[1]}.${parts[2]}.255';
            _log('尝试发送到子网广播 $subnetBroadcast:$port');
            final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
            socket.broadcastEnabled = true;
            final addr = InternetAddress(subnetBroadcast);
            final result = socket.send(data, addr, port);
            socket.close();
            _log('子网广播发送结果: $result bytes');
            if (result > 0) sent = true;
          }
        } catch (e) {
          _log('子网广播发送失败: $e');
        }
      }

      // 方式3: 发送到常用端口
      if (!sent) {
        for (final testPort in [7, 9]) {
          if (testPort == port) continue;
          try {
            _log('尝试发送到端口 $testPort');
            final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
            socket.broadcastEnabled = true;
            final broadcastAddress = InternetAddress('255.255.255.255');
            final result = socket.send(data, broadcastAddress, testPort);
            socket.close();
            _log('端口 $testPort 发送结果: $result bytes');
            if (result > 0) sent = true;
          } catch (e) {
            _log('端口 $testPort 发送失败: $e');
          }
        }
      }

      if (sent) {
        _log('WoL 唤醒包发送成功');
      } else {
        _log('警告: 所有发送方式均未成功');
      }
      return sent;
    } catch (e) {
      _log('WoL 发送失败: $e');
      return false;
    }
  }

  /// 检测电脑是否在线（通过 Ping）
  static Future<bool> isHostOnline(String ipAddress, {int timeoutSeconds = 2}) async {
    try {
      _log('开始 Ping 检测: $ipAddress');
      // Windows 使用 -n 参数，Linux/macOS 使用 -c
      final isWindows = Platform.isWindows;
      final result = await Process.run(
        'ping',
        isWindows
            ? ['-n', '1', '-w', '${timeoutSeconds * 1000}', ipAddress]
            : ['-c', '1', '-W', '$timeoutSeconds', ipAddress],
        runInShell: true,
      );
      final online = result.exitCode == 0;
      _log('Ping 结果: ${online ? "在线" : "离线"} (exitCode: ${result.exitCode})');
      return online;
    } catch (e) {
      _log('Ping 检测失败: $e');
      return false;
    }
  }

  /// 根据 IP 地址自动发现 MAC 地址
  /// 通过读取 ARP 缓存表实现
  static Future<String?> discoverMacFromIp(String ipAddress) async {
    try {
      _log('开始从 IP 发现 MAC 地址: $ipAddress');
      // 先 Ping 一下目标 IP，确保 ARP 表中有记录
      await isHostOnline(ipAddress);
      await Future.delayed(const Duration(seconds: 1));
      
      // 读取 ARP 缓存
      String? macAddress;
      if (Platform.isWindows) {
        final result = await Process.run('arp', ['-a', ipAddress], runInShell: true);
        _log('ARP 命令输出: ${result.stdout}');
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
        _log('ARP 命令输出: ${result.stdout}');
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
      
      _log('发现的 MAC 地址: $macAddress');
      return macAddress;
    } catch (e) {
      _log('MAC 地址发现失败: $e');
      return null;
    }
  }
}
