import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Linking,
  ScrollView,
  Image,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const GITHUB_URL = 'https://github.com/suqiguniang/suqitools';
const APP_ICON_URL = 'https://suqiguniang.github.io/img/111238110.png';

const SettingsScreen: React.FC = () => {
  const openGitHub = async () => {
    const supported = await Linking.canOpenURL(GITHUB_URL);
    if (supported) {
      await Linking.openURL(GITHUB_URL);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Image
          source={{ uri: APP_ICON_URL }}
          style={styles.appIcon}
        />
        <Text style={styles.appName}>苏小盒</Text>
        <Text style={styles.appVersion}>版本 1.0.0</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>关于</Text>
        
        <TouchableOpacity style={styles.item} onPress={openGitHub}>
          <Icon name="github" size={24} color="#333" />
          <View style={styles.itemContent}>
            <Text style={styles.itemTitle}>GitHub 仓库</Text>
            <Text style={styles.itemSubtitle} numberOfLines={1}>
              {GITHUB_URL}
            </Text>
          </View>
          <Icon name="open-in-new" size={20} color="#999" />
        </TouchableOpacity>

        <View style={styles.item}>
          <Icon name="information" size={24} color="#333" />
          <View style={styles.itemContent}>
            <Text style={styles.itemTitle}>应用介绍</Text>
            <Text style={styles.itemSubtitle}>
              苏小盒是一个便捷的导航工具，支持网页快捷方式和WOL远程开机功能。
            </Text>
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>功能</Text>
        
        <View style={styles.item}>
          <Icon name="web" size={24} color="#333" />
          <View style={styles.itemContent}>
            <Text style={styles.itemTitle}>网页导航</Text>
            <Text style={styles.itemSubtitle}>
              添加常用网页快捷方式，快速访问
            </Text>
          </View>
        </View>

        <View style={styles.item}>
          <Icon name="power" size={24} color="#333" />
          <View style={styles.itemContent}>
            <Text style={styles.itemTitle}>WOL 远程开机</Text>
            <Text style={styles.itemSubtitle}>
              通过局域网 UDP 广播发送唤醒信号
            </Text>
          </View>
        </View>

        <View style={styles.item}>
          <Icon name="widgets" size={24} color="#333" />
          <View style={styles.itemContent}>
            <Text style={styles.itemTitle}>桌面小组件</Text>
            <Text style={styles.itemSubtitle}>
              支持 Android 桌面小组件，快速访问
            </Text>
          </View>
        </View>
      </View>

      <View style={styles.footer}>
        <Text style={styles.footerText}>
          © 2024 苏小盒. All rights reserved.
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    alignItems: 'center',
    padding: 32,
    backgroundColor: '#fff',
  },
  appIcon: {
    width: 80,
    height: 80,
    borderRadius: 16,
    marginBottom: 12,
  },
  appName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  appVersion: {
    fontSize: 14,
    color: '#999',
    marginTop: 4,
  },
  section: {
    marginTop: 16,
    backgroundColor: '#fff',
    paddingHorizontal: 16,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#999',
    paddingVertical: 12,
    textTransform: 'uppercase',
  },
  item: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  itemContent: {
    flex: 1,
    marginLeft: 12,
  },
  itemTitle: {
    fontSize: 16,
    color: '#333',
  },
  itemSubtitle: {
    fontSize: 13,
    color: '#999',
    marginTop: 2,
  },
  footer: {
    padding: 24,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    color: '#ccc',
  },
});

export default SettingsScreen;