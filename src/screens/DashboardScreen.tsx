import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Alert,
  RefreshControl,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { useNavigation, NavigationProp } from '@react-navigation/native';
import { CardItem } from '../types';
import { loadCards, saveCards } from '../storage';
import { QuickLinkCard } from '../features/dashboard';
import { WolCard } from '../features/wol';
import { AddCardModal } from '../components';
import { Colors, Spacing, Typography, Shadows, BorderRadius } from '../theme';

type RootStackParamList = {
  WebView: { url: string; title: string };
};

export const DashboardScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const [cards, setCards] = useState<CardItem[]>([]);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingCard, setEditingCard] = useState<CardItem | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    loadCardsData();
  }, []);

  const loadCardsData = async () => {
    const loadedCards = await loadCards();
    setCards(loadedCards);
  };

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadCardsData();
    setRefreshing(false);
  }, []);

  const handleAddCard = async (cardData: Omit<CardItem, 'id'>) => {
    if (editingCard) {
      const updatedCard: CardItem = {
        ...cardData,
        id: editingCard.id,
      };
      const updatedCards = cards.map(c =>
        c.id === editingCard.id ? updatedCard : c
      );
      setCards(updatedCards);
      await saveCards(updatedCards);
      setEditingCard(null);
    } else {
      const newCard: CardItem = {
        ...cardData,
        id: Date.now().toString(),
      };
      const updatedCards = [...cards, newCard];
      setCards(updatedCards);
      await saveCards(updatedCards);
    }
  };

  const handleEditCard = (card: CardItem) => {
    setEditingCard(card);
    setModalVisible(true);
  };

  const handleDeleteCard = (card: CardItem) => {
    Alert.alert(
      '删除卡片',
      `确定要删除 "${card.title}" 吗？`,
      [
        { text: '取消', style: 'cancel' },
        {
          text: '删除',
          style: 'destructive',
          onPress: async () => {
            const updatedCards = cards.filter(c => c.id !== card.id);
            setCards(updatedCards);
            await saveCards(updatedCards);
          },
        },
      ]
    );
  };

  const handleCardPress = (card: CardItem) => {
    if (card.type === 'web' && card.url) {
      navigation.navigate('WebView', { url: card.url, title: card.title });
    }
  };

  const renderItem = ({ item }: { item: CardItem }) => {
    if (item.type === 'wol') {
      return (
        <WolCard
          item={item}
          onPress={handleCardPress}
          onLongPress={handleDeleteCard}
        />
      );
    }
    return (
      <QuickLinkCard
        item={item}
        onPress={handleCardPress}
        onLongPress={handleDeleteCard}
      />
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>苏小盒</Text>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => {
            setEditingCard(null);
            setModalVisible(true);
          }}
        >
          <Icon name="plus" size={24} color={Colors.primary} />
        </TouchableOpacity>
      </View>

      {cards.length === 0 ? (
        <View style={styles.emptyState}>
          <Icon name="cards-outline" size={64} color={Colors.textDisabled} />
          <Text style={styles.emptyText}>还没有卡片</Text>
          <Text style={styles.emptySubtext}>点击右上角 + 添加卡片</Text>
        </View>
      ) : (
        <FlatList
          data={cards}
          renderItem={renderItem}
          keyExtractor={item => item.id}
          contentContainerStyle={styles.list}
          refreshControl={
            <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
          }
        />
      )}

      <AddCardModal
        visible={modalVisible}
        onClose={() => {
          setModalVisible(false);
          setEditingCard(null);
        }}
        onSave={handleAddCard}
        editCard={editingCard}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: Spacing.md,
    backgroundColor: Colors.surface,
    ...Shadows.sm,
  },
  headerTitle: {
    ...Typography.h2,
    color: Colors.textPrimary,
  },
  addButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.primaryLight,
    justifyContent: 'center',
    alignItems: 'center',
  },
  list: {
    paddingVertical: Spacing.sm,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 18,
    color: Colors.textSecondary,
    marginTop: Spacing.md,
  },
  emptySubtext: {
    fontSize: 14,
    color: Colors.textDisabled,
    marginTop: Spacing.sm,
  },
});
