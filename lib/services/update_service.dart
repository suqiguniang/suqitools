import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final bool hasUpdate;
  final String? downloadUrl;
  final String? releaseNotes;
  final String htmlUrl;

  UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.hasUpdate,
    this.downloadUrl,
    this.releaseNotes,
    required this.htmlUrl,
  });
}

class UpdateService {
  static const String _repoOwner = 'suqiguniang';
  static const String _repoName = 'suqitools';
  static const String _apiUrl = 'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  /// 获取当前应用版本
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      print('获取当前版本失败: $e');
      return '1.0.0';
    }
  }

  /// 检查是否有新版本
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final currentVersion = await getCurrentVersion();
      
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'QiXiaoHe-UpdateChecker',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('GitHub API 请求失败: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final tagName = data['tag_name'] as String?;
      final htmlUrl = data['html_url'] as String? ?? 'https://github.com/$_repoOwner/$_repoName/releases';
      final body = data['body'] as String?;

      if (tagName == null) {
        return null;
      }

      // 去掉 tag 前面的 v 前缀
      final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      // 比较版本号
      final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

      // 查找 APK 下载链接
      String? downloadUrl;
      final assets = data['assets'] as List<dynamic>?;
      if (assets != null) {
        for (final asset in assets) {
          final name = asset['name'] as String?;
          final url = asset['browser_download_url'] as String?;
          if (name != null && name.endsWith('.apk') && url != null) {
            downloadUrl = url;
            break;
          }
        }
      }

      return UpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        hasUpdate: hasUpdate,
        downloadUrl: downloadUrl,
        releaseNotes: body,
        htmlUrl: htmlUrl,
      );
    } catch (e) {
      print('检查更新失败: $e');
      return null;
    }
  }

  /// 比较两个版本号
  /// 返回 1 表示 v1 > v2, -1 表示 v1 < v2, 0 表示相等
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.tryParse).whereType<int>().toList();
    final parts2 = v2.split('.').map(int.tryParse).whereType<int>().toList();

    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }

    return 0;
  }
}
