import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { CardItem } from '../../../types';
import { Colors, Spacing, BorderRadius, Shadows } from '../../../theme';

interface Props {
  item: CardItem;
  onPress?: (item: CardItem) => void;
  onLongPress?: (item: CardItem) => void;
}

export const QuickLinkCard: React.FC<Props> = ({ item, onPress, onLongPress }) => {
  return (
    <TouchableOpacity
      style={styles.container}
      onPress={() => onPress?.(item)}
      onLongPress={() => onLongPress?.(item)}
      activeOpacity={0.8}
    >
      <View style={[styles.iconContainer, { backgroundColor: Colors.primaryLight }]}>
        <Icon name={item.icon || 'web'} size={28} color={Colors.primary} />
      </View>
      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={1}>
          {item.title}
        </Text>
        <Text style={styles.subtitle} numberOfLines={1}>
          {item.url || ''}
        </Text>
      </View>
      <Icon name="open-in-new" size={20} color={Colors.textDisabled} />
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
});
