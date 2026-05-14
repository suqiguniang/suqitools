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
import CardItemComponent from '../components/CardItem';
import AddCardModal from '../components/AddCardModal';

type RootStackParamList = {
  WebView: { url: string; title: string };
};

const HomeScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const [cards, setCards] = useState<CardItem[]>([]);
  const [modalVisible, setModalVisible] = useState(false);
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

  const handleAddCard = async (cardData: Omit<CardItem, "id">) => {
    const newCard: CardItem = {
      ...cardData,
      id: Date.now().toString(),
    };
    const updatedCards = [...cards, newCard];
    setCards(updatedCards);
    await saveCards(updatedCards);
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

  const renderItem = ({ item }: { item: CardItem }) => (
    <CardItemComponent
      item={item}
      onPress={handleCardPress}
      onLongPress={handleDeleteCard}
    />
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>苏小盒</Text>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => setModalVisible(true)}
        >
          <Icon name="plus" size={24} color="#2196F3" />
        </TouchableOpacity>
      </View>

      {cards.length === 0 ? (
        <View style={styles.emptyState}>
          <Icon name="cards-outline" size={64} color="#ccc" />
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
        onClose={() => setModalVisible(false)}
        onSave={handleAddCard}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#fff',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  addButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#E3F2FD',
    justifyContent: 'center',
    alignItems: 'center',
  },
  list: {
    paddingVertical: 8,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 18,
    color: '#999',
    marginTop: 16,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#ccc',
    marginTop: 8,
  },
});

export default HomeScreen;