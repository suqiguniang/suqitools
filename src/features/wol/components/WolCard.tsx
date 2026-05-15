import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { CardItem } from '../../../types';
import { Colors, Spacing, BorderRadius, Shadows } from '../../../theme';
import { useWol } from '../hooks/useWol';

interface Props {
  item: CardItem;
  onPress?: (item: CardItem) => void;
  onLongPress?: (item: CardItem) => void;
}

export const WolCard: React.FC<Props> = ({ item, onPress, onLongPress }) => {
  const { isLoading, success, sendWakeSignal, reset } = useWol();

  const handlePress = async () => {
    if (isLoading) return;
    reset();
    await sendWakeSignal({
      macAddress: item.macAddress || '',
      ipAddress: item.ipAddress,
      port: item.port,
    });
    onPress?.(item);
  };

  const getStatusColor = () => {
    if (isLoading) return Colors.warning;
    if (success) return Colors.success;
    return Colors.error;
  };

  return (
    <TouchableOpacity
      style={[styles.container, success && styles.successBorder]}
      onPress={handlePress}
      onLongPress={() => onLongPress?.(item)}
      activeOpacity={0.8}
    >
      <View style={[styles.iconContainer, { backgroundColor: Colors.primaryLight }]}>
        {isLoading ? (
          <ActivityIndicator size="small" color={Colors.primary} />
        ) : (
            <Icon
              name={item.icon || (success ? 'check-circle' : 'power')}
              size={28}
              color={getStatusColor()}
            />
        )}
      </View>
      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={1}>
          {item.title}
        </Text>
        <Text style={styles.subtitle} numberOfLines={1}>
          {item.macAddress || '未设置 MAC'}
        </Text>
          <Text style={styles.detail} numberOfLines={1}>
            {item.ipAddress || '192.168.1.255'}:{item.port || 9}
          </Text>
          <Text style={[styles.status, {color: isLoading ? Colors.warning : (success ? Colors.success : Colors.error)}]} numberOfLines={1}>
            {isLoading ? '发送中...' : success ? '在线' : '离线'}
          </Text>
        </View>
      <Icon name="power" size={20} color={getStatusColor()} />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    padding: Spacing.md,
    marginHorizontal: Spacing.md,
    marginVertical: Spacing.sm,
    ...Shadows.md,
    borderWidth: 1,
    borderColor: 'transparent',
  },
  successBorder: {
    borderColor: Colors.success,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: BorderRadius.full,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: Spacing.md,
  },
  content: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.textPrimary,
  },
  subtitle: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginTop: 2,
  },
  detail: {
    fontSize: 11,
    color: Colors.textDisabled,
    marginTop: 2,
  },
  status: {
    fontSize: 11,
    marginTop: 2,
  },
});
