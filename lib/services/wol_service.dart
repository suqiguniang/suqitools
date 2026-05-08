import 'dart:io';
import 'dart:typed_data';

class WolService {
  /// 发送 Wake-on-LAN 魔术包
  /// macAddress 格式: "00:11:22:33:44:55" 或 "00-11-22-33-44-55"
  static Future<bool> sendWolPacket(String macAddress, {int port = 9}) async {
    try {
      final cleanMac = macAddress.replaceAll(RegExp(r'[:-]'), '');
      if (cleanMac.length != 12) {
        throw ArgumentError('MAC 地址格式不正确');
      }

      // 构建魔术包: 6个0xFF + 16次MAC地址重复
      final macBytes = <int>[];
      for (int i = 0; i < cleanMac.length; i += 2) {
        macBytes.add(int.parse(cleanMac.substring(i, i + 2), radix: 16));
      }

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

      // 发送到广播地址
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final broadcastAddress = InternetAddress('255.255.255.255');
      socket.send(data, broadcastAddress, port);

      socket.close();
      return true;
    } catch (e) {
      print('WoL 发送失败: $e');
      return false;
    }
  }

  /// 检测电脑是否在线（通过 Ping）
  static Future<bool> isHostOnline(String ipAddress, {int timeoutSeconds = 2}) async {
    try {
      // Windows 使用 -n 参数，Linux/macOS 使用 -c
      final isWindows = Platform.isWindows;
      final result = await Process.run(
        'ping',
        isWindows
            ? ['-n', '1', '-w', '${timeoutSeconds * 1000}', ipAddress]
            : ['-c', '1', '-W', '$timeoutSeconds', ipAddress],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (e) {
      print('Ping 检测失败: $e');
      return false;
    }
  }
}
