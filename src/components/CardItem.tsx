import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { CardItem as CardItemType } from '../types';
import { sendWOL } from '../wol';

interface Props {
  item: CardItemType;
  onPress: (item: CardItemType) => void;
  onLongPress: (item: CardItemType) => void;
}

const CardItemComponent: React.FC<Props> = ({ item, onPress, onLongPress }) => {
  const handlePress = async () => {
    if (item.type === 'wol') {
      try {
        await sendWOL(
          item.macAddress || '',
          item.ipAddress,
          item.port || 9
        );
        Alert.alert('成功', `已发送唤醒信号到 ${item.title}`);
      } catch (error) {
        Alert.alert('错误', '发送唤醒信号失败');
      }
    } else {
      onPress(item);
    }
  };

  const getIcon = () => {
    if (item.icon) return item.icon;
    return item.type === 'web' ? 'web' : 'power';
  };

  const getSubtitle = () => {
    if (item.type === 'web') return item.url;
    return item.macAddress;
  };

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={handlePress}
      onLongPress={() => onLongPress(item)}
      activeOpacity={0.7}
    >
      <View style={styles.iconContainer}>
        <Icon name={getIcon()} size={32} color="#2196F3" />
      </View>
      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={1}>
          {item.title}
        </Text>
        <Text style={styles.subtitle} numberOfLines={1}>
          {getSubtitle()}
        </Text>
      </View>
      <Icon 
        name={item.type === 'web' ? 'open-in-new' : 'power'} 
        size={20} 
        color="#999" 
      />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginHorizontal: 16,
    marginVertical: 6,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#E3F2FD',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  content: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  subtitle: {
    fontSize: 12,
    color: '#999',
    marginTop: 2,
  },
});

export default CardItemComponent;